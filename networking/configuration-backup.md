# Configuration capture and recovery

Capture the working network while the new WDS setup completes its soak test.
Start with the AXT1800 and WAX202. Then capture the MikroTik, MT6000, and MT1300.
Run collection from the Air with confirmed SSH aliases and host keys.

From the Air homelab clone, run:

```sh
bash scripts/capture-network-config.sh --run
```

The collector uses `axt1800`, `wax202`, `mt6000`, `mt1300`, and `mikrotik`.
It stores private files under ignored `secrets/local/network/<UTC timestamp>/`.
It captures OpenWrt board identity, UCI exports, package versions, backup file
lists, and native configuration archives. It captures the MikroTik identity and
text export. It validates archive readability and local SHA-256 checksums.
It retains partial files on failure. It does not publish raw exports to Git.

The MikroTik encrypted binary backup and certificate/key recovery remain manual
steps. The text export alone does not complete MikroTik recovery coverage.

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

The device aliases and MT1300 role are confirmed. No live configuration collection
was performed during the documentation pass. Current exports, reviewed templates,
private recovery copies, and restore verification remain pending.

The collector passed Bash syntax, ShellCheck, and mocked success and interrupted
SSH tests. These tests do not prove compatibility with the five live devices.
Track completion only in
[work package 12](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery).
