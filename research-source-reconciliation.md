# Home-lab research source record

Reviewed on 2026-10-08. Sources: `confluence/30277635`, version 5, and
`confluence/235208708`, version 4. These are historical ideas and source leads,
not deployed configuration, purchase decisions or a second implementation plan.

## Source intent and existing ownership

The research page described changed workflows with AI and the Apple ecosystem.
It wanted a reproducible system that could be torn down and restarted with
minimal downtime, and described atomic operation as a goal. These statements
do not prove cluster implementation, tested recovery or a downtime guarantee.

The repository already owns reproducibility and recovery. Use the
[standing plan](plan.md), [audit work plan](intial-plan-after-audit.md) and
[recovery runbook](host/recovery/README.md) for accepted policies and outcomes.
The audit work plan remains the only audit checklist. The user approved this
bounded documentation reconciliation while package 12 remains active.

## Ideas preserved from the sources

| Source idea | Boundary |
| --- | --- |
| NAS in its best form; possibly a new file-server box | Existing NAS implementation and recovery docs own current configuration. No hardware replacement decision. |
| Quieter NAS or 10 GbE | Future questions from the NAS page. No purchase or performance requirement. |
| AirPlay, music and video streaming | Service leads. This record does not establish what is installed or require a new deployment. |
| Photo backup with indexing | Existing [iPhone-sync specification](services/iphone-sync/iphone-sync-spec.md) owns safe publication and the optional Immich external-library boundary. It remains incomplete; indexing is not proof of backup or safe deletion. |
| Thread/Matter and home automation | Unbuilt exploration leads, not an approved automation architecture. See the [historical adviser source record](home-automation-source-reconciliation.md). |
| Mixed ARM/x86, virtual-machine/bare-metal nodes, old and new hardware | Historical architecture ideas. No Kubernetes or cluster design selected. |
| End-to-end coding ecosystem, public website/server and private-cloud access | Broad outcomes without a specified implementation. Keep existing security and service decisions authoritative. |

## Original reference leads — unreviewed

The 12 source URLs below preserve the original research trail. They were not
opened or evaluated in this reconciliation. Demo links are examples, not
proof of local installation or endorsement. Revisit a lead only for a defined
future work package; this list creates no automatic task or research commitment.

- [Mixed VM/bare-metal Kubernetes article](https://www.linkedin.com/pulse/possible-deploy-kubernetes-both-vms-bare-metal-servers-adnan-drina-g3ree)
- [Awesome Selfhosted](https://awesome-selfhosted.net/)
- [Immich demo](https://demo.immich.app/photos)
- [PhotoPrism people demo](https://demo.photoprism.app/library/people/new)
- [CyberChef](https://gchq.github.io/CyberChef/)
- [IT Tools](https://it-tools.tech/)
- [PairDrop](https://pairdrop.net/)
- [Pi-hole](https://pi-hole.net/)
- [Tailscale](https://tailscale.com/)
- [Awesome Homelab](https://www.awesome-homelab.com/)
- [PhotoPrism](https://www.photoprism.app/)
- [Stirling PDF](https://www.stirlingpdf.com/)
