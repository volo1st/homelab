# Management access and first hardening batch

Status: first unused-service batch applied and verified on 2026-10-09.
Other hardening batches remain open.

The user requires SSH and browser management on all five devices.
Remote management must work through Tailscale. GL.iNet cloud access is not required.
The user does not require Winbox, FTP, Telnet, API/API-SSL, reverse proxy, or the
MikroTik bandwidth-test server. The user subsequently approved the exact first batch.

## Required access matrix

| Device | Address | Required management | Observed web front end |
|---|---|---|---|
| MikroTik | .1 | SSH and browser; LAN and Tailscale | HTTP WebFig enabled; HTTPS WebFig disabled |
| MT6000 | .2 | SSH and browser; LAN and Tailscale | nginx; HTTP and HTTPS listeners |
| MT1300 | .3 | SSH and browser; LAN and Tailscale | nginx; HTTP and HTTPS listeners |
| WAX202 | .4 | SSH and browser; LAN and Tailscale | uHTTPd; HTTP and HTTPS listeners |
| AXT1800 | .5 | SSH and browser; LAN and Tailscale | uHTTPd; HTTP and HTTPS listeners |

Workspace and Air key-based SSH passed on all five devices in Stage 1.
All four OpenWrt devices still permit root SSH passwords.
A listener does not prove browser certificate validity or trust.
Do not disable HTTP until HTTPS works from the user's browser.
Do not change browser passwords when changing SSH password authentication.

Fresh private evidence:
`secrets/local/network-management/20261009T101202Z/` for MikroTik,
`20261009T101326Z/` for native script parsing and preflight,
and `20261009T101405Z/` for the four OpenWrt devices.
The fresh MikroTik certificate listing contains no certificate objects.
Do not count its flag legend as a certificate. HTTPS needs separate preparation.

## Proposed first batch

Disable these MikroTik services: `ftp`, `telnet`, `winbox`, `api`, `api-ssl`,
and `reverse-proxy`. Disable `/tool bandwidth-server`.
Retain `ssh` and `www` with their existing ports and source-address settings.
HTTPS WebFig remains disabled until its certificate and browser access are ready.
DNS, DHCP, forwarding, accounts, keys, and radio settings are outside this batch.
This does not disable link-layer MAC Winbox, RoMON, or neighbor discovery.
Review those separately before claiming all Winbox-related access is removed.

Native files:

- `mikrotik-management/preflight.rsc`: read-only expected-state guards.
- `mikrotik-management/disable-unused.rsc`: the guarded proposed changes.
- `mikrotik-management/restore-unused.rsc`: restores the captured enabled state.

All three passed RouterOS `:parse`. The read-only preflight also passed.
The apply file was executed after approval. The rollback file remains untested.
The preflight intentionally rejects the completed state; do not rerun the apply file.
The files contain one logical command line to avoid the earlier multiline
interactive parser failure. Re-run preflight immediately before application.
Stop if a required service is disabled, a target is absent, or a prior value differs.

## Application after approval

1. Save fresh service and bandwidth-server state in private evidence.
2. Open an interactive MikroTik SSH session. Enter Safe Mode with Ctrl-X.
3. Confirm the Safe Mode prompt. Keep the session open.
4. Run the read-only preflight. Require `MANAGEMENT_PREFLIGHT_OK` and no errors.
5. Run the guarded apply line. Require its marker and no native error output.
6. Read back every service flag and the bandwidth-server enabled value.
7. Test a second SSH session and HTTP WebFig. Verify local DNS and Internet.
8. Confirm no unexpected configuration change. Exit Safe Mode with Ctrl-X.
9. Record state, client checks, and any untested remote paths in work package 12.

Safe Mode is not a substitute for independent verification.
If a check fails, run the rollback line while the session is available.
For an abnormal lost session, RouterOS Safe Mode should reverse its changes.
Confirm the actual result after reconnection. Do not assume rollback succeeded.
The rollback only restores these seven captured enabled states.

## Remote access and later batches

Tailscale's subnet-router location and actual observed source addresses remain
unverified. Local sessions reach MikroTik with source `.6`; that is not evidence
of a remote Tailscale client's source. Do not apply a LAN-only allowlist yet.
Do not alter Tailscale DNS, routing, access rules, or cloud services in this batch.
A remote client must verify SSH and browser management before source filtering.

