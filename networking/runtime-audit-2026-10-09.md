# Network runtime audit: 2026-10-09

## Scope and result

This report extends the [saved-configuration audit](configuration-audit-2026-10-09.md).
The user authorized SSH collection from the five network devices. Collection used
existing aliases, key authentication, and strict host-key checks. No configuration,
service, package, clock, firewall, or radio setting was changed. No active probe,
scan, transfer benchmark, or packet capture ran. No SSH session opened to the NAS
or Mac Studio. Collection ran from the NAS development container and is not an
independent reachability test of the studio network.

The runtime evidence confirms the address-allocation risk and broad management
access. It establishes exact vendor versions and finds a substantial clock error
on MT1300. It supports retaining the working WDS path. The immediate priorities
are management-service reduction, address protection, radio country settings,
and time synchronization. All implementation still requires approval.

## Private evidence and collection coverage

Evidence root: `secrets/local/network-runtime/20261009T004414Z/`.
Initial collection ran from 00:44:14 to 00:44:28 UTC. A separate follow-up completed
at approximately 02:25 UTC. These are two observation windows, not one atomic
snapshot. Raw UCI, service data, leases, and logs can contain secrets. Keep the
whole directory ignored and private.

`manifest.json` records 18 initial SSH results and SHA-256 hashes. All transports
returned zero. All initial output and stderr hashes were recalculated and matched.
`follow-up-manifest.json` records four follow-ups; their output and stderr hashes
also matched. All collected directories and files deny group and other access.
Transport success does not prove every command succeeded.

| Device | Coverage | Limitation retained |
|---|---|---|
| AXT1800 | Configuration, services, listeners, nftables, IPv4/IPv6, wireless state, logs, resources | BusyBox rejected `ip -s link`; `bridge` was absent. Follow-up read `/proc/net/dev` and bridge sysfs |
| WAX202 | Same coverage, plus bridge command and passive survey counters | No DHCP lease file; legacy iptables tools absent, with nftables available |
| MT6000 | Configuration, services, listeners, nftables/iptables, addresses, logs, vendor radio data | `iw` and `bridge` absent. Used `iwinfo`, sysfs, and saved vendor radio files; effective driver country remains unconfirmed |
| MT1300 | Configuration, services, listeners, firewall state, wireless state, logs, clock and resources | `bridge` absent; sysfs supplied bridge settings. Clock is wrong, so device log dates need correction |
| MikroTik | Services, users, SSH, interfaces, DHCP, IPv4/IPv6, rules and counters, firmware, queues, cloud and time settings | Unsupported Back To Home query in follow-up; do not infer feature state from that error |

MT6000 and MT1300 follow-up shells returned status 2 because a queried nginx
runtime directory was absent. Earlier output, including nginx configuration,
was retained. The RouterOS shell returned zero despite the unsupported final
query. These are partial section failures, not clean coverage of every query.
The initial collector also returned zero for an empty wireless pipeline when
`iw` was absent. The maintained collector now checks that tool explicitly.

The collector is [capture-network-runtime.py](../scripts/capture-network-runtime.py).
It defaults to help. `--run` opens SSH sessions. It records command status for
OpenWrt sections and retains partial evidence. It does not install missing tools.
The updated collector adds `/proc/net/dev`, bridge sysfs, vendor radio country,
and nginx configuration fallbacks. The initial live capture predates these
refinements; the follow-up supplies their evidence for this session.

## Findings confirmed or refined

### N01: protect the AXT1800 management address

Current UCI remains identical to the 2026-10-06 export and assigns `.115`
statically. MikroTik still has the `.100-.199` pool and no `.115` lease or
reservation. No current duplicate was established. Protect the address by a
reviewed exclusion or reservation policy before a future allocation causes trouble.
Sources: `axt1800/runtime.txt`, section `config`; `mikrotik/dhcp.txt`.

### N02: review country settings on MT6000 and WAX202

