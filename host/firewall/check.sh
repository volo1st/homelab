#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FILTER_SOURCE="${SCRIPT_DIR}/docker-filter.sh"
FILTER_DEST="/usr/local/sbin/homelab-docker-firewall"
UNIT_SOURCE="${SCRIPT_DIR}/homelab-docker-firewall.service"
UNIT_DEST="/etc/systemd/system/homelab-docker-firewall.service"
LAN_INTERFACE="enp5s0"
LAN_ADDRESS="192.168.88.6/24"
FAILURES=0
VERBOSE="${DEBUG:-0}"

usage() {
  cat <<'USAGE'
Usage: check.sh [--verbose]

Run non-mutating firewall checks on the NAS host.
Run this script as root.
USAGE
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

case "${1:-}" in
  --verbose|-v)
    VERBOSE=1
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    echo "Unknown argument: $1" >&2
    usage >&2
    exit 2
    ;;
esac

if [[ "$EUID" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 2
fi

for command_name in cmp grep ip systemctl ufw; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
done

is_verbose() {
  [[ "$VERBOSE" == "1" || "$VERBOSE" == "true" || "$VERBOSE" == "yes" ]]
}

check() {
  local label="$1"
  local output
  local status
  shift

  printf '%-44s' "${label} ..."
  output=$("$@" 2>&1)
  status=$?

  if [[ "$status" -eq 0 ]]; then
    printf 'pass\n'
    if is_verbose && [[ -n "$output" ]]; then
      printf '%s\n' "$output"
    fi
    return
  fi

  printf 'fail\n'
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output" >&2
  fi
  FAILURES=$((FAILURES + 1))
}

# The check function invokes the next five functions by name.
# shellcheck disable=SC2329
check_ufw_active() {
  ufw status | grep -Fxq 'Status: active'
}

# shellcheck disable=SC2329
check_ufw_defaults() {
  ufw status verbose | grep -Fq 'Default: deny (incoming), allow (outgoing)'
}

# shellcheck disable=SC2329
check_ufw_lan_rule() {
  ufw show added | grep -Fq \
    'ufw allow in on enp5s0 from 192.168.88.0/24'
}

# shellcheck disable=SC2329
check_ufw_link_local_rule() {
  ufw show added | grep -Fq \
    'ufw allow in on enp5s0 from fe80::/10'
}

# shellcheck disable=SC2329
check_ufw_tailscale_rule() {
  ufw show added | grep -Fq 'ufw allow in on tailscale0'
}

check "Checking LAN address" ip -4 address show dev "$LAN_INTERFACE" to "$LAN_ADDRESS"
check "Checking installed filter" cmp -s "$FILTER_SOURCE" "$FILTER_DEST"
check "Checking installed unit" cmp -s "$UNIT_SOURCE" "$UNIT_DEST"
check "Checking firewall unit enabled" systemctl is-enabled --quiet homelab-docker-firewall.service
check "Checking firewall unit active" systemctl is-active --quiet homelab-docker-firewall.service
check "Checking UFW active" check_ufw_active
check "Checking UFW defaults" check_ufw_defaults
check "Checking UFW trusted LAN rule" check_ufw_lan_rule
check "Checking UFW link-local rule" check_ufw_link_local_rule
check "Checking UFW Tailscale rule" check_ufw_tailscale_rule
check "Checking Docker ingress rules" "$FILTER_DEST" --check

printf '\n'
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Firewall check passed."
  exit 0
fi

echo "Firewall check completed with ${FAILURES} failure(s)."
exit 1
