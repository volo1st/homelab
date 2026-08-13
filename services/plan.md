# iPhone Sync Plan

This plan optimizes for reaching a safe, usable manual workflow quickly, then
hardens it from real-world use. Automated unit tests are intentionally deferred
until the 1.0.0 milestone; each stage should instead be exercised manually on a
real iPhone and both Macs where applicable.

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

- [ ] Choose the local staging location and minimum free-space policy on each Mac.
- [ ] Choose an initial NAS transport: SSH is the preferred first option; document
      the Samba fallback only if SSH is unsuitable.
- [ ] Confirm the NAS path mounted into the Immich service and choose a temporary
      landing path such as `/volume/photos/_incoming/`.
- [ ] Prototype iPhone enumeration, download, and deletion with both candidate
      backends (`afcclient`/libimobiledevice and Image Capture).
  - Needs you: run the Mac-specific commands against the connected, unlocked iPhone;
        record the exact macOS version, tool versions, and observed behavior in the
        project notes.
- [ ] Run the defined benchmark on a representative set that includes photos,
      large videos, and Live Photos; record throughput and failure behavior.
- [ ] Pick the initial import backend, while keeping the CLI independent of it.

## Stage 1 — MVP: usable manual import and NAS copy

Goal: manually import media from either Mac, copy it to the NAS, and inspect it
in Immich. No automatic deletion from the iPhone or local staging cleanup.

- [ ] Scaffold the `iphone-sync` Python CLI and its per-Mac configuration.
- [ ] Implement `iphone-sync import` to enumerate and download selected/new iPhone
      media into local staging.
- [ ] Download to a temporary file, then atomically rename only after the transfer
      completes successfully.
- [ ] Create a simple local SQLite manifest with source identifier, filename, size,
      local path, capture date, import time, and local content hash.
- [ ] Make repeated imports skip media already recorded in that Mac's manifest.
- [ ] Preserve related assets together where supported, especially HEIC/MOV Live
      Photo pairs and `.AAE` edit sidecars.
- [ ] Implement `iphone-sync push` to copy completed staging files to the NAS.
- [ ] Use a deterministic NAS directory convention, with a documented fallback when
      capture-date metadata is unavailable.
- [ ] Make unreachable NAS behavior non-destructive and easy to retry.
- [ ] Manually test: ordinary photos, Live Photos, a large 4K/ProRes video, an
      interrupted import, an interrupted push, and rerunning each command.
- [ ] Configure Immich to scan/index the landing directory; verify imported media
      appears with sensible dates and that the files remain intact on both source
      locations.

## Stage 2 — Daily-use safety and recovery

Goal: make retrying, verification, and reclaiming iPhone storage trustworthy.

- [ ] Model manifest state explicitly: discovered, copied locally, locally verified,
      pushed, NAS verified, and eligible to clear.
- [ ] Verify the local hash while streaming the initial download; avoid an automatic
      second read of the iPhone solely for checksumming.
- [ ] Verify the NAS copy by size and content hash before marking it NAS verified.
- [ ] Implement `iphone-sync status` to show counts, failures, and pending work.
- [ ] Implement `iphone-sync verify` for local/NAS reconciliation and recovery.
- [ ] Implement `iphone-sync clear` as an explicit, interactive command that only
      deletes items verified on the NAS by default.
- [ ] Optionally add `clear --local-only` for urgent phone-space recovery, with a
      prominent warning that the Mac remains the sole verified copy.
- [ ] Confirm deletion behavior and source identifiers against real iPhone media.
- [ ] Manually test crashes or Ctrl-C at every state transition and confirm retries
      do not duplicate, lose, or falsely mark media as complete.
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
- [ ] Decide whether Immich owns canonical files or indexes a permanent external
      archive before any automated NAS-side cleanup.

## Stage 4 — Nice-to-haves

- [ ] Add an optional post-push Immich scan trigger or document the scheduled scan.
- [ ] Add progress display, throughput statistics, and a benchmark command.
- [ ] Add notifications for completed pushes or failed retries.
- [ ] Add configurable inclusion/exclusion policies for media types and albums.
- [ ] Evaluate `rclone` and a direct 10GbE Mac Studio-to-NAS link only if observed
      transfer performance warrants it.
- [ ] Consider packaging as a signed macOS app or a single distributable binary.

## 1.0.0 — Test and release hardening

- [ ] Add unit tests for manifest transitions, idempotency, path/date handling, and
      command construction.
- [ ] Add backend fakes or fixtures for import and deletion failure cases.
- [ ] Add integration tests for an interrupted transfer and NAS verification.
- [ ] Review the destructive-command UX and recovery documentation.
- [ ] Tag and document version 1.0.0 after the workflow has seen sustained daily use.