MT6000 UCI still sets US on both active radios. Vendor radio files, including
`mt7986.1.dat` and `mt7986.2.dat`, also contain US. Standard `iw` is absent, so
this is configuration evidence rather than a verified effective driver domain.
WAX202 `iw reg get` reports country `00`, the world domain. AXT1800 and MT1300
report AU. Plan the Australian settings with a reconnection check. Do not assert
a measured power violation from these values alone.
Sources: each `runtime.txt`, sections `config` and `regulatory`;
`mt6000/follow-up.txt`. See [OpenWrt country guidance](https://openwrt.org/docs/guide-user/network/wifi/wifi_countrycode).

### N03 and N08: exact installed software is now known

| Device | Runtime identity |
|---|---|
| AXT1800 | Official OpenWrt 25.12.5 |
| WAX202 | Official OpenWrt 25.12.2 |
| MT6000 | GL.iNet 4.9.1; OpenWrt base 21.02-SNAPSHOT |
| MT1300 | GL.iNet 4.3.25; OpenWrt base 22.03.4 |
| MikroTik | RouterOS 7.23.2 stable; current and offered RouterBOOT firmware both 7.23.2 |

MikroTik still selects the development update channel. It is not running a
development build in this capture. No update check or installation ran. These
identities enable a model-specific release and patch review; they do not prove
that every installed release is current or free of known vulnerabilities.
Sources: OpenWrt `vendor-version` sections; `mikrotik/identity.txt` and
`maintenance.txt`.

### N04-N06: management hardening is now a confirmed runtime concern

All four OpenWrt devices have Dropbear listening on port 22. AXT1800 and WAX202
run uHTTPd on 80 and 443. MT6000 runs nginx on 80/443 and uHTTPd on 8080/8443.
MT1300 runs nginx on 80/443. Their saved SSH password-authentication settings
remain enabled. Both vendor nginx configurations declare HTTP and HTTPS
listeners; the selected configuration review found no redirect directive.
This does not replace an end-to-end redirect or certificate check.

MikroTik reports FTP, Telnet, HTTP WebFig, SSH, Winbox, API, API-SSL, and
reverse-proxy enabled. Their service source-address fields are empty.
HTTPS WebFig is disabled. The authenticated bandwidth-test server is enabled.
These services are available to the trusted LAN under the captured input rules.
No active service connection test was made.

The default `admin` user is enabled, has full rights, and has an imported Ed25519
public key. SSH reports `password-authentication=yes-if-no-key` and
`strong-crypto=no`. Do not describe this as unconditional password login for
that keyed user. Confirm required administrative clients and recovery access.

Proposed action: reduce unused MikroTik services first, particularly Telnet, FTP,
HTTP management, and unused APIs. Review the reverse proxy and bandwidth server
before disabling them. Restrict required service sources. Verify a second key
session before narrowing authentication. Review stronger SSH settings against
client compatibility. Keep the default administrator change separate from key
and firewall changes to preserve a usable rollback path.

The edge rule `drop input in-interface-list=!LAN` is active and has counted drops.
No destination-NAT rule appeared in the saved or live NAT rule list. This is a
separate barrier; service enablement does not establish Internet exposure.

Sources: OpenWrt `listeners` and `config` sections; vendor `follow-up.txt` files;
`mikrotik/services.txt`, `users.txt`, `firewall4.txt`, and `follow-up.txt`.
Guidance: [RouterOS services](https://help.mikrotik.com/docs/spaces/ROS/pages/103841820/Services),
[RouterOS hardening](https://help.mikrotik.com/docs/spaces/ROS/pages/328353/Securing%20your%20router),
and [RouterOS SSH settings](https://help.mikrotik.com/docs/spaces/ROS/pages/132350014/SSH).

### N13 — Medium: MT1300 time synchronization is not working

The initial MT1300 UTC clock was `2026-09-20 14:19:16`, while the collector and
other OpenWrt devices were on `2026-10-09 00:44`. The later follow-up still
showed September 20. The offset is approximately 18 days and 10 hours, not a
time-zone difference. `sysntpd` and an `ntpd` process are running, and pool server
names are configured. Running the daemon does not prove synchronization.

Proposed action: inspect NTP resolution, permitted egress, synchronization state,
and relevant logs before an approved correction. Do not change the clock merely
to hide the symptom. Validate UTC against the collector after correction and
again after a reboot in a planned maintenance window. Until then, do not compare
MT1300 log timestamps directly with the other devices.

MikroTik's NTP client is disabled, but cloud `update-time=yes` is configured and
its observed clock agrees with the collection window. Do not claim it has no
time source. A deliberate NTP policy can improve consistency for future evidence.
Sources: `mt1300/runtime.txt`, sections `clock`, `services`, and `config`;
`mt1300/follow-up.txt`; `mikrotik/maintenance.txt` and `remote-access.txt`.
Guidance: [OpenWrt NTP](https://openwrt.org/docs/guide-user/services/ntp/client-server)
and [MikroTik cloud time](https://help.mikrotik.com/docs/spaces/ROS/pages/97779929/Cloud).

## Reliability and network observations

- WAX202 reports the WDS station authorized, authenticated, and associated.
  Its connected time is 233544 seconds, about 2.7 days. Historical handshake and
  deauthentication messages align with October 6 setup activity. Do not count
  all retained messages as post-acceptance failures.
- WAX202 reports approximately -53 dBm average signal and roughly 0.9-1.1 Gbit/s
  negotiated radio rates. These are link telemetry, not measured file throughput.
- Wireless retry and failure counters are cumulative. A single snapshot cannot
  establish a current loss rate. `iwinfo` reports `Encryption: none` on WAX202,
  while configuration, supplicant history, and station authorization indicate an
  authenticated WDS connection. Do not infer an open network from that field.
  A protocol-status check can resolve the telemetry inconsistency if needed.
- AXT1800 and MT1300 use channel 153 at 80 MHz. MT6000 currently reports channel
  40 at 80 MHz on 5 GHz and channel 8 at 20 MHz on 2.4 GHz. Its configured HE40
  does not mean it is currently using 40 MHz. Channel changes still need workload
  and airtime evidence.
- OpenWrt bridges report STP and VLAN filtering disabled. Retain the single-uplink
  topology. A parallel wired studio uplink needs a loop-prevention plan.
- OpenWrt temporary and overlay storage have free space. The WDS endpoints do
  not show the earlier full `/tmp` condition. The read-only `/rom` being full is
  expected and is not a writable-storage fault.
- MikroTik has 4.9 MiB free storage and about 193 MiB free RAM in this snapshot.
  Check required upgrade space before maintenance. A single sample does not
  establish a resource trend or a memory leak.
- MikroTik has a WAN IPv4 address in `100.64.0.0/10`, consistent with carrier-grade
  NAT. This does not replace its firewall or establish external reachability.
- MikroTik has only loopback and link-local IPv6 addresses, no IPv6 default route,
  and no DHCPv6 client entry in this snapshot. Its default neighbor-discovery
  entry still targets all interfaces. Review intended IPv6 behavior before
  enabling Internet IPv6. APs have link-local or local-only IPv6 state.
- UPnP, the MikroTik OpenVPN server, HTTP proxy, and SOCKS proxy report disabled.
  No simple queue or queue-tree entry was present. No latency test was run.

Sources: OpenWrt runtime wireless, route, storage, and memory sections;
`mikrotik/addresses.txt`, `ipv6.txt`, `identity.txt`, `remote-access.txt`,
`queues.txt`, and `follow-up.txt`.

## Remaining limits and next step

This is a substantially broader audit, not complete assurance. Effective MT6000
driver country, Tailscale control-plane policy, vendor cloud enrollment, certificate
validation, external exposure, physical cable mapping, latency under load, and
restore behavior remain unverified. Driver-specific wireless telemetry needs care.
Snapshot counters cannot prove sustained loss or long-term health.

Keep the WDS operational fault closed. Prepare bounded change proposals for
management services, address protection, radio country, and MT1300 time first.
Track implementation only in
[work package 12](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery).
