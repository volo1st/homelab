# Home automation — historical source record

Source: `confluence/117604353`, version 2, last changed 2025-07-27.
Migration source audit: 2026-10-08. Most material is copied adviser context.
This record preserves historical examples and research leads. It does not
establish the user's installed devices or an accepted automation design.
Use the [standing plan](plan.md) and [audit work plan](intial-plan-after-audit.md)
for current decisions and implementation work.

## Adviser model and reported setup

The adviser separated four layers: physical devices (lights, switches, outlets
and sensors), device firmware, coordination software, and hub hardware.
The adviser preferred open-source device firmware for local control, upgrades
and less dependence on vendor applications. Limited preinstalled choices and
potentially difficult flashing were the stated tradeoffs.

The reported setup used Tasmota devices, Homebridge for Apple Home/Siri and
Denon receiver integration, and an Apple TV for remote status and automation.
Most simple on/off schedules ran on devices. Receiver-on/lights-off and
receiver-off/lights-on rules ran through Apple Home. Home Assistant had been
tried but was unnecessary for that adviser's simple setup; it remained an
option for more complex rules. The older ESPHome comparison was personal
experience, not a current product evaluation.

The source described Tasmota browser configuration, MQTT integration,
Prometheus metrics and feature-specific builds. Device-local schedules were
preferred to reduce coordination-service dependence. This is a historical
rationale, not evidence of tested clock, power-loss or network-loss behavior.

The adviser preferred Ethernet-connected Apple TV hardware and mentioned
Tailscale exit-node use. The repository's network documentation owns current
network state. This source does not establish Apple hub or Thread support for
any particular model.

## Untested integration and hardware leads

The source proposed Tasmota-to-Apple/Home Assistant paths using Matter, and
MQTT-to-Homebridge/Home Assistant paths without it. Its diagram also illustrated
bridged devices and several controller ecosystems. The adviser had not tried
Matter and had not researched Thread in depth. Wi-Fi was reported adequate
for that household. Keep protocol, radio, bridge and controller roles distinct
when a future implementation is evaluated. No present compatibility matrix
or supported path is established here.

Historical device leads include Athom preflashed products and an ESP32-C3 AU
plug, Adafruit ESP32-C6 Feather and QT Py ESP32-C3 boards, SHT40 temperature/
humidity sensing, SCD30/SCD40 CO2 sensing, PMSA003I particle sensing, displays,
LEDs and buttons. The source preferred newer chip families for feature capacity.
Exact hardware revision, firmware and required capabilities need verification
before selection. These are leads, not a purchase list or a wiring procedure.

## Information retained from the images

The screenshots illustrate browser-based sensor control, RGB controls,
energy monitoring, repeating device-local timers and centralized Apple Home
status. Sensor examples include temperature, humidity, CO2 and particles.
The metrics view illustrates environmental readings and device-health metrics.
The photograph shows prototype microcontroller and sensor assemblies; it does
not provide a tested bill of materials, pin mapping or calibration evidence.

Apple Home examples include alarm-linked playback, receiver/light linkage,
last-person-leaves actions and phone widgets for remote status. These are
adviser examples, not the user's selected schedules or automation requirements.

All 11 images were hash-checked and visually reviewed. The proposed migration
retains useful information in text and excludes the original binaries. Private
household labels, calendar/location details, identifiers, addresses and live
readings are not reproduced. The originals remain in private migration storage;
this record is not a claim that they have a durable archive or backup.

## Generated buying material — excluded

The source appended a generated 2025 Australian smart-bulb guide. Its brand
rankings, CRI values, prices, availability and protocol/integration claims lack
supporting evidence in this source. They are excluded from purchasing guidance.
High colour quality and local control were interests in that generated text;
they are not accepted requirements. No buying research was added for migration.

## Original URLs — unreviewed

The following 27 occurrences preserve source order, duplicates and original
malformed targets. Availability and technical claims were not verified.
They are source leads, not recommended products or current instructions.

```text
https://tasmota.github.io/docs/)
https://templates.blakadder.com/)
https://esphome.io/
https://templates.blakadder.com/
https://www.athom.tech/tasmota
https://www.athom.tech/blank-1/tasmota-esp32-c3-au-plug-v3
https://homebridge.io/)
https://www.home-assistant.io/)
https://tailscale.com/kb/1103/exit-nodes
https://en.wikipedia.org/wiki/Matter_(standard)
https://en.wikipedia.org/wiki/Thread_(network_protocol)
https://tasmota.github.io/docs/Matter/
https://tasmota.github.io/docs/Matter/)
https://tasmota.github.io/docs/Home-Assistant/)
https://tasmota.github.io/docs/Homebridge/)
https://tasmota.github.io/docs/Home-Assistant/)
https://www.adafruit.com/product/5933
https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/5933/24892281)
https://www.adafruit.com/product/5405
https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/5405/21283808)
https://www.adafruit.com/product/4885
https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/4885/13694670)
https://www.adafruit.com/product/5187
https://www.adafruit.com/product/4632
https://www.adafruit.com/search?q=display
https://www.adafruit.com/search?q=led
https://www.adafruit.com/search?q=button
```

## Suggested URL repairs — unverified

These candidates remove one stray final parenthesis from malformed targets.
The original targets remain above. No corrected target was fetched.

| Original target | Candidate target |
| --- | --- |
| `https://tasmota.github.io/docs/)` | `https://tasmota.github.io/docs/` |
| `https://templates.blakadder.com/)` | `https://templates.blakadder.com/` |
| `https://homebridge.io/)` | `https://homebridge.io/` |
| `https://www.home-assistant.io/)` | `https://www.home-assistant.io/` |
| `https://tasmota.github.io/docs/Matter/)` | `https://tasmota.github.io/docs/Matter/` |
| `https://tasmota.github.io/docs/Home-Assistant/)` | `https://tasmota.github.io/docs/Home-Assistant/` |
| `https://tasmota.github.io/docs/Homebridge/)` | `https://tasmota.github.io/docs/Homebridge/` |
| `https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/5933/24892281)` | `https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/5933/24892281` |
| `https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/5405/21283808)` | `https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/5405/21283808` |
| `https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/4885/13694670)` | `https://www.digikey.com.au/en/products/detail/adafruit-industries-llc/4885/13694670` |

## Personal setup report — 2026-08-01

Additional source: `todoist/6g2v2MVVP2FJwj8w`, refreshed on 2026-10-08.
This is the owner’s historical report, separate from the adviser examples above.

The comment marked an Apple TV hub and an office sensor as set up. It reported
duplicate sensor entries that appeared resolved after manual removal. Exact
device models, protocol, software versions and later test results are absent.
This record does not establish current installed state or reliable recovery.

Downstairs signal coverage remained unresolved. An additional powered “TR”
was a possibility; the abbreviation and required device role are not confirmed.
Spare smart plugs were to be checked for support. Neither proposal is a selected
network change or purchase. The maintainable-baseline task and the separate
Matter-control-centre decision remain open in Todoist. No platform is chosen.
