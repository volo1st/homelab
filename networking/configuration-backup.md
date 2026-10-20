# Configuration capture and recovery

Updated: 2026-10-20 (Australia/Sydney).
Keep a current private configuration copy, paired firmware, and the two local
fixes. Refresh them after a meaningful configuration or firmware change.
A live restore drill is not required for this home-network baseline.

## Current coverage

Current encrypted recovery directory:
`/sandbox/vincent/home_network_backup/20261020T033118Z/`.
Private configuration source: `secrets/local/network/20261020T031655Z/`.
The outer passphrase file is
`secrets/local/network-recovery-keys/20261020T033118Z.passphrase`.
Keep it private. Keep the Air's SSH private key available separately.

The bundle contains all five configurations, paired firmware, package records,
the encrypted MikroTik binary backup, and both local fixes. Hashes, decryption,
and repeated MikroTik downloads pass. All 33 [essential AP templates](devices/README.md)
pass native parsing. The full private archives retain credentials and vendor state.
Actual router restoration, replacement hardware, and bootloader recovery remain
untested. These are recovery notes, not pending completion gates.

The owner accepts NAS-local-only storage. NAS loss also loses the bundle and
local key. Another directory on this NAS is not off-host protection.
Earlier backups remain historical copies. Use this bundle for the present state.

## Refresh a backup

From the homelab clone, collect the five device configurations:

```sh
bash scripts/capture-network-config.sh --run
```

The collector uses the known SSH aliases. It saves ignored private files under
`secrets/local/network/<UTC>/`. It validates native AP archives and source hashes.
It also collects the MikroTik text export. Keep errors and partial results private.
A complete runtime audit is not needed for every backup refresh.

Use the existing helper to refresh the encrypted copy and MikroTik binary backup:

```sh
python3 scripts/prepare-network-recovery.py --run \
  --source secrets/local/network/<configuration-UTC> \
  --supplement <reviewed-recovery-assets-directory>
```

The current supplement path is saved in the recovery directory's `inputs.json`.
That file records the original collection paths. If the investigation workspace
is removed, recover `supplement/` from the current encrypted bundle before a
later refresh. The bundle itself does not require the old workspace for recovery.
Keep its firmware, custom files, and `SHA256SUMS.json` current before reuse.
The helper verifies source hashes, encryption/decryption, and repeated MikroTik
retrieval. It requires an explicit source and refuses output inside the repository.
Use `--runtime` only when a relevant runtime capture already exists.

## Prepared device recovery

Use this only when recovery is needed. Confirm physical access and a wired Air
connection before a disruptive restore. Keep recovery files reachable if WDS fails.

1. Decrypt the bundle into a private directory with the saved passphrase file.
2. Match the target model and firmware family to its saved image and configuration.
3. Use the full native AP archive or password-encrypted MikroTik binary backup.
4. Restore the build-specific local fixes and required packages below.
5. Check management access and the affected household connection.

Native archives omit two custom fixes. Their saved files are under
`supplement/custom/`. Follow [MT1300 time recovery](changes/mt1300-time.md)
and [MT6000 hostname recovery](changes/mt6000-firmware.md#browser-hostname-compatibility).
Do not copy old vendor code over a different firmware build without review.

Official OpenWrt stock images need the corrected uHTTPd/module pair from the
existing trusted release feed. Follow [the package procedure](changes/openwrt-uhttpd-security.md).
Included APKs alone do not prove standalone trust. Do not bypass package verification.
Do not mix GL.iNet and official OpenWrt configuration archives.

Device-specific details are in [the device directories](devices/README.md).
[The dated review](baseline-review-2026-10-20.md) retains verification evidence.
