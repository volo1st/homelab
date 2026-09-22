#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FILTER_SOURCE="${SCRIPT_DIR}/docker-filter.sh"
FILTER_DEST="/usr/local/sbin/homelab-docker-firewall"
UNIT_SOURCE="${SCRIPT_DIR}/homelab-docker-firewall.service"
UNIT_DEST="/etc/systemd/system/homelab-docker-firewall.service"
CHECK_SCRIPT="${SCRIPT_DIR}/check.sh"
BACKUP_ROOT="/etc/homelab-backups/firewall"
LOCK_FILE="/run/lock/homelab-firewall-apply.lock"
BACKUP_KEEP=10
MODE="check"

BACKUP_DIR=""
INSTALL_STARTED=0
UFW_WAS_ACTIVE=0
UNIT_WAS_ACTIVE=0
UNIT_WAS_ENABLED=0

usage() {
  cat <<'USAGE'
Usage: apply.sh [--check | --install]

--check    Validate the host and proposed firewall policy. This is the default.
--install  Back up, install, enable, and verify the firewall policy.

Run this script as root from a real NAS host shell.
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
  if [[ ! -x "$FILTER_SOURCE" || ! -x "$CHECK_SCRIPT" || ! -r "$UNIT_SOURCE" ]]; then
    echo "A required repository firewall file is missing or has an incorrect mode." >&2
    return 1
  fi

  bash -n "$FILTER_SOURCE" "$CHECK_SCRIPT"

  if ! ip -4 address show dev enp5s0 to 192.168.88.6/24 | grep -q '192\.168\.88\.6/24'; then
    echo "The trusted LAN address is not active on enp5s0." >&2
    return 1
  fi

  if ! systemctl is-active --quiet docker.service; then
    echo "Docker is not active." >&2
    return 1
  fi
  if ! iptables -n -L DOCKER-USER >/dev/null 2>&1; then
    echo "Docker did not create the IPv4 DOCKER-USER chain." >&2
    return 1
  fi
  if ! ip6tables -n -L DOCKER-USER >/dev/null 2>&1; then
    echo "Docker did not create the IPv6 DOCKER-USER chain." >&2
    return 1
  fi
  if ! grep -Fxq 'IPV6=yes' /etc/default/ufw; then
    echo "UFW IPv6 support is not enabled in /etc/default/ufw." >&2
    return 1
  fi
  if ! ufw status >/dev/null; then
    echo "UFW cannot read its current state." >&2
    return 1
  fi

  echo "Firewall preflight passed."
  echo "Trusted interface: enp5s0"
  echo "Trusted IPv4 network: 192.168.88.0/24"
  echo "Trusted IPv6 link-local network: fe80::/10"
  echo "Direct tailscale0 traffic will be trusted if that interface is added later."
  echo "Other new inbound host and Docker traffic will be denied."
  echo "The install operation will replace the current UFW user rules."
  ufw show added
}

backup_file() {
  local source="$1"
  local name="$2"

  if [[ -e "$source" ]]; then
    cp -a "$source" "${BACKUP_DIR}/${name}"
  else
    install -m 0600 /dev/null "${BACKUP_DIR}/${name}.was-absent"
  fi
}

restore_file() {
  local destination="$1"
  local name="$2"

  if [[ -f "${BACKUP_DIR}/${name}.was-absent" ]]; then
    rm -f -- "$destination"
  else
    cp -a --remove-destination "${BACKUP_DIR}/${name}" "$destination"
  fi
}

