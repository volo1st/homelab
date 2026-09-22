#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_FILE="${REPO_ROOT}/host/packages.tsv"
VERBOSE="${DEBUG:-0}"
FAILURES=0

EXPECTED_CONTAINERS=(
  dde-vincent
  blackbox-exporter
  jellyfin
  prometheus
  node-exporter
  grafana
)

TCP_PORTS=(22 139 445 3000 5201 8096 9090 9100 9115)
UDP_PORTS=(5353 7359)

usage() {
  cat <<'USAGE'
Usage: validate-host.sh [--verbose]

Run all read-only checks for the implemented NAS host configuration.
Run this script as root from a real NAS host shell.
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

if [[ "$(cat /proc/1/comm 2>/dev/null || true)" != "systemd" ]]; then
  echo "This script requires a real host shell with systemd as process 1." >&2
  exit 2
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 2
fi

for command_name in docker dpkg-query grep hostname ip ss systemctl; do
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

  printf '%-46s' "${label} ..."
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
check_package() {
  local package="$1"
  local status

  status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null) || return 1
  [[ "$status" == "ii " ]]
}

# shellcheck disable=SC2329
check_container() {
  local container="$1"
  [[ "$(docker inspect --format '{{.State.Running}}' "$container" 2>/dev/null)" == "true" ]]
}

# shellcheck disable=SC2329
check_dde_security_option() {
  local option="$1"

  docker inspect --format \
    '{{range .HostConfig.SecurityOpt}}{{println .}}{{end}}' dde-vincent 2>/dev/null |
    grep -Fxq "$option"
}

# shellcheck disable=SC2329
check_tcp_port() {
  local port="$1"
  ss -H -ltn "sport = :${port}" | grep -q .
}

# shellcheck disable=SC2329
check_udp_port() {
  local port="$1"
  ss -H -lun "sport = :${port}" | grep -q .
}

check "Checking Ubuntu 24.04" grep -Fxq 'VERSION_ID="24.04"' /etc/os-release
check "Checking hostname nas" test "$(hostname)" = nas
check "Checking LAN address" ip -4 address show dev enp5s0 to 192.168.88.6/24

while IFS=$'\t' read -r package _version _purpose; do
  [[ -z "$package" || "$package" == \#* ]] && continue
  check "Checking package ${package}" check_package "$package"
done <"$PACKAGE_FILE"

check "Checking storage" "${REPO_ROOT}/host/storage/check.sh"
check "Checking generated mount unit" "${REPO_ROOT}/host/storage/check-generated.sh"
check "Checking Samba" "${REPO_ROOT}/host/samba/check.sh"
check "Checking firewall" "${REPO_ROOT}/host/firewall/check.sh"

for unit in ssh.service smbd.service avahi-daemon.service docker.service; do
  check "Checking service ${unit}" systemctl is-active --quiet "$unit"
done

check "Checking Docker Engine" docker info --format '{{.ServerVersion}}'
check "Checking Docker Compose" docker compose version

for container in "${EXPECTED_CONTAINERS[@]}"; do
  check "Checking container ${container}" check_container "$container"
done

check "Checking dde-vincent not fully privileged" test \
  "$(docker inspect --format '{{.HostConfig.Privileged}}' dde-vincent 2>/dev/null)" = false
check "Checking dde-vincent seccomp option" check_dde_security_option seccomp=unconfined
check "Checking dde-vincent AppArmor option" check_dde_security_option apparmor=unconfined
check "Checking dde-vincent host network" test \
  "$(docker inspect --format '{{.HostConfig.NetworkMode}}' dde-vincent 2>/dev/null)" = host

for port in "${TCP_PORTS[@]}"; do
  check "Checking TCP listener ${port}" check_tcp_port "$port"
done

for port in "${UDP_PORTS[@]}"; do
  check "Checking UDP listener ${port}" check_udp_port "$port"
done

printf '\n'
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Host validation passed."
  exit 0
fi

echo "Host validation completed with ${FAILURES} failure(s)."
exit 1
