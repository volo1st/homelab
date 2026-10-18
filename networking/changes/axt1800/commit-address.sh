#!/bin/sh
# Historical failed attempt. Do not execute. See the migration record.
echo "Archived failed procedure; use the migration record" >&2
exit 1
set -eu
[ -d /tmp/axt-address-migration ]
ip -4 addr show dev br-lan | grep -q '192.168.88.5/24'
uci set network.lan.ipaddr='192.168.88.5'
uci set system.@system[0].hostname='axt1800'
uci commit network
uci commit system
echo axt1800 > /proc/sys/kernel/hostname
ip addr del 192.168.88.115/24 dev br-lan
printf 'ADDRESS_COMMITTED\n'
