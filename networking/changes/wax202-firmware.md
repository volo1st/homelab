# WAX202 firmware preparation

Prepared upgrade: OpenWrt 25.12.2 to 25.12.5, ramips/mt7621, netgear,wax202.
No firmware was installed during preparation.
Evidence: private `network-firmware/20261010T143127Z-wax202/`.

A fresh native configuration backup passed tar inspection and remote/local SHA-256
comparison. It includes network, wireless, Dropbear, authorized keys, and password
state. Keep this archive private. Free working space exceeds 200 MiB.
Saved official sysupgrade and factory images for both the original and target
versions. All downloaded images match the official HTTPS checksum lists.
The staged target image matches the local hash and passes `sysupgrade -T`.
Target sysupgrade SHA-256:
`ef3a66ea09ec2500b3f9f4572be235f63fc447e90517a04ca341a681eb894ac1`.
The checksum-list signature was not independently verified.
Sources: [target files](https://downloads.openwrt.org/releases/25.12.5/targets/ramips/mt7621/),
[release notes](https://github.com/openwrt/openwrt/releases/tag/v25.12.5).

The initial manifest downloads returned 404. A filename correction did not match
the script text, and a subsequent device-specific filename was also absent.
The published checksum list identifies the target-wide manifest. That file was
then downloaded and verified. These failures occurred before any flash.
The target-wide manifest does not enumerate all device-specific driver packages.
Do not treat its package difference as a missing wireless driver.
The stock device image is the tested compatible image.

## Application procedure

1. Confirm direct wired recovery remains available.
2. Verify the staged image hash and run `sysupgrade -T` again.
3. Use `sysupgrade /tmp/wax-25.12.5.bin` with configuration retention enabled.
4. Wait for WDS and SSH to return before any other device change.
5. Verify version, kernel, AU, channel 153/80 MHz, original peer, four-address
   mode, LAN bridge, SSH restrictions, and web access.
6. Compare network, wireless, and Dropbear hashes with the saved baseline.
7. Restore the extra diagnostic packages `bridge`, `ip-bridge`, `ip-full`,
   `iputils-arping`, and `tcpdump` from the new release repositories if absent.
   Do not reinstall old kernel packages. The stock image supplies device drivers.
8. Verify fresh ARP forwarding to the gateway and obtain Air NAS-file and
   authenticated browser checks. Verify remote Tailscale access.
9. Record a later stability check. Do not close it from immediate boot success.

## Recovery

If WDS fails, connect the Air directly to a WAX202 LAN port. Management is
192.168.88.4. Use an unused manual LAN address if DHCP cannot cross the link.
Inspect the failed state before another restart. Keep AU during diagnosis.
If a software rollback is required and management works, use the saved matching
25.12.2 sysupgrade image and its paired private configuration backup.
A return to older firmware reintroduces missing security fixes; use it only for
recovery. Bootloader recovery is a separate last-resort procedure. Do not upload
a factory image through sysupgrade. No rollback flash or recovery restore was tested.
Backups remain on the NAS under the owner's accepted local-only storage policy.


## Applied result: 2026-10-11 Sydney

The owner authorized installation after preparation. Final board, image hash,
and native image test passed. Ran sysupgrade with configuration retention.
The flash SSH connection ended with status 246 during the restart. Do not use
that disconnect status as proof of success. Fresh post-boot evidence verifies
OpenWrt 25.12.5, the original WDS peer, four-address mode, and effective AU.
SSH and HTTP 200 pass. Network, wireless, and Dropbear hashes match preflight.
Restored bridge, ip-bridge, ip-full, iputils-arping, and tcpdump successfully
from the new release repositories. Three fresh gateway ARP probes received
three replies. Overlay has about 19.5 MiB available.
Evidence: private `network-firmware/20261010T143127Z-wax202/upgrade-acceptance.json`,
`restore-tools.stdout`, and `gateway-arp.stdout`.
Owner NAS-file, authenticated browser, and Tailscale acceptance remain pending.
The later stability observation remains open. AXT1800 was not changed.

Owner acceptance after firmware upgrade: the owner confirms NAS-file access,
WAX202 authenticated browser login, and off-LAN Tailscale access all work.
Recorded 2026-10-11 Sydney. Immediate acceptance passes.
Later runtime observation remains open.
