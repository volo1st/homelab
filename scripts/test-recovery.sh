#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Run this command inside a Git worktree." >&2
  exit 2
}
RESTORE_ROOT="$(mktemp -d /tmp/homelab-recovery-test.XXXXXXXX)"

cleanup() {
  if [[ "$RESTORE_ROOT" == /tmp/homelab-recovery-test.* ]]; then
    rm -rf -- "$RESTORE_ROOT"
  fi
}
trap cleanup EXIT

required_files=(
  host/README.md
  host/packages.tsv
  host/recovery/README.md
  host/storage/fstab
  host/samba/smb.conf
  host/firewall/homelab-docker-firewall.service
  scripts/validate-host.sh
  scripts/check-recovery-readiness.sh
)

git -C "$REPO_ROOT" checkout-index --all --prefix="${RESTORE_ROOT}/"

for path in "${required_files[@]}"; do
  if [[ ! -f "${RESTORE_ROOT}/${path}" ]]; then
    echo "Restored checkout is missing: $path" >&2
    exit 1
  fi
done

mapfile -d '' shell_scripts < <(
  find "$RESTORE_ROOT" -type f -name '*.sh' -print0
)
bash -n "${shell_scripts[@]}"

if command -v testparm >/dev/null 2>&1; then
  testparm -s "${RESTORE_ROOT}/host/samba/smb.conf" >/dev/null
else
  echo "warning: testparm is unavailable; Samba syntax was not tested." >&2
fi

echo "Non-production recovery test passed."
