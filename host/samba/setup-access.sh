#!/usr/bin/env bash
set -euo pipefail

BASE_GROUP="smbshareusers"
WRITER_GROUP="smbwriters"
READER_GROUP="smbreaders"

WRITER_USERS=(vincent)
READER_USERS=(nas)
PUBLIC_ONLY_USERS=()

POOL_PATH="/mnt/nas_pool"
MEDIA_PATH="${POOL_PATH}/Media"
PUBLIC_PATH="${POOL_PATH}/Public"

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

sudo install -d -o vincent -g "$BASE_GROUP" -m 2770 "$POOL_PATH"
sudo install -d -o vincent -g "$BASE_GROUP" -m 2775 "$MEDIA_PATH"
sudo install -d -o vincent -g "$BASE_GROUP" -m 2775 "$PUBLIC_PATH"

echo "Samba access groups and share directories are in place."
echo "Make sure each Samba user also exists in Samba passdb, for example: sudo smbpasswd -a <user>"
