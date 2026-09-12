#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="/"

usage() {
  cat <<'USAGE'
Usage: check-generated.sh [--root PATH]

Compare the generated ocean.mount unit with the tracked golden test fixture.
Use --root /host from the development container.
USAGE
}

if [[ $# -gt 0 ]]; then
  if [[ "$1" != "--root" || $# -ne 2 ]]; then
    usage >&2
    exit 2
  fi
  ROOT="${2%/}"
  [[ -n "$ROOT" ]] || ROOT="/"
fi

EXPECTED="${SCRIPT_DIR}/expected/ocean.mount"
if [[ "$ROOT" == "/" ]]; then
  ACTUAL="/run/systemd/generator/ocean.mount"
else
  ACTUAL="${ROOT}/run/systemd/generator/ocean.mount"
fi

for file in "$EXPECTED" "$ACTUAL"; do
  if [[ ! -r "$file" ]]; then
    echo "Cannot read required file: $file" >&2
    exit 1
  fi
done

if ! diff -u --label expected/ocean.mount --label generated/ocean.mount \
  "$EXPECTED" "$ACTUAL"; then
  echo "The generated ocean.mount unit differs from the golden test fixture." >&2
  exit 1
fi

echo "The generated ocean.mount unit matches the golden test fixture."
