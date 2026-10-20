# Home baseline review: 2026-10-20

This record extends the dated configuration and runtime audits. It does not
rewrite their findings. Work package 12 remains the only action checklist.
The owner accepts normal home use without a fixed waiting period.
The later 20 October scope correction removes unnecessary closure procedures.
The home baseline is complete: everyday access, basic security corrections,
production firmware, and current private backups have supporting evidence.
Untested items below remain facts. They are outside the revised completion criteria.

## Evidence

Fresh private configuration: `secrets/local/network/20261020T031655Z/`.
All five collections completed. Source hashes and four native archives pass.
Fresh private runtime: `secrets/local/network-runtime/20261020T031653Z/`.
All SSH transports completed. Per-command omissions are listed below.
Supplement: `secrets/local/network-closeout/20261020T031655Z/`.
It contains the two custom files and passive MikroTik port/key/certificate state.

The investigation workspace retains template parse results under
`backups/network-closeout/template-checks/`. All 33 AP templates pass native
parsing from temporary directories. No active configuration changed.
The five [device directories](devices/README.md) hold reviewed templates,
package inventories, image hashes, dependencies, and recovery instructions.

The refreshed encrypted bundle is
`/sandbox/vincent/home_network_backup/20261020T033118Z/`.
It contains current configurations, runtime evidence, paired firmware,
web-service packages, both custom fixes, and the encrypted MikroTik backup.
Two MikroTik downloads match. Outer decryption and plaintext hashes match.
The bundle has 145 members. Actual device restoration remains untested.
The approved NAS-local-only storage limit remains unchanged.

## Findings and disposition

| Finding | Current disposition and supporting evidence |
|---|---|
| N01 address overlap | Corrected. AXT1800 is static `.5` outside `.100–.199`. Fresh export agrees with the accepted address change. |
| N02 radio country | Corrected. AU settings and earlier native runtime/reboot checks pass. Fresh templates retain AU. This is not an emissions test. |
| N03 update channel | Corrected. MikroTik retains long-term and RouterOS/RouterBOOT 7.23.8. |
| N04 SSH passwords | Corrected. Four AP templates retain disabled SSH password authentication. Fresh keyed SSH passed. Private browser recovery remains. |
| N05 HTTP management | Retained under the owner's prior acceptance. HTTPS remains deferred. |
| N06 management trust | Applied MikroTik service restrictions and stronger SSH remain. The LAN is still trusted broadly. Tailnet policy and vendor-cloud enrollment are not fully audited. Functional off-LAN access passed by owner report. No complete security clearance is claimed. |
| N07 recovery | Refreshed and integrity-checked. Essential templates pass native parsing. Actual restore, replacement hardware, and bootloader recovery remain untested. NAS-local-only storage is accepted. |
| N08 firmware coverage | Production maintenance and update acceptance complete. Detailed vendor patch mapping is deferred by owner decision. Latest release does not prove every advisory fixed. |
| N09 residual routing | Reviewed. WAX202 WAN/WAN6 are down with no address or second IPv4 default route. Keep its separate WAN jack unused. Vendor AP mode is retained on MT6000/MT1300; primary WAN/WAN6 are disabled. Their residual uplinks are down. No configuration change is needed for the present cable roles. Recheck before using a spare WAN jack or changing mode. |
| N10 Wi-Fi tuning | Deferred under the accepted placement and coverage decision. Preserve WDS channel 153 / 80 MHz. OX client acceptance passed. |
| N11 isolation | Retain the current single LAN for discovery and file access. No guest/IoT isolation is claimed. A future isolation requirement needs a separate approved design. |
| N12 shaping/loops | Retain current forwarding. No second studio uplink is planned. Defer tuning until latency symptoms or topology changes justify measurements. |
| N13 time | Corrected. MT1300's persistent resolver-jail fix passed a controlled reboot. Fresh capture retains the fix and correct date. |

## IPv6 and remote-access limits

Fresh routes show no Internet IPv6 default on the four APs or MikroTik.
The APs retain local IPv6 addresses; WAX202 has a unique local prefix.
MikroTik IPv6 remains enabled with link-local state. This does not prove that
no LAN client receives an advertisement. Internet IPv6 is not being enabled.
Vendor AP IPv6 controls remain disabled. Do not redesign this working network
solely to remove dormant native settings.

Retain the tested Apple TV Tailscale path. Do not deploy another VPN.
Router vendor configuration alone cannot prove cloud unbinding or a tailnet
access policy. MT6000 retains rtty feature flags; these are not proof of an
active cloud session. No external enrollment/policy audit was performed.
A full policy audit is outside this baseline. Revisit it when users, enrollment,
exposure, or access needs change. No audit pass or cloud-unbinding claim is made.

## Runtime collector coverage

SSH success is not command success. The collector records status markers.
Review raw sections privately. The following nonzero results are retained.

| Device | Omitted or unsupported commands | Available alternatives |
|---|---|---|
| AXT1800 | `ip -s link` (1); `bridge`, iptables/ip6tables saves, vendor country text, nginx text (127) | `/proc/net/dev`, bridge sysfs, nft rules, iw/iwinfo, uHTTPd state |
| WAX202 | iptables/ip6tables saves, vendor country text, nginx text (127); DHCP lease file (1) | nft rules, native radio/web state; no local DHCP service expected |
| MT6000 | DHCP lease file (1) | AP obtains its management lease from MikroTik |
| MT1300 | `bridge`, vendor country text (127); DHCP lease file (1) | Bridge sysfs, iw/iwinfo; AP obtains its management lease from MikroTik |

No router package was installed to fill a report. Compound commands may hide
an earlier subcommand failure. This capture does not certify full coverage.
Transport and per-section results were inspected separately.

## Acceptance and checks outside the baseline

Recent owner checks cover fresh Air SSH, browser login, off-LAN Tailscale,
OX app control, and normal use. MT6000's repaired browser login passed.
The owner reports about half a day without MT6000 issues and no other AXT1800
issues. Earlier WDS packet evidence and demanding file use remain valid for
the original fault. No later network change occurred in this closeout.
No new fixed observation timer or routine regression campaign is required.

Printer wake, discovery from every client, fresh idle ARP, and measured transfer
counters were not rerun after the last firmware change. Treat them as untested.
Do not imply that earlier tests measured the final firmware state.

After reading the host procedure, a scoped read-only `/host` check found no
active reference to `ping_arp_hosts.sh` in the inspected cron/systemd files.
The old script still exists. Manual process state and other launch methods
were not inspected. No NAS SSH connection or host change ran. Original failed
WDS evidence was already collected before this inspection.

The incident capture tools remain in the investigation repository. They are
not promoted as shared tools. Stop/ownership failure hardening and its mocked
failure tests remain required before such promotion. Do not claim that this
closeout tested or corrected those cleanup paths.

Physical faceplate and intermediate switch labels remain unverified.
The [router-side port map](topology.md#observed-router-side-ports) is usable,
but it does not identify every cable end. Physical labelling, live restore drills,
and complete policy audits are outside the home baseline. The owner asked to
remove superfluous procedures. This changes scope; it does not convert an
untested item into a passed test. The earlier request for another acceptance
round is superseded. Required household operation has already been confirmed.
