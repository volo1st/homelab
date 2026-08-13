# iPhone Photo/Video Import & Sync — Spec

## 1. Goal

Automatically pull new photos/videos off an iPhone 16 Pro, land them on the NAS, and let
Immich handle categorization. No custom categorization component — Immich's existing
ML pipeline (faces, CLIP smart search, object/scene tags, dedup) covers that requirement.

**In scope:** import from iPhone, integrity verification, space reclamation on iPhone, sync to NAS.
**Out of scope:** categorization/tagging logic (delegated to Immich), audio file handling
(separate existing workflow), Jellyfin integration (revisit later if needed).

## 2. Devices & topology

| Device | Role | Network to NAS |
|---|---|---|
| MacBook Air M4 | Portable import host | Wi-Fi, intermittent |
| Mac Studio M1 Max | Desktop import host | 2.5GbE switch (possible future 10GbE direct link) |
| iPhone 16 Pro | Source | USB-C, direct to whichever Mac |
| NAS (Ubuntu 24.04) | Destination + Immich host | Samba share, SSH available |

Import must work identically on **either** Mac. The tool doesn't get to assume it's
always near the NAS — sync-to-NAS is a separable step that may run immediately
(Mac Studio, wired) or later (MacBook Air, next time it's on the home network).

## 3. Architecture

```
iPhone 16 Pro
   │  USB-C (afcclient or Image Capture — TBD, see §5)
   ▼
[Mac] Local staging dir  ──(A: import + verify + dedup)──┐
   │                                                       │
   │  iPhone files deleted only after verified copy        │
   ▼                                                       ▼
[Mac] manifest (sqlite/log, tracks imported hashes)   ready-to-sync queue
                                                             │
                                    rsync/rclone over Samba or SSH
                                                             ▼
                                          NAS: /volume/photos/_incoming/<date>/
                                                             │
                                          Immich external library watch
                                                             ▼
                                     Categorized, searchable, deduped library
```

Two components, as you originally sketched — but Component B is now "point Immich at
a folder," not custom code.

## 4. Component A — Mac importer

**Interface:** single CLI tool, e.g. `iphone-sync`, with subcommands:

```
iphone-sync import    # pull new files from connected iPhone into local staging
iphone-sync verify    # checksum staging files against device (or re-verify last import)
iphone-sync clear     # delete verified-imported files from iPhone
iphone-sync push      # rsync staging -> NAS
iphone-sync status    # show pending/staged/pushed counts
```

`import` should default to import+verify, with `clear` as a separate explicit step
(safety: never auto-delete from iPhone without a human able to `Ctrl-C` between verify
and clear, at least until you trust it).

**State/manifest:**
- A local manifest (sqlite is easiest — one row per file: filename, hash, size, capture
  date, import timestamp, pushed-to-NAS timestamp) lives alongside the staging dir on
  *each* Mac. Since both Macs import independently, the manifest is per-Mac, not shared —
  dedup across Macs happens at the NAS landing dir (by content hash) or is handled by
  Immich's own dedup on ingest.
- Re-running `import` should be a no-op for files already in the manifest (dedup by
  iPhone-side file identifier + hash, not just filename — Live Photos and burst shots
  can collide on naming).

**Live Photos:** each Live Photo is a HEIC + MOV pair sharing a content identifier —
make sure whatever import mechanism you pick doesn't split the pair across separate
import batches (relevant mainly if you ever paginate/batch the pull).

**Safety invariants:**
1. Never delete from iPhone before checksum-verifying the local copy.
2. `push` (Mac → NAS) should also be checksum-verified before considering staging
   files safe to prune locally.
3. All steps idempotent — re-running any subcommand after a crash/interrupt should
   converge to the same end state, not duplicate or corrupt data.

## 5. Import mechanism — decision pending your benchmark

Two candidates, both worth prototyping before committing:

| | `afcclient` (libimobiledevice) | Image Capture via `osascript` |
|---|---|---|
| Protocol | AFC — known for chatty per-file overhead, historically bottlenecked well below USB link speed | Apple's native transfer path, generally faster for bulk pulls |
| CLI-native | Yes, pure CLI | Semi — shell script invoking AppleScript, still git-trackable |
| Risk | Actual throughput on M-series + 16 Pro unverified — could be fine, could be the bottleneck regardless of your 10GbE cable | Less scriptable control over partial-failure/resume behavior |

**Benchmark methodology** (since you're doing this yourself):
1. Pick a fixed test set — e.g. 500 photos + 20 videos already on the iPhone, note total size.
2. Time a full cold pull with each method, same USB-C cable, same Mac.
3. Compute MB/s for each; also note CPU load and whether either method chokes on
   large video files (4K/ProRes) differently than photos.
4. Re-run once more each (warm) to see if there's a meaningful cold/warm gap.
5. Whichever wins becomes the `import` subcommand's backend — keep the interface
   (`iphone-sync import`) stable so you can swap backends later without touching
   the rest of the pipeline.

Note: the 10GbE USB-C cable only helps if the bottleneck is link bandwidth. For AFC-style
transfer it likely isn't — protocol overhead per file tends to dominate. Don't assume
cable alone fixes speed; the benchmark will tell you where the real ceiling is.

## 6. Transport — Mac → NAS

- `rsync -av --checksum` (or `rclone` if you want richer retry/logging) over Samba,
  or direct SSH if enabled on the NAS — SSH avoids Samba's per-file overhead and is
  likely faster for large batches.
- Landing path convention: `/volume/photos/_incoming/<YYYY-MM-DD>/` (date = capture
  date, not import date, so Immich's timeline stays sane regardless of when you
  actually ran the sync).
- MacBook Air case: `push` simply fails/skips gracefully if the NAS isn't reachable
  (Wi-Fi-only, off the home network) and retries next time `iphone-sync push` runs.

## 7. Component B — NAS / Immich

- No custom code. Configure Immich to watch `/volume/photos/_incoming/` as an
  external library (or have it actively ingest + you archive the original
  `_incoming` copy separately, depending on whether you want Immich managing the
  canonical copy or just indexing a copy you control).
- Decision to make later, not now: does Immich *own* the files (moves/manages them
  into its own storage structure), or does it *index* files you keep organized
  yourself? This affects whether `_incoming/` is transient or a permanent archive.
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
│   └── push.py              # rsync/rclone wrapper
├── tests/
└── .github/ (or just a local pre-commit) for lint/test on push
```

Language choice: Python is the pragmatic default (good libimobiledevice bindings,
easy sqlite, easy to shell out to `osascript` if that backend wins) — swap for Go/Rust
only if you specifically want a single static binary across both Macs.

## 9. Open decisions log

| Decision | Status |
|---|---|
| afcclient vs Image Capture | **Pending — your benchmark** |
| Immich owns files vs indexes files | Deferred, not blocking |
| Direct 10GbE Mac Studio↔NAS link | Not required for import speed; may still help general NAS throughput — separate from this project |
| Rsync over Samba vs SSH | Pick during Component A build, easy to swap |

## 10. Suggested build order

1. Prototype both import backends against the benchmark test set → pick one.
2. Build `import` + `verify` + manifest (this is the highest-risk, most novel part).
3. Build `push` (rsync wrapper) — comparatively boilerplate.
4. Build `clear` last, once you trust verify/push (this is the only destructive step).
5. Point Immich at `_incoming/`, observe categorization quality, then decide on §7's
   ownership question.
