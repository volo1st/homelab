#!/usr/bin/env python3
"""Collect private, read-only runtime evidence from the five network devices."""
import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

OPENWRT = r'''
run() {
    label="$1"
    shift
    printf '\n=== %s ===\n' "$label"
    "$@"
    result=$?
    printf '\n=== status %s %s ===\n' "$label" "$result"
}
run clock date -u
run uptime uptime
run board ubus call system board
run vendor-version sh -c 'for f in /etc/glversion /etc/gl-release /etc/openwrt_release; do if [ -f "$f" ]; then echo "$f"; cat "$f"; fi; done'
run config uci export
run addresses ip addr show
run routes4 ip -4 route show table all
run routes6 ip -6 route show table all
run rules4 ip -4 rule show
run rules6 ip -6 rule show
run interface-state ubus call network.interface dump
run links ip -s link show
run link-counters cat /proc/net/dev
run bridge sh -c 'command -v bridge >/dev/null 2>&1 || exit 127; bridge -d link show; bridge vlan show; bridge fdb show'
run bridge-sysfs sh -c 'for b in /sys/class/net/br-lan/bridge/*; do case "$b" in */stp_state|*/multicast_snooping|*/vlan_filtering) echo "$b"; cat "$b";; esac; done; ls /sys/class/net/br-lan/brif'
run listeners sh -c 'if command -v ss >/dev/null 2>&1; then ss -lntup; else netstat -lntup; fi'
run services ubus call service list
run nft sh -c 'if command -v nft >/dev/null 2>&1; then nft list ruleset; else exit 127; fi'
run iptables sh -c 'if command -v iptables-save >/dev/null 2>&1; then iptables-save -c; else exit 127; fi'
run ip6tables sh -c 'if command -v ip6tables-save >/dev/null 2>&1; then ip6tables-save -c; else exit 127; fi'
run regulatory iw reg get
run wireless iw dev
run iwinfo sh -c 'if command -v iwinfo >/dev/null 2>&1; then iwinfo; else exit 127; fi'
run wireless-state ubus call network.wireless status
run wireless-counters sh -c 'command -v iw >/dev/null 2>&1 || exit 127; iw dev | awk '\''$1 == "Interface" {print $2}'\'' | while IFS= read -r iface; do case "$iface" in ""|*[!a-zA-Z0-9_.-]*) continue;; esac; echo "INTERFACE $iface"; iw dev "$iface" link; iw dev "$iface" station dump; iw dev "$iface" survey dump; done'
run vendor-radio-country sh -c 'if [ -d /etc/wireless ]; then grep -r -E "^(CountryCode|CountryRegion|CountryRegionABand)=" /etc/wireless; else exit 127; fi'
run web-listener-config sh -c 'if [ -d /etc/nginx ]; then grep -r -E "listen |return 30[1278]|ssl_protocols|ssl_certificate " /etc/nginx; else exit 127; fi'
run dhcp-leases sh -c 'if [ -f /tmp/dhcp.leases ]; then cat /tmp/dhcp.leases; else exit 1; fi'
run storage df -h
run memory free
run kernel-log dmesg
run system-log logread
run packages sh -c 'if command -v apk >/dev/null 2>&1; then apk info -v; else opkg list-installed; fi'
exit 0
'''

