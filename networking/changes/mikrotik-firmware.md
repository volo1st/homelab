# MikroTik security upgrade

Target: RouterOS 7.23.8 long-term on RB760iGS, architecture mmips.
The existing development channel was changed to long-term. The native HTTPS
update check, with certificate validation enabled, offers exactly 7.23.8.
The official download changelog includes CVE-2026-84411. The target is also newer
than the corrected September SSH fix threshold, 7.23.6.
Sources: [download and changelog](https://mikrotik.com/download/routeros?architecture=arm64),
[September advisory](https://mikrotik.com/supportsec/september-2026-vulnerability/).
The linked download page shows arm64 by default. This router requires mmips.
Never install an arm64 package on this router.

Fresh evidence and recovery files: private
`secrets/local/network-firmware/20261010T134518Z/`.
The native AES-encrypted binary backup was retrieved twice. Both copies match.
A full sensitive export is private. The backup password is private in the same
restricted evidence directory. Restore has not been tested. The original
RouterOS 7.23.2 mmips package and target package are saved locally.
`images.json` records sizes and SHA-256 values. These local digests are transfer
checks, not independent publisher signatures. The native updater checks signed
packages. Keep HTTPS certificate validation enabled.

## Application and recovery

Only the routeros package is installed. Free flash is about 4.9 MiB on a 16 MiB
device. Use the native updater and stop if it reports insufficient storage.
Do not delete configuration or old backups to force installation.
Download first. Confirm the target, successful download status, and absence of
errors before reboot. Do not combine this upgrade with network configuration edits.
After reboot, verify exact version, package state, routes, DHCP leases, static DNS,
management restrictions, SSH, web access, Internet access, and WDS management.
Compare the private exports. Obtain Air local and off-LAN Tailscale acceptance.
Record a subsequent runtime check. Keep the observation gate open until then.

If the router remains manageable but fails acceptance, inspect the logs first.
Use the saved matching mmips package and the native downgrade procedure if a
software rollback is required. Restore the encrypted binary backup on the same
model and compatible original version if configuration recovery is required.
A downgrade reintroduces the known security issues and is temporary recovery.
If management fails, use a direct Ethernet connection for diagnosis. Netinstall
is the last-resort recovery path. It requires physical access and a suitable
recovery computer. No Netinstall or restore test was performed.
Keep the current RouterBOOT during the first RouterOS acceptance check.
Review the offered RouterBOOT update separately after RouterOS passes.


## Applied result

Installed RouterOS 7.23.8 long-term through the native HTTPS updater.
Download completed before the explicit reboot. Fresh SSH returned on the sixth
poll. HTTP returned 200. Router-originated Internet ping received three replies
with zero loss. A public DNS lookup succeeded. The default route, bound WAN
DHCP client, LAN DHCP server, Apple TV `.8` lease, and static AXT1800 DNS remain.
Management source restrictions remain. No device role or firewall change occurred.

The private configuration comparison has two changes: the intended update channel,
and omission of the explicit clock timezone line from the new export. A live
clock check still reports Australia/Sydney, automatic timezone detection, and
UTC+11. This is an export difference, not evidence of a changed effective timezone.
The backup and sensitive comparison remain private. A sandbox write attempt for
the comparison failed read-only; it was rerun with the required filesystem approval.

RouterBOOT remains 7.23.2 and now offers 7.23.8. No bootloader update occurred.
Obtain owner Air Internet, local SSH/browser, and off-LAN Tailscale acceptance.
Then review the separate RouterBOOT update and subsequent runtime observation.
The original security advisory page and index disagree about the WebFig fix
threshold. The selected 7.23.8 changelog explicitly includes CVE-2026-84411.
The target also exceeds the corrected September fix threshold.


Owner acceptance: the owner confirms all requested Air checks pass after the
upgrade. These include normal Internet access, local MikroTik SSH and browser
login, and off-LAN Tailscale access. Recorded 2026-10-11 Sydney.
RouterBOOT update and subsequent runtime observation remain open.


## RouterBOOT application: 2026-10-11 Sydney

The owner authorized the separate bootloader update and reboot after RouterOS
client acceptance passed. The upgrade command exited successfully without text.
The initial runner expected confirmation text and stopped before reboot.
RouterBOARD status then explicitly confirmed that firmware was upgraded and
required a reboot. Saved this state before proceeding. No repeated flash occurred.
After reboot, RouterBOOT and RouterOS both report 7.23.8. Fresh SSH and HTTP 200
pass. Network state and router-originated Internet/DNS checks were collected.
Evidence: private `network-firmware/20261010T134518Z/routerboot-acceptance.json`.
Owner client acceptance after this second reboot and later stability observation
remain pending. No network configuration change occurred.

Owner confirms all requested checks also pass after the RouterBOOT reboot.
Only subsequent runtime observation remains open for MikroTik acceptance.
