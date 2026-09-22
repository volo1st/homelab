# Minimal Recovery Policy

## Scope

This policy restores the NAS configuration. It does not back up the NAS data pool or
mutable service state.

The user keeps important documents in multiple cloud systems. Those systems are
outside this repository. The user accepts permanent loss of files that exist only on
the NAS.

Mergerfs combines filesystems. It does not provide redundancy or parity. A failed
branch can remove all files stored on that branch. It does not reconstruct those
files.

General recovery guidance recommends isolated backups and regular restore tests. This
host deliberately uses a smaller policy because its NAS-only data is replaceable or
scheduled for cleanup. Reassess this decision if the workload changes.

## Recovery objectives

Use these recovery objectives:

| Item | Recovery-point objective | Recovery-time objective |
| --- | --- | --- |
| Repository configuration | Last commit pushed to the upstream Git remote | Best effort |
| Important personal documents | Existing cloud-provider recovery point | Outside this repository |
| NAS-only pool data | No recovery point | No recovery objective |
| Local development data | No recovery point | No recovery objective |
| Mutable service state | No recovery point | Recreate the service |

Do not interpret an uncommitted or unpushed Git change as protected. Push each
completed work package to the upstream remote.

## Protected configuration

The upstream Git repository is the off-host copy of these items:

- Host package inventory and build procedure.
- Storage configuration and safety checks.
- Samba configuration and access procedure.
- Firewall configuration and recovery procedure.
- Validation and recovery checks.

The active Docker Compose configuration remains outside this repository at
`/home/vincent/homelab/docker/docker-compose.yml`. It has no off-host copy in this
policy. Work package 9 owns its migration into the repository. Accept loss of the
current Compose file until that work is complete.

## Accepted data loss

Do not create a repository-managed backup for these items:

- `/ocean` and all mergerfs branch data.
- `/sandbox` development files, caches, toolchains, and local-only repositories.
- Uncommitted files and commits that are not pushed.
- Grafana data in `docker_grafana-data`.
- Prometheus history in `docker_prometheus-data` and `nas_prometheus_data`.
- Jellyfin configuration, metadata, and cache.
- Samba databases and Samba passwords.
- Local Secure Shell (SSH), GNU Privacy Guard (GPG), and application credentials.

Restore important personal documents through the existing cloud workflow. Recreate
credentials through their providers. Do not put a recovered secret in Git.

## Routine recovery readiness

After each completed work package, run:

```bash
git push
./scripts/check-recovery-readiness.sh
./scripts/test-recovery.sh
```

The readiness check does not contact the Git remote. Run `git fetch --prune` first
when you must confirm the current remote state. The check fails when the worktree is
not clean, the upstream is missing, the upstream is local, or local commits are not
present in the upstream tracking reference.

## Bare-host restoration

Use this procedure after the operating-system disk or complete host fails:

1. Install the supported Ubuntu Long Term Support (LTS) release.
2. Create the `vincent` administrator account.
3. Configure the stable NAS address and hostname.
4. Install Git and clone the upstream homelab repository.
5. Check out the required recovery commit.
6. Follow [`../README.md`](../README.md) to install packages and host configuration.
7. Recreate the `nas` account and Samba credentials.
8. Recreate application secrets through their providers.
9. Recreate Docker services after work package 9 supplies their tracked definitions.
10. Restore important documents through the existing cloud workflow when needed.
11. Run `sudo ./scripts/validate-host.sh`.
12. Test Samba and each required service from a representative client.

The firewall, storage, and Samba installers print their rollback locations. Keep the
active shell open while you apply network or access changes.

## Data-disk replacement

All four data disks are required for normal operation. The storage policy keeps
`/ocean` and Samba unavailable when one branch is absent.

Use this procedure after a branch disk fails:

1. Stop Samba and any service that uses `/ocean`.
2. Record `lsblk -f`, `findmnt`, and the failed disk serial number.
3. Decide whether to attempt read-only recovery before you modify the failed disk.
4. Replace the physical disk.
5. Create the replacement partition and ext4 filesystem during an approved
   maintenance operation.
6. Record the new filesystem universally unique identifier (UUID).
7. Update `host/storage/fstab`, `host/storage/README.md`, and the expected mount unit.
8. Run the storage static checks and preflight.
9. Install the approved storage configuration.
10. Reboot and confirm that all four branches and `/ocean` mount.
11. Run `sudo ./scripts/validate-host.sh`.
12. Restore selected documents from their cloud copies when needed.

Do not format a disk until its device path and serial number are confirmed. Do not
expect mergerfs to reconstruct files from the failed branch. Files on the other ext4
branches remain directly accessible during manual recovery.

## Service recovery

Use these service-specific recovery results:

- Grafana starts with a new empty volume. Recreate dashboards and settings.
- Prometheus starts with a new empty volume. Historical metrics are not restored.
- Jellyfin starts with empty configuration and cache directories. Configure it and
  scan the media library again.
- Samba uses the tracked configuration. Recreate local Samba passwords.
- The DDE development environment uses tracked source repositories where available.
  Reinstall toolchains and dependencies. Local-only work is not restored.

The unused `nas_prometheus_data` volume is an orphan candidate. Work package 9 must
confirm it is obsolete before deletion.

## Recovery tests

Run the non-production repository recovery test after a recovery-document or host
configuration change:

```bash
./scripts/test-recovery.sh
```

The test exports the Git index to a temporary directory. It verifies the required
recovery files and shell syntax. It does not read, change, or delete production data.

Work package 11 must run the complete procedure from a clean clone.

## Monitoring boundary

Disk Self-Monitoring, Analysis and Reporting Technology (SMART) metrics, filesystem
capacity alerts, mount alerts, and notification delivery belong to work package 9.
Monitoring can warn about a failure. It does not replace a backup.

## References

- [Git clone documentation](https://git-scm.com/docs/git-clone)
- [Docker volume backup and restore](https://docs.docker.com/engine/storage/volumes/)
- [mergerfs features and non-features](https://github.com/trapexit/mergerfs)
- [CISA ransomware guidance](https://www.cisa.gov/stopransomware/ransomware-guide)
