# Radio country correction: 2026-10-09

## MT6000

The owner authorized staged audit improvements. Both radios had US configured.
The installed `gl-sdk4-mtk-wifi-v2` handler accepts `country` through netifd.
GL.iNet documents a country control through LuCI. The installed handler confirms
the native UCI path on this build. Do not edit generated driver files directly.

Applied `AU` to `wireless.mt798611.country` and `wireless.mt798612.country`.
Used `wifi reload`. The guarded script is `mt6000-country-au.sh`.
Its default mode only checks prerequisites. Its apply mode requires `--apply`.
It checks board identity, bridge MAC, clean wireless changes, original country,
wired uplink carrier and bridge membership, and the installed handler.
The private original remains at `/root/wireless-before-au.conf` on MT6000.

Fresh SSH and HTTP200 passed. Both radios operate and have associated clients.
The bridge retains its wired uplink and both radio interfaces. The 2.4GHz radio
selected channel 10 at HE20; it previously used channel 8. The 5GHz radio remains
on channel 40 at HE80. Channel selection remains automatic. No SSID, key, or
width setting changed. Apple TV reassociated but its `.8` lease is still waiting.

Live driver channel-map verification passed. Evidence is private
`network-radio/20261009T130059Z/country-map-proof.json`.
The supported read-only commands are `iwpriv ra0 show channelinfo` and
`iwpriv rax0 show channelinfo`. Their output appears in the kernel log.
Read it with `dmesg`; do not clear the kernel log.

Offline inspection of the installed vendor Lua bytecode identifies AU as 5GHz
region14 and US as region13. Its setup function selects 2.4GHz region1 for AU;
US uses region0. It sends country and region values through driver setters.
Extracted the corresponding channel descriptors from the installed `mt_wifi.ko`.
Compared their expanded channel lists with the live driver lists. Both match exactly:

- 2.4GHz: channels 1 through 13, matching region1. US region0 has 1 through 11.
- 5GHz: 36–64 in steps of 4; 100–116 in steps of 4; 132–144 in steps of 4;
  149–165 in steps of 4. These 22 channels match region14. Vendor US region13
  includes 120, 124, and 128. The old on-disk region9 also differs: it lacks 144.

This confirms active AU channel-map application despite stale US text in the
profile files. The driver country string was not read directly. Beacon country,
actual radio-frequency power calibration, and all regulatory behavior were not
independently verified. Do not claim full compliance certification from this check.
UCI, live driver maps, and operation agree. Client acceptance, reboot persistence,
and the 24-hour observation remain open. Unsupported initial country queries and
the first failed offline bytecode parse are preserved in the session history.
No network configuration changed during this verification.

Recovery uses wired management. The saved original is evidence and a recovery
reference. Do not restore US as the continuing operating configuration. If AU
cannot operate, disable the affected radio from wired management and investigate.
Do not force a foreign country to recover wireless operation.

Evidence: private `network-radio/20261009T114832Z` and
`network-radio/20261009T115404Z`. Raw wireless status includes credentials.
Keep these captures private and out of Git. The first read-only collector ended
with an unsupported private-query error on MT6000. Its prior output is preserved.

## WAX202

The owner authorized this separate change and confirmed that the Air Ethernet
adapter and cable were ready for direct LAN recovery. Saved fresh WDS evidence
from both endpoints and the original private wireless configuration before applying.
The guarded script is `wax202-country-au.sh`. Its default mode is read-only.

Applied AU to radio0 and radio1. Radio0 stays disabled. Used the installed
`wifi reload` path. On this build, that command calls `ubus call network reload`.
No full device reboot occurred. Private `/root/wireless-before-au.conf` is retained.
Before/after normalized wireless exports differ only in the two country values.
The network configuration SHA256 is unchanged. No SSID, key, channel, width,
bridge, address, or authentication setting changed.

Fresh SSH verifies runtime `country AU: DFS-ETSI`. WDS is associated with the same
AXT1800 peer on channel 153, 80MHz, with four-address mode on. Bridge membership
is retained. Reported station transmit power is now 28 dBm, versus 20 dBm before.
This is the driver's automatic result under AU, not a manually tuned power value.

WAX202 sent three ARP probes to the gateway and received three replies.
MikroTik sent three ARP probes to WAX202 and received three replies with zero loss.
Fresh WAX202 HTTP returned 200. AXT1800 peer evidence was collected after reconnect.
These tests verify WDS endpoint traffic. They do not replace the requested Air-to-NAS
representative client test or prove every downstream device path.

