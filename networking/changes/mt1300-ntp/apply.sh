#!/bin/sh
set -eu
[ "$(ubus call system board | jsonfilter -e '@.board_name')" = glinet,gl-mt1300 ]
[ -z "$(uci changes system)" ]
[ "$(sha256sum /etc/init.d/sysntpd | awk '{print $1}')" = f4ae98536711bbaf5cd1e8de5154d1e654ebf88af6cc07d003119b0571745c0d ]
[ "$(sha256sum /tmp/sysntpd-resolver.new | awk '{print $1}')" = 6b5ff4e846d0b4f9c815a0f77d4502746e86a9dcd367ef83aef243559876a6e1 ]
sh -n /tmp/sysntpd-resolver.new
[ ! -e /root/sysntpd-before-resolver-tracking ]
if [ "${1:---check}" = --check ]; then echo PREFLIGHT_OK; exit 0; fi
[ "$1" = --apply ]
umask 077
cp -p /etc/init.d/sysntpd /root/sysntpd-before-resolver-tracking
cp /tmp/sysntpd-resolver.new /etc/init.d/sysntpd
chmod 755 /etc/init.d/sysntpd
/etc/init.d/sysntpd reload
echo RESOLVER_TRACKING_APPLIED
