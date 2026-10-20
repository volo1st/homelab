# Home network

Updated: 2026-10-20 (Australia/Sydney).
This directory owns the current network design and recovery instructions.
The original wireless distribution system (WDS) reachability fault is closed.
On 2026-10-17, the owner also accepted the swapped access point (AP) layout
as sufficient for normal use.
Retain MT6000 in the kitchen, MT1300 in the study, and the AXT1800–WAX202 WDS pair.
Hardware purchases and further Wi-Fi tuning are deferred.
Firmware acceptance is complete. Recovery and final closeout decisions remain in work package 12.

- [Topology, addressing, naming, and accepted limits](topology.md)
- [Studio WDS backhaul](wds-backhaul-setup.md)
- [Studio OX Wi-Fi: Moo Moo Farm](changes/wax202-ox-wifi.md)
- [Troubleshooting workflow](troubleshooting.md)
- [WDS retrospective and operational acceptance](wds-retrospective.md)
- [Network configuration audit, 2026-10-09](configuration-audit-2026-10-09.md)
- [Network runtime audit, 2026-10-09](runtime-audit-2026-10-09.md)
- [Firmware and advisory review, current checkpoint](firmware-review-2026-10-11.md#current-review--2026-10-17-sydney)
- [MT6000 production update and hostname compatibility](changes/mt6000-firmware.md)
- [OpenWrt web-service security update and results](changes/openwrt-uhttpd-security.md)
- [Network improvement stages](../intial-plan-after-audit.md#network-improvement-stages)
- [Configuration capture and recovery](configuration-backup.md)
- [Reviewed device templates](devices/README.md)
- [Current baseline review and finding dispositions](baseline-review-2026-10-20.md)
- [Source reconciliation](source-reconciliation.md)

## Sources of truth

Use this directory for the retained topology and routine operating notes.
Use [work package 12](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery)
as the only network-audit implementation checklist.
The private [investigation repository](https://github.com/volo1st/wds-arp-discovery-debug)
owns raw WDS evidence, performance logs, hardware research, and investigation tools.
Its local workspace is `/sandbox/vincent/workspace/wds-arp-discovery-debug`.
The 2026-10-16 results and 2026-10-17 owner acceptance are in its local `note.md`
and `plan.md`. Reviewed checkpoints are retained in Git; private recovery
material remains ignored.

The static and runtime audits describe their dated captures. They are not the
current inventory after later changes. Use [topology.md](topology.md) for the
latest recorded software, addresses, and placement. Router-side ports and reviewed essential templates are now recorded.
Physical faceplate labels and actual device restoration remain unverified.

## Routine operating baseline

MikroTik provides the gateway, DHCP, and the five explicit `.lan` device records.
Keep the working DNS-based Air and workspace SSH aliases. The `home.arpa`
migration is deferred. It is not an existing configuration fact.

Retain key-based SSH and browser recovery access. The OpenWrt-based APs have
SSH password login disabled. MikroTik has stronger SSH crypto and SSH/HTTP
source restrictions. HTTP browser management remains accepted for now.
HTTPS migration is deferred. Applied controls and verification limits are in
[management hardening](changes/management-hardening.md),
[SSH authentication](changes/openwrt-ssh-auth.md), and
[management sources](changes/management-sources.md).

Retain the working Tailscale remote-access path through Apple TV. The owner
verified off-LAN SSH, browser access, and DNS during the audit. GL.iNet cloud
access is not required. A separate directly managed WireGuard deployment is
deferred. Tailnet enrollment, access-rule review, and remaining remote-path
checks remain in work package 12. Functional access does not prove a complete
access-policy audit.

Firmware policy accepted on 2026-10-19: use the latest supported production
release for each model and its current firmware family. Use stable GL.iNet
and official OpenWrt releases. Keep MikroTik on its chosen long-term channel.
Exclude beta, testing, and snapshot builds. Check release notes and clear
applicable advisories briefly. Detailed vendor source-to-binary patch mapping
and a vendor response are not baseline closure requirements.
Use post-change checks and owner-confirmed normal use for acceptance.
No fixed 24-hour waiting period is required for this home network.
Investigate again if symptoms occur.
Retain unresolved findings as maintenance notes. Latest firmware does not
prove that every published defect is fixed. Review a clear remaining issue
briefly and record its disposition.

Preserve AU radio settings and the working WDS channel 153 / 80 MHz.
Review the MT1300 local NTP patch after a firmware upgrade.
MT6000 is on vendor 4.11.0 release3. Its retained `mt6000.lan` browser name
requires a local one-host allowlist entry on this build. Review the native
allowlist on a later upgrade; do not copy the old web source over new firmware.
See [the update record](changes/mt6000-firmware.md).
Check a device's exact release, packages, backup, and rollback path before an
approved change. Upgrade the two WDS endpoints separately.
Use [the troubleshooting workflow](troubleshooting.md) if symptoms return.
It requires failed-state evidence before traffic refreshes an idle target.

Pi-hole is reference material. Its deployment, local-domain migration,
Bilibili playback investigation, and new AP purchases are deferred optional
follow-up. They are not baseline closure gates. Resume them when the owner
requests the improvement or a new requirement warrants it.

## Acceptance and recovery limits

The 2026-10-06 packet capture verified broadcast ARP forwarding after the
AXT1800 software replacement. On 2026-10-09, the owner reported several days
of successful idle access, demanding transfers, and NAS file access.
The 2026-10-16 Internet tests and 2026-10-17 acceptance support keeping the
current AP placement. See [the retrospective](wds-retrospective.md) and
[the accepted limits](topology.md#accepted-performance-and-review-trigger).

These reports do not complete later upgrade telemetry, a quantitative loss
test, printer-wake checks, service discovery, or every idle-client path.
Keep each untested acceptance gate explicit in work package 12.
Do not reopen the resolved ARP fault solely because a separate check is pending.

The encrypted NAS-local recovery bundle passed integrity, decryption, and
retrieval checks. The owner accepts that NAS loss also loses that copy.
It is not off-host protection or an actual restore test.
Current templates and the refreshed final-state recovery bundle pass their
integrity and syntax checks. A representative device restore remains untested. See [recovery coverage](configuration-backup.md#current-coverage).
