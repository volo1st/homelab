# WDS Wireless Bridge — Studio Backhaul

Goal: give the studio (no cable run) a solid network link, so wax202 can
act as a wired switch for MacBook Air, NAS, and Mac Studio in that room.

## Devices

| Device | Role | Chipset / driver |
|---|---|---|
| GL-MT6000 (Flint 2) | Main house AP, central room | MediaTek, closed driver |
| GL-AXT1800 (Slate AX) | WDS AP, upstairs above studio | Qualcomm, open `hostapd`/mac80211 |
| Netgear wax202 | WDS client, in studio | OpenWrt stock, mac80211 |
| GL-MT1300 (Beryl) | Spare (tested, not used) | MediaTek MT7615E, open `hostapd` |

## Critical findings

1. **GL-MT6000 cannot do WDS.** Its wifi is run by a closed-source
   MediaTek driver/daemon, not standard `hostapd`. Stations fully
   associate and complete the WPA 4-way handshake, but no WDS frames are
   ever forwarded — confirmed by a live kernel log capture during
   reconnect (no WDS-related log lines at all) and no exposed WDS
   controls (`wappd_cli` missing, no WDS state files anywhere).
   Matches reports on the GL.iNet community forum for this hardware.

2. **GL-MT1300 does support WDS** (real `hostapd` process), but its
   MT7615E chipset is Wi-Fi 5 (AC) only, 2×2 MIMO — capped throughput
   around 300 Mbps even with a strong signal. Too slow for the studio's
   needs (NAS + Mac Studio + MacBook Air).

3. **GL-AXT1800 supports WDS and is fast enough.** Wi-Fi 6 (HE80), real
   `hostapd`. WDS backhaul tested at 690–780 Mbps over iperf3, one floor
   apart from wax202. This is the device now used for the backhaul link.

4. **The original DUP! problem (stock wax202 bridge firmware) is a
   separate issue from everything above** — not yet deliberately
   reproduced, but not seen either during sustained iperf3 load. Worth
   continued casual monitoring, not urgent.

5. **Same SSID across multiple APs caused real problems.** Early on, the
   wax202 silently roamed to a much weaker back-of-house AP because it
   shared the same SSID as the main one — this caused most of the
   original "intermittent connection" symptoms. Fixed by giving the
   backhaul its own dedicated, hidden SSID.

6. **A wifi client bottleneck was initially mistaken for a WDS
   problem.** Air's iperf3 numbers over its own wifi to MT6000 (120–175
   Mbps, heavy retries) looked bad, but plugging Air in by cable to
   either AP showed the WDS backhaul itself is fine (690–780 Mbps). The
   real bottleneck is Air's own wifi link to MT6000 — a separate,
   ordinary client-wifi problem to debug another day.

## Key decisions

- **Use AXT1800, not MT6000, as the WDS AP.** MT6000's driver can't do
  it; not fixable from config.
- **Relocate MT6000 to a central room.** It no longer needs to be near
  the studio for backhaul, so move it to serve the whole house better.
  AXT1800 takes its old spot (front of house, above the studio).
- **Dedicated, hidden backhaul SSID** (`Secret Cow Level`), separate
  from client-facing SSIDs. Removes the roaming ambiguity that caused
  the original bug.
- **iperf3 over cable, not wifi speedtest, for real diagnosis.**
  Speedtests are short bursts and miss sustained retransmit/congestion
  patterns. Isolate the wireless hop under test by temporarily wiring
  the client directly into each AP in the chain.
- **Disable DHCP server on wax202.** OpenWrt ships DHCP on by default;
  left on, it randomly raced the real router and caused devices to get
  wax202 as their gateway instead of the router.

## Final config (uci)

### wax202 (studio, WDS client)

```sh
# Network
uci set network.lan.ipaddr='192.168.88.4'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.88.1'
uci set network.lan.dns='192.168.88.1'
uci commit network

# Wireless — 5GHz WDS client only, 2.4GHz off
uci set wireless.radio0.disabled='1'
uci set wireless.radio1.channel='153'
uci set wireless.radio1.htmode='HE80'
uci set wireless.default_radio1.disabled='1'
uci set wireless.wdssta=wifi-iface
uci set wireless.wdssta.device='radio1'
uci set wireless.wdssta.mode='sta'
uci set wireless.wdssta.network='lan'
uci set wireless.wdssta.ssid='Secret Cow Level'
uci set wireless.wdssta.encryption='psk2'
uci set wireless.wdssta.key='<key>'
uci set wireless.wdssta.wds='1'
uci set wireless.wdssta.bssid='<AXT1800 5GHz BSSID>'
uci commit wireless
wifi

# DHCP — must be off, or wax202 fights the real router for gateway duty
uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

### AXT1800 (near MT6000, WDS AP)

Must first be switched from factory router mode to AP mode (GL.iNet
LuCI: Internet/Network settings → AP mode). Once in AP mode its `lan`
DHCP is auto-disabled by GL.iNet's own logic — confirm with
`uci show dhcp` (`dhcp.lan.ignore='1'` should already be there).

```sh
uci set wireless.default_radio0.ssid='Secret Cow Level'
uci set wireless.default_radio0.hidden='1'
uci set wireless.default_radio0.key='<key>'
uci set wireless.default_radio0.wds='1'
uci set wireless.radio0.channel='153'
uci set wireless.radio1.disabled='1'         # 2.4GHz off
uci set wireless.guest5g.disabled='1'
uci commit wireless
wifi
```

### MT6000 (central main AP — cleanup only)

WDS flags left over from testing should be removed; nothing else
needs to change.

```sh
uci set wireless.wifi5g.wds='0'
uci set wireless.wifi2g.wds='0'
uci set wireless.mt798612.channel='auto'   # let it pick a clean channel
uci commit wireless
wifi
```

## Testing notes

- **iperf3 for throughput**, wired between real devices — not router-
  to-router (routers are low-power and can mask the true wireless
  ceiling either way; test what you actually use).
- Isolate a specific hop by temporarily wiring the client straight into
  one AP, bypassing other hops.
- CPU was checked (`top`) on both APs during a loaded test — stayed
  under 1%, ruling out router CPU as a bottleneck.
- A brief burst of high ping right after replugging an Ethernet cable
  is normal (bridge MAC relearning + ARP refresh) — not a fault.

## Open items / worth future attention

- MT6000's `guest` and `iot` networks are inert (disabled) but still
  have firewall forwarding rules pointing at its unused `wan` zone —
  harmless today, but would need re-checking before ever enabling them.
- Air's own wifi link to MT6000 underperforms under sustained load
  (retries, throughput collapse) — separate problem from this backhaul
  project, not yet investigated.
- DUP! was never deliberately reproduced under the new setup. No sign
  of it during heavy sustained iperf3 testing so far.
- GL-MT1300 is now free for reuse elsewhere.
