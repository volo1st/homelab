#!/bin/sh
set -eu
[ "$(ubus call system board | jsonfilter -e '@.board_name')" = glinet,gl-mt6000 ]
[ "$(cat /sys/class/net/br-lan/address)" = 94:83:c4:c4:43:d1 ]
[ -z "$(uci changes wireless)" ]
[ "$(uci get wireless.mt798611.country)" = US ]
[ "$(uci get wireless.mt798612.country)" = US ]
[ "$(cat /sys/class/net/eth1/carrier)" = 1 ]
[ -e /sys/class/net/br-lan/brif/eth1 ]
grep -q 'config_add_string country' /lib/netifd/wireless/mtk.sh
[ ! -e /root/wireless-before-au.conf ]
if [ "${1:---check}" = --check ]; then echo PREFLIGHT_OK; exit 0; fi
[ "$1" = --apply ]
umask 077
cp -p /etc/config/wireless /root/wireless-before-au.conf
uci set wireless.mt798611.country=AU
uci set wireless.mt798612.country=AU
uci commit wireless
wifi reload
echo COUNTRY_APPLIED
