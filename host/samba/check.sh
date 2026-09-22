#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONF="${SCRIPT_DIR}/smb.conf"
STORAGE_CHECK="${SCRIPT_DIR}/../storage/check.sh"
VERBOSE="${DEBUG:-0}"
FAILURES=0

OWNER_USER="vincent"
BASE_GROUP="smbshareusers"
WRITER_GROUP="smbwriters"
READER_GROUP="smbreaders"

BRANCH_PATHS=(
  /mnt/disks/ssd1
  /mnt/disks/ssd2
  /mnt/disks/ssd3
  /mnt/disks/ssd4
)

usage() {
  cat <<'USAGE'
Usage: check.sh [--verbose]

Run non-mutating Samba health checks on the NAS host.
Run the script as root to include the Samba passdb checks.
Set DEBUG=1 or pass --verbose to print output for every check.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --verbose|-v)
      VERBOSE=1
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

is_verbose() {
  [[ "$VERBOSE" == "1" || "$VERBOSE" == "true" || "$VERBOSE" == "yes" ]]
}

check() {
  local label="$1"
  local output
  local status
  shift

  printf '%-42s' "${label} ..."
  output=$("$@" 2>&1)
  status=$?

  if [[ $status -eq 0 ]]; then
    printf 'pass\n'
    if is_verbose && [[ -n "$output" ]]; then
      printf '%s\n' "$output"
    fi
    return 0
  fi

  printf 'fail\n'
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output" >&2
  fi
  FAILURES=$((FAILURES + 1))
  return 1
}

# The check function invokes the next three functions by name.
# shellcheck disable=SC2329
check_metadata() {
  local path="$1"
  local expected_mode="$2"
  local actual

  if ! actual=$(stat -Lc '%U:%G:%a' -- "$path"); then
    return 1
  fi

  if [[ "$actual" != "${OWNER_USER}:${BASE_GROUP}:${expected_mode}" ]]; then
    echo "Expected ${OWNER_USER}:${BASE_GROUP}:${expected_mode}; found $actual at $path." >&2
    return 1
  fi
}

# shellcheck disable=SC2329
user_in_group() {
  local user="$1"
  local group="$2"
  local member

  while IFS= read -r member; do
    if [[ "$member" == "$group" ]]; then
      return 0
    fi
  done < <(id -nG "$user" | tr ' ' '\n')

  echo "User $user is not a member of $group." >&2
  return 1
}

# shellcheck disable=SC2329
has_samba_user() {
  local user="$1"
  local entry

  while IFS= read -r entry; do
    if [[ "${entry%%:*}" == "$user" ]]; then
      return 0
    fi
  done < <(pdbedit -L)

  echo "Samba passdb does not contain user $user." >&2
  return 1
}

for cmd in cmp getent id stat systemctl test testparm tr; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 2
  fi
done

if [[ ! -x "$STORAGE_CHECK" ]]; then
  echo "Missing executable storage check: $STORAGE_CHECK" >&2
  exit 2
fi

check "Checking repo config" testparm -s "$CONF" || true
check "Checking installed config" testparm -s /etc/samba/smb.conf || true
check "Checking installed config matches" cmp -s "$CONF" /etc/samba/smb.conf || true
check "Checking Samba service" systemctl is-active --quiet smbd || true
check "Checking storage and branch health" "$STORAGE_CHECK" || true

check "Checking NasShare metadata" check_metadata /ocean 2770 || true
check "Checking Media metadata" check_metadata /ocean/Media 2770 || true
check "Checking Public metadata" check_metadata /ocean/public 2770 || true
check "Checking obsolete Public path" test ! -e /ocean/Public || true

for path in "${BRANCH_PATHS[@]}"; do
  check "Checking ${path} metadata" check_metadata "$path" 2770 || true
done

check "Checking Unix user vincent" id vincent || true
check "Checking Unix user nas" id nas || true
check "Checking group ${BASE_GROUP}" getent group "$BASE_GROUP" || true
check "Checking group ${WRITER_GROUP}" getent group "$WRITER_GROUP" || true
check "Checking group ${READER_GROUP}" getent group "$READER_GROUP" || true
check "Checking vincent baseline access" user_in_group vincent "$BASE_GROUP" || true
check "Checking vincent writer access" user_in_group vincent "$WRITER_GROUP" || true
check "Checking nas baseline access" user_in_group nas "$BASE_GROUP" || true
check "Checking nas reader access" user_in_group nas "$READER_GROUP" || true

if [[ $EUID -eq 0 ]]; then
  if command -v pdbedit >/dev/null 2>&1; then
    check "Checking Samba user vincent" has_samba_user vincent || true
    check "Checking Samba user nas" has_samba_user nas || true
  else
    echo "Missing required command: pdbedit" >&2
    FAILURES=$((FAILURES + 1))
  fi
else
  echo "Samba passdb checks ... skipped (run this script as root)"
  FAILURES=$((FAILURES + 1))
fi

printf '\n'
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Samba health check passed."
  exit 0
fi

echo "Samba health check completed with ${FAILURES} issue(s)."
exit 1
