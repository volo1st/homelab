# Repository Audit Results

Audit date: 2026-09-12

## Purpose

This document records a read-only audit of the repository. The audit examined the
repository structure, Git state, host configuration, scripts, secret rules, network
documents, and service plans.

Use [`intial-plan-after-audit.md`](intial-plan-after-audit.md) to track corrective
work. Do not use this document as a task list.

## Summary

The repository has a clear structure. It contains useful safety requirements. The
iPhone sync design has good controls for deletion and incomplete transfers.

The repository cannot yet reproduce the complete homelab. It does not contain a
complete host build, validation, backup, restore, or service deployment process.

The audit found five primary problems:

1. The storage document does not agree with `fstab`.
2. The Samba Public share uses two path names.
3. A missing data disk can cause data to go to the operating-system disk.
4. The Samba setup script does not verify the mergerfs mount.
5. The repository has no `.gitignore` for secret files.

## Findings

### Critical: a missing data disk can redirect data

All data-disk entries use `nofail`. The mergerfs entry also uses `nofail`. It does
not explicitly require each data-disk mount.

If a disk does not mount, its mount point can remain on the root filesystem. Mergerfs
can use this directory as a branch. NAS data can then fill the operating-system disk.

Define a degraded-storage policy. The proposed policy stops mergerfs and Samba when a
required branch is not mounted.

### High: the Samba Public path is not consistent

`setup-access.sh`, `check.sh`, and the Samba README use `/ocean/Public`.
`smb.conf` uses `/ocean/public`. Samba also enables case-sensitive names. Thus,
these paths are different. The health check can pass while Samba uses an incorrect
path.

### High: the setup script does not verify the pool

`setup-access.sh` creates directories below `/ocean`. It does not first verify that
`/ocean` is an active mergerfs mount. If the pool is not mounted, the script can
create these directories on the root filesystem and report success.

### High: the storage document is obsolete

The storage README specifies `/media/1` through `/media/4`, `/mnt/nas_pool`, the
`mfs` policy, and an obsolete UUID map. The tracked `fstab` specifies
`/mnt/disks/ssd1` through `ssd4`, `/ocean`, the `epmfs` policy, and a 50 GiB
minimum-free-space value. An operator can build an incorrect system from the README.

### Medium: secret controls are incomplete

The documents prohibit plaintext secrets. The audit found no obvious password, token,
or private key in the current files or scanned Git history. The repository has no
`.gitignore`. The current control depends on operator review.

### Medium: Samba options need tests

- Disabled server signing reduces protection against network modification.
- Disabled strict locking can affect concurrent DAW or video work.
- Case-sensitive names can cause problems in macOS applications.
- Mode `2775` gives Media and Public permissions to users outside the access groups.

Keep nondefault options only after representative tests and an accepted risk decision.

### Medium: Samba rollback is incomplete

`apply.sh` validates and backs up the configuration. It restores the backup only
after installed-file validation fails. It does not restore the backup after a restart
failure. It does not check service health after restart.

Two runs in one second can use the same backup name. The script has no execution lock.
It also has no backup retention rule.

### Medium: the host is not reproducible

The repository does not define complete procedures to install packages, create users,
create mounts, install Docker, deploy services, configure the firewall, validate the
host, back up data, restore data, or replace a disk.

The root README refers to Docker Compose services. No Compose file exists. The
`scripts` directory describes planned tools but contains no top-level tools.

### Low: the iPhone sync documents do not agree

The plan selects AFC and SSH. The specification still marks these decisions as open.
The specification uses both `incoming` and `_incoming`.

The design has good controls for deletion, atomic publication, asset groups, repeat
operation, and interruption recovery. No implementation or test verifies them.

### Low: one service contains only placeholders

`services/digital-archive-2026` contains empty directories. It has no README. Its
purpose, inputs, process, and completion criteria are not defined.

### Information: Git state

The working tree was clean before the audit changes. Local `main` was two commits
ahead of `origin/main`. These commits moved the iPhone sync documents and added the
digital archive placeholders.

## Positive results

- The top-level structure is small and clear.
- Host configuration is separate from service configuration.
- The shell scripts quote variables and have correct file modes.
- The apply script validates Samba configuration before installation.
- Samba groups clearly define access roles.
- The WDS document contains test evidence and exact commands.
- The iPhone sync design uses conservative data controls.

## Validation results

- All three Samba scripts passed `bash -n`.
- ShellCheck 0.11.0 found two `SC2181` style messages in `check.sh`.
- A pattern scan found no obvious plaintext secret.
- The audit environment did not contain `testparm`.
- The repository had no automated test suite or CI configuration.

## Assessment

The repository has a sound initial design. Configuration drift and unsafe behavior
during a storage failure are the primary risks. Correct these risks before you add
more services. Then add the minimum build, validation, backup, and restore procedures.
