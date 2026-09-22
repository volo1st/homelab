#!/usr/bin/env bash
# The test changes variables and calls functions defined in the sourced apply script.
# shellcheck disable=SC1091,SC2034
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/apply.sh"

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEST_ROOT"' EXIT

FAILURES=0
MOCK_LOG=""

fail() {
  echo "fail: $1" >&2
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "pass: $1"
}

assert_file_content() {
  local label="$1"
  local expected="$2"
  local path="$3"

  if [[ "$(<"$path")" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

testparm() {
  return 0
}

systemctl() {
  if [[ "$1" == "is-active" && "$2" == "--quiet" && "$3" == "smbd.service" ]]; then
    return 0
  fi

  if [[ "$1" == "cat" && "$2" == "nmbd.service" ]]; then
    return 1
  fi

  if [[ "$1" == "restart" || "$1" == "stop" ]]; then
    printf '%s %s\n' "$1" "$2" >>"$MOCK_LOG"
    return 0
  fi

  echo "Unexpected mock systemctl call: $*" >&2
  return 1
}

reset_case() {
  local case_name="$1"
  local case_dir="${TEST_ROOT}/${case_name}"

  mkdir -p "$case_dir"
  SRC="${case_dir}/candidate.conf"
  DEST="${case_dir}/smb.conf"
  BACKUP_DIR="${case_dir}/backups"
  LOCK_FILE="${case_dir}/apply.lock"
  MOCK_LOG="${case_dir}/systemctl.log"
  INSTALL_OWNERSHIP=()
  BACKUP=""
  DEST_WAS_PRESENT=0
  INSTALL_STARTED=0
  SMBD_WAS_ACTIVE=0
  NMBD_EXISTS=0
  NMBD_WAS_ACTIVE=0
  NMBD_RESTART_ON_APPLY=0

  printf 'candidate\n' >"$SRC"
  printf 'prior\n' >"$DEST"
  : >"$MOCK_LOG"
}

reset_case success
HEALTH_CHECK=/usr/bin/true
install_config
assert_file_content "successful install keeps candidate config" "candidate" "$DEST"
if [[ "$(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'smb.conf.*' | wc -l)" -eq 1 ]]; then
  pass "successful install creates one backup"
else
  fail "successful install creates one backup"
fi
if [[ "$(grep -c '^restart smbd.service$' "$MOCK_LOG")" -eq 1 ]]; then
  pass "successful install restarts smbd"
else
  fail "successful install restarts smbd"
fi
install_config
if [[ "$(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'smb.conf.*' | wc -l)" -eq 2 ]]; then
  pass "two installs create unique backups"
else
  fail "two installs create unique backups"
fi

reset_case lock
HEALTH_CHECK=/usr/bin/true
exec 8>"$LOCK_FILE"
flock -n 8
if install_config; then
  fail "execution lock rejects a concurrent install"
else
  pass "execution lock rejects a concurrent install"
fi
flock -u 8
exec 8>&-
assert_file_content "rejected install does not change config" "prior" "$DEST"

reset_case rollback
HEALTH_CHECK=/usr/bin/false
set +e
(
  set -Ee
  install_config
)
rollback_status=$?
set -e
if [[ "$rollback_status" -ne 0 ]]; then
  pass "failed health check returns a failure"
else
  fail "failed health check returns a failure"
fi
assert_file_content "failed health check restores prior config" "prior" "$DEST"
if [[ "$(grep -c '^restart smbd.service$' "$MOCK_LOG")" -eq 2 ]]; then
  pass "failed health check restores active smbd state"
else
  fail "failed health check restores active smbd state"
fi

reset_case retention
mkdir -p "$BACKUP_DIR"
for index in $(seq -w 1 12); do
  touch "${BACKUP_DIR}/smb.conf.20260922-000000-${index}"
done
prune_backups
if [[ "$(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'smb.conf.*' | wc -l)" -eq 10 ]]; then
  pass "backup retention keeps ten files"
else
  fail "backup retention keeps ten files"
fi
if [[ ! -e "${BACKUP_DIR}/smb.conf.20260922-000000-01" &&
      ! -e "${BACKUP_DIR}/smb.conf.20260922-000000-02" ]]; then
  pass "backup retention removes the oldest files"
else
  fail "backup retention removes the oldest files"
fi

if [[ "$FAILURES" -ne 0 ]]; then
  echo "Samba apply tests completed with ${FAILURES} failure(s)." >&2
  exit 1
fi

echo "Samba apply tests passed."