Plan HTTPS certificate generation, validity, hostnames, and client trust separately.
Review stronger MikroTik SSH settings without rotating host keys in the same step.
For OpenWrt, change one device at a time. Keep an existing key session and verify a
second key login before disabling SSH password authentication. Preserve browser
login and a verified recovery path. Prepare each exact change before approval.

References: [RouterOS services](https://help.mikrotik.com/docs/spaces/ROS/pages/103841820/Services)
and [Safe Mode](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration+Management).

## Applied first-batch evidence

Private evidence: `secrets/local/network-management/20261009T101809Z/`.
The interactive SSH owner confirmed `Taking Safe Mode session... Success!`.
Fresh preflight passed. A separate SSH session applied the guarded single line
while the Safe Mode owner remained open. RouterOS tracks changes from other
sessions during Safe Mode. The owner later confirmed `Releasing Safe Mode...
Success!` and `Safe Mode released`, then closed.

Readback verified disabled flags for FTP, Telnet, IP Winbox, API, API-SSL, and
reverse proxy. The bandwidth server reports `enabled=false`. SSH and HTTP
WebFig remain enabled. HTTPS WebFig remains disabled. A second SSH session
passed. WebFig returned HTTP 200. Internet HTTPS returned HTTP 200.
All five network-device DNS names resolved to the expected addresses.
Postcommit readback after the owner session closed confirmed the retained state.
RouterOS history lists exactly the six service changes and bandwidth-server
change for this batch. No account, key, source-address, or firewall change occurred.
Remote Tailscale access and a denied-source probe were not tested.

The first interactive terminal misdetected its width and produced fragmented
output. No command was applied through that console. Safe Mode control remained
visible; native commands ran through separate SSH sessions with readable output.
For future interactive sessions, use the documented login suffix
`admin+ct80w` to disable colors and detection and set the terminal width.
See [RouterOS console login options](https://help.mikrotik.com/docs/spaces/ROS/pages/328134/Command+Line+Interface).

Next prepare HTTPS WebFig with a reviewed certificate and browser trust method.
Keep HTTP until the new browser path is verified. Keep source restrictions open
until remote Tailscale observations establish the required source addresses.

## HTTPS deferral

On 2026-10-09, the user deferred certificate and HTTPS work after reviewing
maintenance effort. The public domain is `volo1st.com`, managed through Squarespace.
No DNS migration, validation delegation, certificate issuance, or HTTP removal is
authorized by this decision. Keep current SSH and browser access available.
Continued HTTP management is an accepted risk for now. HTTPS is deferred, not
verified or complete. Tailscale access remains required; its source-path review
is still open. Next prepare a separate bounded SSH-hardening proposal.

## Air and remote functional acceptance

The user confirms post-change Air SSH on all five devices. The user then tested
from the Air through a phone hotspot and Tailscale. All five IP-based SSH checks,
browser logins, `.lan` DNS lookup, and name-based SSH passed.
This confirms required remote function, not its translated source address.
Private capture `network-management/20261009T111342Z` saw only the collector's
active SSH session from `.6`. The short user tests had closed. Requested a held
remote Air SSH session before setting any management allowlist. No source filter
has been changed. Do not attribute `.6` to the Air without correlation.

## Completed source verification and retained administrator

The held remote Air session was observed as `.181`; DHCP/ARP identify that LAN
address as VincentsAppleTV. This supports source translation through the Apple TV,
without direct inspection of its Tailscale settings. Source lists were then limited
to LAN and IPv6 link-local on MikroTik SSH and HTTP only. A new remote Air SSH
command and authenticated browser login passed. Safe Mode was released and the
postcommit state verified. See `management-sources.md` and private evidence
`network-management/20261009T111706Z`, `20261009T111925Z`.

Retain the existing keyed MikroTik administrator. No account rename or credential
migration is part of this audit. Existing keyed-user SSH password refusal, stronger
crypto, service reduction, and source limits provide the implemented protection.
Browser password recovery remains available. HTTPS is still deferred by the user.
