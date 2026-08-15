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

### 2026-08-15 — MacBook Air Image Capture smoke test

- Mac and macOS version: MacBook Air M4; macOS 26.6.1 (build 25G76).
- iPhone/iOS version: not yet recorded.
- Backend and version: built-in Image Capture; Homebrew 6.0.16 is available for a
  later libimobiledevice/AFC comparison.
- Test set: a photo, a short video, and a 1.83 GB MOV. No existing Live Photo was
  available for this smoke test.
- Command or procedure: connected and unlocked the iPhone, used Image Capture to
  import the sample to local storage without enabling deletion.
- Result: the phone appeared in Image Capture, including a `Delete after import`
  control; all selected sample media imported successfully. The 1.83 GB MOV appeared
  to complete in only a few seconds over a 20 Gbps-rated USB-C cable. This is a
  qualitative observation, not yet a timed throughput benchmark.
- Decision / next action: run a timed representative Image Capture benchmark. Install
  libimobiledevice via Homebrew only when ready to compare the AFC backend.

### 2026-08-15 — Image Capture Live Photo and edit behavior

- Mac and macOS version: MacBook Air M4; macOS 26.6.1 (build 25G76).
- iPhone/iOS version: not yet recorded.
- Backend and version: built-in Image Capture.
- Test set: one newly taken Live Photo, followed by the same Live Photo after an edit.
- Command or procedure: imported each version through Image Capture and inspected the
  exported file names and sidecars.
- Result: the original imported as `IMG_9780.HEIC` and `IMG_9708.MOV`; the edited
  version imported as `IMG_E9780.HEIC` and `IMG_E9780.MOV`. No `.AAE` sidecar was
  produced.
- Decision / next action: treat source/backend relationship data or an import batch as
  authoritative for grouping; never infer a Live Photo relationship solely from the
  exported basename. Support the edited rendered pair even when no `.AAE` exists.

### 2026-08-15 — Image Capture scripting availability

- Mac and macOS version: MacBook Air M4; macOS 26.6.1 (build 25G76).
- Backend and version: built-in Image Capture.
- Command or procedure: with the iPhone connected, ran `osascript -e 'tell application
  "Image Capture" to get name of every device'` and `sdef "/System/Applications/Image
  Capture.app"`.
- Result: the AppleScript command failed with `Expected class name but found
  identifier` (error -2741); `sdef` failed with error -192. Image Capture does not
  expose the required scripting dictionary/interface for this approach.
- Decision / next action: do not use fragile GUI automation as the CLI backend;
  install and evaluate libimobiledevice/AFC.

### YYYY-MM-DD — short experiment title

- Mac and macOS version:
- iPhone/iOS version:
- Backend and version:
- Test set (counts, media types, total bytes):
- Command or procedure:
- Result (duration, throughput, correctness, failures):
- Decision / next action:
