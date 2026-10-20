#!/bin/sh
set -eu
umask 077
file=/usr/share/gl-ngx/oui-access.lua
candidate=/tmp/mt6000-web-host-4.11.0.lua
backup=/tmp/mt6000-web-host-4.11.0.before.lua
[ "$(cat /etc/glversion)" = 4.11.0 ]
[ "$(ubus call system board | jsonfilter -e '@.board_name')" = 'glinet,gl-mt6000' ]
[ "$(sha256sum "$file" | cut -d ' ' -f1)" = f6b38266dea0e104b0b704418a668bbb88945b8ae079a6fcbe203d23317eb26f ]
awk '{ print; if (index($0, "[\047console.gl-inet.com\047] = true,")) print "    [\047mt6000.lan\047] = true," }' "$file" > "$candidate"
[ "$(sha256sum "$candidate" | cut -d ' ' -f1)" = 20e1041349b7ec1401ad46a16f61a2d0506b6d12fae1634815c1714843f2a152 ]
lua -e 'assert(loadfile("/tmp/mt6000-web-host-4.11.0.lua"))'
nginx -t
if [ "${1:---check}" = --check ];then echo HOST_FIX_PREFLIGHT_PASS;exit 0;fi
[ "$1" = --apply ]
[ ! -e "$backup" ]
cp -p "$file" "$backup"
cp -p "$file" "$file.mt6000-new"
cat "$candidate" > "$file.mt6000-new"
mv "$file.mt6000-new" "$file"
if ! nginx -s reload;then
    cp -p "$backup" "$file"
    nginx -s reload
    echo HOST_FIX_RELOAD_FAILED >&2
    exit 1
fi
sha256sum "$file"
echo HOST_FIX_APPLIED
