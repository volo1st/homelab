# MT6000 production firmware update

Owner authorization: 2026-10-19 Sydney, “let's do it then”.
Scope: vendor stable 4.9.1 release1 to 4.11.0 release3. Retain configuration.
Keep the current OpenWrt 21.02 vendor family and kitchen AP role.
The owner confirms physical access and Air-to-LAN recovery access.

## Verified preparation

- Fresh native board: `glinet,gl-mt6000`, mediatek/mt7986.
- Vendor catalogue selects `RELEASE`, not a same-number snapshot.
- Target: `mt6000-4.11.0_release3-1147-0924-1790238424.bin`.
  SHA-256: `4004632eaf516fd2844be0e5595b6e4171d243181ff49b81569b986c79007dae`.
- Original: `mt6000-4.9.1_release1-1079-0804-1785826264.bin`.
  SHA-256: `0342114922db0b5e98750a8414eeb23849ce1b8f30f85c46d6d11d69a070bcef`.
- Both local image sizes and SHA-256 hashes match the official HTTPS catalogue.
  Target transfer hash matches. Its vendor signature passes with the existing
  `/etc/key-build.pub`; no new key or forced compatibility override is used.
  Signature extraction used a temporary image copy. The original stays intact.
- Target metadata names MT6000, 4.11.0 release3, compat_version 1.0,
  mediatek/mt7986, and an empty upgrade_control. Native `sysupgrade -T` passes.
- Fresh native backup: 156 archive entries. Local and remote SHA-256 match.
  Network, wireless, AP mode, SSH keys, host keys, and password state are included.
  Backup SHA-256: `d1d71322d1c4da4390713da7ab1d16bb0f05426d3f8f6040577a7c6bc6a8d306`.
- No pending UCI change. AP mode, `.2/24`, gateway `.1`, and both AU radio
  settings pass. Configuration and package inventories are saved privately.
  Free temporary space after image/signature checks exceeds 330 MiB.

Private evidence: investigation workspace `backups/mt6000-update/`.
Private backup: `config-before.tar.gz`. Firmware images remain ignored under
`firmware/mt6000-update/`. Do not commit these files or web-session logs.

## Application and acceptance

1. Recheck board, version, AP mode, AU, configuration hashes, image/backup
   hashes, existing-key signature, and native image test immediately before flash.
2. Run `/sbin/sysupgrade -k /tmp/mt6000-4.11.0.bin` once. This retains native
   configuration and records extra package names. It does not copy old binaries.
   Do not use `-F` or `-n`. Expect SSH and MT6000 Wi-Fi to disconnect.
3. Allow the device to finish writing and reboot. Keep power connected.
4. Verify a fresh keyed SSH connection with the existing host key. Verify
   vendor 4.11.0 release3, `.2`, AP mode, LAN bridge/uplink, default route,
   AU radio settings, Wi-Fi security, and browser response.
5. Compare retained configuration, key, and password state. Review any native
   migration before editing a difference. Record package differences. Optional
   LuCI/diagnostic packages may require supported-feed reinstallation; do not
   reinstall all old packages or old kernel modules automatically.
6. Ask the owner to check Wi-Fi/Internet, fresh Air SSH/browser login, and
   phone-hotspot Tailscale management. Keep the 24-hour observation open.

## Recovery

If management or the AP role fails, first inspect the failed state through
an Ethernet LAN connection from the Air. Keep the backup and original image.
If software rollback is needed, pair the original 4.9.1 image with its original
private backup. Do not retain 4.11.0 configuration during a downgrade.
The native `sysupgrade -f` path can supply the saved 4.9.1 archive explicitly;
verify the image and paired archive before any recovery flash.

If normal management is unavailable, follow the vendor's bootloader procedure.
For MT6000 Flint 2, use LAN 2, LAN 3, or LAN 4; exclude LAN 1.
Use the model-specific U-Boot-compatible image identified by the recovery
page. Do not substitute another model's image or assume every tar image
is a bootloader image. A bootloader flash is not part of this update.
No actual rollback, configuration restore, or bootloader recovery is tested.

