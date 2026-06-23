#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONF="${SCRIPT_DIR}/smb.conf"
VERBOSE="${DEBUG:-0}"
FAILURES=0

usage() {
  cat <<'USAGE'
Usage: check.sh [--verbose]

Runs non-mutating Samba health checks.
Set DEBUG=1 or pass --verbose to print command output for every check.
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
  shift

  printf '%-34s' "${label} ..."

  if is_verbose; then
    printf '\n+ %s\n' "$*"
    "$@"
    local status=$?
    if [[ $status -eq 0 ]]; then
      printf '%-34s%s\n' "${label} ..." "pass"
    else
      printf '%-34s%s\n' "${label} ..." "fail"
      FAILURES=$((FAILURES + 1))
    fi
    return $status
  fi

  local output
  if output=$("$@" 2>&1); then
    printf 'pass\n'
    return 0
  fi

  printf 'fail\n'
  if is_verbose && [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  fi
  FAILURES=$((FAILURES + 1))
  return 1
}

if command -v testparm >/dev/null 2>&1; then
  check "Checking repo config" testparm -s "$CONF" || true
else
  echo "Checking repo config ... skipped (testparm missing)"
  FAILURES=$((FAILURES + 1))
fi

if command -v systemctl >/dev/null 2>&1; then
  check "Checking Samba service" systemctl is-active --quiet smbd || true
else
  echo "Checking Samba service ... skipped (systemctl missing)"
  FAILURES=$((FAILURES + 1))
fi

check "Checking NAS pool mount" findmnt /mnt/nas_pool || true
check "Checking NasShare path" test -d /mnt/nas_pool || true
check "Checking Media path" test -d /mnt/nas_pool/Media || true
check "Checking Public path" test -d /mnt/nas_pool/Public || true

printf '\nSamba users:\n'
if command -v pdbedit >/dev/null 2>&1; then
  samba_users=$(sudo pdbedit -L 2>&1)
  if [[ $? -eq 0 ]]; then
    printf '%s\n' "$samba_users" | sed 's/^/  /'
  else
    printf '  unavailable\n'
    if is_verbose && [[ -n "$samba_users" ]]; then
      printf '%s\n' "$samba_users"
    fi
    FAILURES=$((FAILURES + 1))
  fi
else
  printf '  unavailable (pdbedit missing)\n'
  FAILURES=$((FAILURES + 1))
fi

printf '\nUnix groups:\n'
for group in smbshareusers smbwriters smbreaders; do
  group_entry=$(getent group "$group")
  if [[ $? -eq 0 ]]; then
    printf '  %s\n' "$group_entry"
  else
    printf '  missing: %s\n' "$group"
    FAILURES=$((FAILURES + 1))
  fi
done

if is_verbose; then
  printf '\nStorage paths:\n'
  ls -ld /mnt/nas_pool /mnt/nas_pool/Media /mnt/nas_pool/Public /media/1 /media/2 /media/3 /media/4 || true

  if command -v smbstatus >/dev/null 2>&1; then
    printf '\nActive Samba sessions:\n'
    sudo smbstatus || true
  fi
fi

printf '\n'
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Samba health check passed."
  exit 0
fi

echo "Samba health check completed with ${FAILURES} issue(s)."
exit 1
