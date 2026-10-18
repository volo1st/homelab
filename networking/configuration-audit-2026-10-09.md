# Network configuration audit: 2026-10-09

The [runtime audit](runtime-audit-2026-10-09.md) extends this saved-state baseline
with authorized SSH evidence. Use it for current service, firmware, and clock findings.

## Scope and conclusion

This is a static audit of the five saved device configurations from 2026-10-06.
It covers addressing, bridging, edge rules, management access, wireless settings,
firmware maintenance, recovery, and performance controls. It does not certify
current runtime state or Internet exposure. No device connection, active probe,
or network change occurred during this audit.

The design fits the current workload: one main router, wired access points (APs),
and one transparent wireless distribution system (WDS) bridge to the studio.
The controlled WDS test and subsequent user acceptance support keeping that
working path. There is no evidence here that a hardware replacement is needed.

Correct the address-allocation overlap and review the radio country setting
first. Then restrict management access and complete recovery coverage. Wireless
channel changes, segmentation, and traffic shaping need measurements or an
explicit architecture decision before implementation.

## Evidence and limits

Private evidence root: `secrets/local/network/20261006T103815Z/`.
The paths below are relative to that root. Raw exports and archives remain ignored.
Do not copy them into tracked documentation.

| Device | Reviewed evidence | Captured role and address |
|---|---|---|
| MikroTik RB760iGS | `mikrotik/config.rsc`, `identity.txt`, `SHA256SUMS` | RouterOS 7.23.2; gateway and DHCP server at `192.168.88.1` |
| AXT1800 | `axt1800/config.uci`, `board.json`, `network-state.txt`, `packages.txt`, `config.tar.gz` | Official OpenWrt 25.12.5; WDS AP; static `192.168.88.115` |
| WAX202 | Same files under `wax202/` | Official OpenWrt 25.12.2; WDS station; static `192.168.88.4` |
| MT6000 | Same files under `mt6000/` | GL.iNet AP mode; OpenWrt base 21.02-SNAPSHOT; DHCP management address `192.168.88.2` |
| MT1300 | Same files under `mt1300/` | GL.iNet AP mode; OpenWrt base 22.03.4; DHCP management address `192.168.88.3` |

All hashes in the five `SHA256SUMS` files were recalculated and matched on
2026-10-09. Each OpenWrt archive was readable. Every entry in each captured
`backup-files.txt` was present in its archive. This proves integrity and listed-file
coverage. It does not prove a complete restore or that the configured services run.

The archives contain authentication and key material. Only member names and
counts were used for the access review. The audit did not print their contents.

The RouterOS export normally omits unchanged defaults. An absent service setting
therefore means unknown, not disabled. User passwords, certificates, and SSH keys
are outside text-export recovery coverage. See
[MikroTik configuration management](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration+Management).

No current IPv6 addresses, dynamic leases, listening sockets, generated vendor
firewall rules, radio survey, link counters, service health, RouterBOOT version,
or Tailscale access policy were supplied. NAS host configuration and client
security are outside this network-device audit. The topology includes unmanaged
switches; those devices have no reviewed configuration export.

## Findings

Priorities are an action order. High means a concrete reliability or configuration
issue worth addressing first. Medium means hardening or a verification gap.
Low means an optional improvement that needs a measured benefit.

### N01 — High: static AXT1800 address overlaps the DHCP pool

Observed: AXT1800 `config.uci:259` assigns `192.168.88.115` statically.
The MikroTik pool is `192.168.88.100-192.168.88.199`. Its saved static leases
have no AXT1800 entry for `.115`.

Conclusion: the saved configuration does not explicitly protect `.115` from
allocation to another client. No duplicate address was observed in this audit.
Do not infer a current collision from the overlap alone.

Proposed action: retain the current management address if possible. Exclude it
from the dynamic ranges or establish a correct reservation after verifying the
AXT1800 bridge MAC address and current lease state. Verify the DHCP server's
handling of the chosen reservation. A pool exclusion avoids depending on the
statically configured AP sending DHCP requests. Save the original pool before
an approved change. Verify that existing client leases remain usable.
See [RouterOS DHCP](https://help.mikrotik.com/docs/spaces/ROS/pages/24805500/DHCP).

### N02 — High: MT6000 country setting does not match the site

Observed: both active MT6000 radios have `country 'US'` at `config.uci:2851`
and `:2879`. The site is in Australia. The AXT1800 active radio and MT1300 radios
use `AU`. WAX202 has no explicit country in the captured wireless configuration.

Proposed action: confirm the effective country in the MT6000 vendor interface
and driver. Then plan an approved change to the Australian setting on both
radios. Verify the effective setting on WAX202 as well. The exported value alone
does not establish the actual transmitted power or channels.
[OpenWrt country-code guidance](https://openwrt.org/docs/guide-user/network/wifi/wifi_countrycode)
requires the deployment country. Radio changes can interrupt clients and require
channel and reconnection verification. Do not translate the MT6000 vendor
`txpower '100'` into dBm without its driver semantics.

### N03 — Medium: MikroTik update channel is development

Observed: `/system package update` has `channel=development`. The installed
version in the capture is 7.23.2. The channel setting does not prove that the
installed build is a development build or that updates run automatically.

Proposed action: use a deliberate stable or long-term maintenance policy for the
main router, unless a documented feature requires another channel. Select a
supported release for this model after release-note review and backup verification.
Changing the channel is distinct from installing firmware. Do not upgrade during
this audit. See [RouterOS release channels](https://help.mikrotik.com/docs/spaces/ROS/pages/328142/Upgrading+and+installation).

### N04 — Medium: root SSH password authentication is enabled

Observed: all four OpenWrt exports set `PasswordAuth 'on'` and
`RootPasswordAuth 'on'`. No Dropbear `Interface` restriction appears. The saved
archives have authorized-key entries: two on AXT1800 and one on each other AP.
Key presence does not prove current key access or identify who retains each key.

Proposed action: inventory the authorized keys privately. Verify a known key in
a second session before disabling password authentication. Keep a recovery path.
Restrict management sources with the applicable firewall or management design.
Binding Dropbear to a LAN address alone does not restrict which LAN clients can
reach it. This is LAN hardening; the audit does not establish Internet exposure.
See [OpenWrt Dropbear configuration](https://openwrt.org/docs/guide-user/base-system/dropbear).

### N05 — Medium: web management permits unencrypted HTTP in saved settings

Observed: AXT1800 and WAX202 uHTTPd listen on all IPv4 and IPv6 addresses on
ports 80 and 443, with `redirect_https '0'`. MT6000 uHTTPd has ports 8080 and
8443 with the same redirect setting. MT1300 has vendor nginx installed; its
active listener and TLS settings are not established by the saved UCI export.
Vendor nginx can also be the front end on MT6000.

Proposed action: verify the actual management front ends and certificates. Prefer
HTTPS and redirect HTTP where supported. Confirm administrative clients can use
the new path before removing another path. A listener setting does not prove
service runtime or reachability through the firewall. See
[OpenWrt secure access](https://openwrt.org/docs/guide-user/security/secure.access).

### N06 — Medium: trusted-LAN management is broad; RouterOS service state is incomplete

Observed: RouterOS drops input from interfaces outside `LAN` after its stated
exceptions. Its `LAN` list contains the main bridge. MAC server, MAC Winbox,
and neighbor discovery are restricted to that list. OpenWrt LAN zones accept
input. Thus, the saved design provides no separate management trust boundary
within the main bridged LAN. RouterOS `/ip service` settings are absent from the
compact export, so their enabled state and source restrictions are unknown.

Proposed action: collect service state and authorized management-source needs
before disabling unused services or narrowing access. Keep access for the Air,
recovery, and intended remote administration. Review vendor cloud access and
Tailscale separately; installed packages do not prove that remote access is active.
See [MikroTik router hardening](https://help.mikrotik.com/docs/spaces/RKB/pages/8323164/Securing+your+router).
A management VLAN would be an architecture change and needs separate approval.

### N07 — Medium: recovery remains incomplete

Observed: four readable OpenWrt archives contain the files on their captured backup
lists. The MikroTik has a text export. The repository documents no verified
off-host private recovery copy, encrypted MikroTik binary backup, or representative
restore. The saved data sits on the NAS that hosts the development container.

Proposed action: complete the existing recovery work before firmware or major
network changes. Keep firmware images, package inventories, dependencies, and
secrets paired with the intended restore target. Do not restore GL.iNet archives
into official OpenWrt. A text export alone cannot restore all RouterOS credentials.
See [configuration-backup.md](configuration-backup.md).

### N08 — Medium: vendor release identity and patch coverage need review

Observed: MT6000 and MT1300 report old OpenWrt base versions, but the package
inventories contain GL.iNet modifications. The collected board files do not
establish their exact GL.iNet release identifiers. WAX202 and AXT1800 have different
official OpenWrt patch versions.

Conclusion: the base version alone cannot establish vendor patch status or a
specific vulnerability. GL.iNet states that it backports security patches to some
older bases. See [GL.iNet firmware policy](https://www.gl-inet.com/en-us/pages/firmware-versions/).

Proposed action: collect exact vendor releases and review supported security
updates for each model. Create a tested maintenance policy with image hashes,
configuration compatibility, and rollback. Do not replace stable firmware simply
to make version numbers match. No CVE clearance or latest-version claim is made.

### N09 — Medium: unused routing and bridge options can cause future surprises

Observed: WAX202 retains DHCP WAN and DHCPv6 WAN interfaces on its separate
`wan` device. The saved IPv4 state shows only the intended bridge route.
MT6000 and MT1300 have disabled primary WAN interfaces, AP mode, and residual
vendor routing configuration. MT1300 LAN uses DHCP; its saved `192.168.8.1`
value is not its captured live address. MikroTik reserves `.2` and `.3` for the
MT6000 and MT1300. AXT1800 includes its physical `wan` port in `br-lan`.

Proposed action: document exact cable roles first. Confirm whether WAX202 WAN is
intentionally available before disabling its protocols. Mark the bridged AXT1800
WAN port as LAN in recovery instructions. Preserve vendor AP-mode configuration
until its generated runtime behavior is known. Removing apparently unused sections
can break vendor controls. See [OpenWrt bridged AP roles](https://openwrt.org/docs/guide-user/network/wifi/wifiextenders/bridgedap).

### N10 — Low: channel reuse and width deserve measurement

Observed: AXT1800 WDS uses channel 153 at 80 MHz. The active MT1300 5-GHz AP
also uses channel 153 at 80 MHz. MT6000 uses automatic channels, 80 MHz on
5 GHz, and 40 MHz on 2.4 GHz. MT1300's 2.4-GHz AP interface is disabled even
though the radio is enabled. These settings do not prove harmful interference.

Proposed action: measure channel utilization and client performance at the actual
locations before assigning channels. Consider 20 MHz on 2.4 GHz if congestion
or legacy-client reliability warrants it. Separate nearby client AP airtime from
the backhaul where the measured benefit justifies it. Keep the established WDS
channel until a controlled change is planned. See
[OpenWrt wireless throughput guidance](https://openwrt.org/faq/i_am_not_reaching_theoretical_wireless_throughput).

### N11 — Medium decision: one trust domain; guest settings do not prove isolation

Observed: active client wireless interfaces attach to `lan`. MT6000 guest and
IoT interfaces and wireless networks are disabled. MT1300 guest networks are
also disabled. There is no active exported guest design to validate. The
current transparent bridge serves discovery and file access on one LAN.

Proposed action: decide whether guests or less-trusted devices need isolation
from NAS and management services. Do not enable a guest SSID and assume its
vendor router-mode rules work in AP mode. A future design needs end-to-end
routing or VLAN support, explicit access rules, and discovery exceptions where
required. This can add complexity and interrupt discovery. It needs user approval.
See [OpenWrt guest networking on an AP](https://openwrt.org/docs/guide-user/network/wifi/guestwifi/guestwifi_dumbap).

### N12 — Low: define latency and loop requirements before tuning

Observed: MikroTik has IPv4 FastTrack. MT6000 SQM and QoS controls are disabled.
No measured latency-under-load result was supplied. AXT1800 explicitly disables
Spanning Tree Protocol (STP); other OpenWrt bridge exports do not explicitly enable
it. The documented studio topology has a single WDS uplink, not a verified loop.

Proposed action: retain the working topology and forwarding settings. Do not
connect a parallel Ethernet uplink while WDS remains bridged without a reviewed
loop-prevention plan. If latency under load is a problem, measure it at the gateway
before considering shaping. FastTrack bypasses simple queues and some queue-tree
paths, so a shaping design must account for it. See
[RouterOS FastTrack packet flow](https://help.mikrotik.com/docs/spaces/ROS/pages/328227/Packet+Flow+in+RouterOS)
and [OpenWrt bridge STP](https://openwrt.org/docs/guide-user/network/network_configuration).

## Positive controls retained

- MikroTik separates the Internet-facing `ether1` from the LAN bridge.
- Saved IPv4 rules drop unsolicited new WAN forwarding unless destination NAT applies.
  No destination-NAT port-forward rule appears in this export.
- RouterOS IPv6 filter rules are present. This does not prove active IPv6 service
  or complete client protection; current addresses and policy state are missing.
- LAN DHCP service is ignored on all four OpenWrt devices. The MikroTik is the
  intended authority. Runtime absence of another DHCP server was not probed.
- Management addresses for MT6000, MT1300, and WAX202 have saved reservations.
- Active exported Wi-Fi networks use WPA2-PSK, not open authentication. WAX202's
  open default AP sections are disabled. WPA3 changes need client and WDS testing.
- WDS passes the original broadcast ARP reproduction test and user load tests.
- Backup files are private and have matching hashes. Recovery gaps are explicit.

## Verification needed to complete a live audit

A future authorized read-only collection should record current DHCP leases and
AP bridge MAC addresses; effective radio country and channels; management
listeners and service enablement; generated firewall rules and counters; IPv6
addresses, routes, delegation, and advertisements; exact vendor releases and
RouterBOOT version; vendor remote-access state; and Tailscale route and access
policy. Preserve secrets locally and summarize only reviewed fields.

Radio surveys, latency tests, and external exposure tests require a separately
scoped active test. They were not run here. Exact wall-port and cable mapping
needs a physical check. Restore verification needs its own approved procedure.

Actionable follow-up is tracked only in
[work package 12](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery).
This report records findings and proposals. It does not authorize implementation.
