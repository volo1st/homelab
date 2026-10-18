# Remaining OpenWrt SSH password authentication

Applied on 2026-10-09 after the user authorized continued staged hardening without
further confirmation prompts. AXT1800 had already passed user Air SSH and browser
checks. The user previously confirmed browser login on all OpenWrt devices.

## Applied scope

| Device | Bridge MAC | Result |
|---|---|---|
| WAX202 | 34:98:b5:28:89:52 | Both SSH password flags off |
| MT6000 | 94:83:c4:c4:43:d1 | Both SSH password flags off |
| MT1300 | 94:83:c4:08:8f:b9 | Both SSH password flags off |

Fresh public-key-only preflight evidence:
`secrets/local/network-management/20261009T105234Z/`.
Sequential application and verification evidence:
`secrets/local/network-management/20261009T105332Z/`.

The reviewed `openwrt-key-only.sh` defaults to `--check`. It accepts only these
three bridge MACs. It checks a single enabled Dropbear section, existing keys,
expected password flags and port, and no uncommitted Dropbear configuration.
It handles MT1300's anonymous section through `@dropbear[0]`.
Each application saved the original configuration in collector evidence and at
`/root/dropbear-before-key-only.conf` on that AP, then set `PasswordAuth=off`
and `RootPasswordAuth=off` and reloaded only Dropbear.
The completed state intentionally fails the old-state preflight. Do not rerun it.

For each device, a separate key-authenticated shell remained open during the
change. A fresh key-only connection passed afterward. No-auth probes offered only
`publickey`; no password was sent. Each browser interface returned HTTP 200.
The recovery sessions closed after successful checks. Root passwords, browser
settings, authorized keys, host keys, addresses, and source restrictions did not
change. Automated checks did not perform authenticated browser login.
Post-change Air login checks for these three devices remain a client acceptance
item. No reboot test or vendor-UI persistence test has been performed.

## Recovery

Log into the existing web interface with the unchanged device password. Use LuCI
SSH administration to add a replacement public key or re-enable password login.
On GL.iNet vendor pages, use the Advanced/LuCI interface if the SSH control is not
available in the main page. The exact recovery UI steps remain untested here.
From a working key session, restore the original Dropbear file:

```sh
cp /root/dropbear-before-key-only.conf /etc/config/dropbear
/etc/init.d/dropbear reload
```

The apply runner requests this restoration over the preserved shell if a check
fails. No rollback was needed. Automatic rollback was not deliberately tested.
If both management paths fail, use physical recovery after checking the device's
procedure. Do not reset a device merely because a private key is lost.

Reference: [Dropbear authentication settings](https://openwrt.org/docs/guide-user/base-system/dropbear).
