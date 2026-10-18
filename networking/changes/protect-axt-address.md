# AXT1800 address and local DNS migration

Applied on 2026-10-09 with user approval. This replaces the `.115` pool split.

## Result

AXT1800 uses static `192.168.88.5/24`, gateway `.1`, and DNS `.1`.
Its saved and runtime hostname is `axt1800`.
MikroTik has a static lease for MAC `94:83:C4:63:DF:8A` with comment `WDS-AP`.
The lease documents the AP. Its `waiting` state is expected because the AP uses
a locally configured static address. The dynamic pool remains `.100-.199`.

MikroTik serves explicit A records with a five-minute TTL:

| Name | Address |
|---|---|
| mikrotik.lan | 192.168.88.1 |
| mt6000.lan | 192.168.88.2 |
| mt1300.lan | 192.168.88.3 |
| wax202.lan | 192.168.88.4 |
| axt1800.lan | 192.168.88.5 |

DHCP already advertises DNS `.1` and search domain `lan`.
Short names and qualified names resolve in the workspace environment.
The workspace SSH config retains users and identity files. Its five network
entries accept both name forms and have no hardcoded `HostName` IP.
Trusted public host keys were copied from the existing address entries.
Host-key checking remained enabled. Other SSH entries were preserved.
The Air has a separate SSH config. The user reports its DNS-based migration and
all five SSH tests passed. Its IP-valued HostKeyAlias fields select existing
trusted keys only. Gateway, Internet, AP web, and hostname checks also passed.
Remote DNS through Tailscale was not changed or verified.

## Evidence and limitations

Private evidence is below `secrets/local/network-migration/`:

- `20261009T091901Z`: failed initial migration and successful staged web check.
- `20261009T092805Z`: recovered IPv4 SSH and HTTP, persistent address and hostname.
- `20261009T092806Z`: router additions and qualified DNS resolution.
- `20261009T092829Z`: saved SSH config and known hosts; five DNS-based SSH checks.
- `20261009T093238Z`: final hashes, router inventory, AP configuration,
  network-manager state, WAX202 SSH, and AP HTTP 200.

Initial preflight is `secrets/local/network-stage0/20261009T091612Z/`.
No lease or ARP entry used `.5`. Three ARP probes received no reply.
A negative probe cannot exclude an offline device.
No reboot or broad DHCP renewal was performed. Reboot persistence is untested.
The earlier encrypted recovery bundle contains the pre-change configuration.
Use this record and the final private exports to identify the subsequent changes.

## Failed steps and recovery

Deleting primary `.115` also removed secondary `.5`. The SSH commit timed out.
The rollback timer did not start because `nohup` is absent on this OpenWrt image.
Both were preparation errors. IPv4 management was unavailable during recovery.
SSH over unchanged link-local IPv6 restored access. The recovery command added
`.5` back to `br-lan`. No reboot was required.
The saved configuration already contained `.5` and `axt1800`.
`ubus call network reload` then reconciled netifd with the saved configuration.
The final kernel and netifd addresses agree. WAX202 SSH passed after the reload.
No continuous traffic test was running, so uninterrupted forwarding is not claimed.

The RouterOS multiline outer block returned `missing closing brace`.
Individual commands still ran. Independent inventory and DNS checks verified the
result. Do not accept an SSH exit code or a success marker without checking native
error output and resulting state.
The archived shell scripts stop immediately. They preserve the failed procedure
for review and must not be used as operational tools.

## Recovery procedure

Use `.5` and the same trusted AP key for normal SSH recovery.
If IPv4 is unavailable, use the observed AP link-local IPv6 address on the main LAN.
The interface scope depends on the client. In this execution environment:

```sh
ssh -o HostName=fe80::9683:c4ff:fe63:df8a%%enp5s0 -o HostKeyAlias=192.168.88.115 axt1800
```

OpenSSH needs `%%` inside its `HostName` option to preserve the scope separator.
Original network and system files remain in `/tmp/axt-address-migration/` on the AP.
They disappear after reboot. The encrypted recovery copy also contains the old state.
Before restoring `.115`, confirm it has no DHCP owner. It is inside the pool.
Restore saved configuration, then use netifd to apply it from a verified recovery
session. Remove only the reservation and DNS records introduced here if reverting.
Restore the private SSH-config backup if its DNS-based changes must be reversed.
Do not disable host-key verification.

For future address migrations, test a recovery session first. Verify every timer
dependency and prove that the timer runs before changing the address.
Account for Linux primary/secondary address removal. Prefer netifd-managed changes.

References: [RouterOS DNS](https://help.mikrotik.com/docs/spaces/ROS/pages/37748767/DNS),
[RouterOS DHCP](https://help.mikrotik.com/docs/spaces/ROS/pages/24805500/DHCP),
and [OpenWrt network reload](https://openwrt.org/docs/guide-developer/ubus/network).
