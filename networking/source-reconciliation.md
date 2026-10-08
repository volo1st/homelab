# Network source reconciliation

Reviewed on 2026-10-07 against the repository baseline
`f0fa9ebba6f127fd8870a8301c2684add560121d`.

This directory remains the canonical network documentation. Older Todoist
material does not establish additional current configuration facts.
No second copy is required in Obsidian.

## Reviewed source material

| Source | Result |
| --- | --- |
| `todoist/6h7CWHW554cVVqj2` | Network-baseline outcome and five comments. WDS investigation is already covered by the topology, backhaul, and troubleshooting documents. Keep reliability and representative tests open |
| `todoist/6f3vj3Rh54wMxpcm` | Documentation outcome and one historical progress comment. Topology, addressing, device roles, and operating procedures already exist here. Naming policy and reproducibility still need confirmation |
| `confluence/30277635` | Live version 5 is unchanged. Broad service and architecture wishlist; no current network configuration. Keep outside this network batch |

The Todoist family also contains Pi-hole, remote-access, local-domain migration,
and playback-diagnosis work. These are separate decisions or unfinished actions.
Their titles and references do not prove deployment or a current network fault.
Do not turn these leads into configuration without a separate decision.
Certification links are study leads outside the operational network boundary.
No uploaded source attachment exists in the reviewed family or Confluence page.
Website previews are incidental metadata.

## Reconciliation decisions

- Retain the current topology and operating documents. No older source supplies
  a verified replacement for their device inventory or forwarding evidence.
- Correct the backhaul runbook's stale statement that device exports are pending.
  The recovery record confirms collection on 2026-10-06. Reviewed templates
  and restore verification remain incomplete.
- Keep the current audit plan as the only work-package checklist. This record
  adds no implementation commitment and closes no acceptance gate.
- Keep current local names and intended domain migration distinct. A task to
  migrate names does not establish that the migration has occurred.
- Keep the separate WDS investigation repository as the owner of raw incident
  evidence and tools.

No source task or Confluence page was changed by this reconciliation.
Private source snapshots and detailed migration evidence remain in the
migration project's ignored workbench.

## NAS source reconciliation — 2026-10-08

Reviewed `confluence/235208708`, version 4, and the research parent
`confluence/30277635`, version 5. Both live versions and empty attachment lists
match the migration inventory. The NAS page is the research page's only child.
This documentation reconciliation has a user-approved exception to package
sequencing. Work package 12 remains active; no recovery gate is closed.

The source's four-NVMe Ubuntu machine, host Samba, container-service preference
and Mac Studio workload are already covered by [standing architecture](../plan.md),
[storage](../host/storage/README.md) and [Samba](../host/samba/README.md).
The old description of four Ethernet ports and two used links is source history,
not a replacement for the [current topology](topology.md).

| Source statement | Reconciled treatment |
| --- | --- |
| TP-Link TL-SG105S-M2; both clients negotiated 2500 Mb/s | Historical model/link report. Current topology records an unmanaged 2.5-Gbit/s switch; exact hardware and port evidence remains separate. |
| Green LEDs mean 2.5G, amber means 1G | Unverified source interpretation. Confirm the exact model manual before using LEDs as a diagnostic rule. |
| Mac/NAS → switch → Wi-Fi bridge → router; 192.168.88.x | Broadly covered by the newer topology. Keep its device roles and captured addresses authoritative. |
| Local ping below 1 ms; iperf3 2.36 Gbps | Historical source-reported measurements. No raw output, test date, endpoint/version or command parameters supplied. Not a new performance acceptance test. |
| Ethernet first in macOS service order, Wi-Fi fallback | Source-described client preference, not a fresh routing observation or verified universal selection rule. |
| SMB 3.1.1, vfs_fruit and AES_128_GMAC | Samba configuration includes fruit; its README already distinguishes observed Mac negotiation from the signing policy. Do not infer a universal macOS algorithm requirement from the old summary. |
| Bonjour/mDNS; nmbd permanently disabled to prevent timeouts | Source explanation, not a newly verified daemon state or causal diagnosis. Existing Samba deployment/check procedures remain authoritative. |

No live host state was inspected for this reconciliation. Quieter hardware,
10 GbE and broader service ideas are retained in the
[research source record](../research-source-reconciliation.md).
No host, service or executable configuration changed.
