# iPhone Sync Plan

This plan optimizes for reaching a safe, usable manual workflow quickly, then
hardens it from real-world use. Unit tests should cover deterministic code we
own—especially SQLite manifest transitions and destructive-command eligibility—as
soon as that code exists. Real-device and real-service testing remains the source
of truth for the iPhone, NAS transport, and Immich integration.

## How this plan is maintained

- Keep this file as the concise source of truth for scope, ordering, and completion.
- Put brief, actionable dependencies immediately under a checklist item, indented as
  `Needs you:` or `Research:`. Remove them once resolved.
- Record durable details—benchmark results, commands run on a Mac, configuration
  values, decisions and their rationale, and unresolved observations—in
  [`project-notes.md`](project-notes.md). Link to the relevant dated note from the
  checklist item when useful.
- Check an item only when its result and any consequential decision are recorded in
  the notes file. A checkmark should remain meaningful weeks later.

## Stage 0 — Decisions and device discovery

- [x] Choose the local staging location on each Mac: `~/Pictures/iphone-sync`.
- [x] Choose the exact free-space margin the CLI should reserve before its first
      import: the planned new-download total plus 5 GiB.
- [x] Choose the initial NAS transport: SSH to host `nas`. Connection confirmed;
      document the Samba fallback only if SSH becomes unsuitable.
- [x] Choose host-side NAS paths, with the Immich container mounts to be configured
      when Immich is set up:
  - Photos: `/ocean/personal/photos/iphone/{incoming,.uploading}/`
  - Videos: `/ocean/personal/videos/iphone/{incoming,.uploading}/`
  - Immich will mount and scan only each `incoming/` directory; `.uploading/` remains
        outside its scan roots.
  - Confirmed: the paths have been created on the NAS host.
- [x] Prototype iPhone enumeration and download with both candidate backends
      (`afcclient`/libimobiledevice and Image Capture). Image Capture worked manually
      but has no usable scripting interface; AFC successfully enumerated and copied
      DCIM media. Deletion behavior remains a Stage 2 real-device test.
  - Recorded: [AFC and Image Capture experiments](project-notes.md).
- [x] Run the defined benchmark on a representative set that includes photos,
      videos, and Live Photos; record throughput and failure behavior.
  - Recorded: [AFC batch benchmark](project-notes.md).
- [x] Pick the initial import backend, while keeping the CLI independent of it.
  - Decision: use `afcclient`/libimobiledevice first; retain Image Capture only as a
        manual fallback until another scriptable native interface is available.
- [x] Confirm the clearing policy: Stage 1 never clears the phone. A subsequent
      manual and interactive `clear` operation requires a complete local asset group
      and a successfully published NAS copy. It does not require an end-to-end
      checksum comparison. Keep the local copy until a separate prune operation.

## Stage 1 — MVP: usable manual import and NAS copy

Goal: manually import media from either Mac and copy it to the NAS. Inspect the
published files directly or through Immich when Immich is available. Do not delete
media from the iPhone or local staging during this stage.

- [x] Scaffold the `iphone-sync` Python CLI and its per-Mac configuration.
  - Recorded: [CLI and manifest scaffold](project-notes.md).
- [ ] Implement `iphone-sync import` to enumerate and download selected/new iPhone
      media into local staging.
- [ ] Download to a temporary file, then atomically rename only after the transfer
      completes successfully.
- [ ] Create a simple local SQLite manifest with source identifier, filename, size,
      local path, capture date, and import time. A local content hash may be stored
      when available as a stable identity or diagnostic, but is not a required gate.
- [ ] Make repeated imports skip media already recorded in that Mac's manifest.
- [ ] Preserve related assets together where supported, especially HEIC/MOV Live
      Photo pairs and `.AAE` edit sidecars; record and operate on them as one asset
      group where deletion is concerned. Do not infer a group solely from exported
      filenames: Image Capture may change names for edited variants.
