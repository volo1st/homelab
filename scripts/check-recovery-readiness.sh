#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
FAILURES=0

check() {
  local label="$1"
  local output
  local status
  shift

  printf '%-46s' "${label} ..."
  output=$("$@" 2>&1)
  status=$?

  if [[ "$status" -eq 0 ]]; then
    printf 'pass\n'
    return
  fi

  printf 'fail\n'
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output" >&2
  fi
  FAILURES=$((FAILURES + 1))
}

# The check function invokes the next four functions by name.
# shellcheck disable=SC2329
check_clean_worktree() {
  [[ -z "$(git -C "$REPO_ROOT" status --porcelain)" ]]
}

# shellcheck disable=SC2329
check_upstream() {
  git -C "$REPO_ROOT" rev-parse --verify '@{upstream}' >/dev/null
}

# shellcheck disable=SC2329
check_off_host_remote() {
  local remote
  local url

  remote=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref '@{upstream}') || return 1
  remote=${remote%%/*}
  url=$(git -C "$REPO_ROOT" remote get-url "$remote") || return 1

  case "$url" in
    /*|./*|../*|file://*)
      echo "The upstream remote is local." >&2
      return 1
      ;;
  esac
}

# shellcheck disable=SC2329
check_upstream_contains_head() {
  local upstream

  upstream=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref '@{upstream}') || return 1
  git -C "$REPO_ROOT" merge-base --is-ancestor HEAD "$upstream"
}

check "Checking clean recovery worktree" check_clean_worktree
check "Checking configured upstream" check_upstream
check "Checking off-host upstream" check_off_host_remote
check "Checking upstream contains HEAD" check_upstream_contains_head
check "Checking repository secrets" "${SCRIPT_DIR}/check-secrets.sh"

printf '\n'
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Recovery readiness check passed."
  echo "Existing cloud data protection requires separate manual verification."
  exit 0
fi

echo "Recovery readiness check completed with ${FAILURES} failure(s)."
exit 1
