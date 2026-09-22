#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SCRIPT_DIR}/smb.conf"
HEALTH_CHECK="${SCRIPT_DIR}/check.sh"
STORAGE_CHECK="${SCRIPT_DIR}/../storage/check.sh"
DEST="/etc/samba/smb.conf"
BACKUP_DIR="/etc/samba/backups"
LOCK_FILE="/run/lock/homelab-samba-apply.lock"
BACKUP_KEEP=10
MODE="check"
INSTALL_OWNERSHIP=(-o root -g root)

BACKUP=""
DEST_WAS_PRESENT=0
INSTALL_STARTED=0
SMBD_WAS_ACTIVE=0
NMBD_EXISTS=0
NMBD_WAS_ACTIVE=0
NMBD_RESTART_ON_APPLY=0

usage() {
  cat <<'USAGE'
Usage: apply.sh [--check | --install]

--check    Validate the configuration and host storage. This is the default.
--install  Back up, install, restart, and verify the Samba configuration.

Run this script only from a real NAS host shell.
USAGE
}

need_cmd() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
}

validate_candidate() {
  if [[ ! -r "$SRC" ]]; then
    echo "Missing source config: $SRC" >&2
    return 1
  fi

  if [[ ! -x "$STORAGE_CHECK" ]]; then
    echo "Missing executable storage check: $STORAGE_CHECK" >&2
    return 1
  fi

  echo "Validating repository Samba config: $SRC"
  testparm -s "$SRC" >/dev/null

  echo "Checking storage before applying the Samba config."
  "$STORAGE_CHECK"
}

record_service_state() {
  if systemctl is-active --quiet smbd.service; then
    SMBD_WAS_ACTIVE=1
  fi

  if systemctl cat nmbd.service >/dev/null 2>&1; then
    NMBD_EXISTS=1
    if systemctl is-active --quiet nmbd.service; then
      NMBD_WAS_ACTIVE=1
      NMBD_RESTART_ON_APPLY=1
    fi
    if systemctl is-enabled --quiet nmbd.service; then
      NMBD_RESTART_ON_APPLY=1
    fi
  fi
}

restore_service_state() {
  local unit="$1"
  local was_active="$2"

  if [[ "$was_active" -eq 1 ]]; then
    systemctl restart "$unit"
  else
    systemctl stop "$unit"
  fi
}

restore_after_failure() {
  local original_status="$1"
  local rollback_failed=0

  trap - ERR
  set +e

  if [[ "$INSTALL_STARTED" -ne 1 ]]; then
    exit "$original_status"
  fi

  echo "Samba application failed. Restoring the prior state." >&2

  if [[ "$DEST_WAS_PRESENT" -eq 1 ]]; then
    if ! cp -a --remove-destination "$BACKUP" "$DEST"; then
      echo "Failed to restore Samba config from: $BACKUP" >&2
      rollback_failed=1
    elif ! testparm -s "$DEST" >/dev/null; then
      echo "The restored Samba config failed validation: $DEST" >&2
      rollback_failed=1
    fi
  elif ! rm -f -- "$DEST"; then
    echo "Failed to remove the newly installed Samba config: $DEST" >&2
    rollback_failed=1
  fi

  if ! restore_service_state smbd.service "$SMBD_WAS_ACTIVE"; then
    echo "Failed to restore the prior smbd service state." >&2
    rollback_failed=1
  fi

  if [[ "$NMBD_EXISTS" -eq 1 ]]; then
    if ! restore_service_state nmbd.service "$NMBD_WAS_ACTIVE"; then
      echo "Failed to restore the prior nmbd service state." >&2
      rollback_failed=1
    fi
  fi

  if [[ "$rollback_failed" -eq 0 ]]; then
    echo "Restored the prior Samba configuration and service state." >&2
    exit "$original_status"
  fi

  echo "Automatic rollback was incomplete. Use the printed backup path." >&2
  exit 1
}

prune_backups() {
  local -a backups=()
  local index

  mapfile -t backups < <(
    find "$BACKUP_DIR" -maxdepth 1 -type f -name 'smb.conf.*' -printf '%p\n' |
      sort -r
  )

  for ((index = BACKUP_KEEP; index < ${#backups[@]}; index++)); do
    if ! rm -f -- "${backups[index]}"; then
      echo "Warning: Could not remove old backup: ${backups[index]}" >&2
    fi
  done
}

install_config() {
  local timestamp

  exec 9>"$LOCK_FILE"
  if ! flock -n 9; then
    echo "Another Samba configuration installation is active." >&2
    return 1
  fi

  record_service_state

  echo "Install target: $DEST"
  echo "Backup directory: $BACKUP_DIR"
  echo "Restart service: smbd.service"
  if [[ "$NMBD_RESTART_ON_APPLY" -eq 1 ]]; then
    echo "Restart service: nmbd.service"
  fi

  install -d "${INSTALL_OWNERSHIP[@]}" -m 0700 "$BACKUP_DIR"
  if [[ -f "$DEST" ]]; then
    DEST_WAS_PRESENT=1
    timestamp="$(date +%Y%m%d-%H%M%S-%N)"
    BACKUP="$(mktemp -p "$BACKUP_DIR" "smb.conf.${timestamp}.XXXXXX")"
    cp -a --remove-destination "$DEST" "$BACKUP"
    echo "Backup: $BACKUP"
  fi

  INSTALL_STARTED=1
  trap 'restore_after_failure $?' ERR

  echo "Installing Samba config: $DEST"
  install "${INSTALL_OWNERSHIP[@]}" -m 0644 "$SRC" "$DEST"

  echo "Validating installed Samba config."
  testparm -s "$DEST" >/dev/null

  echo "Restarting smbd."
  systemctl restart smbd.service

  if [[ "$NMBD_RESTART_ON_APPLY" -eq 1 ]]; then
    echo "Restarting nmbd."
    systemctl restart nmbd.service
  fi

  echo "Checking Samba health after restart."
  "$HEALTH_CHECK"

  trap - ERR
  prune_backups

  echo "Samba configuration installation passed."
  if [[ -n "$BACKUP" ]]; then
    echo "Rollback backup: $BACKUP"
  fi
}

main() {
  if [[ $# -gt 1 ]]; then
    usage >&2
    exit 2
  fi

  case "${1:---check}" in
    --check)
      MODE="check"
      ;;
    --install)
      MODE="install"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac

  if [[ "$(cat /proc/1/comm 2>/dev/null || true)" != "systemd" ]]; then
    echo "This script requires a real host shell with systemd as process 1." >&2
    exit 2
  fi

  for command_name in cat cp date find flock install mktemp rm sort systemctl testparm; do
    need_cmd "$command_name"
  done

  validate_candidate

  if [[ "$MODE" == "check" ]]; then
    echo "Samba configuration preflight passed. No changes were made."
    exit 0
  fi

  if [[ "$EUID" -ne 0 ]]; then
    echo "Run --install as root." >&2
    exit 2
  fi

  if [[ ! -x "$HEALTH_CHECK" ]]; then
    echo "Missing executable health check: $HEALTH_CHECK" >&2
    exit 2
  fi

  install_config
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
