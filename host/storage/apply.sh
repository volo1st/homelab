#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
SRC_FSTAB="${SCRIPT_DIR}/fstab"
SRC_DROPIN="${REPO_ROOT}/host/samba/smbd.service.d/storage.conf"
DEST_FSTAB="/etc/fstab"
DEST_DROPIN="/etc/systemd/system/smbd.service.d/storage.conf"
MODE="check"
BACKUP_DIR=""
INSTALL_STARTED=0

usage() {
  cat <<'USAGE'
Usage: apply.sh [--check | --install]

--check    Validate the repository configuration. This is the default.
--install  Back up and install the configuration. This does not activate it.

Run this script only from a real NAS host shell.
USAGE
}

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

need_cmd() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
}

if [[ "$(cat /proc/1/comm 2>/dev/null || true)" != "systemd" ]]; then
  echo "This script requires a real host shell with systemd as process 1." >&2
  exit 2
fi

for command_name in findmnt systemctl install cp cmp grep date flock; do
  need_cmd "$command_name"
done

if [[ ! -r "$SRC_FSTAB" || ! -r "$SRC_DROPIN" ]]; then
  echo "A repository source file is missing." >&2
  exit 2
fi

validate_candidate() {
  local branch

  echo "Validate the candidate fstab."
  findmnt --verify --verbose --tab-file "$SRC_FSTAB"

  for branch in /mnt/disks/ssd1 /mnt/disks/ssd2 /mnt/disks/ssd3 /mnt/disks/ssd4; do
    if ! grep -Fq "x-systemd.requires-mounts-for=${branch}" "$SRC_FSTAB"; then
      echo "Missing mergerfs requirement: $branch" >&2
      return 1
    fi
  done

  if ! grep -Fxq 'RequiresMountsFor=/ocean' "$SRC_DROPIN"; then
    echo "The Samba drop-in does not require /ocean." >&2
    return 1
  fi
}

restore_backup() {
  local saved_dropin="${BACKUP_DIR}/storage.conf"

  trap - ERR

  if [[ "$INSTALL_STARTED" -ne 1 || -z "$BACKUP_DIR" ]]; then
    return
  fi

  echo "Restore configuration from $BACKUP_DIR." >&2
  cp -a "${BACKUP_DIR}/fstab" "$DEST_FSTAB"

  if [[ -f "${BACKUP_DIR}/dropin.was-absent" ]]; then
    rm -f "$DEST_DROPIN"
  else
    install -D -o root -g root -m 0644 "$saved_dropin" "$DEST_DROPIN"
  fi

  systemctl daemon-reload || true
}

validate_candidate

if [[ "$MODE" == "check" ]]; then
  echo "Storage configuration check passed."
  exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "Run --install as root." >&2
  exit 2
fi

exec 9>/run/lock/homelab-storage-apply.lock
if ! flock -n 9; then
  echo "Another storage configuration installation is active." >&2
  exit 1
fi

timestamp="$(date +%Y%m%d-%H%M%S-%N)"
BACKUP_DIR="/etc/homelab-backups/storage/${timestamp}"
install -d -o root -g root -m 0700 "$BACKUP_DIR"
cp -a "$DEST_FSTAB" "${BACKUP_DIR}/fstab"

if [[ -f "$DEST_DROPIN" ]]; then
  cp -a "$DEST_DROPIN" "${BACKUP_DIR}/storage.conf"
else
  install -m 0600 /dev/null "${BACKUP_DIR}/dropin.was-absent"
fi

INSTALL_STARTED=1
trap 'restore_backup' ERR

echo "Install $SRC_FSTAB at $DEST_FSTAB."
install -o root -g root -m 0644 "$SRC_FSTAB" "$DEST_FSTAB"

echo "Install $SRC_DROPIN at $DEST_DROPIN."
install -D -o root -g root -m 0644 "$SRC_DROPIN" "$DEST_DROPIN"

systemctl daemon-reload

cmp -s "$SRC_FSTAB" "$DEST_FSTAB"
cmp -s "$SRC_DROPIN" "$DEST_DROPIN"

ocean_requires=$(systemctl show ocean.mount --property=Requires --value)
for unit in mnt-disks-ssd1.mount mnt-disks-ssd2.mount mnt-disks-ssd3.mount mnt-disks-ssd4.mount; do
  if [[ " $ocean_requires " != *" $unit "* ]]; then
    echo "The generated ocean.mount unit does not require $unit." >&2
    false
  fi
done

samba_requires=$(systemctl show smbd.service --property=Requires --value)
if [[ " $samba_requires " != *" ocean.mount "* ]]; then
  echo "The Samba service does not require ocean.mount." >&2
  false
fi

trap - ERR
echo "Storage configuration installation passed."
echo "Backup: $BACKUP_DIR"
echo "The command did not restart the current mounts or Samba process."
echo "Test the new startup behavior during an approved maintenance period."
