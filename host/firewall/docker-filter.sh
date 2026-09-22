#!/usr/bin/env bash
set -euo pipefail

LAN_INTERFACE="enp5s0"
LAN_IPV4="192.168.88.0/24"
LAN_IPV6="fe80::/10"
FILTER_CHAIN="HOMELAB-DOCKER"
MODE="apply"

usage() {
  cat <<'USAGE'
Usage: docker-filter.sh [--apply | --check | --remove]

Manage the Docker ingress filter for the trusted home LAN.
Run this script as root on the NAS host.
USAGE
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

case "${1:---apply}" in
  --apply)
    MODE="apply"
    ;;
  --check)
    MODE="check"
    ;;
  --remove)
    MODE="remove"
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

if [[ "$EUID" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 2
fi

for command_name in iptables ip6tables; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
done

check_base_chain() {
  local command_name="$1"

  if ! "$command_name" -n -L DOCKER-USER >/dev/null 2>&1; then
    echo "$command_name does not contain the Docker DOCKER-USER chain." >&2
    return 1
  fi
}

remove_jump() {
  local command_name="$1"

  while "$command_name" -C DOCKER-USER -j "$FILTER_CHAIN" >/dev/null 2>&1; do
    "$command_name" -D DOCKER-USER -j "$FILTER_CHAIN"
  done
}

remove_family() {
  local command_name="$1"

  remove_jump "$command_name"
  if "$command_name" -n -L "$FILTER_CHAIN" >/dev/null 2>&1; then
    "$command_name" -F "$FILTER_CHAIN"
    "$command_name" -X "$FILTER_CHAIN"
  fi
}

apply_family() {
  local command_name="$1"
  local lan_source="$2"

  check_base_chain "$command_name"

  if ! "$command_name" -n -L "$FILTER_CHAIN" >/dev/null 2>&1; then
    "$command_name" -N "$FILTER_CHAIN"
  fi
  "$command_name" -F "$FILTER_CHAIN"

  "$command_name" -A "$FILTER_CHAIN" -m conntrack \
    --ctstate RELATED,ESTABLISHED -j ACCEPT
  "$command_name" -A "$FILTER_CHAIN" -i "$LAN_INTERFACE" \
    -s "$lan_source" -j RETURN
  "$command_name" -A "$FILTER_CHAIN" -i tailscale0 -j RETURN
  "$command_name" -A "$FILTER_CHAIN" -i lo -j RETURN
  "$command_name" -A "$FILTER_CHAIN" -i 'docker+' -j RETURN
  "$command_name" -A "$FILTER_CHAIN" -i 'br+' -j RETURN
  "$command_name" -A "$FILTER_CHAIN" -j DROP

  remove_jump "$command_name"
  "$command_name" -I DOCKER-USER 1 -j "$FILTER_CHAIN"
}

check_family() {
  local command_name="$1"
  local lan_source="$2"

  check_base_chain "$command_name"
  "$command_name" -C DOCKER-USER -j "$FILTER_CHAIN"
  "$command_name" -C "$FILTER_CHAIN" -m conntrack \
    --ctstate RELATED,ESTABLISHED -j ACCEPT
  "$command_name" -C "$FILTER_CHAIN" -i "$LAN_INTERFACE" \
    -s "$lan_source" -j RETURN
  "$command_name" -C "$FILTER_CHAIN" -i tailscale0 -j RETURN
  "$command_name" -C "$FILTER_CHAIN" -i lo -j RETURN
  "$command_name" -C "$FILTER_CHAIN" -i 'docker+' -j RETURN
  "$command_name" -C "$FILTER_CHAIN" -i 'br+' -j RETURN
  "$command_name" -C "$FILTER_CHAIN" -j DROP
}

case "$MODE" in
  apply)
    apply_family iptables "$LAN_IPV4"
    apply_family ip6tables "$LAN_IPV6"
    echo "Docker ingress filter applied."
    ;;
  check)
    check_family iptables "$LAN_IPV4"
    check_family ip6tables "$LAN_IPV6"
    echo "Docker ingress filter passed."
    ;;
  remove)
    remove_family iptables
    remove_family ip6tables
    echo "Docker ingress filter removed."
    ;;
esac
