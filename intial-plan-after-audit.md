# Initial Plan After Audit

## Purpose

This document is the single source of truth for audit work. The audit date is
2026-09-12. [`audit-results.md`](audit-results.md) contains the evidence.

The filename keeps the spelling from the initial request. Do not create a second plan.

## Current status

Last update: 2026-09-22

Current package: **Work package 3: Samba security and application behavior**

State: **Complete**

The Mac Studio uses SMB 3.1.1 with AES-128-GMAC signing over one active 2.5 GbE
channel. The installed policy requires signing. The normal Studio One and CapCut
workflow has one writer. Other clients can read files, but they do not edit the same
project. The Mac Studio baseline was 275.7 MB/s write and 226.7 MB/s read. After the
change, write throughput was unchanged and read throughput was 8.9 percent lower.
Both results met the predefined acceptance threshold. The case test and the two-Mac
Vim conflict test passed. The user accepted the omission of a protocol-level SMB2
byte-range lock test for this single-writer workload. Representative Studio One,
CapCut, and read-only client tests passed.

Resume work with work package 4:

1. Inspect the current Samba deployment and rollback scripts.
2. Test the documented recovery path without changing the host.
3. Define the remaining host and restart checks.

Next available focus: **Work package 4: Samba deployment and recovery**

## Work rule

Complete one work package before you start the next work package.

Update the Current status section before each planned stop. Include the active or
blocked package, the exact resume action, and the next available focus.

Use this cycle for each package:

1. Inspect the repository and applicable live state.
2. Confirm the purpose, requirements, and failure model.
3. Compare the design with current best practice for its purpose.
4. Record decisions and tradeoffs.
5. Make the repository changes.
6. Run static checks and safe tests.
7. Review the complete diff.
8. Get approval for host changes.
9. Apply the change from a real host context.
10. Verify the host and applicable clients.
11. Add evidence to this plan.
12. Commit the completed package.

Do not start a later package to avoid an incomplete step. Stop when a required test,
approval, or external action is not available.

Follow [`working-with-host.md`](working-with-host.md) for host work. Get approval
before a host change or destructive test.

## Package states

Use one state for each package:

- **Pending:** Work did not start.
- **Active:** This is the only active package.
- **Blocked:** A named dependency prevents work.
- **Complete:** All completion gates passed.

## Global completion criteria

- [ ] Storage stops safely when a required mount is absent.
- [ ] Samba stops safely when required storage is absent.
- [ ] Documents agree with executable configuration.
- [ ] An operator can rebuild the host from repository instructions.
- [ ] Important data has tested backup and restore procedures.
- [ ] Repository controls help prevent secret commits.
- [ ] Each service has operation and recovery instructions.
- [ ] One command or documented sequence validates the homelab.

## Work package 0: audit operating rules

State: **Complete**

- [x] Define the safe host-work method.
  - Evidence: [`working-with-host.md`](working-with-host.md).
- [x] Add repository instructions for future agents.
  - Evidence: [`AGENTS.md`](AGENTS.md).
- [x] Require a purpose-specific best-practice review.
  - Evidence: `AGENTS.md` and `plan.md` contain this rule.

## Work package 1: fail-closed NAS storage

State: **Complete**

Goal: Keep Ubuntu available after a data-disk failure. Do not provide an incomplete
NAS as a healthy service.

### Decisions

- [x] Decide if all four mergerfs branches are required.
  - Decision: Require all four branches for normal NAS operation.
  - Decision: Keep the Ubuntu host available when one branch is absent.
  - Decision: Do not mount the normal pool when one branch is absent.
  - Decision: Do not start its Samba service when one branch is absent.
  - Decision: Permit recovery access only in a manual and read-only mode.
  - Evidence: The host-generated `ocean.mount` unit has no branch requirements.
  - Evidence: Mergerfs does not provide data redundancy.

### Repository changes

- [x] Make mergerfs require all four branch mounts.
  - Evidence: A systemd 255 generator test produced `RequiresMountsFor=` for all four
    branch paths.
- [x] Make mergerfs start after all four branch mounts.
  - Evidence: `RequiresMountsFor=` adds requirement and ordering dependencies.
- [x] Prevent mergerfs from using an unmounted directory on the root filesystem.
  - Evidence: `/ocean` now requires each branch mount unit to start successfully.
- [x] Review `nofail` for the host and branch mount entries.
  - Decision: Keep `nofail` so Ubuntu remains available for recovery.
- [x] Define the Samba dependency on healthy storage.
  - Evidence: `host/samba/smbd.service.d/storage.conf` requires `/ocean`.
- [x] Add checks for UUIDs, mounts, filesystem types, mergerfs, and free space.
  - Evidence: `host/storage/check.sh` passed all identity checks against `/host`.
  - Evidence: The check reported that `ssd2` has less than 50 GiB available.
- [x] Track and check the expected generated mount unit.
  - Evidence: `host/storage/expected/ocean.mount` contains the golden test fixture.
  - Evidence: `host/storage/check-generated.sh` compares the live generated unit with
    the fixture.
- [x] Document normal boot, disk-failure, recovery, and rollback behavior.
- [x] Make the storage README match the current paths, UUIDs, `epmfs`, and 50 GiB
  limit.
- [x] Remove obsolete storage paths from remaining applicable documents.
  - Evidence: The Samba README now uses `/mnt/disks/ssd1` through `ssd4`.

### Completion gates

- [x] Static validation passes.
  - Evidence: Bash syntax, ShellCheck, `git diff --check`, the storage-state check, and
    the generated-unit comparison passed.
- [x] Decide how to validate the missing-branch condition.
  - Accepted limitation: The production NAS will not receive a physical missing-disk
    test only for this work package.
  - Rationale: The test requires unnecessary production hardware work and service
    risk.
  - Evidence: The generated unit requires all four branch mounts. Standard systemd
    dependency behavior stops `/ocean` when a required branch cannot start.
  - Residual risk: The exact physical failure path is not tested on this NAS.
- [x] Host application has explicit approval.
  - Evidence: The user approved and ran `sudo ./apply.sh --install` on 2026-09-12.
- [x] Complete a normal host reboot after the other NAS work finishes.
  - Evidence: The user completed a normal NAS reboot on 2026-09-22.
- [x] Run the storage-state and generated-unit checks after the reboot.
  - Evidence: `./host/storage/check.sh` and
    `./host/storage/check-generated.sh` succeeded after the reboot.
- [x] Confirm that Samba starts and a representative client reconnects after the
  reboot.
  - Evidence: `ocean.mount` and `smbd` were active after the reboot.
  - Evidence: A MacBook Air M4 opened a Samba share and showed the expected files.
- [x] Host verification evidence is recorded.
  - Evidence: The installed files match the repository.
  - Evidence: The generated `ocean.mount` unit requires all four branches.
  - Evidence: The storage checks, services, and representative client passed after a
    normal reboot.
- [x] The complete package is committed.
  - Evidence: This plan update completes the package commit.

## Work package 2: Samba access paths and permissions

State: **Complete**

Goal: Make the configured shares agree with host paths and the access model.

- [x] Inspect the live Public path, share paths, users, groups, owners, and modes.
  - Evidence: The 2026-09-22 host inventory confirmed the mergerfs pool, four ext4
    branches, two Unix users, three access groups, two Samba users, and current path
    metadata.
- [x] Select one Public filesystem path.
  - Decision: Use `/ocean/public` because it is the installed Samba path and the
    existing data path. Do not create `/ocean/Public`.
- [x] Use the selected path in configuration, scripts, checks, and documents.
- [x] Make `setup-access.sh` verify storage before a change.
  - Evidence: The script runs the complete storage check before its first change.
- [x] Make `setup-access.sh` verify all required users before a change.
  - Evidence: The script checks the owner and all role arrays before its first
    change.
- [x] Select group-only modes unless other-user access is necessary.
  - Decision: Use `0660` for files and `2770` for directories. Samba share rules
    separate writer and reader access. No current workload requires other-user
    access.
- [x] Make `check.sh` verify paths, owners, groups, modes, and branch health.
  - Evidence: The check validates both configurations, complete storage state, path
    metadata, Unix roles, and Samba users.
  - Evidence: All health checks passed on the host after application on 2026-09-22.
- [x] Validate the Samba configuration with `testparm`.
  - Evidence: Host Samba accepted the repository configuration on 2026-09-22. It
    reported `/ocean/public`, file mode `0660`, and directory mode `02770` for the
    applicable shares.
  - Evidence: `apply.sh` stored the prior configuration at
    `/etc/samba/backups/smb.conf.20260922-134119`, installed the repository
    configuration, validated it, and restarted `smbd` successfully.
- [x] Test each Samba role with a representative account.
  - Evidence: The `vincent` writer role and `nas` reader role passed from a MacBook
    Air M4 on 2026-09-22.
- [x] Test denied access and hidden shares.
  - Evidence: The `nas` account could not write to its read-only shares. `NasShare`
    was hidden and denied to this account.
- [x] Test macOS browse, create, rename, metadata, and reconnect behavior.
  - Evidence: Browse, create, rename, Finder tag, and reconnect tests passed from a
    MacBook Air M4.
- [x] Update the Samba README and troubleshooting instructions.
- [x] Record evidence and commit the complete package.
  - Evidence: This plan update completes the package commit.

## Work package 3: Samba security and application behavior

State: **Complete**

Goal: Use safe Samba defaults unless a representative test supports an override.

- [x] Select the server-signing policy.
  - Decision: Require signing. The Mac Studio already uses AES-128-GMAC signing, so
    this policy enforces its current protected path.
- [x] Select the locking policy for DAW and video work.
  - Decision: Use `strict locking = auto`. This is the Samba 4.19 default and balances
    lock enforcement with opportunistic-lock performance.
- [x] Select the case policy for macOS clients.
  - Decision: Use `case sensitive = auto`. This gives macOS case-insensitive and
    case-preserving behavior.
- [x] Test signing, locking, case behavior, and socket options.
  - Baseline evidence: The Mac Studio wrote 8 GiB at 275.7 MB/s and read it at
    226.7 MB/s over the 2.5 GbE path. The session used SMB 3.1.1 and AES-128-GMAC
    signing. Compression counters remained zero.
  - Preflight evidence: Host `testparm` accepted the repository configuration and
    reported `server signing = required`.
  - Host evidence: The installed file matched the repository, `smbd` was active, and
    all health checks passed after application on 2026-09-22.
  - Rollback backup: `/etc/samba/backups/smb.conf.20260922-144938`.
  - Performance evidence: Post-change write throughput was 275.75 MB/s. Baseline
    write throughput was 275.71 MB/s.
  - Performance evidence: Post-change read throughput was 206.42 MB/s. Baseline read
    throughput was 226.70 MB/s. The 8.9 percent reduction was within the predefined
    10 percent limit.
  - Signing evidence: The new Mac Studio session reported SMB 3.1.1,
    `SIGNING_REQUIRED TRUE`, `SIGNING_ON TRUE`, and AES-128-GMAC.
  - Compression evidence: All compression counters remained zero.
  - Case evidence: A differently capitalized lookup opened the existing file. A
    differently capitalized create operation did not create a second file.
  - Multichannel evidence: The new session used multichannel on the active 2.5 GbE
    Ethernet path after the explicit override was removed.
  - Test limitation: macOS `smbfs` returned `Errno 45` for a POSIX `lockf` request.
    This method cannot test SMB locking on this client.
  - Application evidence: Vim on the Mac Studio and MacBook Air detected a concurrent
    open through its swap-file protection. The file remained readable after the edit.
  - Workload evidence: Representative Studio One and CapCut operations passed. Read
    access from the other Apple clients also passed.
  - Accepted risk: The user chose not to install `smbtorture` or run a protocol-level
    SMB2 byte-range lock test. The normal workload has one writer and can have
    multiple readers. The user does not open one project for editing from two Macs.
- [x] Remove each override that has no necessary measured benefit.
  - Evidence: The repository uses Samba defaults for multichannel, leases,
    asynchronous input/output, socket options, and `use sendfile`. The accepted
    performance test did not show a necessary benefit from an override.
- [x] Document each decision, tradeoff, test, and accepted risk.
  - Evidence: This plan and `host/samba/README.md` contain the policy, workload,
    measurements, and accepted lock-test limitation.
- [x] Record evidence and commit the complete package.
  - Evidence: This plan update records the completed repository, host, performance,
    case, multichannel, application, and reader checks for the package commit.

## Work package 4: Samba deployment and recovery

State: **Pending**

Goal: Make Samba configuration deployment predictable and recoverable.

- [ ] Check Samba health after restart.
- [ ] Restore prior configuration and service state after failure.
- [ ] Add an execution lock.
- [ ] Make backup names unique.
- [ ] Define and apply a backup retention rule.
- [ ] Add a preflight or dry-run mode.
- [ ] Prevent unexpected privilege prompts in unattended checks.
- [ ] Correct the two ShellCheck messages.
- [ ] Test successful application and failed-application rollback.
- [ ] Document manual rollback.
- [ ] Record evidence and commit the complete package.

## Work package 5: secret controls

State: **Pending**

Goal: Prevent common secret files from entering Git.

