# Home network

Updated: 2026-10-20 (Australia/Sydney). The home-network baseline is complete.
The owner asked to keep its scope practical. Everyday use, basic security,
production firmware, and current configuration backups have supporting evidence.

Keep MT6000 in the kitchen and MT1300 in the study. Keep the AXT1800–WAX202
wireless distribution system (WDS) bridge on channel 153 / 80 MHz.
OX uses Moo Moo Farm on WAX202. Current coverage and the study path limit
are accepted. No hardware purchase or further tuning is needed now.

- [Topology, addresses, and accepted performance](topology.md)
- [Configuration backups and recovery](configuration-backup.md)
- [Device templates and firmware hashes](devices/README.md)
- [Troubleshooting](troubleshooting.md)
- [Completed baseline and scope](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery)
- [Evidence and finding dispositions](baseline-review-2026-10-20.md)

## Routine maintenance

Use the latest supported production release within each device's current
firmware family. Keep MikroTik on long-term. Before an update, save configuration,
check the relevant release notes, and review the two local fixes below.
Update one device at a time. Check the affected service and ordinary use afterward.
No fixed waiting period or complete test rerun is required.

Retain AU radio settings, key-based SSH, current management restrictions,
working browser access, and the existing `.lan` names. HTTP management keeps
its recorded limit. Use [the firmware record](firmware-review-2026-10-11.md)
and [applied changes](changes/management-hardening.md) when a change is needed.
Detailed patch mapping and broad audits are not routine maintenance steps.

Two local fixes need review after a firmware update:

- [MT1300 time synchronization](changes/mt1300-time.md).
- [MT6000 browser hostname](changes/mt6000-firmware.md#browser-hostname-compatibility).

## Remote access

Keep the working Tailscale path through Apple TV. Local and off-LAN access
passed the owner's checks. It meets the present need without another VPN.
The intended user is the owner on trusted devices. This design trusts the LAN,
tailnet account, and enrolled devices. A complete account-policy or vendor-cloud
audit has not run. Revisit access when users, enrollment, exposure, or needs change.
A separate WireGuard deployment remains optional research.

## Scope and records

There is no remaining required baseline work. Live restore drills, full policy
audits, cable labels, repeated benchmarks, and diagnostic-tool promotion are
outside this home project. Investigate actual symptoms or requested changes.
Pi-hole, `home.arpa`, Bilibili investigation, and hardware upgrades remain optional.

Backups pass integrity and decryption checks. Actual device restoration remains
untested. The owner previously accepted NAS-local-only storage; NAS loss also
loses that recovery copy. Keep these facts in the recovery notes.

This directory owns the operating reference. The investigation repository owns
[WDS evidence and incident tools](https://github.com/volo1st/wds-arp-discovery-debug).
The dated [configuration audit](configuration-audit-2026-10-09.md),
[runtime audit](runtime-audit-2026-10-09.md), [retrospective](wds-retrospective.md),
and [source reconciliation](source-reconciliation.md) remain supporting history.
