#!/usr/bin/env bash
set -euo pipefail

CHECK_ONLY=0

BASE_GROUP="smbshareusers"
WRITER_GROUP="smbwriters"
READER_GROUP="smbreaders"
OWNER_USER="vincent"

WRITER_USERS=(vincent)
READER_USERS=(nas)
PUBLIC_ONLY_USERS=()

BRANCH_PATHS=(
  /mnt/disks/ssd1
  /mnt/disks/ssd2
  /mnt/disks/ssd3
  /mnt/disks/ssd4
)

POOL_PATH="/ocean"
MEDIA_PATH="${POOL_PATH}/Media"
PUBLIC_PATH="${POOL_PATH}/public"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STORAGE_CHECK="${SCRIPT_DIR}/../storage/check.sh"

usage() {
  cat <<'USAGE'
Usage: setup-access.sh [--check]

Create the Samba access groups and set the expected path metadata.
Use --check to run all preflight checks without making a change.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --check)
      CHECK_ONLY=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

require_user() {
  local user="$1"
  if ! id "$user" >/dev/null 2>&1; then
    echo "Missing Unix user: $user" >&2
    return 1
  fi
}

add_user_to_group() {
  local user="$1"
  local group="$2"
  require_user "$user"
  sudo usermod -aG "$group" "$user"
}

for cmd in groupadd id install sudo usermod; do
  need_cmd "$cmd"
done

if [[ ! -x "$STORAGE_CHECK" ]]; then
  echo "Missing executable storage check: $STORAGE_CHECK" >&2
  exit 1
fi

for user in "$OWNER_USER" "${WRITER_USERS[@]}" "${READER_USERS[@]}" \
  "${PUBLIC_ONLY_USERS[@]}"; do
  require_user "$user"
done

echo "Checking storage before making an access change."
"$STORAGE_CHECK"

if (( CHECK_ONLY == 1 )); then
  echo "Samba access preflight passed. No changes were made."
  exit 0
fi

echo "Requesting administrator access before making an access change."
sudo -v

sudo groupadd -f "$BASE_GROUP"
sudo groupadd -f "$WRITER_GROUP"
sudo groupadd -f "$READER_GROUP"

for user in "${WRITER_USERS[@]}"; do
  add_user_to_group "$user" "$BASE_GROUP"
  add_user_to_group "$user" "$WRITER_GROUP"
done

for user in "${READER_USERS[@]}"; do
  add_user_to_group "$user" "$BASE_GROUP"
  add_user_to_group "$user" "$READER_GROUP"
done

for user in "${PUBLIC_ONLY_USERS[@]}"; do
  add_user_to_group "$user" "$BASE_GROUP"
done

for path in "${BRANCH_PATHS[@]}"; do
  sudo install -d -o "$OWNER_USER" -g "$BASE_GROUP" -m 2770 "$path"
done

sudo install -d -o "$OWNER_USER" -g "$BASE_GROUP" -m 2770 "$POOL_PATH"
sudo install -d -o "$OWNER_USER" -g "$BASE_GROUP" -m 2770 "$MEDIA_PATH"
sudo install -d -o "$OWNER_USER" -g "$BASE_GROUP" -m 2770 "$PUBLIC_PATH"

echo "Samba access groups and share directories are in place."
echo "Make sure each Samba user also exists in Samba passdb, for example: sudo smbpasswd -a <user>"
