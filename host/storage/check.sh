#!/usr/bin/env bash
set -uo pipefail

ROOT="/"
STRICT_SPACE=0
FAILURES=0
WARNINGS=0

BRANCH_PATHS=(
  /mnt/disks/ssd1
  /mnt/disks/ssd2
  /mnt/disks/ssd3
  /mnt/disks/ssd4
)

BRANCH_UUIDS=(
  97caca7d-101b-45f8-8527-f881822d6ce2
  17976c3b-0d4c-4c1b-9eb8-d99b4ca90018
  a4f268c3-4e0e-431b-9877-1181453f7369
  eb317902-0497-4151-b343-57cd4823931e
)

ROOT_MIN_BYTES=$((20 * 1024 * 1024 * 1024))
BRANCH_MIN_BYTES=$((50 * 1024 * 1024 * 1024))

usage() {
  cat <<'USAGE'
Usage: check.sh [--root PATH] [--strict-space]

Run read-only storage checks. Use --root /host from the development container.
Use --strict-space to treat a free-space warning as a failure.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --root." >&2
        exit 2
      fi
      ROOT="${2%/}"
      [[ -n "$ROOT" ]] || ROOT="/"
      shift 2
      ;;
    --strict-space)
      STRICT_SPACE=1
      shift
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
done

for cmd in findmnt readlink df; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 2
  fi
done

if [[ ! -d "$ROOT" ]]; then
  echo "Root path does not exist: $ROOT" >&2
  exit 2
fi

root_path() {
  local path="$1"
  if [[ "$ROOT" == "/" ]]; then
    printf '%s\n' "$path"
  else
    printf '%s%s\n' "$ROOT" "$path"
  fi
}

pass() {
  printf 'pass: %s\n' "$1"
}

fail() {
  printf 'fail: %s\n' "$1" >&2
  FAILURES=$((FAILURES + 1))
}

warn() {
  printf 'warning: %s\n' "$1" >&2
  WARNINGS=$((WARNINGS + 1))
}

check_space() {
  local path="$1"
  local minimum="$2"
  local label="$3"
  local available

  if ! available=$(df -B1 --output=avail "$path" 2>/dev/null | tail -n 1); then
    fail "Cannot read free space for $label at $path."
    return
  fi

  available=${available//[[:space:]]/}
  if [[ ! "$available" =~ ^[0-9]+$ ]]; then
    fail "Free-space result is invalid for $label at $path."
  elif (( available < minimum )); then
    warn "$label has less than $((minimum / 1024 / 1024 / 1024)) GiB available."
  else
    pass "$label free space"
  fi
}

for index in "${!BRANCH_PATHS[@]}"; do
  branch="${BRANCH_PATHS[$index]}"
  uuid="${BRANCH_UUIDS[$index]}"
  target=$(root_path "$branch")
  uuid_link=$(root_path "/dev/disk/by-uuid/$uuid")

  if [[ ! -e "$uuid_link" ]]; then
    fail "Expected UUID is not available: $uuid."
    continue
  fi

  if ! findmnt -n -M "$target" >/dev/null 2>&1; then
    fail "Branch is not a mount point: $target."
    continue
  fi

  fstype=$(findmnt -n -M "$target" -o FSTYPE)
  source=$(findmnt -n -M "$target" -o SOURCE)
  expected_device=$(readlink -f "$uuid_link")

  if [[ "$fstype" != "ext4" ]]; then
    fail "Branch has type $fstype instead of ext4: $target."
  elif [[ "$(basename -- "$source")" != "$(basename -- "$expected_device")" ]]; then
    fail "Branch source does not match UUID $uuid: $target."
  else
    pass "$branch is the expected ext4 mount"
  fi

  check_space "$target" "$BRANCH_MIN_BYTES" "$branch"
done

pool=$(root_path /ocean)
if ! findmnt -n -M "$pool" >/dev/null 2>&1; then
  fail "Pool is not a mount point: $pool."
else
  pool_type=$(findmnt -n -M "$pool" -o FSTYPE)
  pool_source=$(findmnt -n -M "$pool" -o SOURCE)
  if [[ "$pool_type" == "fuse.mergerfs" && "$pool_source" == "mergerfs_pool" ]]; then
    pass "/ocean is the expected mergerfs pool"
  else
    fail "Pool identity is incorrect: source=$pool_source type=$pool_type."
  fi
fi

check_space "$ROOT" "$ROOT_MIN_BYTES" "root filesystem"

if (( STRICT_SPACE == 1 && WARNINGS > 0 )); then
  FAILURES=$((FAILURES + WARNINGS))
fi

printf 'Storage check: %d failure(s), %d warning(s).\n' "$FAILURES" "$WARNINGS"
(( FAILURES == 0 ))
