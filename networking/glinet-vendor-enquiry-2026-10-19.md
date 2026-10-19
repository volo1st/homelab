# GL.iNet patch-coverage enquiry

Prepared: 2026-10-19 Sydney. Deferred after the owner chose production-release
maintenance for this home network. Draft only. Not sent. No response is
required for baseline closure.
Use the vendor's official support channel after owner approval.
Do not attach configuration archives, keys, or raw web logs.

Subject: Exact security fix coverage for MT6000 4.9.1 and MT1300 4.3.25

We use these devices as home LAN access points:

- MT6000: GL.iNet 4.9.1; mediatek/mt7986;
  `r15812+1092-46b6ee7ffc`.
- MT1300: GL.iNet 4.3.25; ramips/mt7621;
  `r20123-38ccc47687`.

Saved package inventories show MT6000 uHTTPd and uhttpd-mod-ubus at
`2021-03-21-15346de8-2`, nginx `1.26.1-1`, and Dropbear `2024.86-1`.
MT1300 has nginx `1.17.7-2`, Dropbear `2022.82-2`, and no uHTTPd package.
We have not run exploit tests.

Please provide these model-specific details:

1. Does the installed MT6000 build include equivalent fixes for
   GHSA-vhx4-3p5q-m59q, GHSA-2mpg-6wp5-435p,
   GHSA-83vv-qrc6-h3hx, GHSA-c2wg-hcff-hqrm, and
   GHSA-wvgh-cm54-q6f6? Please identify patch commits or matching source.
   The upstream fix commits are f6c2fcf, e76736e, 42e30ca, d6205aa,
   and 3c48b9e. Please identify the exact first fixed stable firmware.
2. Your CVE repository names MT6000 4.9.1 for disabled Host validation
   after setup and WebSocket administrator sessions written to readable
   logs. Which exact stable build fixes each issue? Does stable 4.11.0
   contain both corrections?
3. Thirteen authenticated RPC denial-of-service notices name MT6000
   fixes in 4.10.x and MT1300 fixes in 4.5.x. Please identify exact fixed
   builds. MT1300's public catalogue still lists 4.3.25. Does that build
   contain equivalent backports, or is another maintenance build planned?
4. Please identify the fixed builds and required permissions for the
   language-update and Wi-Fi-power timer command-injection notices.
   Please also confirm NAS-web listing-overflow coverage and whether
   the NAS/default-token/firewall fixes described as 4.9.x include 4.9.1.
5. For MT6000 Dropbear 2024.86-1, is OpenWrt advisory 2025-12-16-1
   backported? Our present baseline uses root keys only. We need the
   patch status before introducing non-root or forced-command accounts.
6. Where can we obtain matching source manifests and security-backport
   lists for these exact shipping builds, including kernel, OpenSSL,
   nginx, and ubus? General support status does not identify the patches.

Please distinguish affected, fixed, and inapplicable items. Include any
supported temporary mitigation if no fixed build is available.

The source references and our bounded comparison are in
[the review](firmware-review-2026-10-11.md#vendor-patch-review--2026-10-19-sydney).