- [ ] Implement `iphone-sync push` to copy completed staging files to the NAS.
- [ ] Upload first to a unique, non-Immich-scanned temporary NAS location, then
      atomically rename the completed file into the landing directory. Never expose
      a partial upload to Immich. On mergerfs, treat an `EXDEV` rename failure as a
      failed push rather than falling back to a visible copy.
- [ ] Use a deterministic NAS directory convention, with a documented fallback when
      capture-date metadata is unavailable and collision-safe destination names.
- [ ] Make unreachable NAS behavior non-destructive and easy to retry.
- [ ] Manually test: ordinary photos, Live Photos, a large 4K/ProRes video, an
      interrupted import, an interrupted push, and rerunning each command.
- [ ] When Immich is available, configure it to index the landing directory. Verify
      that imported media has sensible dates. Do not let Immich scan the temporary
      upload location. This step does not block import or NAS publication.
- [ ] Add unit tests for manifest creation/transitions, idempotent import decisions,
      asset grouping, path/date handling, and non-destructive command construction.

## Stage 2 — Daily-use safety and recovery

Goal: make retrying, verification, and reclaiming iPhone storage trustworthy.

- [ ] Model manifest state explicitly: discovered, copied locally, NAS published,
      eligible to clear, and cleared. Keep optional verification results separate
      from the normal state machine.
- [ ] Implement `iphone-sync status` to show counts, failures, and pending work.
- [ ] Implement `iphone-sync verify` as an on-demand local/NAS reconciliation and
      recovery tool; use size and/or content hash when the user wants that assurance.
- [ ] Implement `iphone-sync clear` as an explicit, interactive command that only
      deletes complete asset groups that have been successfully published to the NAS
      by default.
- [ ] Optionally add `clear --local-only` for urgent phone-space recovery, with a
      prominent warning that the Mac remains the sole verified copy.
- [ ] Confirm deletion behavior and source identifiers against real iPhone media.
- [ ] Manually test crashes or Ctrl-C at every state transition and confirm retries
      do not duplicate, lose, or falsely mark media as complete.
- [ ] Add unit tests for clear eligibility, grouped deletion decisions, interrupted
      state recovery, and retry idempotency.
- [ ] Test the same workflow independently on the MacBook Air and Mac Studio.

## Stage 3 — Operational polish

- [ ] Add `iphone-sync push --retry` or a convenient retry mode for the MacBook Air
      when it returns to the home network.
- [ ] Add clear, actionable error messages and a dry-run option for destructive
      commands.
- [ ] Add structured logs and an exportable diagnostic report.
- [ ] Store NAS connection secrets in macOS Keychain rather than config files.
- [ ] Document installation, configuration, normal workflow, recovery workflow, and
      how to upgrade the tool on both Macs.
- [ ] Define retention/pruning rules for local staging after NAS verification.
- [x] Keep the NAS files as the canonical archive. Configure Immich to index them as
      an external library. Implement Immich as a separate service package. Do not let
      Immich own, move, or rename the canonical files.

## Stage 4 — Nice-to-haves

- [ ] Add an optional post-push Immich scan trigger or document the scheduled scan.
- [ ] Add progress display, throughput statistics, and a benchmark command.
- [ ] Add notifications for completed pushes or failed retries.
- [ ] Add configurable inclusion/exclusion policies for media types and albums.
- [ ] Evaluate `rclone` and a direct 10GbE Mac Studio-to-NAS link only if observed
      transfer performance warrants it.
- [ ] Consider packaging as a signed macOS app or a single distributable binary.

## 1.0.0 — Release hardening

- [ ] Add backend fakes or fixtures for import and deletion failure cases.
- [ ] Add integration tests for an interrupted transfer and NAS verification.
- [ ] Review the destructive-command UX and recovery documentation.
- [ ] Tag and document version 1.0.0 after the workflow has seen sustained daily use.
