# MikroTik management source policy

Applied and verified under the user's continuing authorization.
Fresh remote SSH/browser checks passed. Safe Mode was released successfully. Apply only SSH and HTTP
WebFig service source fields. Do not change firewall, DNS, DHCP, routes, accounts,
or OpenWrt bind settings in this batch.

Observed held remote Air SSH: source `192.168.88.181`, port 59694.
Collector SSH: source `.6`, port 33220. Private evidence:
`secrets/local/network-management/20261009T111706Z/`.
DHCP and ARP identify `.181` as `VincentsAppleTV`, MAC `8C:26:AA:E7:DA:BB`.
This is consistent with Tailscale subnet routing through that Apple TV with source
translation. Its Tailscale configuration was not directly inspected.
The user confirms remote SSH, browser login, and `.lan` DNS work on all devices.

Set service source addresses to `192.168.88.0/24,fe80::/10` for SSH and HTTP.
The first prefix retains local clients, the collector, and the observed remote
translated source. The second retains IPv6 link-local recovery. This policy still
trusts the flat LAN; it is not per-client isolation or a Tailscale access policy.
The WAN input firewall remains an independent boundary.
No global `100.64.0.0/10` permission is needed for this observed translated path.
If Tailscale routing changes to preserve client source addresses, revisit the
allowlist before using the new path. The entire LAN prefix tolerates subnet-router
DHCP changes. Do not pin management only to the current `.181` lease.

Native files: `mikrotik-management/sources-apply.rsc` and `sources-restore.rsc`.
The apply guards require enabled SSH/HTTP with empty source lists.
Parse both before application. Save fresh original values. Enter verified RouterOS
Safe Mode and keep the owner session open. Apply the single-line change, verify
readback and a fresh collector SSH session, then have the user open a new remote
SSH session and reload WebFig while still off-LAN. Release Safe Mode only after
required checks pass. The existing held session alone is not a fresh-access test.

Rollback restores empty source fields on these two services only. It does not
enable any disabled service. Keep IPv6 recovery available; an OpenWrt Dropbear
`Interface=lan` change can exclude link-local addresses and is not part of this work.
No denied-source probe is included. Do not claim rejection was experimentally
verified. Service source fields deny application access; they are not firewall rules.

References: [Tailscale subnet routing](https://tailscale.com/docs/features/subnet-routers)
and [RouterOS services](https://help.mikrotik.com/docs/spaces/ROS/pages/103841820/Services).

## Provisional application

Private evidence: `secrets/local/network-management/20261009T111925Z/`.
Both native scripts parsed successfully. Fresh service state still had empty
source lists. Applied only SSH and HTTP source fields after the owner session
8164 confirmed Safe Mode. Independent readback shows the two intended prefixes.
A fresh collector key-only session passed and WebFig returned HTTP 200.
The existing remote Air session from `.181` remained connected. That alone does
not verify a new remote session. Requested a new Air SSH command and browser
login while the user remains on the hotspot with Tailscale enabled.
Safe Mode remains active until that check passes or the change is rolled back.

## Final acceptance

The user confirms a new SSH command and authenticated WebFig login both passed
from the Air while still on the hotspot with Tailscale enabled. The owner then
released Safe Mode successfully and closed. A fresh collector key-only session
verified that both source lists remain `192.168.88.0/24,fe80::/10`.
The same private manifest records user acceptance and the postcommit capture.
No denied-source or IPv6 client probe was performed. Link-local permission is
preserved in configuration; its functional recovery was not retested here.
The user can close the held test session normally.
