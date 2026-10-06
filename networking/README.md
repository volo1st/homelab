# Home network

This directory records the current network and the files needed to rebuild it.
The WDS forwarding test passed on 2026-10-06. The user is running the setup for
several days and will apply sustained load. Long-duration acceptance remains open.

- [Topology and device inventory](topology.md)
- [Studio WDS backhaul](wds-backhaul-setup.md)
- [Troubleshooting workflow](troubleshooting.md)
- [Configuration capture and recovery](configuration-backup.md)

The MikroTik RB760iGS is the main router. The AXT1800 is the wireless
distribution system (WDS) access point. The WAX202 is the WDS station in the
studio. These two devices bridge one Layer 2 local area network (LAN).

## Sources of truth

This directory owns the current network design and recovery instructions.
The private [WDS investigation repository](https://github.com/volo1st/wds-arp-discovery-debug)
owns the detailed incident history, raw evidence, and investigation tools.
Keep the evidence there. Link to the relevant session from these documents.

Current configuration exports for the network devices have not yet been collected
into this directory. The topology uses the investigation inventory. Confirm the
remaining management addresses, firmware versions, and cable ports
during the configuration-capture step.

The user confirmed the current AP locations, MT1300 coverage, and the five Air
SSH aliases. Use `scripts/capture-network-config.sh` for the next capture.

## Acceptance still required

- Observe AXT1800 memory use and WDS reassociations for at least 24 hours.
- Verify NAS and Mac Studio reachability after an idle period.
- Verify name resolution, multicast Domain Name System (mDNS), and file-service discovery.
- Complete a large transfer across the bridge. Record loss and link errors.
- Confirm that the printer does not resume its periodic wake behaviour.
- Verify the saved recovery files and a representative restore procedure.

Record the date, test source, duration, workload, and evidence for each result.
The original failure interval is not known. Record the actual idle interval used.
The captures show background NAS and Mac Studio traffic. Account for keepalive
workarounds when interpreting an idle test.
