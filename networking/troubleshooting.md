# Network troubleshooting

Use this when a real problem appears. Routine operation needs no capture or
benchmark campaign.

1. Identify the affected device and operation. Note whether Internet, local access,
   or both fail. Check whether other clients work.
2. Check the relevant power, cable, Wi-Fi association, and management page.
3. Compare the affected device with the [known topology](topology.md) and recent changes.
4. Make one justified change. Check the original symptom and ordinary use.
5. Update the backup if a lasting configuration change fixes the problem.

## If the old studio WDS symptom returns

The original fault involved broadcast address resolution across the studio bridge.
Collect its failed state before contacting the NAS or Mac Studio. Their traffic
can hide the fault. Do not reboot or clear neighbour state first.
Use the Air on the main LAN as the independent source.

The [WDS retrospective](wds-retrospective.md) links the failed and passing evidence.
The investigation [capture workflow](https://github.com/volo1st/wds-arp-discovery-debug/blob/master/automation.md)
contains the detailed procedure. Use packet captures only when simpler checks
cannot explain the fault. Separate observed facts from hypotheses.

Bound captures and confirm they stop before deleting files. The old runner
suppresses some stop errors. Review that path before reuse; it is not a routine
maintenance tool. Failed collection attempts do not establish a network cause.
Tool generalization and promotion are outside the home-network baseline.
