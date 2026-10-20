# Configuration capture and recovery

Updated: 2026-10-20 (Australia/Sydney).
The WDS fault is closed and the current AP layout is accepted.
Use this procedure for a later authorized capture or recovery preparation.
Dated change records below identify later per-device backups.
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

The current capture is `secrets/local/network/20261020T031655Z/`.
Four readable native AP archives match their backup lists and SHA-256 checks.
The MikroTik export and current private dependencies were collected.
Reviewed [device templates](devices/README.md) preserve the essential native
settings. All 33 AP templates pass native parsing. Private authentication files
and remaining vendor state stay in the full archives. Keep the Air private key
available separately; a router archive does not contain that client key.

Current encrypted recovery directory:
`/sandbox/vincent/home_network_backup/20261020T033118Z/`.
Outer archive SHA-256:
`7f38f90ad39317fd1b2452eeab280db3c95ff6480d9de5dc93ef2c34af7e25b5`.
The 145-member archive passes decryption and plaintext hash comparison.
The new encrypted MikroTik binary backup is 43,611 bytes. Two downloads match.
Its random password is inside the outer archive. No certificate objects were
listed. Authorized public keys were inventoried privately.

The bundle includes current runtime, paired firmware images, corrected web
packages, both custom files, and recovery notes. MT6000's native archive omits
its web-host Lua change. MT1300's native archive omits its sysntpd patch.
Both are separately included under `supplement/custom/`. Review the patches
against their exact firmware before restoration. Never copy stale vendor code
over a different build.

The outer passphrase remains privately at
`secrets/local/network-recovery-keys/20261020T033118Z.passphrase`.
The existing helper verifies ignored key storage and refuses repository output.
It now requires an explicit current source. It records inputs and rejects a
resume with different paths. Its CLI guard and offline fixture checks pass.
Its live bundle creation, retrieval, encryption, and decryption checks pass.

To refresh an approved copy, run from this repository:

```sh
python3 scripts/prepare-network-recovery.py --run \
  --source secrets/local/network/<configuration-UTC> \
  --runtime secrets/local/network-runtime/<runtime-UTC> \
  --supplement <reviewed-recovery-assets-directory>
```

The supplement needs a complete reviewed `SHA256SUMS.json`. The current input
paths are saved in the recovery directory's `inputs.json` and `manifest.json`.
Verify them before using `--resume <UTC>`. Partial results remain private.

The owner accepts NAS-local-only storage. NAS loss also loses the bundle and
local key. A second directory on this NAS is not off-host protection.
The previous 20261009 bundle is retained as historical recovery material.
Use the current bundle for the present configuration.

## Prepared device recovery

This is a prepared procedure, not evidence of a completed device restore.
A production restore needs a specific outage and recovery approval.
Use an isolated or spare same-model device first when available.

1. Confirm physical access, power, and a wired Air connection to the target.
2. Keep the recovery archive and private key accessible before taking down WDS.
3. Use the private passphrase file to decrypt the archive into a private directory.
4. Verify the archive hash, included source hashes, model, and paired image hash.
5. Keep the existing known Air SSH key and browser credentials available.
6. For OpenWrt, use the same-family firmware and native full configuration restore.
7. For MikroTik, use the matching version and password-encrypted binary backup.
8. Restore each build-specific custom fix after checking its source and procedure.
9. On official OpenWrt, restore the corrected uHTTPd/module pair through the existing trusted release feed.
10. Verify management IP, DNS, gateway, key access, browser login, role, and AU.
11. Verify WDS and affected client access if the target carries that bridge.
12. If verification fails, use the saved paired firmware/configuration and physical recovery path.

Standalone included APKs previously returned an untrusted verification result.
They are retained evidence, not permission to bypass package trust. The native
signed-index/feed workflow remains required. Keep working Internet access for
that step. Bootloader recovery, replacement hardware, cross-version import,
and actual restores on all five models remain untested.

The [current review](baseline-review-2026-10-20.md) records limits and collector
omissions. Track actions only in
[work package 12](../intial-plan-after-audit.md#work-package-12-network-documentation-and-recovery).
