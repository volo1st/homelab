#!/bin/sh
# Default: read-only checks. Apply only with --apply.
set -eu
[ "$(ubus call system board | jsonfilter -e '@.board_name')" = netgear,wax202 ]
[ "$(cat /sys/class/net/br-lan/address)" = 34:98:b5:28:89:52 ]
[ -z "$(uci changes wireless)" ]
[ -z "$(uci -q get wireless.radio0.country || true)" ]
[ -z "$(uci -q get wireless.radio1.country || true)" ]
[ "$(uci get wireless.radio0.disabled)" = 1 ]
[ "$(uci get wireless.radio1.channel)" = 153 ]
[ "$(uci get wireless.radio1.htmode)" = HE80 ]
[ "$(uci get wireless.wdssta.mode)" = sta ]
[ "$(uci get wireless.wdssta.wds)" = 1 ]
[ "$(uci get wireless.wdssta.network)" = lan ]
[ "$(cat /sys/class/net/lan1/carrier)" = 1 ]
[ -e /sys/class/net/br-lan/brif/lan1 ]
iw dev phy1-sta0 link | grep -qi 'Connected to 5e:81:e0:ee:07:05'
[ ! -e /root/wireless-before-au.conf ]
if [ "${1:---check}" = --check ]; then echo PREFLIGHT_OK; exit 0; fi
[ "$1" = --apply ]
umask 077
cp -p /etc/config/wireless /root/wireless-before-au.conf
uci set wireless.radio0.country=AU
uci set wireless.radio1.country=AU
uci commit wireless
echo COUNTRY_SAVED
wifi reload
echo RELOAD_REQUESTED
