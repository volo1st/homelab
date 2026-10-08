# Home network

This directory records the current network and the files needed to rebuild it.
The WDS forwarding test passed on 2026-10-06. On 2026-10-09, the user reported
several days without an issue during idle access and demanding transfers.
The operational WDS fault is closed. Recovery verification remains open.

- [Topology and device inventory](topology.md)
- [Studio WDS backhaul](wds-backhaul-setup.md)
- [Troubleshooting workflow](troubleshooting.md)
- [WDS retrospective and operational acceptance](wds-retrospective.md)
- [Configuration capture and recovery](configuration-backup.md)
- [Source reconciliation](source-reconciliation.md)

The MikroTik RB760iGS is the main router. The AXT1800 is the wireless
distribution system (WDS) access point. The WAX202 is the WDS station in the
studio. These two devices bridge one Layer 2 local area network (LAN).

## Sources of truth

This directory owns the current network design and recovery instructions.
The private [WDS investigation repository](https://github.com/volo1st/wds-arp-discovery-debug)
owns the detailed incident history, raw evidence, and investigation tools.
Keep the evidence there. Link to the relevant session from these documents.

Current configurations were collected from all five network devices on 2026-10-06
from the Linux development container. The private capture is under ignored
`secrets/local/network/20261006T103815Z/`. The topology now includes verified
OpenWrt management addresses and software base versions. Reviewed native
templates, exact cable ports, and restore verification remain pending.

The user confirmed the current AP locations, MT1300 coverage, and the five Air
SSH aliases. Use `scripts/capture-network-config.sh` for later captures from
macOS or Linux.

## Operational acceptance and remaining verification

See [the retrospective](wds-retrospective.md) for the reported workloads and
evidence limits. Idle access, sustained downloads, NAS file access, and a large
transfer passed in user-reported operation. The following checks remain unverified;
they do not reopen the resolved forwarding fault.

- Observe AXT1800 memory use and WDS reassociations for at least 24 hours.
- Verify NAS and Mac Studio reachability after an idle period.
- Verify name resolution, multicast Domain Name System (mDNS), and file-service discovery.
- Record packet loss and link errors during a measured transfer.
- Confirm that the printer does not resume its periodic wake behaviour.
- Verify the saved recovery files and a representative restore procedure.

Record the date, test source, duration, workload, and evidence for each result.
The original failure interval is not known. Record the actual idle interval used.
The captures show background NAS and Mac Studio traffic. Account for keepalive
workarounds when interpreting an idle test.