record_state() {
  if ufw status | grep -Fxq 'Status: active'; then
    UFW_WAS_ACTIVE=1
  fi
  if systemctl is-active --quiet homelab-docker-firewall.service; then
    UNIT_WAS_ACTIVE=1
  fi
  if systemctl is-enabled --quiet homelab-docker-firewall.service; then
    UNIT_WAS_ENABLED=1
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

  echo "Firewall installation failed. Restoring the prior state." >&2

  "$FILTER_SOURCE" --remove >/dev/null 2>&1 || true
  ufw --force disable >/dev/null 2>&1 || rollback_failed=1

  restore_file /etc/default/ufw default-ufw || rollback_failed=1
  restore_file /etc/ufw/ufw.conf ufw-conf || rollback_failed=1
  restore_file /etc/ufw/before.rules ufw-before-rules || rollback_failed=1
  restore_file /etc/ufw/after.rules ufw-after-rules || rollback_failed=1
  restore_file /etc/ufw/user.rules ufw-user-rules || rollback_failed=1
  restore_file /etc/ufw/before6.rules ufw-before6-rules || rollback_failed=1
  restore_file /etc/ufw/after6.rules ufw-after6-rules || rollback_failed=1
  restore_file /etc/ufw/user6.rules ufw-user6-rules || rollback_failed=1
  restore_file "$FILTER_DEST" docker-filter || rollback_failed=1
  restore_file "$UNIT_DEST" firewall-unit || rollback_failed=1

  systemctl daemon-reload || rollback_failed=1

  if [[ "$UFW_WAS_ACTIVE" -eq 1 ]]; then
    ufw --force enable >/dev/null 2>&1 || rollback_failed=1
    ufw reload >/dev/null 2>&1 || rollback_failed=1
  else
    ufw --force disable >/dev/null 2>&1 || rollback_failed=1
  fi

  if [[ "$UNIT_WAS_ENABLED" -eq 1 ]]; then
    systemctl enable homelab-docker-firewall.service >/dev/null 2>&1 || rollback_failed=1
  else
    systemctl disable homelab-docker-firewall.service >/dev/null 2>&1 || true
  fi

  # Apply the Docker filter after UFW. A UFW state change can replace firewall chains.
  if [[ "$UNIT_WAS_ACTIVE" -eq 1 ]]; then
    systemctl restart homelab-docker-firewall.service || rollback_failed=1
  else
    systemctl stop homelab-docker-firewall.service >/dev/null 2>&1 || true
  fi

  if [[ "$rollback_failed" -eq 0 ]]; then
    echo "Restored the prior firewall files and active state." >&2
    exit "$original_status"
  fi

  echo "Automatic firewall rollback was incomplete. Backup: $BACKUP_DIR" >&2
  exit 1
}

prune_backups() {
  local -a backups=()
  local index

  mapfile -t backups < <(
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d \
      -name 'firewall.*' -printf '%p\n' | sort -r
  )

  for ((index = BACKUP_KEEP; index < ${#backups[@]}; index++)); do
    rm -rf -- "${backups[index]}"
  done
}

install_policy() {
  local timestamp

  exec 9>"$LOCK_FILE"
  if ! flock -n 9; then
    echo "Another firewall installation is active." >&2
    return 1
  fi

  record_state

  install -d -o root -g root -m 0700 "$BACKUP_ROOT"
  timestamp="$(date +%Y%m%d-%H%M%S-%N)"
  BACKUP_DIR="$(mktemp -d -p "$BACKUP_ROOT" "firewall.${timestamp}.XXXXXX")"

  backup_file /etc/default/ufw default-ufw
  backup_file /etc/ufw/ufw.conf ufw-conf
  backup_file /etc/ufw/before.rules ufw-before-rules
  backup_file /etc/ufw/after.rules ufw-after-rules
  backup_file /etc/ufw/user.rules ufw-user-rules
  backup_file /etc/ufw/before6.rules ufw-before6-rules
  backup_file /etc/ufw/after6.rules ufw-after6-rules
  backup_file /etc/ufw/user6.rules ufw-user6-rules
  backup_file "$FILTER_DEST" docker-filter
  backup_file "$UNIT_DEST" firewall-unit

  echo "Backup: $BACKUP_DIR"
  echo "Trusted interface: enp5s0"
  echo "Trusted networks: 192.168.88.0/24 and fe80::/10"
  echo "Installing Docker filter: $FILTER_DEST"
  echo "Installing systemd unit: $UNIT_DEST"

  INSTALL_STARTED=1
  trap 'restore_after_failure $?' ERR

  install -o root -g root -m 0755 "$FILTER_SOURCE" "$FILTER_DEST"
  install -o root -g root -m 0644 "$UNIT_SOURCE" "$UNIT_DEST"
  systemctl daemon-reload
  systemctl enable homelab-docker-firewall.service

  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow in on enp5s0 from 192.168.88.0/24 comment 'trusted home LAN'
  ufw allow in on enp5s0 from fe80::/10 comment 'trusted link-local LAN'
  ufw allow in on tailscale0 comment 'direct Tailscale'
  ufw --force enable

  systemctl restart homelab-docker-firewall.service

  "$CHECK_SCRIPT"

  trap - ERR
  prune_backups

  echo "Firewall installation passed."
  echo "Rollback backup: $BACKUP_DIR"
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

  if [[ "$EUID" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 2
  fi

  for command_name in bash cat cp date find flock grep install ip iptables \
    ip6tables mktemp rm sort systemctl ufw; do
    need_cmd "$command_name"
  done

  validate_candidate

  if [[ "$MODE" == "check" ]]; then
    echo "No changes were made."
    exit 0
  fi

  install_policy
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
