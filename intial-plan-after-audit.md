# Initial Plan After Audit

## Purpose

This document is the single source of truth for audit work. The audit date is
2026-09-12. [`audit-results.md`](audit-results.md) contains the evidence.

The filename keeps the spelling from the initial request. Do not create a second plan.

## Plan rules

- Track all audit work here.
- Put design details in the applicable domain document.
- Complete an item only after implementation and validation.
- Add an `Evidence:` note to each important completed item.
- Add new work as a new checkbox.
- Record difficult decisions before implementation.
- Do stability work before performance and maintenance work.
- Follow [`working-with-host.md`](working-with-host.md) for host work.
- Get approval before a host change or destructive test.

## Completion criteria

- [ ] Storage stops safely when a required mount is absent.
- [ ] Samba stops safely when required storage is absent.
- [ ] Documents agree with executable configuration.
- [ ] An operator can rebuild the host from repository instructions.
- [ ] Important data has tested backup and restore procedures.
- [ ] Repository controls help prevent secret commits.
- [ ] Each service has operation and recovery instructions.
- [ ] One command or documented sequence validates the homelab.

## Phase 0: decisions

- [x] Define the safe host-work method.
  - Evidence: [`working-with-host.md`](working-with-host.md).
- [ ] Decide if all four mergerfs branches are required.
  - Proposed decision: Stop the pool and Samba when one branch is absent.
- [ ] Select `/ocean/Public` or `/ocean/public`.
  - Proposed decision: Use `/ocean/Public`.
- [ ] Select the Samba signing policy.
  - Proposed decision: Use the default until tests show a necessary benefit.
- [ ] Select the Samba locking policy.
  - Proposed decision: Use conservative locking until application tests pass.
- [ ] Select the Samba case policy.
  - Proposed decision: Use macOS-compatible behavior until application tests pass.
- [ ] Select secret-file naming rules.
- [ ] Select the Immich file-ownership model.

## Phase 1: immediate hazards

### Storage

- [ ] Make mergerfs require all selected branch mounts.
- [ ] Make mergerfs start after all selected branch mounts.
- [ ] Prevent mergerfs from using an unmounted root-filesystem directory.
- [ ] Review `nofail` for each required disk.
- [ ] Document boot behavior when a disk is absent.
- [ ] Check expected UUIDs before service start.
- [ ] Check branch mounts and filesystem types before service start.
- [ ] Check the `/ocean` mergerfs mount before service start.
- [ ] Stop Samba when a storage check fails.
- [ ] Test each missing-branch condition with non-production data.
- [ ] Check free space on the root filesystem and pool branches.

### Samba

- [ ] Use one Public path in configuration, scripts, and documents.
- [ ] Make `setup-access.sh` verify mergerfs before a change.
- [ ] Make `setup-access.sh` verify all required users before a change.
- [ ] Use group-only directory modes unless other-user access is necessary.
- [ ] Make `check.sh` verify share paths.
- [ ] Make `check.sh` verify owners, groups, and modes.
- [ ] Make `check.sh` verify mergerfs branch health.
- [ ] Run `testparm` on the repository configuration.
- [ ] Apply corrections in an approved maintenance period.
- [ ] Test each Samba role with a representative account.
- [ ] Test denied access and hidden shares.
- [ ] Test macOS browse, create, rename, metadata, and reconnect behavior.

## Phase 2: document current state

- [ ] Make the storage README match current paths and UUIDs.
- [ ] Document `epmfs` and the 50 GiB limit.
- [ ] Document storage packages, setup, validation, and rollback.
- [ ] Remove obsolete storage paths.
- [ ] Correct branch paths in the Samba README.
- [ ] Document Samba signing, locking, case, and storage-failure policies.
- [ ] Separate current observations from permanent instructions.
- [ ] Add Samba authentication, permission, mergerfs, and share troubleshooting.
- [ ] Record AFC and SSH decisions in the iPhone sync specification.
- [ ] Use `incoming` and `.uploading` in all iPhone sync documents.
- [ ] Add a README for `digital-archive-2026` or remove the placeholder.
- [ ] Distinguish implemented and planned services in the root README.

