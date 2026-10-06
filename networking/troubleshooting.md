# Network troubleshooting workflow

Use this workflow when a device beyond the studio bridge becomes unreachable.
The detailed WDS evidence and tools are in the
[investigation repository](https://github.com/volo1st/wds-arp-discovery-debug).

## Procedure

1. Define the failed operation. Test IP reachability, ARP, name resolution,
   mDNS, and service discovery as separate functions.
2. Select a test source on the other side of the suspect path. For a NAS test,
   use the Air on the main LAN. The development container runs on the NAS;
   its traffic can refresh the target state.
3. Record the time, firmware versions, link roles, neighbour entries, bridge
   ports, forwarding database (FDB), and relevant counters before intervention.
4. Draw the expected frame path. Select capture points on each side of every
   suspect forwarding boundary.
5. Discover runtime interface names. Validate capture tools, temporary storage,
   startup, and cleanup before the target probe.
6. Start simultaneous captures. If the test requires fresh address resolution,
   remove only the selected target entry from the test source after capture starts.
7. Send a small, bounded probe. Compare Ethernet source and destination
   addresses, ARP fields, and timestamps at each boundary.
8. Find the first boundary where the frame disappears or changes. Compare
   observed state with the working baseline.
9. Write one hypothesis, expected result, and rollback procedure. Change one
   variable. Repeat the same probe. Verify rollback independently.
10. If Ethernet captures cannot explain the wireless boundary, use a bounded
    raw IEEE 802.11 capture. Correlate the source and timestamp. Distinguish
    the wireless receiver from address 3, the final Ethernet destination.
11. Verify the fix against the original failing frame path. Then test idle
    behaviour, normal services, sustained load, and recovery.

Keep observed facts, hypotheses, and confirmed conclusions distinct.
Preserve failed setup attempts. A capture failure does not test a hypothesis.
Successful ping with a cached ARP entry does not prove broadcast ARP forwarding.

## Tools that earned their place

| Tool | Purpose | Lesson |
|---|---|---|
| State collector | Firmware, links, neighbours, FDB, wireless state, logs | Collect before the first active probe |
| Session runner | Concurrent captures and a bounded Air probe | Record selected interfaces and each startup stage |
| Credential scan | Gate evidence publication | Review binary captures separately |
| Runtime collectors | Bridge flags, hostapd, filters, driver state | Inspect before changing a suspected control |
| Monitor analyzer | Correlate Ethernet ARP with raw four-address frames | Capture support can differ by driver and direction |
| Firmware workflow | Private backup, verified images, bootstrap, acceptance | Define rollback and pass criteria before flashing |

Use the scripts from the investigation repository. Keep one maintained copy.
Promote a shared tool into the homelab only when its device support, interface
discovery, cleanup, and tests form a useful general contract.

## Capture reliability

- Verify each capture is alive before the probe. Record its interface and error log.
- Bound capture size or duration. Confirm free space first.
- Stop a capture if its process-ID file cannot be written.
- Confirm that captures stopped before deleting their files. Surface stop failures.
- If `df` reports a full temporary filesystem but `du` finds little data,
  inspect open deleted files and their owning processes before cleanup.
- Preserve captures when retrieval fails. Recover them without another target probe.
- Use legacy SCP when the router lacks an SFTP server.
- Use scripts compatible with the Air shell and the router BusyBox shell.

The investigation exposed orphan `tcpdump` processes that held deleted files
open. The free-space guard prevented another capture from starting on the full
filesystem. Cleanup errors must remain visible; the current runner suppresses
some stop errors, so this is a remaining tool-hardening item.

## Avoid misleading conclusions

Known-unicast forwarding can work while broadcast forwarding fails.
An intact FDB does not prove correct wireless frame construction.
Outbound NAS traffic can hide an idle failure.
The transmit monitor produced decisive evidence; the station receive monitor
did not expose the required frames on the tested driver.
A firmware upgrade changes several components. Record the passing behaviour
without assigning the defect to one commit unless source evidence proves it.
