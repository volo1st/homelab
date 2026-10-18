#!/bin/sh
set -eu
mode=${1:---check}
expected_mac=${2:-}
case "$mode" in --check|--apply) ;; *) exit 2;; esac
case "$expected_mac" in 34:98:b5:28:89:52|94:83:c4:c4:43:d1|94:83:c4:08:8f:b9) ;; *) exit 2;; esac
[ "$(cat /sys/class/net/br-lan/address)" = "$expected_mac" ]
[ "$(uci show dropbear | grep -c '=dropbear$')" = 1 ]
section='@dropbear[0]'
[ "$(uci -q get "dropbear.$section.Port")" = 22 ]
[ "$(uci -q get "dropbear.$section.PasswordAuth")" = on ]
[ "$(uci -q get "dropbear.$section.RootPasswordAuth")" = on ]
case "$(uci -q get "dropbear.$section.RootLogin" || echo on)" in on|1) ;; *) exit 1;; esac
case "$(uci -q get "dropbear.$section.enable" || echo 1)" in on|1) ;; *) exit 1;; esac
[ -z "$(uci changes dropbear)" ]
[ -s /etc/dropbear/authorized_keys ]
echo SSH_AUTH_PREFLIGHT_OK
[ "$mode" = --apply ] || exit 0
backup=/root/dropbear-before-key-only.conf
[ ! -e "$backup" ]
umask 077
cp -p /etc/config/dropbear "$backup"
uci set "dropbear.$section.PasswordAuth=off"
uci set "dropbear.$section.RootPasswordAuth=off"
uci commit dropbear
/etc/init.d/dropbear reload
echo SSH_AUTH_APPLIED
