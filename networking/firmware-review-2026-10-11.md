# Firmware review: 2026-10-11 Sydney

For the accepted maintenance scope, see [the owner decision](#home-network-maintenance-decision--2026-10-19-sydney).
For the latest vendor findings, see [the 2026-10-19 review](#vendor-patch-review--2026-10-19-sydney).
The five-device comparison is in [the 2026-10-17 review](#current-review--2026-10-17-sydney).
The initial review below is retained as history.

This is an initial source review. No firmware or update-channel change occurred.
Installed versions come from the authorized runtime audit. The complete advisory
and release-note gate remains open. Do not interpret this review as proof that
any device is free of vulnerabilities.

| Device | Installed | Initial disposition |
| --- | --- | --- |
| MikroTik | RouterOS 7.23.2 | Prepare a security upgrade first. Review the current long-term and stable targets. |
| WAX202 | OpenWrt 25.12.2 | Prepare a separate upgrade to 25.12.5 after package and image checks. |
| AXT1800 | OpenWrt 25.12.5 | Retain provisionally. This is the latest release listed by the reviewed series page. Preserve the proven WDS fix. |
| MT6000 | GL.iNet 4.9.1 | Retain provisionally. This matches the vendor status table. Check model release notes and remaining advisories. |
| MT1300 | GL.iNet 4.3.25 | Retain provisionally. This matches the vendor status table. Preserve and review the local NTP correction on any upgrade. |

## MikroTik priority

The [September advisory, updated October 6](https://mikrotik.com/supportsec/september-2026-vulnerability/)
recommends an upgrade. It lists SSH security fixes in 7.24.2 and 7.23.4.
One certificate and SSH-host-key correction was incomplete in those versions.
The complete correction requires 7.24.3 or 7.23.6 or later.
Our installed 7.23.2 predates these fixes. LAN and Tailscale management restrictions
reduce exposure. They do not substitute for a software correction.
The [security index](https://mikrotik.com/supportsec) also lists newer notices.
Review each relevant notice and the exact target changelog before selecting an image.
No exploit or compromise was established by this review.

## OpenWrt

The [series page](https://openwrt.org/releases/25.12/start) search result lists
25.12.5 as latest. Direct wiki access returned a bot-check page.
The [official GitHub release](https://github.com/openwrt/openwrt/releases/tag/v25.12.5)
is readable. It lists fixes for web request handling, DHCPv6 services, management
applications, and the kernel. WAX202 is older than this release. Exact exposure
depends on installed packages and active services; do not infer it from the version
alone. Verify the WAX202 target image, package inventory, recovery image, and
configuration compatibility before an upgrade. Upgrade one WDS endpoint at a time.

## GL.iNet

The [vendor status table](https://www.gl-inet.com/en-gb/pages/firmware-versions)
lists MT6000 4.9.1 as active. It lists MT1300 4.3.25 in maintenance, with support
through June 8, 2028. The older OpenWrt base alone does not establish missing
vendor patches. The vendor states that it patches older bases.
The [April 2025 advisory](https://www.gl-inet.com/blogs/security-updates/security-advisories-vulnerabilities-and-cves-apr-24-2025)
lists fixes at 4.7.4 for MT6000 and 4.3.25 for MT1300. Installed versions meet
those release thresholds. That notice excludes OpenWrt CVEs.
Complete the remaining vendor release-note and advisory comparison before closing
Stage 5. Recheck all sources before applying an upgrade or after a new advisory.

## Current review — 2026-10-17 Sydney

The source comparison is complete for the five recorded builds. Security
remediation and upgrade acceptance remain open in work package 12, Stage 5.
This review used saved evidence and public sources. It made no SSH connection,
active probe, package installation, service restart, or firmware change.
It does not establish that any device is free of vulnerabilities.

### Recorded software and disposition

The runtime audit and later approved-change records supersede the initial
installed-version table above. These are saved observations, not a new inventory.

| Device | Recorded build | Disposition and next review trigger |
| --- | --- | --- |
| MikroTik RB760iGS | RouterOS and RouterBOOT 7.23.8; long-term | Retain. Reviewed fixes are in this branch. Recheck on a new applicable advisory, a new long-term release, or a change to certificate-based services. Later stability acceptance remains open. |
| AXT1800 | OpenWrt 25.12.5, r33051-f5dae5ece4; qualcommax/ipq60xx | Targeted uHTTPd/module update applied on 2026-10-19 Sydney. Technical and immediate client checks passed. Its 24-hour observation remains open. |
| WAX202 | OpenWrt 25.12.5; ramips/mt7621 | Targeted uHTTPd/module update applied on 2026-10-17. Technical, client, and 26-hour web-service observation checks passed. Other final audit gates remain open. |
| MT6000 | GL.iNet 4.9.1; mediatek/mt7986; r15812+1092-46b6ee7ffc | Prepare the latest stable production update under the owner policy below. The last catalogue check identifies 4.11.0. Recheck before installation. Vendor patch mapping is deferred. |
| MT1300 | GL.iNet 4.3.25; ramips/mt7621; r20123-38ccc47687; local NTP patch | Retain provisionally. Preserve the time repair. Recheck vendor patches and support status. Support ends on 2028-06-08. |

Review retained builds at the next maintenance session, no later than
2026-11-17, or sooner on a new applicable advisory. This is a review trigger,
not a scheduled installation or a new Todoist due date.

### MikroTik findings

The [security index](https://mikrotik.com/supportsec) lists the September SSH,
WebFig, certificate, and bandwidth-test issues. Their final long-term fix
threshold is 7.23.6. The fetch issue, CVE-2026-89020, is fixed from 7.23.4.
The TLS firewall matcher issue, CVE-2026-52346, has an earlier fix threshold.
Recorded 7.23.8 exceeds these thresholds.

The October 6 WebFig notice still says the long-term fix for CVE-2026-84411
is pending. The later October 8 [7.23.8 changelog](https://mikrotik.com/download/routeros?architecture=x86)
explicitly includes this fix and CVE-2026-103903. Retention uses the newer
release evidence. The discrepancy is retained here. The x86 page supplies
the shared changelog only; this RB760iGS uses MMIPS, not an x86 image.

CVE-2025-42611 needs service-specific certificate-authority restrictions
when multiple authorities and certificate-based services are used. An
upgrade alone does not establish that control. Saved runtime evidence says
the OpenVPN server is disabled. Certificate-service scope is not fully
audited. Review it before enabling OpenVPN, CAPsMAN, or Dot1X.

The container advisory, CVE-2026-89021, has no 7.23.x backport. It requires
the container feature. This review did not establish container use on this
MMIPS router. Do not use the general retain decision to approve that feature.
Keep the existing management-source restrictions.

### OpenWrt findings

The [support table](https://openwrt.org/docs/guide-developer/security) lists
25.12 as supported. The [25.12.5 release](https://github.com/openwrt/openwrt/releases/tag/v25.12.5)
is still the latest full release in the reviewed series. It includes June
fixes for DHCPv6, web handling, LuCI, and other core components. Latest full
firmware does not mean that all installed packages have later fixes.

Saved AXT1800 packages and the verified WAX202 25.12.5 image manifest both
include `uhttpd` and `uhttpd-mod-ubus` at `2026.06.16~7b1bec45-r1`.
The WAX202 manifest is image evidence, not a fresh installed-package capture.
Its pre-upgrade `package-world.stdout` describes 25.12.2; do not treat that
file as the post-upgrade inventory.

The following later advisories include the packaged source revision.
No exploit was run. Published impact and the saved package match support
remediation; they do not establish exploitation or compromise here.

| Advisory | Published effect | Upstream correction |
| --- | --- | --- |
| [GHSA-vhx4-3p5q-m59q](https://github.com/openwrt/uhttpd/security/advisories/GHSA-vhx4-3p5q-m59q) | Unauthenticated header-memory exhaustion | `f6c2fcf`: cap header count and bytes |
| [GHSA-2mpg-6wp5-435p](https://github.com/openwrt/uhttpd/security/advisories/GHSA-2mpg-6wp5-435p) | Unauthenticated out-of-bounds write through the ubus HTTP handler | `e76736e`: validate parameter type |
| [GHSA-83vv-qrc6-h3hx](https://github.com/openwrt/uhttpd/security/advisories/GHSA-83vv-qrc6-h3hx) | Unauthenticated memory leak through non-POST ubus requests | `42e30ca`: release request data |
| [GHSA-c2wg-hcff-hqrm](https://github.com/openwrt/uhttpd/security/advisories/GHSA-c2wg-hcff-hqrm) | Request smuggling with an unread body | `d6205aa`: close or drain the request |
| [GHSA-wvgh-cm54-q6f6](https://github.com/openwrt/uhttpd/security/advisories/GHSA-wvgh-cm54-q6f6) | Listener exhaustion; authentication depends on access rules | `3c48b9e`: release the client reference |

The advisory metadata still says no patched version. Later
[upstream commits](https://github.com/openwrt/uhttpd/commits/master/) contain
the corrections. The [25.12 package recipe](https://github.com/openwrt/openwrt/blob/openwrt-25.12/package/network/services/uhttpd/Makefile)
selects `2026.08.24~373145f7`. Both official architecture feeds publish
`2026.08.24~373145f7-r1`. The newer source and package evidence supersede
the stale advisory fix field. Native signature and dependency checks remain
required before installation. See the [separate procedure](changes/openwrt-uhttpd-security.md).

Saved runtime evidence shows AXT1800 and WAX202 web listeners on IPv4 and
IPv6. MT6000 also has uHTTPd on 8080/8443 behind or beside nginx. HTTPS does
not remove these parser defects. LAN-only access reduces Internet exposure
but still admits LAN clients. The accepted use of HTTP is not acceptance
of these newly identified defects.

The [LuCI advisory index](https://github.com/openwrt/luci/security/advisories)
also contains later items. `luci-lib-px5g` is absent from all three saved AP
package lists and the WAX202 image manifest; `px5g-mbedtls` is a different
component. The optional HTTPS-DNS-proxy, adblock-fast, BMX7, travelmate,
banIP, UPnP, and OpenVPN LuCI packages were absent from those lists.
The [mounts ACL issue](https://github.com/openwrt/luci/security/advisories/GHSA-v5f9-62c7-cw29)
belongs to installed `luci-mod-system`. It requires delegated mount-management
access. No such delegated role is documented. Recheck before adding one;
do not mistake its advisory title for a separate package name.

The October [package-feed advisories](https://github.com/openwrt/packages/security/advisories)
concern `ser2net` and `luci-app-ddns`. Both were absent from the saved lists
and WAX202 image manifest. Reassess if packages or delegated roles change.
These bounded package comparisons are not an exhaustive binary audit.

### GL.iNet findings

The vendor [status table](https://www.gl-inet.com/en-us/pages/firmware-versions/)
still lists MT6000 4.9.1. Its newer model download data lists stable 4.11.0,
released 2026-09-28, and testing 4.11.1. The public download API distinguishes
`RELEASE`, `TESTING`, and `SNAPSHOT`; a version number alone does not select
the stable record. Do not describe 4.9.1 as the newest available build.

The [4.11.0 notes](https://dl.gl-inet.com/release/router/release/mt6000/4.11.0)
describe network monitoring, VLAN, Mesh, account, DNS, and VPN features.
They do not identify a fix for the uHTTPd issues above. A security-scan
feature is not proof of those fixes. Defer this feature upgrade while the
accepted AP layout works. This is not owner acceptance of an unresolved
security defect. No change to vendor firmware family is selected.

The [MT1300 notes](https://dl.gl-inet.com/release/router/release/mt1300/4.3.25)
and current download record retain 4.3.25. The vendor's
[end-of-production notice](https://www.gl-inet.com/en-us/blogs/blog/beryl-gl-mt1300-product-end-of-life-notice)
sets security support through 2028-06-08. Production end is not the same as
security-support end. Review the local NTP patch after any later upgrade.

The [router security index](https://www.gl-inet.com/blogs/security-updates/)
lists the April 2025, October 2024, August 2024, and April 2024 notices.
The 2026 entry concerns KVM devices, not these routers. The
[April 2025 table](https://www.gl-inet.com/blogs/security-updates/security-advisories-vulnerabilities-and-cves-apr-24-2025)
sets MT6000's fix threshold at 4.7.4 and MT1300's at 4.3.25. Recorded builds
meet those thresholds and the applicable earlier vendor thresholds.
That notice excludes OpenWrt CVEs.

Vendor policy says it backports fixes. It does not map every upstream issue
to these exact binaries. MT6000 has old uHTTPd/ubus package labels and broad
web listeners. MT1300 has nginx and no `uhttpd` package in its saved list.
Do not infer MT1300 uHTTPd exposure from its old OpenWrt base. Do not infer
that all vendor kernel, TLS, or ubus patches are present from support status.
Exact vendor patch mapping remains open. Do not install official OpenWrt
packages into either vendor image to make versions match.

The [Dropbear advisory](https://openwrt.org/advisory/2025-12-16-1) requires an
authenticated non-root SSH user for privilege escalation. Saved MT6000
Dropbear 2024.86 is within the upstream affected range; MT1300 2022.82 is
outside that range. The recorded SSH baseline uses root keys. Reassess if
non-root or forced-command accounts are added. Vendor patch status remains
separate from that exposure assessment.

### Evidence and maintenance boundaries

Private evidence remains in `secrets/local/network/20261006T103815Z`,
`network-runtime/20261009T004414Z`, and the two `network-firmware` change
directories dated 2026-10-10. Later applied records establish the MikroTik
and WAX202 versions. Private exports were not copied into this report.

Public model-API responses, feed listings, candidate package hashes, and
the failed sandbox download result are retained in the investigation
workspace at `logs/firmware-review/20261017/`. The GL.iNet download page uses
JavaScript. The public API host was read from its application script:
`https://firmware-api.gl-inet.com/cloud-api/model/info`.
API queries used the model and version; records were filtered by stage.

Keep RouterOS on long-term. Use supported OpenWrt release feeds for the WDS
pair. Keep GL.iNet stable builds for the two vendor APs unless a separate
change is selected. Do not enable automatic installations or use testing
images. Review security notices at each maintenance session. Prioritize a
confirmed applicable fix over a feature update. Apply one device at a time,
with a private backup, a validated recovery path, and client acceptance.
Keep the later stability and representative-restore gates open.

## Subsequent authorized device preflight — 2026-10-17

Both APs now have fresh native inventories and private configuration backups.
The recorded older uHTTPd packages are still installed. Signed repository
verification, native candidate fetch, the two-package simulation, storage,
and original firmware image compatibility checks pass. Package/configuration
state and running web-service processes are unchanged. Nothing was installed.
Package-only rollback files are unavailable. Firmware recovery is a proposed
fallback. The owner confirmed Air SSH and physical access to both APs.
WAX202 recovery files are also staged on AXT1800. Fallback acceptance and
installation approval remain pending. See the [complete preflight checkpoint](changes/openwrt-uhttpd-security.md#native-preflight-checkpoint--2026-10-17).
This later session does not change the scope of the earlier source review.

## Subsequent WAX202 application — 2026-10-17

The owner approved the update and its original-firmware recovery fallback.
WAX202 now has the corrected uHTTPd/module pair. One explicit web-service
restart activated it. Fresh SSH, the running executable hash, the LuCI login
challenge, and WDS state pass. Existing configuration and APK world are
unchanged. The owner confirmed Air SSH, browser login, and off-LAN Tailscale
management. The 24-hour observation remains open. AXT1800 is not
updated. See the [application checkpoint](changes/openwrt-uhttpd-security.md#wax202-application-checkpoint--2026-10-17).

## Later observation and preparation — 2026-10-19 Sydney

WAX202's web-service observation passed after about 26 hours, with the same
process, boot ID, continuous WDS association, and owner report of no issues.
AXT1800's refreshed native trust, candidate hashes, two-package simulation,
storage, fresh backup, and original-image tests pass. Its installation still
requires separate approval. See the [current checkpoint](changes/openwrt-uhttpd-security.md#wax202-observation-and-axt1800-preparation--2026-10-19-sydney).

## AXT1800 update applied — 2026-10-19 Sydney

The approved update installed and activated the corrected pair on AXT1800.
Both WDS endpoints now have `2026.08.24~373145f7-r1`. Native package,
configuration, running executable, SSH, LuCI, and WDS checks pass. The owner
confirmed Air SSH, browser login, and off-LAN Tailscale. Review AXT1800's
24-hour observation after 2026-10-20 01:27 Sydney. See the
[application checkpoint](changes/openwrt-uhttpd-security.md#axt1800-application-checkpoint--2026-10-19-sydney).

## Vendor patch review — 2026-10-19 Sydney

Outcome: exact upstream patch coverage remains unresolved. The vendor's
[CVE repository](https://github.com/gl-inet/CVE-issues) also contains later
model-specific findings that are absent from its router security index.
These findings supersede the earlier feature-only reason to defer MT6000
4.11.0. They do not establish a complete fix in that release.
No device connection, probe, package change, or network change ran.

### Observed records and source comparison

Saved package inventories from 6 October show MT6000 uHTTPd/module
`2021-03-21-15346de8-2` and nginx `1.26.1-1`. MT1300 has nginx `1.17.7-2`
and no uHTTPd package. Both have the vendor VPN and plugin RPC packages.
MT6000 also has `gl-sdk4-nas-web`. Installed packages alone do not prove
that each optional feature is active or reachable.

The upstream [15346de8 ubus source](https://github.com/openwrt/uhttpd/blob/15346de8/ubus.c)
contains the REST call path and unchecked parameter iteration corrected by
[e76736e](https://github.com/openwrt/uhttpd/commit/e76736e).
Its [client source](https://github.com/openwrt/uhttpd/blob/15346de8/client.c)
lacks the cumulative header limits added by
[f6c2fcf](https://github.com/openwrt/uhttpd/commit/f6c2fcf).
This is source evidence for the revision in the label. It does not prove
that the installed vendor binary lacks equivalent backports.
All five uHTTPd issues in the earlier table still need vendor mapping.

The public `gl-feeds` branches contain nginx and Dropbear recipes that
match the saved MT6000 labels. They do not provide a matching uHTTPd recipe
or a shipping-build source manifest in the inspected trees.
`libuhttpd` is a separate project; its recipe cannot establish an OpenWrt
uHTTPd fix. The vendor's `openwrt-patch-status` pages describe device support
and compilation, rather than security backports. The inspected `gl-image`
branches cover other models. No exact source-to-binary mapping was found.
This bounded search does not establish that such source is unavailable.

### Later vendor findings

| Finding | Published scope and our conclusion |
| --- | --- |
| [Host validation after setup](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/Host%20header%20validation%20disabled%20after%20initialization%20enables%20DNS%20rebinding%20on%20GL-MT6000.md) | Names MT6000 4.9.1. Reports unauthenticated information disclosure through DNS rebinding. No fixed build is named. LAN-only listeners do not eliminate a browser-mediated path. Wider impact is not established. |
| [WebSocket session in logs](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/WebSocket%20session%20token%20exposed%20in%20URL%20query%20string%20and%20plaintext%20logs%20on%20GL-MT6000.md) | Names MT6000 4.9.1. Requires access to a log containing a live session. Root-key-only SSH reduces one entry path. It does not establish that local processes cannot read the log. No fixed build is named. Treat future web logs as potentially secret-bearing. |
| [Authenticated management RPC failures](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/wg-server.set_peer%20Null%20Pointer%20Dereference%20Denial-of-Service%20Vulnerability%20After%20Authentication.md) | Thirteen notices cover traffic, OpenVPN, WireGuard, and plugin methods. They name MT6000 fixes in 4.10.x and MT1300 fixes in 4.5.x. These family-level references do not identify an exact corrected build. Do not substitute the separate “Native OpenWrt” row for installed MT6000 vendor firmware. |
| [NAS listing overflow](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/Heap%20buffer%20overflow%20in%20nas-web.get_file_list%20leading%20to%20authenticated%20denial%20of%20service.md) | MT6000 and its installed NAS-web package are in published scope. Authentication and a large listing are required. Feature activation and a corrected version are not established. |
| [Language timer](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/Language%20Auto-Update%20Cron%20RCE.md) and [Wi-Fi timer](https://github.com/gl-inet/CVE-issues/blob/main/4.0.0/Wi-Fi%20Timer%20Power-Schedule%20Cron%20RCE.md) | Both list MT6000 4.6 or later and command execution through schedule input. No upper affected version or fixed build is given. Confirm required permissions and exact fixed versions. No schedule API was tested. |

Earlier vendor fixes with exact model thresholds remain satisfied.
Some later NAS/firewall notices say only “fixed in 4.9.x”. Ask whether that
includes installed 4.9.1. Do not infer that all newer notices are resolved
from the April 2025 table. Reports naming only other models are not
confirmed findings on these two devices.

Fresh vendor catalogue data still lists MT6000 stable 4.11.0 and MT1300
stable 4.3.25. The MT1300 4.5.x fix reference conflicts with that published
maintenance catalogue. This needs clarification. Do not invent an MT1300
upgrade target. Preserve its local NTP correction.

### Initial disposition and evidence

The owner decision below supersedes this initial closure requirement.

Keep security closeout open for both vendor devices. Request an exact
model/build response and corresponding patch evidence. The
[prepared enquiry](glinet-vendor-enquiry-2026-10-19.md) is a draft and has
not been sent. A response must distinguish covered, affected, and
inapplicable issues. Then prepare a separate upgrade or mitigation procedure
for review if required. No new risk acceptance or firmware-family choice
was made. Do not mix official OpenWrt packages into vendor firmware.

Public source metadata, pinned source comparisons, catalogue responses,
and the 63-notice comparison are in the investigation workspace at
`logs/firmware-review/20261019-vendor/`. Its `sources.json` records retrieval
times, URLs, hashes, and storage. Full public notices are retained locally
under ignored `backups/vendor-review/20261019/`. The committed comparison
contains relevant summaries and affected-version lines. Saved package
identities are in `saved-package-comparison.json`; this is not a fresh audit.
The review does not prove compromise or a complete absence of defects.

## Home-network maintenance decision — 2026-10-19 Sydney

The owner confirmed that this is a home-network baseline. Use the latest
supported production firmware for each model and current firmware family.
Use stable GL.iNet and official OpenWrt releases. Retain MikroTik's chosen
long-term channel. Exclude beta, testing, and snapshot builds.

Keep checks bounded: read release notes and clear applicable advisories,
back up configuration, check compatibility and rollback, update one device
at a time, and verify normal functions. Preserve MT1300's local NTP patch.
The last catalogue check identifies MT6000 stable 4.11.0 as an update
candidate and MT1300 4.3.25 as current. Recheck before application.
No installation or network change was authorized by this policy decision.

Detailed source-to-binary patch mapping and the vendor response are removed
as baseline closure requirements. The enquiry is deferred and remains unsent.
Keep the source findings as dated maintenance evidence. Patch coverage stays
unknown; this decision does not prove that a published defect is fixed.
Record a clear unresolved advisory issue briefly when reviewing the selected
production release. This policy accepts the limits of release-based
maintenance. It does not establish a vulnerability-free network.

The canonical work package records the changed gate dispositions explicitly.
Production-version verification, approved updates, and their normal-function
acceptance remain open. Recovery and other final audit gates are unchanged.
