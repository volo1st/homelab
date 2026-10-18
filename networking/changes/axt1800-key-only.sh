#!/bin/sh
# Specific to the reviewed AXT1800 configuration. Defaults to read-only checks.
set -eu
mode=${1:---check}
case "$mode" in --check|--apply) ;; *) echo 'Use --check or --apply' >&2; exit 2;; esac
[ "$(cat /proc/sys/kernel/hostname)" = axt1800 ]
[ "$(cat /sys/class/net/br-lan/address)" = 94:83:c4:63:df:8a ]
[ "$(uci -q get dropbear.main)" = dropbear ]
[ "$(uci show dropbear | grep -c '=dropbear$')" = 1 ]
[ "$(uci -q get dropbear.main.enable)" = 1 ]
[ "$(uci -q get dropbear.main.Port)" = 22 ]
[ "$(uci -q get dropbear.main.PasswordAuth)" = on ]
[ "$(uci -q get dropbear.main.RootPasswordAuth)" = on ]
[ "$(uci -q get dropbear.main.RootLogin || true)" != 0 ]
[ -z "$(uci changes dropbear)" ]
[ -s /etc/dropbear/authorized_keys ]
echo SSH_AUTH_PREFLIGHT_OK
[ "$mode" = --apply ] || exit 0
backup=/root/dropbear-before-key-only.conf
[ ! -e "$backup" ]
umask 077
cp -p /etc/config/dropbear "$backup"
uci set dropbear.main.PasswordAuth='off'
uci set dropbear.main.RootPasswordAuth='off'
uci commit dropbear
/etc/init.d/dropbear reload
echo SSH_AUTH_APPLIED
