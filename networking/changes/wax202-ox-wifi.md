# WAX202 studio Wi-Fi for OX

Applied: 2026-10-18, 05:26 UTC (16:26 Sydney).
State: radio enabled and technical checks passed. OX connection and app control passed by owner report.

## Purpose and retained profile

The owner reported that the Universal Audio OX Amp Top Box could not find
usable 2.4 GHz Wi-Fi after the kitchen/study AP swap. The OX is in the studio.
The owner approved a local AP on WAX202 and chose `Moo Moo Farm` as its SSID.
The password was supplied separately. Keep it in private configuration only.
The original cause of the missing networks was not confirmed.

| Setting | Retained value |
| --- | --- |
| Device / interface | WAX202 `radio0` / `phy0-ap0` |
| SSID | `Moo Moo Farm`, visible |
| Band / mode | 2.4 GHz, HT20, 20 MHz |
| Channel / country | 1 / AU |
| Security | WPA2-Personal, CCMP (AES); protected management frames optional |
| LAN | Existing `lan` / `br-lan` |
| Client isolation | Off |

Channel 1 was the saved starting value. The disabled radio could not provide
a passive channel survey. No active scan ran. Do not call it the least busy
channel. This profile favors compatibility over maximum client speed.

## Application and evidence

Fresh SSH verified the current board, disabled 2.4 GHz radio, working WDS,
and no pending UCI changes. A native private configuration backup contains
36 members. Its copied hash matches the device. A candidate changed only
`radio0` and `default_radio0`. Native UCI parsing passed before application.

The configuration file was applied and activated with `wifi up radio0`.
The installed helper targets radio0 for down/up and reloads configuration
between those operations. Runtime comparisons verified that the unchanged
radio1 stayed connected. No network service restart or device reboot ran.
A 180-second rollback guard was disarmed after technical checks passed.

Hostapd reports `Moo Moo Farm` enabled on channel 1 at 20 MHz. Its generated
settings confirm WPA2, CCMP, optional protected management frames, LAN
bridging, and no isolation. The first local validator expected `rsn_pairwise`;
the device uses the equivalent `wpa_pairwise=CCMP` with `wpa=2`. Corrected
validation passed. No configuration retry was needed.

Radio1's complete runtime object is unchanged. Its WDS association start
time is unchanged. Channel 153, 80 MHz, four-address mode, peer, and saved
5 GHz configuration are retained. Only `/etc/config/wireless` changed among
the configuration files. The boot ID is unchanged.

OX connection and app control passed by owner report.
Reboot persistence and a new full recovery capture are not claimed.
The earlier web-service update's observation gate remains open. Record this
new radio change separately when interpreting later behavior.

Private evidence is in the investigation workspace at
`backups/ox-wifi/20261018T052336Z/`. It includes the original backup,
candidate, commands, raw state, native parsing, security checks, rollback
record, and `technical-passed.json`. Keep secret-bearing files ignored by Git.
No NAS or Mac Studio connection or active probe ran.

## Recovery and client setup

The saved original wireless file is in the private evidence and the recorded
AP temporary directory. If rollback is needed, first compare current state
with this change. Restore that file only if no later wireless change would
be lost. Apply it with the same radio0-specific helper. Do not disable radio1.

To join OX, first connect the app device to OX's own hotspot if needed.
Select `Moo Moo Farm` in the OX app and enter the private password. Return
the app device to the home LAN. Verify that the app finds and controls OX.
See the [UA manual, pages 59–60](https://media.uaudio.com/support/ox/OX%20Amp%20Top%20Box%20Manual%20210811.pdf#page=59).
