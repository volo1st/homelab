# Configuration capture and recovery

Updated: 2026-10-17 (Australia/Sydney).
The WDS fault is closed and the current AP layout is accepted.
Use this procedure for a later authorized capture or recovery preparation.
This documentation update made no device connection or new backup.
Run collection from the Air or the Linux development container with confirmed
SSH aliases and host keys. Configuration collection can run from either side
of a working bridge. Use the Air for independent cross-bridge reachability tests.

From the homelab clone, run:

```sh
bash scripts/capture-network-config.sh --run
```

The collector uses `axt1800`, `wax202`, `mt6000`, `mt1300`, and `mikrotik`.
It stores private files under ignored `secrets/local/network/<UTC timestamp>/`.
It captures OpenWrt board identity, UCI exports, live IPv4 state, package versions, backup file
lists, and native configuration archives. It captures the MikroTik identity and
text export. It validates archive readability and local SHA-256 checksums.
It retains partial files on failure. It does not publish raw exports to Git.

The collector does not create a MikroTik encrypted binary backup. That step
is separate and has already passed creation and retrieval checks as recorded
below. Certificate/key dependencies and an actual restore remain separate
recovery requirements. The text export alone is not complete recovery coverage.

## Repository and private recovery copies

Commit reviewed configuration templates under `networking/devices/<device>/`.
Keep secrets in the existing ignored `secrets/local/` convention or approved
private recovery storage. Use an encrypted backup for their recovery copies.
This work does not introduce a new repository encryption system.

Each device directory must eventually contain:

- Model, role, firmware version, collection date, and management address.
- Reviewed native configuration or an executable configuration template.
- Required packages and firmware image checksum.
- Secret placeholders and the private recovery-copy location.
- Apply, verification, and rollback instructions.
- Evidence for a representative restore check.

A backup is collected when the files exist and pass integrity checks.
A device is reproducible when its configuration, dependencies, and secrets can
be restored and the documented verification passes. Keep these gates separate.

## OpenWrt capture

Use the device's confirmed alias in these commands. Save output in a private
directory with mode `0700`. Set `umask 077` first. Treat every raw export as
secret-bearing until review is complete.

```sh
ssh <device-alias> 'ubus call system board'
ssh <device-alias> 'uci export'
ssh <device-alias> 'sysupgrade -l'
ssh <device-alias> 'if command -v apk >/dev/null 2>&1; then apk info; else opkg list-installed; fi'
```

Redirect each command into a separate private file. Do not print or paste the
complete UCI export into chat. It contains wireless keys and can contain other
credentials. A broad string replacement is not a reliable redaction policy.
Review complete files and use placeholders for secret values before committing.

For the native recovery archive, use LuCI's configuration-backup download.
The collector streams `sysupgrade -b -` into the private local archive.
The official OpenWrt [backup implementation](https://github.com/openwrt/openwrt/blob/v25.12.5/package/base-files/files/sbin/sysupgrade)
supports this standard-output form. It creates no remote archive to retrieve.
The investigation backup workflow also demonstrates `sysupgrade -b`, private
retrieval, archive validation, hashes, and removal of the temporary router file.
Check the archive against `sysupgrade -l`. Record custom files and packages
that need separate recovery. A configuration archive is not a firmware image.

Keep firmware and configuration paired. Use the current official OpenWrt archive
for AXT1800 recovery to official OpenWrt. Keep the old GL.iNet archive paired
with its verified GL.iNet rollback image.

## MikroTik capture

Record the RouterOS version and model first. Use the installed version's export
syntax. In RouterOS 7, `/export` hides sensitive fields by default.
Review the result before committing it. Custom scripts and comments can still
contain credentials.

Store a password-encrypted binary backup in private recovery storage.
Keep the reviewed text export in Git. Export does not include user passwords,
installed certificates, or SSH keys. Inventory those recovery dependencies
separately. Restore on a compatible model and version before claiming recovery
is tested.

Source: [MikroTik configuration export and import](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration+Management).

## Current coverage

The 2026-10-06 capture completed from the Linux development container.
Its private files are in `secrets/local/network/20261006T103815Z/`.
All four OpenWrt archives passed readability checks. All recorded checksums
passed. The MikroTik text export contains 28 menu sections.
Capture directories are `0700`, files are `0600`, and Git ignores the capture.
No raw configuration was committed.

The encrypted bundle at
`/sandbox/vincent/home_network_backup/20261009T085347Z/` passed decryption,
integrity, and retrieval checks. It contains an encrypted MikroTik binary
backup with matching downloaded copies. Private recovery secrets remain
outside Git. Required SSH-key dependencies were inventoried.
The corrected certificate listing contained no certificate objects.
See [Stage 0 evidence](../intial-plan-after-audit.md#stage-0-prepare-recovery-and-the-first-change).

The owner accepted NAS-local storage on 2026-10-09. NAS loss also loses this
copy. An off-host copy is deferred under that accepted risk; it is not an
unperformed deployment silently required by the current baseline.

MikroTik and WAX202 upgrade preparation also saved paired recovery material.
See [MikroTik firmware](changes/mikrotik-firmware.md) and
[WAX202 firmware](changes/wax202-firmware.md).
The initial bundle predates later configuration and firmware changes.
No complete post-change capture of the retained 2026-10-17 state was verified
in this closeout. Do not assume the old bundle exactly reproduces that state.

Reviewed templates, final-state recovery copies, and a representative restore
remain open. No router restore, Netinstall, or recovery flash was tested.
A successful decrypt proves archive access, not device recovery.
Use an isolated or spare target first when practical. A production restore
requires a separately approved outage and physical recovery path.

The collector passed Bash syntax, ShellCheck, and mocked success and interrupted
SSH checks. It also completed live collection on all five devices from Linux.
Track the remaining implementation only in
[work package 12](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery).