Evidence: private `network-radio/20261009T133446Z`, including original private config,
guarded apply results, runtime AU/link readback, normalized configuration comparison,
both ARP tests, peer state, HTTP result, and `acceptance.json`.
The owner confirms Air-to-NAS file access and WAX202 browser access both work
after this change. Observe stability for 24 hours, at or after 2026-10-10 13:36 UTC.
Reboot persistence remains untested. The owner also reports that the Air NAS
connection used for this conversation and a Studio live stream continued without
visible interruption during the reload. This is user-observed continuity. No
packet-loss or stream-buffer measurements were collected.

If WDS fails, connect the Air directly to a WAX202 LAN port. WAX202 remains
`192.168.88.4/24`. If DHCP is unavailable across the broken WDS link, use an unused
temporary address in that subnet on the Air's wired interface. Keep AU while
diagnosing the link. Disable the affected radio if it cannot operate correctly.
The saved prior file is a comparison and recovery reference. Do not use the world
country setting as a permanent rollback. No automatic country rollback is installed.

The same preflight observed Apple TV Wi-Fi bound to `.8`, with the expected MAC
and client ID. Address migration is verified. Tailscale acceptance after renewal
is still pending. No further Apple TV setting changed during this session.

## Sources

- [GL.iNet country control](https://docs.gl-inet.com/router/en/4/faq/cannot_scan_android_5g_hotspot/).
- [OpenWrt country configuration](https://openwrt.org/docs/guide-user/network/wifi/wifi_countrycode).
- The installed MT6000 netifd handler and vendor package, captured in private evidence.

## Overnight checkpoint: 2026-10-10

At 12:27 UTC, MT6000 had passed 24 hours since its AU change. Both operating bands
retain the prior channels and widths. Both live driver channel lists still match
the installed AU tables exactly. The owner reports no operational issues.
This passes the MT6000 runtime observation. Reboot persistence is untested.

WAX202 retains AU, channel 153 at 80 MHz, four-address mode, bridge membership,
and the original AP association. Its wireless interface index is unchanged since
the reload. The retained log excerpt shows the intentional reload disconnect;
it contains no later WDS disconnect. This is a limited log check, not continuous
monitoring. Only about 22 hours 51 minutes have elapsed. Keep its 24-hour gate open
until at least 2026-10-10 13:36 UTC (2026-10-11 00:36 Sydney).

Apple TV remains bound to `.8`. The owner explicitly confirms that off-LAN
Tailscale access also works after the address migration. That acceptance passes.
Evidence: private `network-stability/20261010T122714Z` and the owner report.
No configuration change or reboot occurred during these checks.

## MT6000 reboot check: 2026-10-10

The owner authorized the reboot. A changed boot ID proves restart. Fresh key-only
SSH, HTTP200, both operating Wi-Fi bands, and saved AU settings pass. Both live
driver channel maps exactly match the installed AU tables after boot. Wireless,
network, and Dropbear hashes match the pre-reboot state. MT6000 country persistence
passes. Evidence: private `network-reboot/20261010T124012Z/acceptance.json`.
Owner client and off-LAN Tailscale acceptance after reboot remain pending.
WAX202 was not rebooted; its observation and reboot gates stay open.


## WAX202 reboot acceptance: 2026-10-10

The owner accepted approximately 23 hours 49 minutes of healthy observation
instead of waiting for exactly 24 hours. This is an accepted change to the
observation target, not a claim that a full 24-hour check occurred.
The owner confirmed the Air Ethernet adapter and cable were available for recovery
and authorized the reboot. Saved a fresh baseline before reboot.
Evidence: private `network-reboot/20261010T132445Z-wax202/acceptance.json`.

The boot ID changed from `66d42e37-6d16-46f4-8f45-8a772ccfc898` to
`cf38291d-ef07-45fd-ac9d-ef881e3fd441`. Fresh SSH returned on the fourth poll.
Both saved country values and the effective domain remain AU. The WDS station
rejoined the original AP at 80 MHz with four-address mode enabled and LAN bridge
membership. HTTP returned 200. Wireless, network, and Dropbear configuration
hashes match the baseline. Country reboot persistence passes.
Owner NAS-file access and authenticated browser acceptance after reboot remain
pending. No NAS or Mac Studio probe was run.


Owner acceptance after WAX202 reboot: the owner confirms NAS-file access and
authenticated browser access both work from the Air. Recorded 2026-10-11 Sydney.
The shortened runtime observation and reboot acceptance are complete.
