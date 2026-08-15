# iPhone Sync Project Notes

Durable project context, experiment results, and decisions live here. Keep entries
dated, factual, and short enough to scan. The checklist in `plan.md` tracks work;
this file preserves why the work was done and what was learned.

## Working environment — 2026-08-14

- The primary Codex development session runs on the NAS, using Ubuntu 24.04.
- The repository is available on each Mac through an SMB mount.
- Anything that talks to an iPhone over USB, uses Image Capture or `osascript`, or
  depends on macOS frameworks must be run on a Mac with the iPhone physically
  connected. Codex should identify those commands clearly for the user to run.
- Portable application code and NAS-side behavior can be developed and inspected on
  Ubuntu. Do not assume macOS tools are available on the NAS.
- The MVP should stage downloads on local Mac storage. Do not use an SMB-mounted
  staging directory as the transfer target: local temporary-file and atomic-rename
  behavior are important to reliable interrupted-transfer recovery.

## Decisions

### Pending

- Import backend: `afcclient`/libimobiledevice versus Image Capture.
- Mac-to-NAS transport: SSH preferred initially; confirm availability and target path.
- Immich file model: Immich-managed canonical files versus permanent external library.

## Experiment log

Add each hardware/backend experiment here using this form:

### 2026-08-15 — MacBook Air import-backend availability

- Mac and macOS version: MacBook Air M4; macOS 26.6.1 (build 25G76).
- iPhone/iOS version: not yet recorded.
- Backend and version: neither `afcclient` nor `ideviceinfo` is installed or on `PATH`.
- Command or procedure: ran `command -v afcclient`, `command -v ideviceinfo`, and
  `ideviceinfo -k ProductVersion`.
- Result: both discovery commands returned no path; the `ideviceinfo` invocation
  returned `zsh: command not found`.
- Decision / next action: test Image Capture with the connected unlocked iPhone;
  separately determine whether Homebrew/libimobiledevice should be installed for the
  AFC benchmark.

### YYYY-MM-DD — short experiment title

- Mac and macOS version:
- iPhone/iOS version:
- Backend and version:
- Test set (counts, media types, total bytes):
- Command or procedure:
- Result (duration, throughput, correctness, failures):
- Decision / next action:
