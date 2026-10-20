# OpenWrt uHTTPd security update

Prepared: 2026-10-17. State: **both APs updated; AXT1800 immediate acceptance passed; its observation remains open**.
This procedure covers AXT1800 and WAX202 only. It excludes the GL.iNet
vendor builds. It does not authorize a device connection or installation.
The source assessment is in the [firmware review](../firmware-review-2026-10-11.md#current-review--2026-10-17-sydney).
The implementation checklist remains in work package 12, Stage 5.

## Proposed change

Retain OpenWrt 25.12.5 and the working WDS configuration. Update only
`uhttpd` and its installed matching modules to `2026.08.24~373145f7-r1`.
The saved baseline includes `uhttpd-mod-ubus`. Confirm the installed module
set before preparing the exact transaction.

Start with WAX202. Verify it before proceeding to AXT1800. Do not reboot or
upgrade both WDS endpoints together. Check service activation after package
scripts. Restart only uHTTPd within the approved activation scope if needed.
Expect browser sessions to disconnect briefly. No Wi-Fi, bridge, routing,
address, or SSH change is intended. Stop if the package transaction requires
one of those changes or an unreviewed core-library upgrade.

## Offline evidence

Official feeds publish the candidate for
[AXT1800](https://downloads.openwrt.org/releases/packages-25.12/aarch64_cortex-a53/base/)
and [WAX202](https://downloads.openwrt.org/releases/packages-25.12/mipsel_24kc/base/).
Four candidate APK files were downloaded to the investigation evidence
directory `logs/firmware-review/20261017/packages/`.

| Device | Package | Downloaded bytes | Local SHA-256 |
| --- | --- | ---: | --- |
| AXT1800 | uhttpd | 32380 | `115b1ea9388696c33c3b0cfa8cc74ab849d84965f9caab46e5865c9689379775` |
| AXT1800 | uhttpd-mod-ubus | 9129 | `7de9ec5a1818db13344df936404b1fc291cf46bcca61a63bb44bcab218bec1c7` |
| WAX202 | uhttpd | 30498 | `04264f39f76c21cceaa08e770aa92f607b00268edb6fb42166139fbd262256fb` |
| WAX202 | uhttpd-mod-ubus | 8291 | `2fff4ca2a69327213fc3fa23dfb674a7c8248427b5c385764c94c92b576fca2b` |

These hashes identify local downloads. They are not a completed publisher
signature check. Offline metadata confirms the architecture and candidate
version. Required library names appear in the saved AXT1800 inventory and
WAX202 image manifest: `libubox20260213`, `libblobmsg-json20260213`,
`libjson-script20260213`, `libjson-c5`, and `libubus20251202`.
The plugin links against those library identities. This is a preliminary
compatibility comparison. It does not replace a native dependency solver.

The workspace has no native `apk` tool. No dependency was installed here.
Native repository trust, package simulation, storage, fresh backups, and
firmware image checks subsequently passed on both APs. Direct-file trust
and package-only rollback have the limits recorded below. The owner confirmed
Air SSH and physical access to both APs. The later WAX202 application
checkpoint records its approved fallback and installation. AXT1800 remains
prepared only.

## Approved preflight, before any installation

1. Obtain authorization for SSH preflight and preparation on the two APs.
   Preparation can write temporary backups, downloads, and package indexes.
   It must not install a package, restart a service, or change network settings.
2. Confirm OpenWrt version, target, architecture, installed package versions,
   installed uHTTPd modules, and current feed URLs. Stop on a mismatch.
3. Record time, free RAM, `/tmp` space, and overlay space. Account for download,
   unpacking, and rollback storage. Stop if storage is insufficient.
4. Verify key SSH recovery from the Air. Keep that session available.
   Confirm physical access to the device and its wired recovery path.
5. Create and inspect a fresh private configuration backup. Preserve the
   package world, uHTTPd configuration, enabled state, and extra custom files.
   Record hashes of wireless, network, DHCP, firewall, SSH, and rpcd settings.
6. Prepare the paired original packages and dependencies for rollback.
   If these cannot be obtained, stop before installation. Prepare the original
   firmware, paired configuration, extra package set, and physical recovery
   instead. Obtain explicit acceptance of that longer firmware-recovery
   fallback. A file-only binary copy is not a complete package rollback.
7. Refresh only the configured official 25.12 feed metadata. Use native APK
   trust keys to verify signatures. Do not bypass trust or mix feed branches.
8. Simulate a world-preserving transaction. Include every installed uHTTPd
   module. Confirm exact candidate versions in its output. Save the complete
   dependency and removal plan. Stop on package removals, core-library changes,
   or an unexpected restart.
9. Record exact files, verified hashes, installation command, rollback command,
   service reload, expected downtime, and acceptance steps in the evidence.
10. Review the completed preflight. Obtain approval for the exact installation.

## Application and acceptance

1. Apply the approved transaction on WAX202 only. Do not run a blanket upgrade.
2. Verify installed versions and the running executable hash. If the old
   executable remains active, restart uHTTPd within the approved scope.
3. Use the Air to verify authenticated browser access and a fresh SSH login.
4. Verify the WDS peer, four-address mode, AU, channel 153 / 80 MHz, and bridge
   role. Compare saved network and wireless hashes. Record any change.
5. Collect WDS forwarding evidence before contacting an idle NAS or Mac Studio.
   Verify gateway ARP and representative client traffic only within approval.
6. Verify required off-LAN Tailscale management from a representative client.
7. Record 24 hours of normal use and relevant restart or error evidence.
8. Proceed to AXT1800 only after WAX202 passes. Repeat the same acceptance.
9. Refresh private recovery records after both devices pass. Preserve the
   original firmware and package baseline until the observation period ends.

Do not run published denial-of-service or memory-corruption proofs of concept
on the live network. Use version, source, configuration, and normal-use
evidence for this change. The separate representative-restore gate stays open.

## Rollback

The original APKs are unavailable. Do not attempt a package-only downgrade.
If browser access fails while SSH works, collect the failure evidence. Use
the original 25.12.5 sysupgrade image and paired private backup only within
an approved firmware-recovery scope. If SSH or WDS fails, stop the second
device change. Use the prepared wired or bootloader recovery path within
that scope. A firmware recovery must restore the intended packages and
custom files as well as UCI. Record the failure and repeat WDS acceptance.
No package rollback, fallback flash, or restore was tested in this review.

## Native preflight checkpoint — 2026-10-17

The owner authorized SSH preflight and temporary preparation on both APs.
Technical checks passed. At this checkpoint, installation was not yet
authorized. The later WAX202 application checkpoint supersedes that state.
The owner confirmed Air SSH and physical access to both APs.
The proposed firmware-recovery fallback below also needs acceptance before
installation. No actual recovery or restore test was run.

| Check | WAX202 | AXT1800 |
| --- | --- | --- |
| Current firmware | 25.12.5, r33051-f5dae5ece4 | 25.12.5, r33051-f5dae5ece4 |
| Target / package architecture | ramips/mt7621 / mipsel_24kc | qualcommax/ipq60xx / aarch64_cortex-a53 |
| Installed uHTTPd and ubus module | 2026.06.16~7b1bec45-r1 | 2026.06.16~7b1bec45-r1 |
| Native signed-index refresh | Pass, existing release key | Pass, existing release key |
| Native fetch and candidate hashes | Pass, both packages | Pass, both packages |
| Simulated change | Two package upgrades only | Two package upgrades only |
| Configuration, package world, and installed packages after checks | Unchanged | Unchanged |
| Web-service process after checks | Same running process | Same running process |
| Free overlay space | 19,968 KiB | 83,500 KiB |
| Free temporary space after image staging | 213,096 KiB | 194,836 KiB |
| Fresh configuration backup | 35 members, required files present | 35 members, required files present |
| Original 25.12.5 image checksum and native `sysupgrade -T` | Pass | Pass |

The signed base-feed URLs came from each device's existing release feed
configuration. Temporary repository lists and caches stayed below
`/tmp/uhttpd-preflight-20261017T023118Z`. Persistent feed configuration and
trust keys were not changed. The installation must recheck these files and
versions; do not assume a historical temporary path still exists.

OpenWrt's [key documentation](https://openwrt.org/docs/guide-user/security/signatures)
defines the APK index trust path. Native index verification passed with the
existing `openwrt-25.12.pem`. Native package fetch through that trusted index
passed. Each fetched file matched the earlier local SHA-256 value above.
Direct `apk verify` of the standalone files reported `UNTRUSTED signature`.
That failed direct-file path remains evidence. Do not install those files
with a trust bypass. The proposed transaction uses the verified repository
by package name. No key was added and no trust override was used.

The first fetch attempt incorrectly supplied version constraints to a
package-name query. A corrected repository fetch succeeded. A simulation
with networking disabled masked uncached repository packages. The corrected
simulation used the verified repository normally, while keeping simulation,
script suppression, and hook suppression enabled. Inspect section status,
not only the outer SSH exit status. An earlier wrapper lost the transaction
exit status; the final capture preserves it and all required sections pass.
A failed cache archive was also preserved and replaced by a complete copy.

The final native simulation used this transaction shape:

```sh
apk --logfile=no --cache-dir "$task_stage/feed-cache" \
  --repositories-file "$task_stage/repositories.list" --timeout 20 \
  fix --simulate --upgrade --scripts=no --commit-hooks=no \
  uhttpd uhttpd-mod-ubus
```

`fix --upgrade` preserves APK world constraints. A version-pinned `add`
transaction would change those constraints, so it is not the proposed
installation command. The final solver selected only the two upgrades
from `2026.06.16~7b1bec45-r1` to `2026.08.24~373145f7-r1`.
It selected no package removal or library upgrade. An installation would
enable normal package scripts so the web service can reload. It still needs
approval after recovery checks. Re-run the simulation before installation;
stop if any selected version, dependency, or removal differs.

### Recovery limitation and proposed fallback

The exact original APK files were not cached. Both original uHTTPd URLs
returned HTTP 404. A package-only downgrade is therefore not prepared.
The copied binaries and package database are diagnostic evidence, not a
complete or approved package rollback.

Prepared original OpenWrt 25.12.5 sysupgrade images match their published
checksum records and pass native image compatibility checks:

| Device | Bytes | SHA-256 |
| --- | ---: | --- |
| WAX202 | 7,997,987 | `ef3a66ea09ec2500b3f9f4572be235f63fc447e90517a04ca341a681eb894ac1` |
| AXT1800 | 12,646,693 | `fea31a77a9f84089badc4ff89f8751f4e73e574a4490adede69a8c18c9b04ef9` |

Proposed fallback: restore the original firmware with the fresh paired
configuration and recorded extra package/custom-file set. This requires
more downtime than a package downgrade. Browser-only failure with working
SSH can use the native recovery route; loss of SSH needs physical recovery.
The previous AXT1800 factory UBI and WAX202 factory image remain available
for their device-specific physical recovery methods. Do not substitute a
factory image for a sysupgrade image. No flash, reboot, or restore occurred.
The owner confirmed physical access and Air SSH. Acceptance of this fallback
and approval for the WAX202 installation remain required. Actual recovery
remains untested.

A private WAX202 recovery bundle is also on the unaffected AXT1800 at
`/tmp/uhttpd-preflight-20261017T023118Z/wax202-recovery-bundle.tar`.
It contains the fresh configuration, saved package state and inventory,
and original sysupgrade and factory images. Its native SHA-256 matches the
local bundle. The Air can retrieve it from AXT1800 if WAX202 loses the NAS
path. Recheck this temporary copy before installation. The local evidence
record is `peer-recovery-20261017T104800Z`. AXT1800 had 177,164 KiB free
in `/tmp` after staging. Its network, wireless, package-world, and uHTTPd
binary hashes still match the initial inventory.

Private evidence is in the investigation workspace:
`backups/uhttpd-preflight/20261017T014237Z-retry/`.
It includes inventory, fresh configuration archives, package state, hashes,
signed feed caches, successful simulations, failed attempts, and recovery
image checks. `feed-check-20261017T040254Z` records the exact pinned simulation.
`recovery-check-20261017T103634Z` records the world-preserving simulation and
native image checks. All configuration hashes, installed package versions,
and web-service processes still match the initial inventory. Private backups
remain ignored by Git. No NAS or Mac Studio connection or active probe ran.

## WAX202 application checkpoint — 2026-10-17

The owner approved the WAX202 two-package update, web-service activation,
and original-firmware recovery if needed. AXT1800 installation was excluded.
Fresh native checks repeated the signed-index verification, candidate fetch,
exact two-package simulation, original image test, and configuration backup.
All existing package versions and configuration hashes matched the preflight.
The recovery bundle on AXT1800 still matched its recorded hash.

The approved command ran on WAX202 through SSH:

```sh
apk --logfile=no --cache-dir "$task_stage/feed-cache" \
  --repositories-file "$task_stage/repositories.list" --timeout 20 \
  fix --upgrade uhttpd uhttpd-mod-ubus
```

Both packages changed from `2026.06.16~7b1bec45-r1` to
`2026.08.24~373145f7-r1`. No other installed package changed. APK world and
every existing configuration file kept their hashes. APK saved the new
default as `/etc/config/uhttpd.apk-new`; the active configuration was retained.
The local default-file comparison is preserved with the private evidence.

Package scripts left PID 1701 running the deleted old executable. One approved
`/etc/init.d/uhttpd restart` activated the update. Fresh SSH then found PID
11198 running the new executable. Its SHA-256 matched `/usr/sbin/uhttpd`.
The boot ID did not change. No device reboot or firmware recovery occurred.

Technical verification passed at `2026-10-17T11:10:47Z` (22:10 Sydney).
The WDS peer stayed associated and authorized. Four-address mode, AU,
channel 153, 80 MHz width, bridge membership, and all existing network
configuration hashes passed. LuCI returned its unauthenticated login page
with HTTP 403 and `x-luci-login-required: yes`. This verifies the login
challenge, not authenticated client acceptance.

The owner confirmed fresh Air SSH, authenticated browser access, and off-LAN
Tailscale management after the change. Immediate client acceptance passed.
The 24-hour normal-use gate remains open. Review it no earlier than
2026-10-18 22:11 Sydney. AXT1800 still has the older package pair. Do not
update it before WAX202 acceptance and a separate approved transaction.
Vendor patch mapping and actual restore verification remain open.

Private evidence is under the investigation workspace at
`backups/uhttpd-update/wax202-20261017T110757Z/`. It contains the fresh backup,
commands, raw output, package/configuration comparisons, WDS state, HTTP
response, and `technical-postcheck.json`. Preserve the failed local validation
results: a broad text check rejected APK's new-default-file message; the
device had no `diff` tool; and a hash check initially included the new
inactive `.apk-new` file. Corrected local checks passed. No installation command
was repeated. No NAS or Mac Studio connection, network configuration change,
or exploit test ran.

## WAX202 observation and AXT1800 preparation — 2026-10-19 Sydney

The owner reports no network issues over the last day. Fresh WAX202 state at
`2026-10-18T13:10:05Z` (00:10 Sydney) is about 26 hours after the verified
web-service activation. The device boot ID and uHTTPd PID 11198 are unchanged.
The running executable matches the updated binary. WDS association start
time, packages, and accepted post-OX configuration are unchanged. OX's AP
remains enabled. Retained logs contain no crash or out-of-memory match.
The logs are ring buffers, not a complete 24-hour recording. These results
and the owner report pass WAX202's web-service observation gate. They do not
close the final observation after later changes or the actual-restore gate.

AXT1800 preparation passed at `2026-10-18T14:13:45Z` (01:13 Sydney).
The existing key verified the signed index. Native fetch hashes match the
recorded candidates. The world-preserving simulation selects only uHTTPd and
its ubus module, from `2026.06.16~7b1bec45-r1` to
`2026.08.24~373145f7-r1`. Installed packages, configuration, package world,
and the running web-service process still match the earlier inventory.
Overlay space is 83,500 KiB free. The fresh backup has 35 members and the
required configuration files. The copied backup hash matches the device.
The original 25.12.5 sysupgrade image matches its recorded official checksum
and passes native `sysupgrade -T` again.

The first AXT1800 check stopped on missing `bridge` (exit 127). The successful
retry used bridge membership from sysfs. Both attempts remain private evidence.
No utility was installed. No package or service change ran.

AXT1800's original sysupgrade and factory images, fresh configuration, package
state, and current inventory are in a private bundle on WAX202:
`/tmp/uhttpd-preflight-20261017T023118Z/axt1800-recovery-bundle.tar`.
Its native hash matches the local bundle. Recovery can use the studio-side
WAX202 path if the AXT1800 link fails. Physical access and Air SSH were
previously confirmed by the owner. Actual firmware recovery is untested.
Package-only rollback remains unprepared because the old APK files were
unavailable. Retain the firmware/configuration recovery fallback.

Next transaction: use the world-preserving installation command above on
AXT1800 only. Verify the running executable after package scripts. Restart
only uHTTPd if the old process remains. Recheck staged files and simulation
immediately before installation. Stop if the selected packages change.
Obtain explicit approval for AXT1800's installation, web-service activation,
and firmware/configuration recovery if needed. The earlier WAX202 approval
does not cover this transaction. No AXT1800 installation has run.

Private evidence roots in the investigation workspace:
`backups/network-next/20261018T131005Z/` and
`backups/network-next/20261018T141345Z/`. The first holds WAX202 observation
and the partial AXT1800 check. The second holds the successful AXT1800
preflight, fresh backup, and peer recovery bundle. These files stay out of Git.

## AXT1800 application checkpoint — 2026-10-19 Sydney

The owner approved the two-package installation, web-service activation,
and prepared firmware/configuration recovery if needed. Immediate checks
revalidated the existing signed release index, fetched candidate hashes,
exact solver output, paired configuration backup, original image, and the
recovery bundle on WAX202. No trust key or persistent feed changed.

The approved world-preserving `apk fix --upgrade uhttpd uhttpd-mod-ubus`
transaction ran once on AXT1800. It used the verified temporary base-feed
list and cache. Only the two expected packages changed. Package scripts
started an intermediate process. The activation guard then selected one
explicit uHTTPd restart before final verification. That guard checks for an
old executable or a deleted module mapping. No network service restart,
device reboot, or firmware flash ran.

| Check | Result |
| --- | --- |
| uHTTPd and ubus module | Both `2026.08.24~373145f7-r1` |
| Other installed packages | Unchanged |
| Existing configuration and APK world hashes | Unchanged |
| New default configuration | Inactive `/etc/config/uhttpd.apk-new`; active file retained |
| Running executable | New PID 26820; SHA-256 matches installed binary |
| Boot ID | Unchanged |
| Wireless runtime and WDS association start time | Unchanged |
| WDS role, AU, channel 153, 80 MHz, four-address mode | Pass |
| Fresh SSH and LuCI login challenge | Pass; expected HTTP 403 with login-required header |
| Owner's Air SSH, browser login, and off-LAN Tailscale checks | All three pass |

Technical verification passed at `2026-10-18T14:26:49Z` (01:26 on October 19
Sydney). Review 24 hours of normal use no earlier than **2026-10-20 01:27
Sydney**. Keep that gate open. WAX202's earlier observation remains accepted.
The final network observation after later changes, vendor patch mapping,
actual restore, and final-state recovery capture remain separate open work.

The first station query on the base AP returned an empty result with exit
zero. The WDS client belongs to `phy0-ap0.sta1`. A separate query verified
its authorized association before application. Both results remain evidence.
No installation was attempted before that check passed.

Private evidence is in the investigation workspace at
`backups/uhttpd-update/axt1800-20261018T142508Z/`. It contains the native
commands, raw results, corrected preflight, paired backup, package comparison,
service activation, HTTP response, and owner acceptance. Recovery was not
needed. Preserve the original firmware and paired configuration until the
observation ends. No NAS or Mac Studio connection or exploit test ran.

## AXT1800 observation acceptance — 2026-10-20 Sydney

Fresh read-only checks passed at `2026-10-20T02:53:00Z`, 13:53 Sydney,
36.44 hours after the immediate post-update verification. The owner reports
no other network issues. The separate MT6000 hostname problem was fixed in
its own change; it does not establish an AXT1800 regression.

The same boot ID, uHTTPd PID 26820, running binary/module hashes, package
set, configuration/APK-world hashes, and wireless runtime remain present.
The WDS station is authenticated, authorized, and associated. Its association
start time is unchanged. LuCI returns its expected HTTP 403 login challenge,
login-required header, and login form. Retained logs contain no matched
uHTTPd crash, out-of-memory kill, or kernel panic. The ring buffer is not a
continuous 24-hour recording. No installation, restart, reboot, or network
configuration change ran during observation collection.

AXT1800's web-service observation passes. WAX202's earlier observation
remains accepted. The two-endpoint uHTTPd remediation gate is complete.
The final network observation after other changes, MT6000 observation,
actual restore, and final-state recovery coverage remain separate gates.
Vendor patch research remains deferred under the owner's maintenance policy.

Private evidence: investigation `backups/axt1800-observation/`.
The public result summary is `logs/firmware-review/20261020-axt1800-observation/summary.json`.
No NAS or Mac Studio connection, ARP/ping probe, throughput test, or exploit
test ran. Only AXT1800 SSH and its unauthenticated LuCI page request were used.
