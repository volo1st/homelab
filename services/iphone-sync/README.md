# iPhone Media Import

This service imports iPhone media through a Mac and publishes it to the
network-attached storage (NAS). Immich is a planned downstream service. The import
and NAS publication process must work without Immich.

## High-level procedure

1. Connect the iPhone to one Mac with USB-C.
2. Run `iphone-sync import`.
3. The tool uses Apple File Conduit (AFC) to list new media.
4. The tool checks the available space on the Mac.
5. The tool downloads each file to a temporary local file.
6. The tool renames the file after the download is complete.
7. The tool records the file and its asset group in the local manifest.
8. The tool keeps related Live Photo files and edit files in one asset group.
9. Run `iphone-sync push`.
10. The tool sends each file to the NAS through Secure Shell (SSH).
11. The tool writes each file below `.uploading/`.
12. The tool moves the complete file to `incoming/` with an atomic rename.
13. Run `iphone-sync status`.
14. Confirm that each asset group is complete locally and published on the NAS.
15. Run `iphone-sync verify` when you want an additional size or checksum check.
16. Inspect the published media directly or through Immich when Immich is available.
17. Run `iphone-sync clear`.
18. Confirm the deletion request.
19. The tool deletes only complete and published asset groups from the iPhone.
20. The tool keeps the local Mac copy until a separate prune operation removes it.

The safety chain is:

```text
iPhone
  -> temporary Mac file
  -> complete Mac file
  -> temporary NAS file
  -> published NAS file
  -> optional Immich index
  -> explicit iPhone deletion
  -> optional later Mac cleanup
```

A failure before NAS publication leaves the iPhone unchanged. A failed NAS upload
stays outside `incoming/`. Repeating an interrupted command must not delete media or
publish an incomplete file.

## Documents

- [`plan.md`](plan.md) is the implementation checklist.
- [`iphone-sync-spec.md`](iphone-sync-spec.md) is the detailed design.
- [`project-notes.md`](project-notes.md) contains decisions and test evidence.

## Current development commands

Run these commands from `services/iphone-sync/`:

```bash
python3 -m iphone_sync --help
python3 -m iphone_sync --config config.example.toml init
python3 -m iphone_sync --config config.example.toml status
python3 -m iphone_sync discover
python3 -m unittest discover -s tests -v
```

Copy `config.example.toml` to a per-Mac file before normal use. Do not commit a local
configuration if it contains a secret. The `init` and `status` commands only create
and read the local staging directory and manifest. The `discover` command reads the
connected iPhone DCIM listing. It does not download or change a file. No current
command connects to the NAS.
