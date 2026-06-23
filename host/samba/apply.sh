#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SCRIPT_DIR}/smb.conf"
DEST="/etc/samba/smb.conf"
BACKUP_DIR="/etc/samba/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="${BACKUP_DIR}/smb.conf.${TIMESTAMP}"

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

need_cmd sudo
need_cmd testparm
need_cmd systemctl

if [[ ! -f "$SRC" ]]; then
  echo "Missing source config: $SRC" >&2
  exit 1
fi

echo "Validating repo Samba config: $SRC"
testparm -s "$SRC" >/dev/null

sudo install -d -o root -g root -m 0755 "$BACKUP_DIR"
if [[ -f "$DEST" ]]; then
  echo "Backing up current config to: $BACKUP"
  sudo cp -a "$DEST" "$BACKUP"
fi

echo "Installing Samba config to: $DEST"
sudo install -o root -g root -m 0644 "$SRC" "$DEST"

echo "Validating installed Samba config"
if ! sudo testparm -s "$DEST" >/dev/null; then
  echo "Installed config failed validation." >&2
  if [[ -f "$BACKUP" ]]; then
    echo "Restoring backup: $BACKUP" >&2
    sudo cp -a "$BACKUP" "$DEST"
  fi
  exit 1
fi

echo "Restarting smbd"
sudo systemctl restart smbd

if systemctl list-unit-files nmbd.service >/dev/null 2>&1 && systemctl is-enabled nmbd >/dev/null 2>&1; then
  echo "Restarting nmbd"
  sudo systemctl restart nmbd
fi

echo "Samba config applied successfully."
