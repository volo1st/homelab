# Storage

Host-level storage configuration belongs here.

## Current Layout

The core host has four M.2 SSD slots. The NAS data disks are mounted as ext4 branch filesystems and combined with mergerfs.

| Mount | UUID | Notes |
| --- | --- | --- |
| `/media/1` | `17976c3b-0d4c-4c1b-9eb8-d99b4ca90018` | NAS branch disk |
| `/media/2` | `97caca7d-101b-45f8-8527-f881822d6ce2` | NAS branch disk |
| `/media/3` | `eb317902-0497-4151-b343-57cd4823931e` | NAS branch disk |
| `/media/4` | `a4f268c3-4e0e-431b-9877-1181453f7369` | NAS branch disk |
| `/mnt/nas_pool` | `mergerfs_pool` | mergerfs pool exposed to Samba |

The mergerfs pool is defined in `fstab` as:

```text
/media/1:/media/2:/media/3:/media/4  /mnt/nas_pool  fuse.mergerfs  defaults,nonempty,allow_other,use_ino,cache.files=partial,dropcacheonclose=true,category.create=mfs,fsname=mergerfs_pool  0  0
```

`category.create=mfs` places new files on the branch with the most free space.

## Files

- `fstab` - Relevant host mount entries for the root disk, EFI partition, NAS branch disks, and mergerfs pool.