- [ ] Select secret-file naming rules.
- [ ] Add a root `.gitignore` for approved secret and generated-file patterns.
- [ ] Keep example files trackable.
- [ ] Add secret templates when services need them.
- [ ] Document secret creation, storage, permissions, rotation, and restore.
- [ ] Add a local secret scan.
- [ ] Add a CI secret scan if the repository adopts CI.
- [ ] Evaluate encryption only when distribution requirements justify it.
- [ ] Test the ignore rules and secret scan.
- [ ] Record evidence and commit the complete package.

## Work package 6: host build and validation

State: **Pending**

Goal: Make the host configuration reproducible and easy to inspect.

- [ ] List required packages and their purposes.
- [ ] Record tested operating-system and package versions.
- [ ] Create an idempotent host build script or procedure.
- [ ] Automate mount-point, group, and non-secret configuration setup.
- [ ] Document manual user creation.
- [ ] Define and implement the firewall policy.
- [ ] Document network and name-resolution requirements.
- [ ] Add one read-only validation entry point below `scripts`.
- [ ] Validate storage, Samba, Docker, and each implemented service.
- [ ] Provide concise output and detailed diagnostics.
- [ ] Return a nonzero status after validation failure.
- [ ] Document and test the host build and validation procedures.
- [ ] Record evidence and commit the complete package.

## Work package 7: backup and disaster recovery

State: **Pending**

Goal: Restore important data and configuration after a failure.

- [ ] List all data and configuration that need backup.
- [ ] Define recovery-point and recovery-time objectives.
- [ ] Select off-host and off-site backup destinations.
- [ ] Implement backup automation and failure reports.
- [ ] Document bare-host restoration.
- [ ] Document disk replacement and mergerfs recovery.
- [ ] Document backup and restore for each stateful service.
- [ ] Test a restore with non-production data.
- [ ] Record and repeat restore tests.
- [ ] Record evidence and commit the complete package.

## Work package 8: iPhone sync

State: **Pending**

Goal: Implement a safe import and NAS publication process before phone deletion.

- [ ] Select the free-space reserve and phone clearing policy.
- [ ] Select the Immich file-ownership model before automatic cleanup.
- [ ] Record AFC and SSH decisions in the specification.
- [ ] Use `incoming` and `.uploading` in all documents.
- [ ] Build the command-line interface, manifest, AFC import, and SSH push.
- [ ] Make local and NAS publication atomic.
- [ ] Preserve complete asset groups with source data.
- [ ] Test mergerfs publication before Immich scans files.
- [ ] Add unit and device tests before phone deletion.
- [ ] Add explicit states, status, verification, and recovery.
- [ ] Require confirmation and NAS publication before deletion.
- [ ] Document installation, operation, and recovery on both Macs.
- [ ] Record evidence and commit each safe implementation milestone.

## Work package 9: service standards

State: **Pending**

Goal: Give each service a consistent and recoverable operating model.

- [ ] Define one service directory layout.
- [ ] Define an image-version policy.
- [ ] Add health, restart, dependency, and resource rules.
- [ ] Keep secrets outside committed Compose files.
- [ ] Document backup and restore next to each stateful service.
- [ ] Validate each Compose file before deployment.
- [ ] Add a README for `digital-archive-2026` or remove the placeholder.
- [ ] Distinguish implemented and planned services in the root README.
- [ ] Record evidence and commit the complete package.

## Work package 10: repository quality

State: **Pending**

Goal: Keep routine repository checks reliable and low maintenance.

- [ ] Select a minimal local or continuous-integration validation method.
- [ ] Run shell syntax checks and ShellCheck automatically.
- [ ] Add low-maintenance Markdown checks.
- [ ] Add tests next to executable code.
- [ ] Give priority to deletion, state, and recovery tests.
- [ ] Exclude generated logs, reports, databases, and staging data.
- [ ] Move remaining audit tasks from other TODO files to this plan.
- [ ] Compare documents with host state at defined intervals.
- [ ] Back up local-only commits outside this host.
- [ ] Record evidence and commit the complete package.

## Work package 11: audit closure

State: **Pending**

- [ ] Run all validation from a clean checkout.
- [ ] Test or safely dry-run the host build.
- [ ] Complete and record a restore test.
- [ ] Audit degraded storage and Samba authorization again.
- [ ] Confirm operation and recovery documents for each service.
- [ ] Resolve each audit finding or record its accepted risk.
- [ ] Write the final audit summary.
- [ ] Archive or replace this plan.
