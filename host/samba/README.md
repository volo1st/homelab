# Samba

Samba exposes the mergerfs NAS pool at `/mnt/nas_pool` as `NasShare`.

## Primary Clients

- Mac Studio over a local Layer 2 2.5GbE switch. This is the heaviest client and the main performance target.
- Apple TV over Wi-Fi, mainly for streaming.
- iPhone and iPad over Wi-Fi, mainly for general file access.


## Target Access Model

The share should support tiered access by account/group:

- Personal or privileged users get full read/write access.
- TV/media users get read-only access.
- Guest or public users should only see a limited public area.

Current symptom after recent group changes: clients can discover and mount the NAS, but browsing into a directory closes/fails. This points toward an authorization or filesystem permission mismatch after mount, not basic network discovery.

For direct Mac Studio work, the share should prioritize stable editing from the share for DAW projects and occasional video editing up to about 4k60. This makes predictable locking, metadata behavior, and permission mapping more important than maximum synthetic throughput.

## Shares

| Share | Path | Access | Purpose |
| --- | --- | --- | --- |
| `NasShare` | `/mnt/nas_pool` | `@smbwriters` read/write | Full NAS access for trusted writer accounts |
| `Media` | `/mnt/nas_pool/Media` | `@smbreaders` read-only, `@smbwriters` read/write | Media-focused access for TV and playback clients |
| `Public` | `/mnt/nas_pool/Public` | `@smbshareusers` read-only, `@smbwriters` read/write | Limited public area for low-privilege accounts |

`access based share enum = yes` is enabled so accounts should only see shares they are allowed to access.

## Current Host State

From the current host:

```text
/mnt/nas_pool mergerfs_pool fuse.mergerfs rw,relatime,user_id=0,group_id=0,default_permissions,allow_other
```

Directory ownership:

```text
drwxrws--- vincent smbshareusers /media/1
drwxrws--- vincent smbshareusers /media/2
drwxrws--- vincent smbshareusers /media/3
drwxrws--- vincent smbshareusers /media/4
drwxrws--- vincent smbshareusers /mnt/nas_pool
```

`testparm` accepts `smb.conf` on the host running Samba 4.19.5-Ubuntu.

## Verification Notes

Current checks from the host:

- `testparm /sandbox/vincent/repos/homelab/host/samba/smb.conf` loads successfully.
- `smbstatus` showed no active sessions or locked files when captured.
- `getent group nas` returned no group.
- The backing directories are owned by user `vincent` and group `smbshareusers`.


## Mergerfs And Access Control

Mergerfs can work well with Samba access control when the model stays POSIX-friendly:

- Samba should authenticate users and apply share-level rules.
- The mergerfs pool should expose normal Unix ownership, groups, modes, and xattrs from the branch filesystems.
- Branch directories under `/media/1` through `/media/4` should keep consistent ownership and permissions.
- `allow_other` and `default_permissions` are appropriate for letting Samba access the FUSE mount while still enforcing Unix permissions.
- Avoid relying on per-branch special cases; permissions should make sense at the pool path and on every branch.

For this setup, prefer Unix groups plus Samba share rules over forcing every session to one user. The current Samba users are `vincent` and `nas`; both are members of `smbshareusers`.

Expected role groups:

- `smbshareusers` - baseline group for accounts allowed to access the public share.
- `smbwriters` - trusted accounts with write access, initially `vincent`.
- `smbreaders` - read-only media accounts, initially `nas`.

Run `setup-access.sh` on the host to create the groups, apply memberships, and create the expected share directories.


## Operations

Apply the access model first when setting up a host:

```bash
./host/samba/setup-access.sh
```

Then install and validate the Samba config:

```bash
./host/samba/apply.sh
```

`apply.sh` validates the repo config with `testparm`, backs up the current `/etc/samba/smb.conf`, installs the repo config, validates the installed config, and restarts `smbd`.

Run a non-mutating health check with concise default output:

```bash
./host/samba/check.sh
```

Print detailed command output when diagnosing:

```bash
./host/samba/check.sh --verbose
DEBUG=1 ./host/samba/check.sh
```

Samba users must exist both as Unix users and in Samba passdb. Add or update Samba credentials with:

```bash
sudo smbpasswd -a vincent
sudo smbpasswd -a nas
```

List Samba users with:

```bash
sudo pdbedit -L
```

## Open Items

- Run `setup-access.sh` on the host, then run `testparm -s /etc/samba/smb.conf` before restarting Samba.
- Confirm whether `case sensitive = true` is safe for DAW project workflows on macOS. It may improve lookup performance, but some macOS applications expect case-insensitive behavior.
- Confirm how clients normally connect: hostname, mDNS, static IP, DNS name, or saved SMB URL.
