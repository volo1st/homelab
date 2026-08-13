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

### YYYY-MM-DD — short experiment title

- Mac and macOS version:
- iPhone/iOS version:
- Backend and version:
- Test set (counts, media types, total bytes):
- Command or procedure:
- Result (duration, throughput, correctness, failures):
- Decision / next action:
