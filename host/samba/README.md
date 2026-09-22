# Samba

Samba exposes the mergerfs NAS pool at `/ocean` as `NasShare`.

## Primary clients

- Mac Studio over a local Layer 2 2.5GbE switch. This is the heaviest client and the
  main performance target.
- Apple TV over Wi-Fi, mainly for streaming.
- iPhone and iPad over Wi-Fi, mainly for general file access.


## Target access model

The share should support tiered access by account/group:

- Personal or privileged users get full read/write access.
- TV/media users get read-only access.
- Low-privilege users should only see the limited public area.

For direct Mac Studio work, the share must support stable editing from the share for
digital audio workstation (DAW) projects and occasional video editing up to 4k60.
Predictable locking, metadata behavior, and permission mapping are more important
than maximum synthetic throughput.

## Shares

| Share | Path | Access | Purpose |
| --- | --- | --- | --- |
| `NasShare` | `/ocean` | `@smbwriters` read/write | Full NAS access for trusted writer accounts |
| `Media` | `/ocean/Media` | `@smbreaders` read-only, `@smbwriters` read/write | Media-focused access for TV and playback clients |
| `Public` | `/ocean/public` | `@smbshareusers` read-only, `@smbwriters` read/write | Limited public area for low-privilege accounts |

`access based share enum = yes` is enabled. An account can only see a share that it
can access.

The `Public` share is authenticated. It does not permit guest access.

## Host inventory before work package 2

The host inventory on 2026-09-22 reported this mount state:

```text
/ocean mergerfs_pool fuse.mergerfs rw,relatime,user_id=0,group_id=0,default_permissions,allow_other
```

Directory ownership:

```text
2770 vincent smbshareusers /mnt/disks/ssd1
2770 vincent smbshareusers /mnt/disks/ssd2
2770 vincent smbshareusers /mnt/disks/ssd3
2770 vincent smbshareusers /mnt/disks/ssd4
2770 vincent smbshareusers /ocean
2775 vincent smbshareusers /ocean/Media
2755 vincent smbshareusers /ocean/public
```

The host did not contain `/ocean/Public`. The installed Samba configuration used
`/ocean/public`.

The host contained these accounts:

- `vincent` was a member of `smbshareusers` and `smbwriters`.
- `nas` was a member of `smbshareusers` and `smbreaders`.
- The Samba passdb contained `vincent` and `nas`.

## Permission model

Use Samba access rules with Portable Operating System Interface (POSIX) group
permissions:

- Samba should authenticate users and apply share-level rules.
- The mergerfs pool should expose normal Unix ownership, groups, modes, and extended
  attributes from the branch filesystems.
- Branch directories under `/mnt/disks/ssd1` through `/mnt/disks/ssd4` must have
  consistent ownership and permissions.
- `allow_other` and `default_permissions` let Samba access the Filesystem in
  Userspace (FUSE) mount while the kernel enforces Unix permissions.
- Use mode `2770` for the branch roots, pool root, and share directories.
- Use mode `0660` for files that Samba creates.
- Use mode `2770` for directories that Samba creates.
- Do not give access to other users.

Use Unix groups and Samba share rules. Do not force each session to one user. The
current Samba users are `vincent` and `nas`. Both users are members of
`smbshareusers`.

Expected role groups:

- `smbshareusers` - baseline group for accounts allowed to access the public share.
- `smbwriters` - trusted accounts with write access, initially `vincent`.
- `smbreaders` - read-only media accounts, initially `nas`.

`setup-access.sh` checks the complete storage state and all required Unix users before
it makes a change. It creates the groups, applies the memberships, and sets the
expected owner, group, and mode.

## Security and application behavior

Use these policies for the current Apple client and editing workloads:

- Require Server Message Block (SMB) signing.
- Keep the explicit SMB 2.02 minimum protocol.
- Use automatic strict locking.
- Use automatic case behavior.
- Use the Samba defaults for multichannel, leases, asynchronous input/output, and
  socket options.

The Mac Studio negotiated SMB 3.1.1 and AES-128-GMAC signing before signing became
mandatory. The mandatory policy enforces the protection that this client already
uses. Signing protects message integrity and authenticity. It does not encrypt file
data.

Automatic strict locking checks locks on files that do not have an opportunistic
lock. It keeps the Samba safety and performance balance. The normal workflow has one
writer and can have multiple readers. Do not open one Studio One or CapCut project
for editing from two Macs at the same time.

The two-Mac Vim conflict test passed. macOS did not expose a POSIX `lockf` request on
the mounted share. The user accepted the omission of a protocol-level SMB2
byte-range lock test for the single-writer workload.

Automatic case behavior gives macOS case-insensitive and case-preserving names. It
prevents names that differ only by case from causing application ambiguity.

Samba 4.19 enables multichannel, leases, and asynchronous input/output by default.
It also enables `TCP_NODELAY` by default. Do not add a performance override without a
repeatable measurement on the Mac Studio 2.5 GbE path.


## Operations

Apply the access model first when setting up a host:

```bash
./host/samba/setup-access.sh --check
./host/samba/setup-access.sh
```

Run the read-only deployment preflight:

```bash
./host/samba/apply.sh --check
```

Install the configuration only from a real host shell. The restart interrupts active
Samba sessions. Clients can reconnect after the health check passes.

```bash
sudo ./host/samba/apply.sh --install
```

The install operation uses an execution lock. It creates a unique backup of the
current `/etc/samba/smb.conf`. It keeps the ten newest Samba configuration backups.
It installs and validates the repository configuration. It then restarts `smbd` and
an enabled `nmbd`. It runs the complete Samba health check after the restart.

If validation, restart, or health checks fail, the script restores the prior
configuration and active or inactive service state. The script prints the backup
path for manual recovery.

Run the local deployment tests from the development container:

```bash
./host/samba/test-apply.sh
```

Run the non-mutating health check as root. Root access lets the script read the Samba
passdb.

```bash
sudo ./host/samba/check.sh
```

Print detailed command output when diagnosing:

```bash
sudo ./host/samba/check.sh --verbose
sudo DEBUG=1 ./host/samba/check.sh
```

A Samba user must also exist as a Unix user. Add or update Samba credentials with:

```bash
sudo smbpasswd -a vincent
sudo smbpasswd -a nas
```

List Samba users with:

```bash
sudo pdbedit -L
```

## Manual rollback

Use manual rollback only if automatic rollback is incomplete or a client problem is
found after a successful installation.

1. Select the exact backup path that `apply.sh` printed.
2. Validate the backup.
3. Restore the backup.
4. Restart Samba.
5. Run the health check.

```bash
backup=/etc/samba/backups/smb.conf.YYYYMMDD-HHMMSS-NNNNNNNNN.XXXXXX
sudo testparm -s "$backup"
sudo cp -a --remove-destination "$backup" /etc/samba/smb.conf
sudo testparm -s /etc/samba/smb.conf
sudo systemctl restart smbd
if systemctl is-enabled --quiet nmbd; then sudo systemctl restart nmbd; fi
sudo ./host/samba/check.sh
```

Do not continue if backup validation fails. Correct the selected path first.

## Rollback for the access-mode change

Use this rollback only if the group-only mode change causes a client failure:

```bash
sudo chmod 2775 /ocean/Media
sudo chmod 2755 /ocean/public
```

If the Samba configuration also needs rollback, use the manual rollback procedure.

## Troubleshooting

- If the storage check fails, do not run `setup-access.sh`.
- If a required Unix user is missing, create or correct the user before setup.
- If a share path check fails, compare the installed configuration with `smb.conf`.
- If a permission check fails, run `stat` on the reported path.
- If a client cannot write, confirm that its account is in `smbwriters`.
- If a client has unexpected access, confirm its Unix groups and Samba account.