## Phase 3: harden Samba deployment

- [ ] Check Samba health after restart.
- [ ] Restore prior configuration and service state after failure.
- [ ] Add an execution lock.
- [ ] Make backup names unique.
- [ ] Define and apply a backup retention rule.
- [ ] Add a preflight or dry-run mode.
- [ ] Prevent unexpected privilege prompts in unattended checks.
- [ ] Correct the two ShellCheck messages.
- [ ] Test socket options, signing, locking, and case behavior.
- [ ] Remove overrides that have no measured benefit.

## Phase 4: protect secrets

- [ ] Add a root `.gitignore` for approved secret patterns.
- [ ] Ignore local environment files, credentials, keys, and generated data.
- [ ] Keep example files trackable.
- [ ] Add secret templates when services need them.
- [ ] Document secret creation, storage, permissions, rotation, and restore.
- [ ] Add a local secret scan.
- [ ] Add a CI secret scan if the repository adopts CI.
- [ ] Evaluate encryption only when distribution requirements justify it.

## Phase 5: reproduce and validate the host

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
- [ ] Document the validation command in the root README.

## Phase 6: backup and recovery

- [ ] List all data and configuration that need backup.
- [ ] Define recovery-point and recovery-time objectives.
- [ ] Select off-host and off-site backup destinations.
- [ ] Implement backup automation and failure reports.
- [ ] Document bare-host restoration.
- [ ] Document disk replacement and mergerfs recovery.
- [ ] Document manual Samba rollback.
- [ ] Document backup and restore for each stateful service.
- [ ] Test a restore with non-production data.
- [ ] Record and repeat restore tests.

## Phase 7: services

### iPhone sync

- [ ] Select the free-space reserve and phone clearing policy.
- [ ] Build the CLI, manifest, AFC import, and SSH push.
- [ ] Make local and NAS publication atomic.
- [ ] Preserve complete asset groups with source data.
- [ ] Test mergerfs publication before Immich scans files.
- [ ] Add unit and device tests before phone deletion.
- [ ] Add explicit states, status, verification, and recovery.
- [ ] Require confirmation and NAS publication before deletion.
- [ ] Document installation, operation, and recovery on both Macs.

### Docker Compose

- [ ] Define one service directory layout.
- [ ] Define an image-version policy.
- [ ] Add health, restart, dependency, and resource rules.
- [ ] Keep secrets outside committed Compose files.
- [ ] Document backup and restore next to each stateful service.
- [ ] Validate each Compose file before deployment.
- [ ] Add Immich after file-ownership and backup decisions.

## Phase 8: repository quality

- [x] Add repository instructions for future agents.
  - Evidence: [`AGENTS.md`](AGENTS.md) defines sources of truth, ASD-STE100 writing,
    host safety, change procedure, repository rules, and validation.
- [ ] Select a minimal local or CI validation method.
- [ ] Run shell syntax checks and ShellCheck automatically.
- [ ] Add low-maintenance Markdown checks.
- [ ] Add tests next to executable code.
- [ ] Give priority to deletion, state, and recovery tests.
- [ ] Exclude generated logs, reports, databases, and staging data.
- [ ] Move audit tasks from other TODO files to this plan.
- [ ] Compare documents with host state at defined intervals.
- [ ] Back up local-only commits outside this host.

## Phase 9: close the audit

- [ ] Run all validation from a clean checkout.
- [ ] Test or safely dry-run the host build.
- [ ] Complete and record a restore test.
- [ ] Audit degraded storage and Samba authorization again.
- [ ] Confirm operation and recovery documents for each service.
- [ ] Resolve each audit finding or record its accepted risk.
- [ ] Write the final audit summary.
- [ ] Archive or replace this plan.