Sources: [catalogue](https://dl.gl-inet.com/release/router/release/mt6000/4.11.0),
[upgrade](https://docs.gl-inet.com/router/en/4/interface_guide/upgrade/),
[backup and downgrade](https://docs.gl-inet.com/router/en/4/tutorials/how_to_upgrade_downgrade_router/),
[bootloader recovery](https://docs.gl-inet.com/router/en/4/faq/debrick/).

## Applied result — 2026-10-19/20 Sydney

The owner authorized installation and confirmed physical wired recovery access.
Final board, AP mode, AU, configuration, image/backup hashes, existing-key
signature, and native image checks passed. Ran the recorded `sysupgrade -k`
command once at 22:06 on 19 October. SSH ended with exit 255 during reboot.
The first post-boot connection timed out. A later capture verified 4.11.0
release3, revision `r15812+1095-46b6ee7ffc`, and a new boot ID.
The native upgrade also reported a bad environment CRC and used its default
environment. No environment repair was attempted. Successful fresh boot and
role checks establish the outcome; the disconnect alone does not.

The AP retained `.2/24`, gateway `.1`, the LAN bridge/uplink, both SSIDs,
passphrases, encryption, enabled states, AU, channel, and width.
SSH configuration, authorized keys, password state, system, and AP-mode file
hashes match. Network and wireless files changed through vendor migration.
Reviewed differences add network display/VLAN fields, an explicit disabled
guest bridge, native Mesh/WPS fields, and disabled Mesh backhaul interfaces.
Random BSSIDs changed where already enabled. No manual radio or bridge
change ran. Both new Mesh AP/station interfaces remain disabled.

All earlier LuCI packages remain installed. The vendor package set changed
with the image. No separate package installation command ran. The retained
uHTTPd/module and nginx labels are unchanged. No exact backport claim is
made; the accepted production-release policy still applies.
Three gateway pings and DNS resolution pass. The owner confirms Wi-Fi/Internet,
fresh Air SSH, and off-LAN Tailscale. The owner corrected the initial all-pass
reply: browser access by `mt6000.lan` failed. Preserve that failed result.

### Browser hostname compatibility

The new `/usr/share/gl-ngx/oui-access.lua` validates Host headers after setup.
Its original allowlist admits local addresses and vendor names, but omits the
retained `mt6000.lan` name. The hostname returned HTTP 403; direct `.2` returned
HTTP 200. The source and responses establish this compatibility regression.

Applied [the one-host patch](mt6000-web-host.patch) with
[the guarded helper](mt6000-web-host.sh). It adds only `mt6000.lan`.
Native Lua parsing and `nginx -t` passed before installation. Reloaded nginx
once. The hostname now returns HTTP 200; `not-allowed.invalid` still returns
HTTP 403. Host validation remains active. Wireless runtime and all checked
post-upgrade configuration hashes are unchanged by this web-only repair.
No device reboot or Wi-Fi restart ran for the hostname fix.

Original source SHA-256:
`f6b38266dea0e104b0b704418a668bbb88945b8ae079a6fcbe203d23317eb26f`.
Patched source SHA-256:
`20e1041349b7ec1401ad46a16f61a2d0506b6d12fae1634815c1714843f2a152`.
The helper stops if the version, model, or original source differs.
Review the native allowlist after every later firmware upgrade. Prefer a
vendor-supported hostname setting when available. Do not preserve the whole
old Lua file over new firmware. Reassess this one-host change against new code.
For rollback on this exact build, restore the saved original Lua file, validate
nginx, and reload it. That restores the original hostname restriction too.

### Acceptance and recovery checkpoint

Final technical checks passed at 01:44 on 20 October Sydney. A fresh 163-entry
native configuration backup passes archive and remote/local SHA-256 checks.
Its hash is
`24c5cc59e32a0bc2b9ab920e97285b1ceecd40707a62e50d8c03f010709c08ea`.
The native archive does not include the custom Lua file. Recover the firmware
and paired configuration, then review and apply the tracked hostname patch.
Private before/after Lua copies and manifests are saved beside the archives.
No actual restore or bootloader recovery was needed or tested.

The owner confirmed browser login after the hostname fix. All immediate
client checks now pass. Review 24 hours of normal use no earlier than
2026-10-21 01:45 Sydney,
measured from the final web-change verification. Keep the original recovery
image and paired backup. AXT1800's earlier observation is separate and ready
for review; this MT6000 change does not complete that check.
No other AP or MikroTik setting changed. No NAS or Mac Studio connection ran.
