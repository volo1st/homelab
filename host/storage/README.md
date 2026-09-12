# Storage

## Layout

The NAS host has four ext4 data disks. Mergerfs combines them at `/ocean`.

| Mount | UUID |
| --- | --- |
| `/mnt/disks/ssd1` | `97caca7d-101b-45f8-8527-f881822d6ce2` |
| `/mnt/disks/ssd2` | `17976c3b-0d4c-4c1b-9eb8-d99b4ca90018` |
| `/mnt/disks/ssd3` | `a4f268c3-4e0e-431b-9877-1181453f7369` |
| `/mnt/disks/ssd4` | `eb317902-0497-4151-b343-57cd4823931e` |
| `/ocean` | mergerfs pool |

The tracked [`fstab`](fstab) is specific to this host.

[`expected/ocean.mount`](expected/ocean.mount) is a golden test fixture. It records
the expected effective systemd mount unit. It is not an installation source. Update
it only when an approved source change or systemd upgrade changes the expected unit.

Run the read-only check from the development container:

```bash
./host/storage/check.sh --root /host
```

Run `./host/storage/check.sh` from a host shell. Add `--strict-space` when a
free-space warning must cause a nonzero status.

## Availability policy

All four disks are required for normal NAS operation.

- Keep Ubuntu available when one disk is absent.
- Do not mount `/ocean` when one branch is absent.
- Do not start Samba when `/ocean` is absent.
- Use a separate and read-only mount for manual recovery access.

The disk and pool entries use `nofail`. Thus, a failure does not stop the Ubuntu boot.
The pool uses `x-systemd.requires-mounts-for=` for each branch. These options make the
pool require and start after all branch mounts.

The Samba drop-in at [`../samba/smbd.service.d/storage.conf`](../samba/smbd.service.d/storage.conf)
makes Samba require `/ocean`.

## Mergerfs policy

The pool uses `category.create=epmfs`. This policy selects the branch with the most
free space from branches that contain the relative path. Mergerfs excludes a branch
from create operations when it has less than 50 GiB available.

Mergerfs does not provide redundancy. A missing branch makes part of the data set
unavailable. Do not present this partial data set as the normal NAS.

## Application

Do not edit `/run/systemd/generator/ocean.mount`. Systemd generates this unit from
`/etc/fstab`.

Run the read-only storage-state check from the development container:

```bash
./host/storage/check.sh --root /host
./host/storage/check-generated.sh --root /host
```

Run the configuration preflight from a host shell:

```bash
./host/storage/apply.sh --check
```

Install the files only after the preflight passes and the user approves the host
change:

```bash
sudo ./host/storage/apply.sh --install
```

The install operation creates a backup below `/etc/homelab-backups/storage`. It reloads
the systemd dependency graph. It does not restart a mount or service. Test the new
startup behavior during a separate approved maintenance period.

## Required tests

Test each missing branch with non-production data. Confirm these results:

- Ubuntu remains available.
- The missing branch stays unmounted.
- `/ocean` does not mount.
- Samba does not start.
- No data goes to the root filesystem.

Record the results in the audit plan.
