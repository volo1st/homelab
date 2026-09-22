#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Run this command inside a Git worktree." >&2
  exit 2
}
cd "$REPO_ROOT"

MATCH_FILE="$(mktemp)"
trap 'rm -f -- "$MATCH_FILE"' EXIT

FAILURES=0
declare -A REPORTED=()

report() {
  local scope="$1"
  local path="$2"
  local line="$3"
  local rule="$4"
  local key="${scope}:${path}:${line}:${rule}"

  if [[ -n "${REPORTED[$key]:-}" ]]; then
    return
  fi

  REPORTED[$key]=1
  # This diagnostic names the finding type. It does not contain a secret value.
  printf 'possible secret: %s:%s:%s: %s\n' "$scope" "$path" "$line" "$rule" >&2 # secret-scan: allow
  FAILURES=$((FAILURES + 1))
}

is_allowed_match() {
  local content="$1"
  local angle_placeholder='<[A-Za-z0-9_-]+>'
  local variable_placeholder='\$\{[A-Za-z_][A-Za-z0-9_]*\}'

  if [[ "$content" == *"secret-scan: allow"* ]]; then
    return 0
  fi

  if [[ "$content" =~ $angle_placeholder ]]; then
    return 0
  fi

  if [[ "$content" =~ $variable_placeholder ]]; then
    return 0
  fi

  return 1
}

scan_pattern() {
  local scope="$1"
  local rule="$2"
  local pattern="$3"
  local status
  local match
  local path
  local remainder
  local line
  local content
  local -a grep_args=(-n -I -i -E -e "$pattern")

  if [[ "$scope" == "index" ]]; then
    grep_args=(--cached "${grep_args[@]}")
  fi

  if git grep "${grep_args[@]}" -- . >"$MATCH_FILE"; then
    status=0
  else
    status=$?
  fi

  if [[ "$status" -gt 1 ]]; then
    echo "Secret scan failed while checking: $rule" >&2
    exit 2
  fi

  if [[ "$status" -eq 1 ]]; then
    return
  fi

  while IFS= read -r match; do
    path="${match%%:*}"
    remainder="${match#*:}"
    line="${remainder%%:*}"
    content="${remainder#*:}"

    if is_allowed_match "$content"; then
      continue
    fi

    report "$scope" "$path" "$line" "$rule"
  done <"$MATCH_FILE"
}

scan_prohibited_names() {
  local path
  local name

  while IFS= read -r -d '' path; do
    name="${path##*/}"

    case "$path" in
      secrets/local/*)
        report index "$path" 0 "local secret path is tracked"
        continue
        ;;
    esac

    case "$name" in
      .env.example|.env.*.example|*.secret.example|*.token.example|*.key.example|\
        *.pem.example|*.p12.example|credentials.json.example|\
        credentials.yaml.example|credentials.yml.example)
        continue
        ;;
      .env|.env.*|*.secret|*.token|*.key|*.pem|*.p12|credentials.json|\
        credentials.yaml|credentials.yml|id_rsa|id_ecdsa|id_ed25519)
        report index "$path" 0 "secret-bearing filename is tracked"
        ;;
    esac
  done < <(git ls-files -z)
}

assignment_pattern='(password|passwd|secret|token|api[_-]?key|client[_-]?secret|private[_-]?key|recovery[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]#]+' # secret-scan: allow
private_key_pattern='-----BEGIN ([A-Z0-9]+[[:space:]])*PRIVATE KEY-----' # secret-scan: allow
credential_url_pattern='[a-z][a-z0-9+.-]*://[^[:space:]/:@]+:[^[:space:]@]+@' # secret-scan: allow
provider_token_pattern='(AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9_-]{20,})' # secret-scan: allow

scan_prohibited_names

for scope in worktree index; do
  scan_pattern "$scope" "credential assignment" "$assignment_pattern"
  scan_pattern "$scope" "private key header" "$private_key_pattern"
  scan_pattern "$scope" "credential in URL" "$credential_url_pattern"
  scan_pattern "$scope" "provider token pattern" "$provider_token_pattern"
done

if [[ "$FAILURES" -ne 0 ]]; then
  echo "Secret scan found ${FAILURES} possible issue(s). Values were not printed." >&2
  exit 1
fi

echo "Secret scan passed."
