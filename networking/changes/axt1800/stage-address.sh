#!/bin/sh
# Historical failed attempt. Do not execute. See the migration record.
echo "Archived failed procedure; use the migration record" >&2
exit 1
set -eu
[ "$(uci get network.lan.ipaddr)" = 192.168.88.115 ]
[ "$(cat /sys/class/net/br-lan/address)" = 94:83:c4:63:df:8a ]
[ ! -e /tmp/axt-address-migration ]
mkdir -m 700 /tmp/axt-address-migration
cp /etc/config/network /tmp/axt-address-migration/network
cp /etc/config/system /tmp/axt-address-migration/system
cat > /tmp/axt-address-migration/rollback.sh <<'ROLLBACK'
#!/bin/sh
sleep 180
[ -f /tmp/axt-address-migration/accepted ] && exit 0
cp /tmp/axt-address-migration/network /etc/config/network
cp /tmp/axt-address-migration/system /etc/config/system
ip addr add 192.168.88.115/24 dev br-lan 2>/dev/null || true
ip addr del 192.168.88.5/24 dev br-lan 2>/dev/null || true
echo AXT1800-WDS > /proc/sys/kernel/hostname
ROLLBACK
nohup sh /tmp/axt-address-migration/rollback.sh </dev/null >/tmp/axt-address-migration/rollback.log 2>&1 &
ip addr add 192.168.88.5/24 dev br-lan
printf 'ADDRESS_STAGED\n'
