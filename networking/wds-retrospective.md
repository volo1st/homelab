# WDS fault retrospective

Recorded on 2026-10-09. The operational fault is closed. Configuration recovery
work remains part of homelab work package 12.

## Result and evidence

Main-LAN clients could not reliably reach studio hosts across the wireless
distribution system (WDS) bridge. A fresh Address Resolution Protocol (ARP)
request failed before an IP echo request could reach the NAS.

The old AXT1800 stack changed a broadcast destination to the WAX202 station
address during wireless transmission. The WAX202 did not forward that frame
to the studio Ethernet port. Official OpenWrt 25.12.5 on the AXT1800 preserved
the broadcast destination and restored the request and reply path.

- [Failed transmit capture, 2026-09-25](https://github.com/volo1st/wds-arp-discovery-debug/tree/master/evidence/20260925T113535Z-axt-monitor-nas)
- [Passing controlled capture, 2026-10-06](https://github.com/volo1st/wds-arp-discovery-debug/tree/master/evidence/20261006T081915Z-openwrt-25.12.5-monitor-nas)
- [Investigation plan and session log](https://github.com/volo1st/wds-arp-discovery-debug/blob/master/plan.md)

On 2026-10-09, the user reported several days without an issue. Tests included
several hundred gigabytes of movie downloads, idle access from multiple devices
through different access points and networks including Tailscale, many NAS file
accesses, and a large single-file transfer through the WDS bridge. The reported
rate exceeded `60M/s` on a 500-Mbit/s Internet connection. The unit and measurement
method were not supplied. Do not treat this as a measured backhaul limit.
These results are a user report in the workspace conversation, not new captures.

Together, the controlled evidence and operational report support closure.
The exact defective commit or component in the old software is unconfirmed.
Separate discovery, printer-wake, workaround-removal, and recovery checks were
not explicitly reported. Do not claim that they passed.

## What worked

- We defined the failed operation. ARP failure explained why direct IP access failed.
- We verified the topology. The original AP and station labels were reversed.
- We selected the Air as the test source. The development container runs on the
  NAS and can refresh the state under investigation.
- We collected failed-state evidence before target contact or configuration changes.
- We compared the same frame at four forwarding points. This located the first
  changed destination instead of attributing the failure to a host or an ageing table.
- We wrote an expected result for each controlled change. Bridge conversion and
  hostapd isolation tests failed to restore forwarding. We retained those results.
- We used the AXT1800 transmit monitor when Ethernet captures left a wireless
  boundary unresolved. Address 3 showed the wrong destination before reception.
- We defined firmware backup, checksum, rollback, and acceptance gates before
  the software test. We repeated the original frame test after the upgrade.
- We followed the controlled result with several days of normal use and load tests.

## What cost time and what to change

| Event | Effect on the investigation | Procedure for the next incident |
|---|---|---|
| Initial role labels were reversed | Early descriptions named the wrong side | Verify roles from runtime interface and association state |
| macOS SCP selected SFTP, which the router lacked | Capture retrieval failed after the probe | Check transfer support before testing; recover saved captures without another probe |
| Local shell expansion and a BusyBox sysfs write failed | Controlled tests stopped before a useful probe | Test local and remote shell boundaries with fixtures; record write status and read the value back |
| Remote capture startup returned an unclear failure | Several retries had no useful hypothesis result | Record each startup stage, command status, process ID, interface, and error log |
| Orphan captures held deleted files open | Router temporary storage filled | Bound captures; check free space; confirm process exit before removing files |
| WAX202 receive monitor omitted the needed frames | The raw capture could not answer the question | Verify direction support; preserve an inconclusive result; select the transmit observation point |
| Firmware changed interface names and types | The finalizer and capture runner selected the wrong interface | Discover live bridge ports and dynamic `AP/VLAN` interfaces |
| A passing ping used an existing ARP entry | The first acceptance session did not test broadcast forwarding | Start captures before clearing the selected source ARP entry |

A test setup failure does not reject a network hypothesis. A working unicast path
does not prove broadcast forwarding. A relevant upstream fix is a lead, not proof
that one commit caused this incident.

## Reusable procedure and tools

Use [troubleshooting.md](troubleshooting.md) for the ordered incident procedure.
Use [configuration-backup.md](configuration-backup.md) for private exports and
recovery requirements. Keep raw incident evidence and WDS-specific scripts in the
[investigation repository](https://github.com/volo1st/wds-arp-discovery-debug).
Keep one maintained copy of each tool.

| Capability | Maintained source | Reuse decision |
|---|---|---|
| Inventory and read-only preflight | `scripts/preflight.sh` in the investigation repo | Use before a planned session; connection mode is explicit |
| State and runtime collectors | `scripts/collect-wds-state.sh`, `collect-wds-config.sh`, `collect-wds-wireless-runtime.sh`, `collect-wds-filter-state.sh` there | Reuse for this bridge; adapt allowlists for other devices |
| Capture, bounded probe, retrieval, rollback | `scripts/run-wds-test.sh` and `scripts/air-probe.sh` there | Keep device-specific orchestration there until cleanup is hardened |
| Four-address correlation | `scripts/analyze-wds-monitor.py` there | Use when the radio boundary is unresolved; verify capture direction support |
| Evidence scan and publication | `scripts/check-evidence.sh` and `scripts/publish-evidence.sh` there | Scan before committing evidence; review binary captures separately |
| Firmware preparation and bootstrap | `scripts/prepare-axt-upgrade.sh`, `fetch-axt-firmware.sh`, `bootstrap-axt-openwrt.sh` there | Keep tied to the supported AXT1800 layout and firmware gates |
| Private network configuration capture | `scripts/capture-network-config.sh` in homelab | Already promoted; supports macOS and Linux and keeps private exports ignored |

## Follow-up decisions

Record actionable work only in homelab's canonical work package 12. The following
items explain the scope; they are not a second task list.

Harden the investigation capture runner before promoting it as a shared homelab
tool. It currently suppresses some stop errors. Make cleanup failure visible.
Keep process identity and artifact ownership explicit. Use local mock tests for
startup failure, process-ID-file failure, interrupted collection, failed retrieval,
and stop failure. Retain Bash 3.2 and BusyBox compatibility checks.

For later acceptance records, record exact duration, idle interval, test source,
workaround state, transfer size, units, and measurement point. Record observed
service behaviour separately from packet counters. These details improve future
comparisons; they do not invalidate the current operational acceptance.

Complete the existing private recovery-copy, template, and restore-verification
work. Operational stability does not prove recoverability. Reopen the WDS fault
only if symptoms return. Do not repeat disruptive tests solely to finish historical
diagnostic checkboxes.