ROUTEROS = [
    ('clock', '/system clock print'),
    ('identity', '/system resource print; /system routerboard print; /system package print'),
    ('export', '/export'),
    ('services', '/ip service print detail; /ip ssh print; /tool mac-server print; /tool mac-server mac-winbox print; /ip neighbor discovery-settings print'),
    ('users', '/user print detail; /user ssh-keys print detail'),
    ('interfaces', '/interface print detail; /interface ethernet print detail; /interface bridge print detail; /interface bridge port print detail; /interface bridge vlan print detail; /interface list member print detail'),
    ('addresses', '/ip address print detail; /ip route print detail; /ipv6 address print detail; /ipv6 route print detail'),
    ('dhcp', '/ip pool print detail; /ip dhcp-server print detail; /ip dhcp-server lease print detail; /ip dhcp-server network print detail; /ip dhcp-client print detail; /ip dns print'),
    ('ipv6', '/ipv6 settings print; /ipv6 dhcp-client print detail; /ipv6 nd print detail; /ipv6 nd prefix print detail'),
    ('firewall4', '/ip firewall filter print detail; /ip firewall nat print detail; /ip firewall filter print stats; /ip firewall nat print detail stats; /ip firewall raw print detail stats; /ip firewall mangle print detail stats'),
    ('firewall6', '/ipv6 firewall filter print detail; /ipv6 firewall filter print stats; /ipv6 firewall raw print detail stats; /ipv6 firewall mangle print detail stats'),
    ('remote-access', '/ip upnp print; /ip upnp interfaces print detail; /ip cloud print; /interface ovpn-server server print detail'),
    ('maintenance', '/system package update print; /system logging print detail; /system ntp client print; /system ntp client servers print detail'),
    ('queues', '/queue simple print detail stats; /queue tree print detail stats'),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true', help='Open read-only SSH sessions and save ignored private evidence')
    args = parser.parse_args()
    if not args.run:
        parser.print_help()
        return 0
    root = Path(__file__).resolve().parents[1]
    probe = root / 'secrets/local/network-runtime/protection-check'
    subprocess.run(['git', '-C', str(root), 'check-ignore', '-q', str(probe)], check=True)
    os.umask(0o077)
    stamp = dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    output = probe.parent / stamp
    output.mkdir(parents=True, exist_ok=False, mode=0o700)
    manifest = {'started_utc': stamp, 'mode': 'read-only-runtime', 'captures': []}
    options = ['ssh', '-T', '-o', 'BatchMode=yes', '-o', 'StrictHostKeyChecking=yes',
               '-o', 'ConnectTimeout=8', '-o', 'ConnectionAttempts=1',
               '-o', 'ServerAliveInterval=10', '-o', 'ServerAliveCountMax=2']
    manifest_path = output / 'manifest.json'

    def save_manifest():
        manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')

    def capture(host, label, remote, payload=None):
        device = output / host
        device.mkdir(exist_ok=True, mode=0o700)
        dest = device / (label + '.txt')
        stderr = device / (label + '.stderr')
        record = {'host': host, 'section': label, 'started_utc': dt.datetime.now(dt.timezone.utc).isoformat()}
        manifest['captures'].append(record)
        save_manifest()
        try:
            with dest.open('wb') as out, stderr.open('wb') as err:
                result = subprocess.run(options + [host, remote], input=payload,
                                        stdout=out, stderr=err, timeout=120)
            record['transport_exit'] = result.returncode
        except subprocess.TimeoutExpired:
            record['transport_exit'] = 124
        record['bytes'] = dest.stat().st_size
        record['sha256'] = hashlib.sha256(dest.read_bytes()).hexdigest()
        record['stderr_sha256'] = hashlib.sha256(stderr.read_bytes()).hexdigest()
        save_manifest()
        print(f'{host}/{label}: transport={record["transport_exit"]}, bytes={record["bytes"]}', flush=True)

    print(f'Private output: {output}', flush=True)
    try:
        for host in ['axt1800', 'wax202', 'mt6000', 'mt1300']:
            capture(host, 'runtime', 'sh -s', OPENWRT.encode())
        for label, command in ROUTEROS:
            capture('mikrotik', label, command)
    finally:
        manifest['finished_utc'] = dt.datetime.now(dt.timezone.utc).isoformat()
        manifest['all_transports_passed'] = len(manifest['captures']) == 4 + len(ROUTEROS) and all(
            r.get('transport_exit') == 0 for r in manifest['captures'])
        save_manifest()
    print('Review section status and unsupported commands privately. Transport success alone does not prove coverage.')
    return 0 if manifest['all_transports_passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
