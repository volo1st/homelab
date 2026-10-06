# Studio WDS backhaul

The AXT1800 is the WDS access point on the main LAN. The WAX202 is the
four-address WDS station in the studio. The bridge extends `192.168.88.0/24`
to the studio switch. The MikroTik remains the router and DHCP server.

## Current design

| Property | AXT1800 | WAX202 |
|---|---|---|
| WDS role | Access point | Station |
| Management address | `192.168.88.115/24` | `192.168.88.4/24` |
| Firmware | Official OpenWrt 25.12.5 | OpenWrt 25.12.2 at recorded baseline |
| Bridge | `br-lan` | `br-lan` |
| Ethernet path | `wan` in the acceptance capture | `lan1` |
| Wireless data path | Dynamic `phy0-ap0.sta1`, type `AP/VLAN` | `phy1-sta0` |
| Wireless configuration | 5-GHz AP with WDS enabled | 5-GHz station with WDS enabled |

The dedicated backhaul SSID is `Secret Cow Level`. The WAX202 pins the AXT1800
BSSID `5e:81:e0:ee:07:05`. The link uses channel 153 at 5765 MHz and HE80.
The recorded security mode is WPA2-PSK with CCMP. Keep the wireless key in
private recovery storage.

The official OpenWrt bootstrap bridges AXT1800 `lan1`, `lan2`, and `wan`.
It disables local DHCP service and disables the unused radio.
The recorded baseline disables spanning tree, VLAN filtering, and multicast
snooping on the WDS bridge. Capture current device configuration before treating
these settings as a complete restore specification.

## Failure and fix

On GL.iNet 4.8.3 with kernel 5.4.164, the AXT1800 received a broadcast ARP
request and changed its destination during wireless transmission. Four-address
WDS distinguishes the wireless receiver from the final Ethernet destination.
The receiver must be the WAX202 station MAC address. Address 3 must keep the
final destination, which is `ff:ff:ff:ff:ff:ff` for a broadcast ARP request.

The old stack put the WAX202 station MAC in address 3. The WAX202 received an
Ethernet frame addressed to itself and did not flood it to `lan1`. Studio hosts
therefore did not receive the ARP request. Valid forwarding database entries
and working unicast traffic did not prevent this failure.

Replacing the AXT1800 stack with official OpenWrt 25.12.5 preserved the
broadcast destination. The controlled test on 2026-10-06 verified the complete
ARP request and reply path. The Air then received all three ping replies.

| Observation | Old GL.iNet stack | Official OpenWrt 25.12.5 |
|---|---|---|
| ARP request at AXT1800 Ethernet and WDS ports | Broadcast | Broadcast |
| Raw four-address destination, address 3 | WAX202 station MAC | Broadcast |
| Request at WAX202 wireless port | Station-addressed | Broadcast |
| Request at WAX202 Ethernet port | Absent | Broadcast |
| NAS ARP reply and Air ping | Failed | Passed |

This confirms the failure location and the observed improvement. It does not
identify whether the old defect came from GL.iNet changes, inherited upstream
code, or a missing backport. The exact defective component remains unconfirmed.
The long-duration checks in [README.md](README.md) remain open.

## Rebuild and recovery

Use the investigation [firmware runbook](https://github.com/volo1st/wds-arp-discovery-debug/blob/master/firmware-test.md)
and [staged bootstrap script](https://github.com/volo1st/wds-arp-discovery-debug/blob/master/scripts/bootstrap-axt-openwrt.sh).
The verified test image is
`openwrt-25.12.5-qualcommax-ipq60xx-glinet_gl-axt1800-squashfs-factory.ubi`.
Its SHA-256 is `6703e3f714c4da46ea24c10d2d826298b8549369f2ecd806ead96ae3e0fbd12d`.
The rollback image and private pre-upgrade archive remain required recovery
artifacts. Do not restore the GL.iNet archive into official OpenWrt.

The current device exports are pending. Follow
[configuration-backup.md](configuration-backup.md) to capture the working state
and derive the checked-in configuration templates.

## Evidence and earlier experience

- [Old transmit failure](https://github.com/volo1st/wds-arp-discovery-debug/tree/master/evidence/20260925T113535Z-axt-monitor-nas)
- [Passing broadcast test and monitor cleanup](https://github.com/volo1st/wds-arp-discovery-debug/tree/master/evidence/20261006T081915Z-openwrt-25.12.5-monitor-nas)
- [Capture and probe tools](https://github.com/volo1st/wds-arp-discovery-debug/blob/master/automation.md)

Earlier tests reported 690–780 Mbit/s through the backhaul with wired clients.
This is historical performance, not a benchmark of the new firmware.
The dedicated SSID and pinned BSSID remove station-roaming ambiguity.
Separate client Wi-Fi performance from backhaul performance when measuring load.

The earlier MT6000 WDS limitation was observed on its tested vendor build.
It is not evidence that every firmware for this hardware lacks WDS support.
The earlier MT1300 throughput test was a rejected backhaul option. The user
confirmed its current role as kitchen and work-from-home / TV access point.
