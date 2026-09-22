#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
SCANNER="${SCRIPT_DIR}/check-secrets.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEST_ROOT"' EXIT

FAILURES=0

pass() {
  echo "pass: $1"
}

fail() {
  echo "fail: $1" >&2
  FAILURES=$((FAILURES + 1))
}

assert_ignored() {
  local path="$1"

  if git -C "$REPO_ROOT" check-ignore --no-index --quiet -- "$path"; then
    pass "ignored: $path"
  else
    fail "ignored: $path"
  fi
}

assert_trackable() {
  local path="$1"

  if git -C "$REPO_ROOT" check-ignore --no-index --quiet -- "$path"; then
    fail "trackable: $path"
  else
    pass "trackable: $path"
  fi
}

assert_ignored services/example/.env
assert_ignored services/example/.env.production
assert_ignored services/example/database.secret
assert_ignored services/example/access.token
assert_ignored services/example/private.key
assert_ignored services/example/private.pem
assert_ignored services/example/identity.p12
assert_ignored services/example/credentials.json
assert_ignored secrets/local/example
assert_ignored services/example/service.log
assert_ignored services/example/.edit.swp

assert_trackable services/example/.env.example
assert_trackable services/example/.env.production.example
assert_trackable services/example/database.secret.example
assert_trackable services/example/private.key.example
assert_trackable services/example/credentials.json.example
assert_trackable secrets/example.env.example

TEST_REPO="${TEST_ROOT}/repo"
mkdir -p "$TEST_REPO"
git -C "$TEST_REPO" init -q

printf 'PASSWORD=\n' >"${TEST_REPO}/safe.env.example"
printf 'TOKEN=<token>\n' >>"${TEST_REPO}/safe.env.example"
printf '%s=%s\n' CLIENT_SECRET "\${CLIENT_SECRET}" >>"${TEST_REPO}/safe.env.example"
git -C "$TEST_REPO" add safe.env.example
if (cd "$TEST_REPO" && "$SCANNER" >/dev/null); then
  pass "scanner accepts safe example values"
else
  fail "scanner accepts safe example values"
fi

printf '%s=%s\n' PASSWORD supersecretvalue >"${TEST_REPO}/config.txt"
printf '%s%s\n' ghp_ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa >"${TEST_REPO}/token.txt"
printf '%s\n' '-----BEGIN PRIVATE KEY-----' >"${TEST_REPO}/private.pem"
git -C "$TEST_REPO" add config.txt token.txt private.pem

set +e
scan_output="$(cd "$TEST_REPO" && "$SCANNER" 2>&1)"
scan_status=$?
set -e

if [[ "$scan_status" -ne 0 ]]; then
  pass "scanner rejects test secrets"
else
  fail "scanner rejects test secrets"
fi

for rule in "credential assignment" "provider token pattern" \
  "private key header" "secret-bearing filename is tracked"; do
  if [[ "$scan_output" == *"$rule"* ]]; then
    pass "scanner reports $rule"
  else
    fail "scanner reports $rule"
  fi
done

if [[ "$scan_output" == *"supersecretvalue"* ||
      "$scan_output" == *"ghp_aaaaaaaa"* ]]; then
  fail "scanner hides matched values"
else
  pass "scanner hides matched values"
fi

if [[ "$FAILURES" -ne 0 ]]; then
  echo "Secret-control tests completed with ${FAILURES} failure(s)." >&2
  exit 1
fi

echo "Secret-control tests passed."
