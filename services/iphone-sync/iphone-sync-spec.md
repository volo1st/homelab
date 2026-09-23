# iPhone Photo/Video Import & Sync — Spec

## 1. Goal

Manually pull new photos and videos from an iPhone 16 Pro and publish them on the NAS.
Immich can index and categorize the published media after it is available. The import
and publication process must work without Immich. Automation is a later option after
the manual workflow has proved reliable.

**In scope:** import from iPhone, integrity verification, space reclamation on iPhone, sync to NAS.
**Out of scope:** categorization/tagging logic (delegated to Immich), audio file handling
(separate existing workflow), Jellyfin integration (revisit later if needed).

## 2. Devices & topology

| Device | Role | Network to NAS |
|---|---|---|
| MacBook Air M4 | Portable import host | Wi-Fi, intermittent |
| Mac Studio M1 Max | Desktop import host | 2.5GbE switch (possible future 10GbE direct link) |
| iPhone 16 Pro | Source | USB-C, direct to whichever Mac |
| NAS (Ubuntu 24.04, host `nas`) | Destination + Immich host | Samba share, SSH available |

Import must work identically on **either** Mac. The tool doesn't get to assume it's
always near the NAS — sync-to-NAS is a separable step that may run immediately
(Mac Studio, wired) or later (MacBook Air, next time it's on the home network).

## 3. Architecture

```
iPhone 16 Pro
   │  USB-C (afcclient, see section 5)
   ▼
[Mac] Local staging dir  ──(A: import + staging + dedup)─┐
   │                                                       │
   │  iPhone files deleted only after NAS publication      │
   ▼                                                       ▼
[Mac] manifest (sqlite/log, tracks imported assets)   ready-to-sync queue
                                                             │
                                               SSH
                                                             ▼
                   NAS: /ocean/personal/{photos,videos}/iphone/incoming/<date>/
                                                             │
                               optional Immich external-library index
                                                             ▼
                                          Categorized, searchable, deduped library
```

The iPhone-sync component ends at safe NAS publication. Immich is a separate and
optional downstream service.

## 4. Component A — Mac importer

**Interface:** single CLI tool, e.g. `iphone-sync`, with subcommands:

```
iphone-sync import    # pull new files from connected iPhone into local staging
iphone-sync verify    # optional local/NAS reconciliation and diagnostics
iphone-sync push      # publish staging files to the NAS through SSH
iphone-sync status    # show pending/staged/pushed counts
iphone-sync clear     # delete successfully published asset groups from iPhone
```

`import` should not delete from the phone. `clear` remains a separate explicit,
interactive step, so a human can review the result and stop before deletion.

**State/manifest:**
- A local manifest (sqlite is easiest — one row per file: source identifier, filename,
  size, capture date, import timestamp, published-to-NAS timestamp) lives alongside
  the staging dir on *each* Mac. Since both Macs import independently, the manifest
  is per-Mac, not shared —
  Stage 1 can therefore re-import a still-present phone asset on the other Mac. Once
  the normal explicit clear workflow is used, the phone no longer presents that asset;
  Immich also provides a backstop for duplicates on ingest.
- Re-running `import` should be a no-op for files already in the manifest (dedup by
  iPhone-side file identifier where the backend supplies one, not just filename —
  Live Photos and burst shots can collide on naming).

**Live Photos:** each Live Photo is a HEIC + MOV pair sharing a content identifier —
make sure whatever import mechanism you pick doesn't split the pair across separate
import batches (relevant mainly if you ever paginate/batch the pull). Do not identify
the pair solely by exported filenames: Image Capture can use different filename forms
for edits. An edit may be delivered as an `IMG_E...` rendered pair rather than an
`.AAE` sidecar. Route the full group to the photos tree even though it includes a MOV;
ordinary standalone videos go to the videos tree.

**Safety invariants:**
1. Never delete from iPhone during `import`; clear only complete Live Photo/edit-sidecar
   asset groups after a successful NAS publication.
2. Upload to a unique temporary NAS path outside Immich's scan root, then atomically
   publish the complete file into `incoming`. A failed upload is never visible to Immich.
3. All steps idempotent — re-running any subcommand after a crash/interrupt should
   converge to the same end state, not duplicate or corrupt data.
4. Before import, require enough local free space for the planned download plus 5 GiB.
5. Permit `clear` only when the complete asset group exists locally and is published
   on the NAS. Keep the local copy until a separate prune operation removes it.

Checksums are optional diagnostics and useful stable identities, not required transfer
gates. Re-reading iPhone files solely to obtain an independent source hash is not part
of the normal workflow.

## 5. Import mechanism

The initial backend is `afcclient` from libimobiledevice. A representative AFC test
copied 523 files and 3.54 GiB in 21.741 seconds. The measured rate was approximately
167 MiB/s. Image Capture imported test files but does not provide the required
scripting interface. Keep Image Capture as a manual fallback.

The prototype compared these candidates:

| | `afcclient` (libimobiledevice) | Image Capture via `osascript` |
|---|---|---|
| Protocol | AFC — known for chatty per-file overhead, historically bottlenecked well below USB link speed | Apple's native transfer path, generally faster for bulk pulls |
| CLI-native | Yes, pure CLI | Semi — shell script invoking AppleScript, still git-trackable |
| Result | Selected after a successful 167 MiB/s representative test | Rejected as the CLI backend because it has no usable scripting interface |

The benchmark used this method:
1. Pick a fixed test set — e.g. 500 photos + 20 videos already on the iPhone, note total size.
2. Time a full cold pull with each method, same USB-C cable, same Mac.
3. Compute MB/s for each; also note CPU load and whether either method chokes on
   large video files (4K/ProRes) differently than photos.
4. Re-run once more each (warm) to see if there's a meaningful cold/warm gap.
5. Keep the `iphone-sync import` interface independent of the backend.

Note: the 10GbE USB-C cable only helps if the bottleneck is link bandwidth. For AFC-style
transfer it likely isn't — protocol overhead per file tends to dominate. Don't assume
cable alone fixes speed; the benchmark will tell you where the real ceiling is.

## 6. Transport — Mac → NAS

- Use SSH to host `nas`. Keep the transport behind the `iphone-sync push` interface.
- Landing path convention:
  `/ocean/personal/photos/iphone/incoming/<YYYY-MM-DD>/` for photos and complete
  Live Photo/edit groups; `/ocean/personal/videos/iphone/incoming/<YYYY-MM-DD>/` for
  standalone videos. The date is the capture date, not the import date, so Immich's
  timeline stays sane regardless of when sync occurs.
- Copy to a unique path under the matching sibling `.uploading/` directory first, for
  example `/ocean/personal/photos/iphone/.uploading/<uuid>.part`. After transfer,
  atomically rename it into that tree's `incoming/` path. Configure Immich to scan
  only the two `incoming/` directories, never either `.uploading/` directory.
- Mergerfs requirement: create each `.../iphone/` base directory once through the
  mergerfs mount, then create its `incoming/` and `.uploading/` children there. With
  the configured `epmfs` policy this should keep the sibling paths on the same branch;
  validate it with a small host-side publish test before enabling Immich. Treat a
  cross-device (`EXDEV`) rename error as a failed push, never as permission to copy a
  partial file into a scanned path.
- MacBook Air case: `push` simply fails/skips gracefully if the NAS isn't reachable
  (Wi-Fi-only, off the home network) and retries next time `iphone-sync push` runs.

## 7. Optional Immich service

- Implement Immich as a separate service package.
- Configure Immich to use the two `incoming/` directories after the service is
  available. Do not configure it to use either `.uploading/` directory.
- Do not use Immich availability or index state as a requirement for import, NAS
  publication, or phone-deletion eligibility.
- Decision to make later, not now: does Immich *own* the files (moves/manages them
  into its own storage structure), or does it *index* files you keep organized
  yourself? This affects whether `incoming/` is transient or a permanent archive.
  Worth deciding after you've used Immich for a few weeks and see which model you
  prefer — doesn't block building Component A.

## 8. Repo structure (suggested)

```
iphone-sync/
├── README.md
├── iphone_sync/
│   ├── __main__.py          # CLI entrypoint
│   ├── afc_backend.py       # or image_capture_backend.py — swappable
│   ├── manifest.py          # sqlite manifest read/write
│   ├── verify.py            # checksum logic
│   └── push.py              # SSH publication
├── tests/
└── .github/ (or just a local pre-commit) for lint/test on push
```

Language choice: Python is the pragmatic default (good libimobiledevice bindings,
easy sqlite, easy to shell out to `osascript` if that backend wins) — swap for Go/Rust
only if you specifically want a single static binary across both Macs.

## 9. Open decisions log

| Decision | Status |
|---|---|
| afcclient vs Image Capture | **AFC selected; Image Capture is a manual fallback** |
| Immich owns files vs indexes files | Deferred, not blocking |
| Direct 10GbE Mac Studio↔NAS link | Not required for import speed; may still help general NAS throughput — separate from this project |
| NAS transport | **SSH to host `nas`** |

## 10. Suggested build order

1. Build `import` + manifest and its unit tests (this is the highest-risk, most
   novel part).
2. Build `push` over SSH.
3. Build `clear` last, once you trust push and the grouped-asset eligibility tests
   (this is the only destructive step).
4. When Immich is available, point it at `incoming/`. Observe categorization quality,
   then decide the ownership question in section 7.
