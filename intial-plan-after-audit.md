# Initial Plan After Audit

## Purpose

This document is the single source of truth for audit work. The audit date is
2026-09-12. [`audit-results.md`](audit-results.md) contains the evidence.

The filename keeps the spelling from the initial request. Do not create a second plan.

## Current status

Last update: 2026-10-19

Current package: **Work package 12: network documentation and recovery**

State: **Active**

The operational WDS fault is closed. The 2026-10-06 packet evidence and
2026-10-09 owner report support that conclusion. See
`networking/wds-retrospective.md` for failed results and acceptance limits.
On 2026-10-17, the owner also accepted the swapped AP layout as sufficient.
Keep MT6000 in the kitchen and MT1300 in the study. Preserve AXT1800–WAX202
WDS on channel 153 / 80 MHz. Further coverage work and purchases are deferred.
The reported 2026-10-16 results and acceptance are in the investigation
workspace's `note.md` and `plan.md`.

Applied corrections include AXT1800 static `.5` and DNS-based aliases,
OpenWrt SSH authentication hardening, MikroTik service/source restrictions,
AU radio settings on MT6000 and WAX202, and the persistent MT1300 NTP repair.
MT1300 automatic time recovery passed a second controlled reboot.
MikroTik RouterOS and RouterBOOT are 7.23.8 long-term. WAX202 is on OpenWrt
25.12.5. Immediate MikroTik and WAX202 owner checks passed, including required
Tailscale access. Their later upgrade-specific stability gates remain open.
MT6000 AU runtime and reboot persistence passed. The owner's later everyday
Wi-Fi use is accepted; no new dedicated post-reboot Tailscale test was claimed.

Documentation closeout reconciled `networking/README.md`, `topology.md`,
`configuration-backup.md`, and `source-reconciliation.md` with these records.
The retained baseline uses `.lan` names and the working Tailscale path.
Pi-hole deployment, `home.arpa` migration, Bilibili playback investigation,
new hardware, and radio tuning are deferred optional follow-up.
This closes the current operational-documentation outcome. It does not close
the full firmware review, physical port map, templates, restore verification,
tool hardening, final regression coverage, or finding dispositions.

The encrypted NAS-local recovery bundle passed integrity, decryption, and
retrieval checks. The owner accepts that NAS loss also loses that copy.
An off-host copy is deferred under that accepted risk. Actual restore and a
complete final-state capture remain unverified. HTTP management remains
accepted; HTTPS work is deferred. Tailnet access-policy review is incomplete.

The 2026-10-17 firmware source comparison covers all five recorded builds.
It found later uHTTPd defects in the 25.12.5 web-service revision. The current
official feeds contain corrected packages. A separate targeted-update
procedure is prepared. WAX202 was subsequently updated as recorded below.
AXT1800 remains prepared only. MT6000 stable 4.11.0 is newer than
the status-table entry, but its notes do not establish the required parser
fixes. Vendor patch mapping remains unresolved. Keep these security gates
open. Existing HTTP acceptance does not accept the newly identified defects.

The owner approved the WAX202 uHTTPd/module update. It was applied on
2026-10-17. Both packages are now `2026.08.24~373145f7-r1`. Fresh native
trust, simulation, backup, and original-image checks passed before application.
Only those two installed packages changed. The web service required one
explicit restart to load the new executable. Fresh SSH, executable hashes,
the LuCI login challenge, and WDS state passed. Existing configuration and
APK world hashes are unchanged. No device reboot or network change occurred.

The owner confirmed Air SSH and physical access before installation and
accepted original-firmware recovery if needed. That recovery remains untested.
Exact old APKs are unavailable. WAX202 recovery files are also on AXT1800,
so they do not depend on NAS access through WAX202. AXT1800 was updated
later as recorded below.

On 2026-10-18, the owner approved the separate studio OX Wi-Fi addition.
WAX202 now provides `Moo Moo Farm` on its 2.4 GHz radio. Native AP/security
checks passed. The WDS configuration and association stayed unchanged.
OX connection and app control passed by owner report.
This radio change does not close the web-service observation gate. See
`networking/changes/wax202-ox-wifi.md`.

WAX202's web-service observation passed on 2026-10-19 Sydney, about
26 hours after activation. The owner reports no network issues. Fresh state
confirms the same process, boot ID, continuous WDS association, and accepted
post-OX configuration. Retained logs have no crash/out-of-memory match.
This does not close the final observation after later changes.

AXT1800's two-package update was then approved and applied on 2026-10-19
Sydney. Both WDS endpoints now have uHTTPd and its ubus module at
`2026.08.24~373145f7-r1`. AXT1800's package/world/configuration checks,
new running executable, fresh SSH, LuCI login challenge, and continuous
WDS association pass. One explicit web-service restart completed activation.
The owner confirmed Air SSH, browser login, and off-LAN Tailscale access.
No network setting, device boot, or other installed package changed.

Resume work with these actions:

1. Review AXT1800's 24-hour normal use no earlier than 2026-10-20 01:27
   Sydney. Record client reports and fresh service/WDS state. Retain its
   original recovery images and paired configuration during observation.
2. Use the owner's production-firmware policy recorded on 19 October.
   Prepare MT6000's stable update with backup, compatibility, rollback, and
   normal-function checks. The last catalogue review identified 4.11.0 as
   its stable candidate and 4.3.25 as MT1300's latest stable release.
   Recheck the catalogue before application. Preserve MT1300's NTP patch.
   Vendor patch mapping and the unsent enquiry are deferred maintenance
   research. They are not baseline closure gates.
3. Finish tool hardening, representative regression, the final observation
   after later changes, and finding dispositions in their existing stages.

Next available focus: **Work package 12, Stage 5: AXT1800 observation and
production firmware**. The vendor enquiry is deferred and remains unsent.
WAX202's web-service observation remains accepted.
AXT1800's installation has immediate client acceptance, but its observation
is open. This checkpoint is committed locally. Private evidence and recovery
files remain ignored. Revalidate temporary AP files before any recovery.

The approved 2026-10-07/08 source reconciliations remain in
`networking/source-reconciliation.md`, `research-source-reconciliation.md`,
and `home-automation-source-reconciliation.md`. Their bounded documentation
exceptions did not deploy a service or close recovery gates.
iPhone sync remains paused. Resume it after package 12 at the already planned
atomic local import and small-device tests. Its own plan remains canonical.

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
- **Paused:** The user explicitly deferred this package. Keep its resume steps.
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

State: **Complete**

Goal: Make Samba configuration deployment predictable and recoverable.

- [x] Check Samba health after restart.
  - Evidence: The guarded host installation restarted `smbd` and passed every check
    in `host/samba/check.sh` on 2026-09-22.
- [x] Restore prior configuration and service state after failure.
  - Evidence: The local failed-health-check test restored the prior configuration and
    active `smbd` state.
- [x] Add an execution lock.
  - Evidence: The local test rejected a second installation while the lock was held.
- [x] Make backup names unique.
  - Evidence: Backups use a nanosecond timestamp and a random `mktemp` suffix. The
    local test created two distinct backups.
- [x] Define and apply a backup retention rule.
  - Decision: Keep the ten newest `smb.conf.*` backups.
  - Evidence: The local test removed the two oldest files from a set of twelve.
- [x] Add a preflight or dry-run mode.
  - Evidence: `--check` is the default and does not request root access or make a
    change.
  - Host evidence: The preflight validated the Samba configuration and all required
    storage on 2026-09-22. It reported only the known low-free-space warning for
    `/mnt/disks/ssd2`.
- [x] Prevent unexpected privilege prompts in unattended checks.
  - Evidence: The script does not call `sudo`. The preflight runs without root. The
    install operation stops with an instruction when it does not run as root.
- [x] Correct the two ShellCheck messages.
  - Evidence: ShellCheck 0.11.0 reports no messages for all Samba shell scripts.
- [x] Test successful application and failed-application rollback.
  - Local evidence: The automated test passed the successful installation and failed
    health-check rollback cases.
  - Host evidence: The install operation completed successfully and created
    `/etc/samba/backups/smb.conf.20260922-172610-759754767.KFVeOK`.
  - Host evidence: The installed configuration matched the repository through the
    read-only host mount after installation.
  - Client evidence: A representative Mac reconnected and opened a file after the
    guarded restart.
- [x] Document manual rollback.
  - Evidence: `host/samba/README.md` gives ordered validation, restoration, restart,
    and health-check steps.
- [x] Record evidence and commit the complete package.
  - Evidence: This plan update records the local recovery tests, host preflight,
    guarded installation, health check, installed-file comparison, and client test
    for the package commit.

## Work package 5: secret controls

State: **Complete**

Goal: Prevent common secret files from entering Git.

- [x] Select secret-file naming rules.
  - Decision: Use standard `.env` names and explicit secret, token, private-key, and
    credential suffixes. Append `.example` to a committed template.
- [x] Add a root `.gitignore` for approved secret and generated-file patterns.
- [x] Keep example files trackable.
- [x] Add secret templates when services need them.
  - Decision: No implemented service needs a template. Add one with the first
    service that needs a secret.
- [x] Document secret creation, storage, permissions, rotation, and restore.
- [x] Add a local secret scan.
- [x] Add a CI secret scan if the repository adopts CI.
  - Decision: The repository does not use CI. Reassess this control when CI is added.
- [x] Evaluate encryption only when distribution requirements justify it.
  - Decision: Do not add repository encryption for this private personal repository.
    Reassess it for distribution or one-command rebuild requirements.
- [x] Test the ignore rules and secret scan.
  - Evidence: Tests confirmed that local secret and generated files are ignored and
    `.example` files remain trackable.
  - Evidence: Synthetic password, provider-token, private-key, and prohibited-name
    findings were detected without printing matched values.
  - Evidence: The repository worktree and staged-content scans passed.
- [x] Record evidence and commit the complete package.
  - Evidence: Bash syntax, ShellCheck 0.11.0, secret-control tests, both secret scans,
    and `git diff --cached --check` passed for the package commit.

## Work package 6: host build and validation

State: **Complete**

Goal: Make the host configuration reproducible and easy to inspect.

- [x] List required packages and their purposes.
  - Evidence: `host/packages.tsv` lists the host packages and one purpose for each.
- [x] Record tested operating-system and package versions.
  - Evidence: The tested host is Ubuntu 24.04.5 LTS. `host/packages.tsv` records the
    installed versions found through the read-only host mount.
- [x] Create an idempotent host build script or procedure.
  - Evidence: `host/README.md` gives an ordered build procedure that uses the existing
    idempotent storage, Samba, and firewall installers.
- [x] Automate mount-point, group, and non-secret configuration setup.
  - Evidence: The build procedure uses `host/storage/apply.sh`,
    `host/samba/setup-access.sh`, and `host/samba/apply.sh`.
- [x] Document manual user creation.
  - Evidence: The host build document separates the interactive administrator,
    non-interactive media account, Samba credentials, and Docker administrator role.
- [x] Define and implement the firewall policy.
  - Decision: Trust the home LAN, Apple TV Tailscale subnet route, IPv6 link-local
    LAN traffic, and a future direct `tailscale0` interface. Deny other new inbound
    host and Docker traffic.
  - Decision: Permit established and bridge-originated Docker traffic for the
    current containers.
  - Accepted risk: The required `dde-vincent` development environment uses host
    networking and unconfined seccomp and AppArmor settings. It does not use Docker's
    full privileged mode.
  - Evidence: The preflight passed on the host. The approved install enabled UFW and
    the Docker ingress filter. `host/firewall/check.sh` passed after installation.
  - Evidence: The rollback backup is
    `/etc/homelab-backups/firewall/firewall.20260922-184141-738159001.Odl0Gy`.
  - Evidence: Tailscale access passed with and without the Apple TV exit node after
    the separate WDS ARP discovery path was refreshed.
  - Evidence: Packet capture and a temporary UFW disable showed that the failed test
    did not reach the NAS. Pinging the Apple TV's new address from the NAS refreshed
    the WDS path. Remote access then passed with the firewall enabled.
- [x] Document network and name-resolution requirements.
  - Evidence: `host/README.md` records the interface, address, subnet, gateway,
    hostname, multicast DNS, Tailscale, and no-port-forward requirements.
- [x] Add one read-only validation entry point below `scripts`.
  - Evidence: `scripts/validate-host.sh` runs the host checks without making changes.
- [x] Validate storage, Samba, Docker, and each implemented service.
  - Evidence: `sudo ./scripts/validate-host.sh` passed all package, storage, Samba,
    firewall, service, container, DDE security, and listener checks.
  - Evidence: New SSH, Grafana, Samba, and DDE outbound connections passed after the
    firewall installation.
- [x] Provide concise output and detailed diagnostics.
  - Evidence: The validation entry point prints one result per check and supports
    `--verbose` or `DEBUG=1` output.
- [x] Return a nonzero status after validation failure.
  - Evidence: The validation entry point counts failures and exits with status 1.
- [x] Document and test the host build and validation procedures.
  - Evidence: `host/README.md` documents the build sequence. The host ran each
    implemented component and the complete validation entry point.
  - Evidence: The first firewall install found a UFW output-parser error. Automatic
    rollback restored inactive UFW, the prior Samba rule, and no custom Docker chain.
    The corrected validator and second installation passed.
- [x] Record evidence and commit the complete package.
  - Evidence: Bash syntax, ShellCheck, the secret scan, and `git diff --check` passed.
    The real host preflight, install checks, complete validation, and client tests
    passed.

## Work package 7: backup and disaster recovery

State: **Complete**

Goal: Restore important data and configuration after a failure.

- [x] List all data and configuration that need backup.
  - Evidence: The pool uses 3.2 TB of 3.6 TB. The OS disk uses 162 GB of 233 GB,
    including 123 GB below `/sandbox`.
  - Evidence: The inventory includes Grafana, Prometheus, Jellyfin, Samba, Docker
    definitions and volumes, credentials, Git repositories, and host configuration.
  - Accepted risk: Do not back up NAS-only pool data, local development data,
    unpushed work, credentials, or mutable service state.
- [x] Define recovery-point and recovery-time objectives.
  - Decision: The configuration recovery point is the last commit pushed upstream.
    Recovery is best effort with no formal time guarantee.
  - Decision: NAS-only data and mutable service state have no recovery objective.
- [x] Select off-host and off-site backup destinations.
  - Decision: Use the existing upstream Git remote for committed configuration. Use
    the user's existing cloud workflow for important personal documents. Add no new
    backup destination.
- [x] Implement backup automation and failure reports.
  - Decision: Do not automate bulk backup or Git pushes. No repository-managed data
    set requires scheduled backup.
  - Evidence: `scripts/check-recovery-readiness.sh` reports a dirty worktree, a
    missing or local upstream, local-only commits, and repository secret findings.
- [x] Document bare-host restoration.
  - Evidence: `host/recovery/README.md` defines the ordered bare-host procedure and
    identifies the temporary Compose recovery gap owned by work package 9.
- [x] Document disk replacement and mergerfs recovery.
  - Evidence: The recovery runbook stops dependent services, preserves the option for
    read-only recovery, replaces the branch UUID, and states that mergerfs does not
    reconstruct lost files.
- [x] Document backup and restore for each stateful service.
  - Decision: Recreate Grafana, Prometheus, Jellyfin, Samba credentials, and DDE
    state. Do not restore their mutable state.
- [x] Test a restore with non-production data.
  - Evidence: `scripts/test-recovery.sh` restored the staged Git index to a temporary
    directory and validated all restored shell scripts.
  - Limitation: `testparm` was unavailable in the development container. Work
    package 6 validated the same Samba configuration on the NAS host.
- [x] Record and repeat restore tests.
  - Evidence: `scripts/test-recovery.sh` provides the repeatable test. Work package
    11 owns the complete clean-clone recovery test.
- [x] Record evidence and commit the complete package.
  - Evidence: Commit `511d1fb` contains the recovery policy, readiness check, and
    repeatable restore test. It was pushed to the off-host upstream.
  - Evidence: The clean-worktree, upstream, off-host remote, pushed-commit, and secret
    checks passed after the push.

## Work package 8: iPhone sync

State: **Paused**

The user confirmed the pause on 2026-10-06. The WDS fault caused the access
blocker. The forwarding test now passes, but the user selected network
consolidation while the new setup completes its soak test. Resume at atomic local
import, a small Mac Studio import, and an interrupted import test.

Goal: Implement a safe import and NAS publication process before phone deletion.

- [x] Select the free-space reserve and phone clearing policy.
  - Evidence: Reserve the planned import size plus 5 GiB. Require a complete local
    asset group and successful NAS publication before an explicit and interactive
    phone clear. Keep the local copy until a separate prune operation.
- [x] Keep Immich deployment separate from the iPhone-sync implementation.
  - Evidence: The iPhone workflow ends safely at NAS publication. Immich is an
    optional downstream index and is not a phone-deletion requirement.
- [x] Select the Immich file-ownership model before automatic cleanup.
  - Evidence: The NAS archive remains canonical. Immich will index it as an external
    library and will not own, move, or rename its files.
- [x] Record AFC and SSH decisions in the specification.
  - Evidence: The specification records AFC as the selected import backend and SSH
    to host `nas` as the selected publication transport.
- [x] Use `incoming` and `.uploading` in all documents.
  - Evidence: The iPhone-sync README, plan, specification, and project notes use the
    selected directory names.
- [ ] Build the command-line interface, manifest, AFC import, and SSH push.
  - Progress: Added the Python package, per-Mac configuration, SQLite schema, `init`,
    `status`, read-only AFC discovery, and 19 unit tests. AFC download and SSH
    publication remain pending.
  - Evidence: Mac Studio discovery found 8,157 files and 27,021,035,750 bytes on the
    paired iPhone without downloading or changing a file.
- [ ] Make local and NAS publication atomic.
- [ ] Preserve complete asset groups with source data.
- [ ] Test mergerfs publication before Immich scans files.
- [ ] Add unit and device tests before phone deletion.
- [ ] Add explicit states, status, verification, and recovery.
  - Progress: Added manifest state transitions, grouped clear eligibility, status
    counts, and state-transition tests. Verification and recovery remain pending.
- [ ] Require confirmation and NAS publication before deletion.
- [ ] Document installation, operation, and recovery on both Macs.
- [ ] Record evidence and commit each safe implementation milestone.

## Work package 9: service standards

State: **Pending**

Goal: Give each service a consistent and recoverable operating model.

- [ ] Define one service directory layout.
- [ ] Define an image-version policy.
- [ ] Add health, restart, dependency, and resource rules.
- [ ] Add SMART, filesystem-capacity, mount, and host-validation metrics and alerts.
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

## Work package 12: network documentation and recovery

State: **Active**

Goal: Preserve the working network, implement approved audit corrections, and
make device configuration recoverable. The user requested the complete improvement
plan on 2026-10-09. This expands the existing package explicitly. Optional
architecture changes remain separate decisions within its stages.

### Completed baseline

- [x] Consolidate the current design and focused topology diagrams.
  - Evidence: `networking/README.md` and `networking/topology.md` identify the
    source inventory and the management fields that still need confirmation.
- [x] Replace the old WDS setup instructions with the verified firmware result.
  - Evidence: `networking/wds-backhaul-setup.md` links the old failed capture and
    the passing 2026-10-06 four-address broadcast capture.
- [x] Distil the investigation into a reusable workflow and tool lessons.
  - Evidence: `networking/troubleshooting.md` records interface discovery,
    cached ARP, observer effects, capture cleanup, and failed-test preservation.
- [x] Define configuration and private recovery-copy requirements.
  - Evidence: `networking/configuration-backup.md` follows the existing secret
    policy and separates collection from verified reproducibility.
- [x] Prepare the private macOS and Linux configuration collector.
  - Evidence: `scripts/capture-network-config.sh` passed Bash syntax, ShellCheck,
    and mocked full collection and interrupted SSH checks. It retains partial
    files and records missing MikroTik binary-backup coverage. Live collection
    completed on all five devices from Linux on 2026-10-06.
- [x] Confirm the Air aliases and the MT1300 client coverage.
  - Evidence: User confirmation on 2026-10-06; `networking/topology.md` records
    `mt6000`, `mt1300`, `wax202`, `axt1800`, and `mikrotik`.
- [x] Confirm management addresses and OpenWrt/RouterOS versions.
  - Evidence: Private board identity, MikroTik identity, and live IPv4 state in
    `secrets/local/network/20261006T103815Z/`; `networking/topology.md` records them.
- [x] Audit the five saved network-device configurations without device contact.
  - Evidence: `networking/configuration-audit-2026-10-09.md`; all five checksum
    manifests were recalculated and matched; all four archives were readable and
    contained every captured backup-list entry. Findings separate saved settings,
    inferred risks, and unverified runtime state. No network change occurred.
- [x] Collect and review authorized read-only runtime state from all five devices.
  - Evidence: Private `secrets/local/network-runtime/20261009T004414Z/`;
    `networking/runtime-audit-2026-10-09.md`. All 18 initial SSH transports passed;
    section failures and follow-up limits remain explicit. Output hashes and
    private permissions passed verification. No active probe or network change ran.
- [x] Add a private runtime collector with explicit execution and evidence retention.
  - Evidence: `scripts/capture-network-runtime.py`; Python and remote shell syntax,
    isolated mocked success and connection failure, partial retention, continued
    collection, private permissions, and default-help behavior passed. Live evidence
    exposed missing tools; the final collector adds fallbacks and explicit checks.
- [x] Collect current OpenWrt exports, configuration archives, and MikroTik text export.
  - Evidence: Private capture `20261006T103815Z`; four tar checks and all SHA-256
    checks passed. Directories are `0700`, files are `0600`, and Git ignores them.
- [x] Record the WDS retrospective and reported operational acceptance.
  - Evidence: `networking/wds-retrospective.md`; the user reported several days
    without an issue on 2026-10-09, including idle access and demanding transfers.
    The controlled 2026-10-06 capture verified correct broadcast ARP forwarding.
- [x] Review documentation links and run the repository secret scan.
  - Evidence: The local Markdown links resolve and `scripts/check-secrets.sh`
    passed. The new files contain documentation and synthetic-tested code only.

### Documentation closeout — 2026-10-17

- [x] Reconcile the retained topology, current software, addressing, naming, and operating notes.
  - Evidence: `networking/README.md`, `networking/topology.md`,
    `networking/configuration-backup.md`, and `networking/source-reconciliation.md`.
    Sources include the owner's 2026-10-16 performance report and explicit
    2026-10-17 acceptance, plus applied-change records. No new runtime evidence
    or device configuration was claimed. Exact ports and recovery stay open.
- [x] Record accepted limits and deferred optional improvements.
  - Evidence: owner acceptance in the investigation `note.md` and `plan.md`;
    current topology and README retain MT6000 kitchen, MT1300 study, `.lan`,
    and the working WDS/Tailscale paths. Additional Wi-Fi work and purchases
    are deferred. Optional DNS, Pi-hole, and playback work are not closure gates.

### Network improvement stages

This is the only implementation checklist for the network audit. The reports in
`networking/` retain the evidence and findings. The user requested this plan on
2026-10-09. Stages 1 and 2 have completion evidence. Management hardening and
AU country corrections have passed the bounded checks recorded below. HTTPS
remains deferred. Stage 5 firmware review is the next focus. Stages 6–8 remain
open. Dated earlier results below are history, not instructions to repeat a change.

Complete one stage before the next. Apply one bounded change to one device at a
time. Record each result here with its date and private evidence path. A finding
can close as corrected and verified, retained with an accepted risk, or not
applicable with evidence. An optional idea does not require implementation.
A deferred required fix keeps its finding open.

| Stage | Outcome | Findings |
|---|---|---|
| 0 | Verified recovery artifacts and a concrete first change proposal | N07; all change prerequisites |
| 1 | AXT1800 address protected from dynamic allocation | N01 |
| 2 | MT1300 clock synchronized and its failure explained | N13 |
| 3 | Required management access retained; unused access removed | N04, N05, N06 |
| 4 | Australian radio settings verified with working clients and WDS | N02 |
| 5 | Deliberate update policy and reviewed firmware decisions | N03, N08 |
| 6 | Reproducible configuration and a verified recovery procedure | N07, N09 |
| 7 | Evidence-based decisions on isolation, IPv6, radio tuning, and latency | N10, N11, N12; remaining runtime gaps |
| 8 | Reliable tools, final regression evidence, and recorded dispositions | Retrospective actions; all findings |

#### Stage 0: prepare recovery and the first change

- [x] Review the two audit reports and identify state that must be refreshed before a change.
  - Inputs: `networking/configuration-audit-2026-10-09.md` and
    `networking/runtime-audit-2026-10-09.md`. Use collector timestamps for MT1300
    until its clock is corrected. Keep the WDS operational fix accepted.
- [x] Verify the approved NAS-local encrypted recovery copy.
  - Evidence: `/sandbox/vincent/home_network_backup/20261009T085347Z/manifest.json`.
    AES256 outer archive decrypts and matches the original plaintext hash.
    User explicitly accepts that NAS loss also loses these backups.
    This is a smaller recovery baseline, not off-host protection.
  - Use the existing approved private backup method. Record the destination,
    encryption method, integrity check, and access procedure without secret values.
    Do not treat a second directory on the NAS as off-host protection.
    Recovery helper: `scripts/prepare-network-recovery.py`.
    Use `--run --resume 20261009T085347Z` only to finish this existing attempt.
    The initial outer encryption failed before verification. A shorter temporary
    GPG home corrected the failure. The same router backup was reused.
    No router restore or certificate/key recovery test was performed.
- [x] Create and verify an encrypted MikroTik binary backup under an approved procedure.
  - Evidence: the same recovery manifest records two matching SFTP downloads,
    byte size, SHA256, and explicit AES-SHA256 password encryption.
    Private passphrases remain in ignored `secrets/local/network-recovery-keys/`.
    SSH keys are inventoried; restore remains untested. The fresh Stage 3 certificate
    listing contains no certificate objects. The earlier certificate count included
    a flag legend and was incorrect.
  - Inventory certificate and SSH-key dependencies separately. Store the backup
    password through the existing private secret method. Do not put it in command
    history, the repository, or chat. Verify readability and hashes after retrieval.
- [x] Confirm the recovery path and required SSH and web management.
  - Evidence: user confirms physical access and the Air on the main LAN.
    Preserve SSH and web interfaces on all devices.
    FTP/API, Winbox, cloud, and remote-management dependencies remain unconfirmed;
    review them before disabling services in Stage 3.
  - Record the Air's main-LAN path, the container's WDS dependency, required SSH
    and Winbox access, intended browser access, integrations using FTP/API, remote
    management through Tailscale or vendor cloud, and access if a radio fails.
- [x] Prepare the exact Stage 1 proposal, preflight, verification, and rollback for review.
  - Evidence: `networking/changes/protect-axt-address.md`.
    Fresh read-only capture confirms the static AP address, pool, and empty `.115` state.
    At proposal time, application had not run. Stage 1 below records the later
    applied migration and verification. Do not repeat the original proposal.
  - Include the current pool and leases, intended change, expected interruption,
    change source, and original values. Request approval only when this result is
    concrete. Prepare scripts or native configuration in the repo before application.

Stage gate: the user accepted NAS-local recovery on 2026-10-09.
Private artifacts have passed integrity and decrypt checks. No off-host copy exists.
The first change has a reviewed rollback. If a recovery item cannot be completed,
record the reason and obtain explicit acceptance before using a smaller recovery
baseline. Do not claim restore verification at this stage.

#### Stage 1: protect the AXT1800 address

The user replaced the pool split with static `.5`, hostname `axt1800`,
MikroTik comment `WDS-AP`, and DNS-based SSH on 2026-10-09.

- [x] Refresh the AP identity and check `.5` for a known conflict.
  - Evidence: private `network-stage0/20261009T091612Z`; no `.5` lease or ARP
    entry. Three ARP probes received no reply. Offline use remains unprovable.
- [x] Apply static `.5`, hostname `axt1800`, and the MikroTik inventory reservation.
  - Evidence: `networking/changes/protect-axt-address.md`; final private
    `network-migration/20261009T093238Z`. The pool remains `.100-.199`.
    Saved config, kernel address, and netifd agree. AP SSH and HTTP pass.
- [x] Add explicit DNS records for all five network devices and migrate workspace SSH.
  - Evidence: private `network-migration/20261009T092829Z`; all five short names
    and qualified names resolve. SSH passes with trusted keys. User/key rules remain.
- [x] Verify gateway, DNS, Internet, AP SSH/web, and network-device access from the Air.
  - Evidence: user terminal output confirms `.5` DNS, 3/3 gateway replies, and
    Internet HTTP 200. User confirms AP web, hostname read, and all five SSH tests.
    This verifies WAX202 management access, not a new file-transfer stress test.
- [x] Update the Air's separate SSH config after its DNS checks pass.
  - Evidence: user reports all five SSH checks pass after the documented edits.
    The Air retains IP-valued HostKeyAlias only for trusted-key lookup.
    HostName now selects DNS; usernames and keys remain.

The initial migration interrupted IPv4 management. Secondary-address deletion and
an absent `nohup` caused the failure. IPv6 SSH recovered access. A netifd reload
reconciled state. Native RouterOS multiline parsing also reported an error;
independent checks confirmed the intended entries. Keep these failed results.
The migration record contains recovery steps and evidence. A reboot persistence
test remains unperformed. N01 allocator protection and Air client acceptance are verified. Stage 1 is complete
for this bounded migration; reboot persistence remains untested. The old recovery archive is a pre-change baseline.

#### Stage 2: correct MT1300 time synchronization

Initial diagnosis: the active NTP jail has a zero-byte resolver file. Host DNS
and query-only NTP work. The clock offset is about +1711687.74 seconds.
Evidence: private `network-time/20261009T100429Z` and `20261009T100608Z`.
See `networking/changes/mt1300-time.md`. The empty resolver is observed; its
origin and boot recurrence are unconfirmed. One approved sysntpd restart restored the resolver and clock. No service
configuration was edited. Evidence: `network-time/20261009T100818Z`.
Offset was about -0.194 s at 10:08:30 UTC; SSH and web passed.
The later reboot reproduced the stale jailed resolver. The persistent resolver-tracking
correction passed a second reboot. See the evidence below.

- [x] Diagnose NTP server resolution, routing, egress behavior, daemon state, and synchronization evidence.
  - Evidence: the three private `network-time` captures listed above. DNS and
    NTP replies work outside the jail. The active jailed resolver was empty.
    No exhaustive firewall review or boot-cause claim is implied.
  - Read the relevant state first. Any DNS or NTP probe belongs in the approved
    diagnostic scope. Distinguish a running process from successful synchronization.
- [x] Apply the smallest approved runtime correction and record the supported cause.
  - Evidence: one sysntpd restart rebuilt the resolver and restored synchronization.
    `networking/changes/mt1300-time.md` records the before/after state.
    No persistent configuration edit or manual clock set occurred.
  - Preserve the original configuration. Do not replace the time architecture on
    every device to solve one fault. Do not use a manual date change as the fix.
- [x] Verify UTC alignment and subsequent synchronization from an independent clock.
  - Evidence: private `network-stability/20261010T122714Z`. After more than 26 hours,
    offset is about -0.637 seconds. Same NTP PID8381 and correct 51-byte jailed
    resolver retained. Runtime target passed. Planned reboot later reproduced the empty actual-daemon
    resolver. Evidence: private `network-reboot/20261010T124012Z`. One NTP-service
    restart restored runtime within one second of collector time. The persistent
    resolver-tracking correction then passed a second reboot. Evidence: private
    `network-time/20261010T125426Z/boot-acceptance.json`. Offset was about -0.149
    seconds. The actual UID 123 daemon had the correct resolver. No post-boot
    restart or manual clock change occurred. SSH and HTTP 200 passed.
    The guarded template, apply script, and rollback script are in
    `networking/changes/mt1300-ntp/`. Review this local patch after firmware upgrades.
  - Record the measured offset immediately and after at least 24 hours. Use a
    proposed acceptance target of no more than five seconds. Verify reboot recovery
    in a planned maintenance window before closing persistence checks.

Rollback: restore the original time-service settings if the correction disrupts
operation. Retain the known clock-error finding if rollback is required. Separate
irreversible log timestamp history from configuration rollback. A fleet-wide NTP
policy is a later decision; MikroTik already has cloud time configured.

#### Stage 3: harden management in separate changes

The user requires SSH and browser access only, locally and through Tailscale.
The unused-service proposal and exact native files are in
`networking/changes/management-hardening.md`. All native files passed parse;
read-only preflight passed. The first unused-service batch was applied after
explicit approval and verified in Safe Mode. Evidence: private
`network-management/20261009T101809Z`. Later batches below completed key-only
AP access, stronger MikroTik crypto, and SSH/HTTP source restrictions.
The held remote session was attributed to Apple TV; allowed-source local and
off-LAN checks passed. HTTPS remains deferred. Denied-source and IPv6
functional probes remain untested. Do not repeat the initial hardening batch.

- [x] Agree on a per-device service and source-access matrix.
  - Evidence: user requires SSH/browser locally and through Tailscale.
    `networking/changes/management-hardening.md` records all five devices.
    Held remote source `.181` is identified by DHCP/ARP as VincentsAppleTV.
    Fresh off-LAN SSH/browser/DNS function and post-filter SSH/browser passed.
    This does not inspect or change Apple TV or tailnet access rules.
  - Record which SSH, Winbox, HTTPS, API, reverse-proxy, and remote-management paths
    are required. Account for Tailscale's actual routed or translated source.
    Do not apply a narrow address list until the required sources are verified.
- [x] Disable approved unused MikroTik services in a bounded batch.
  - Evidence: `networking/changes/management-hardening.md` and private
    `network-management/20261009T101809Z`. Disabled FTP, Telnet, IP Winbox,
    API/API-SSL, reverse proxy, and bandwidth server. SSH and HTTP retained.
    Safe Mode entered and released. Second SSH, WebFig HTTP200, Internet
    HTTPS200, five DNS names, and postcommit service state passed.
    MAC Winbox, remote Tailscale, and denied-source checks remain outside this batch.
  - Candidates: Telnet, FTP, HTTP WebFig, unused API/API-SSL, bandwidth server,
    and reverse proxy. Retain each service with a confirmed dependency until its
    replacement works. Save enabled flags, ports, certificates, and source lists.
- [x] Restrict required MikroTik management sources and review stronger SSH settings.
  - Source observation: held remote Air session `.181`; DHCP/ARP identify
    VincentsAppleTV. Collector source is `.6`. Evidence:
    `network-management/20261009T111706Z` and `20261009T111925Z`.
    Applied `192.168.88.0/24,fe80::/10` to SSH/HTTP only in active Safe Mode.
    Local fresh SSH, HTTP200, and readback passed. User confirms fresh remote
    SSH and authenticated browser login passed. Safe Mode released successfully;
    postcommit SSH and both source lists verified. No firewall change.
    Denied-source and IPv6 functional probes were not run.
    Exact recovery: `networking/changes/management-sources.md`.

  - The SSH crypto portion is applied: `strong-crypto=yes`, fresh key-only SSH,
    existing trusted host key, HTTP200, Safe Mode release, and postcommit check
    passed. Evidence: `network-management/20261009T105452Z` and
    `networking/changes/mikrotik-ssh-crypto.md`. Password policy stays
    `yes-if-no-key`; the keyed admin account remains. Source restrictions were subsequently applied and verified as recorded above.

  - Keep the current session and test a second key session. Use RouterOS Safe Mode
    for supported configuration changes. Review its rollback behavior in the current
    release; it is not firmware rollback. Do not rotate host keys in the same batch.
- [x] Verify all OpenWrt administrative keys before disabling SSH password authentication.
  - Completed sequentially after user authorization to continue without further
    confirmation prompts. WAX202, MT6000, and MT1300 fresh key-only preflight
    and post-change sessions passed. Both password flags are off on all four APs.
    Each server offers only publickey. Web HTTP200 and original-config backups
    passed. Evidence: `network-management/20261009T105234Z` and
    `20261009T105332Z`; `networking/changes/openwrt-ssh-auth.md`.
    Reboot/vendor-UI persistence and remaining Air client checks are not implied.
  - User confirms browser login on all four OpenWrt devices. Air and workspace
    key-based SSH pass on all four. Fresh AXT1800 public-key-only login passed;
    evidence: private `network-management/20261009T104004Z`. The prepared
    `networking/changes/axt1800-key-only.sh --check` passed read-only on the AP.
    Applied only to AXT1800 after explicit approval. Evidence:
    `network-management/20261009T104446Z`; fresh key-only session passed, server
    offers only publickey, and web returned HTTP200. Immediate post-reload
    connection refusal was transient and preserved. Air post-change SSH/browser
    acceptance was initially pending; the later acceptance below passed. The
    remaining devices were subsequently hardened under continuing authorization.
  - Change one device at a time. Keep root key access if that is the supported
    administration model. Test a second authorized key session before closing the
    original session. Save authentication settings and a recovery procedure first.
- [ ] Establish and verify HTTPS management before removing or redirecting HTTP access.
  - Deferred by the user on 2026-10-09. Public domain `volo1st.com` uses
    Squarespace. Certificate automation and deployment effort are outside the
    current priority. Retain existing browser access. The user accepts continued
    HTTP management for now; HTTPS remains open, not complete. Do not migrate
    public DNS, create certificates, or disable HTTP under this deferral.
  - Check the actual nginx or uHTTPd front end and intended client certificate trust.
    Remove redundant listeners only after vendor dependencies are understood.
    HTTPS WebFig is an option if browser access is required; it is not mandatory
    when an approved SSH/Winbox-only workflow meets the user's needs.
- [x] Verify post-change Air SSH and authenticated browser access on WAX202, MT6000, and MT1300, and Air SSH compatibility with MikroTik strong crypto.
  - Evidence: user confirms Air SSH on all five devices. On the phone-hotspot/
    Tailscale test, user reports all five IP-based SSH tests, browser logins,
    local DNS lookup, and name-based SSH work. No untested collector browser
    login is claimed. Remote-path functional acceptance is complete.
  - AXT1800 Air SSH/browser passed. Workspace checks passed on all devices.
  - The first source capture, `network-management/20261009T111342Z`, found
    only the collector session from `.6`; the user's short sessions had closed.
    A later held Air session resolved attribution to Apple TV. See
    `network-management/20261009T111706Z` and `20261009T111925Z` above.
- [x] Review the existing MikroTik administrator and verify the retained path.
  - Retain the existing keyed `admin` account for this bounded audit. No account
    migration or rename is required for the implemented protection. Existing
    password policy refuses SSH passwords for keyed users; strong crypto and
    service source limits are enabled. Workspace/Air key sessions and browser
    login pass. This retains browser password recovery and avoids another
    credential migration. No host keys or account credentials were changed.
  - If replacement is chosen, create and test the new account and its key first.
    Disable the old account in a separate approved step. Do not combine account,
    password, source-filter, and host-key changes.

For each batch, verify required access and observed service state from an allowed
client. Test a denied source only with explicit probe approval. Confirm ordinary
Internet, DNS, and WDS access still work. Restore saved service, account, or filter
settings if a required path fails. Do not disable the last verified recovery path.
Guidance: [RouterOS services](https://help.mikrotik.com/docs/spaces/ROS/pages/103841820/Services)
and [Safe Mode](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration+Management#ConfigurationManagement-SafeMode).

#### Apple TV Wi-Fi reservation migration

- [x] Verify the Apple TV uses `.8` after its Wi-Fi reservation migration.
  - The owner confirmed that the same Apple TV moved from Ethernet to Wi-Fi.
    The owner was at home and authorized the migration on 2026-10-09.
  - Three ARP probes to `.8` received no response. The router had no ARP entry
    for `.8`. This supports availability but cannot exclude a powered-off device.
  - Updated static `.8` to Wi-Fi MAC `8C:26:AA:E7:DA:BB` and client ID
    `1:8c:26:aa:e7:da:bb`. The comment preserves the old Ethernet MAC.
  - RouterOS removed the matching dynamic `.181` lease during the update.
    The subsequent explicit remove reported `no such item`. Independent readback
    confirms the intended reservation and no `.181` lease. Preserve this result.
  - Evidence: private `network-management/20261009T113231Z`, including native
    parse, before/after state, and rollback. Rollback restores the original Ethernet
    identity and comment. Wi-Fi then uses dynamic allocation; `.181` is not guaranteed.
  - Initial lease was waiting. Fresh evidence in `network-radio/20261009T133446Z`
    now shows bound `.8`, active Wi-Fi MAC/client ID, and hostname VincentsAppleTV.
    Address migration is verified. Owner confirms off-LAN Tailscale works after renewal;
    acceptance recorded in private `network-stability/20261010T122714Z`.
  - Both addresses are inside the existing management allowlist. No allowlist changed.

#### Stage 4: correct radio country settings

- [x] Confirm the MT6000 vendor-supported country control and WAX202 effective domain.
  - Evidence: private `network-radio/20261009T114832Z` and `20261009T115404Z`;
    `networking/changes/radio-country.md`. Installed MT6000 handler accepts country.
    WAX202 reports world `00` and associated WDS channel 153/80MHz.
  - Do not edit generated MediaTek files as the primary configuration method.
    Save current settings, channels, bridge membership, and management paths.
- [x] Apply AU to MT6000 through its supported control and verify effective operation.
  - Applied AU to both UCI radio sections through the installed handler. Fresh SSH,
    HTTP200, both operating bands, and client association pass. UCI and iwinfo report AU,
    but mapped driver profile files retain US. Live driver channel maps now exactly match
    AU region1/region14 extracted from the installed driver. Evidence: private
    `network-radio/20261009T130059Z/country-map-proof.json`. No profile edits or
    network changes during proof. Driver country-string/beacon and RF power calibration
    were not checked. Keep client acceptance, reboot persistence, and 24-hour observation
    open at that initial checkpoint. Subsequent evidence
    `network-stability/20261010T122714Z` confirms exact AU
    driver channel lists after more than 24 hours and owner reports no issues.
    MT6000 runtime observation passed. Its authorized reboot also retained saved AU
    and exact live AU channel maps, both bands, fresh SSH, and HTTP200. Evidence:
    private `network-reboot/20261010T124012Z`. Country reboot persistence passes.
    The owner subsequently reported several days of productive kitchen Wi-Fi
    use and Internet tests on 2026-10-16, and accepted the layout on 2026-10-17.
    This supports ordinary client acceptance. A dedicated post-reboot Tailscale
    check was not repeated. See `radio-country.md` and `topology.md`.
  - Administer it from a path that survives its Wi-Fi restart. Verify both bands,
    client reconnection, and persistence. Retain supported driver evidence when
    standard `iw` is unavailable; do not infer driver state solely from UCI.
- [x] Apply and verify AU on WAX202 in a separate approved maintenance window.
  - Evidence: private `network-radio/20261009T133446Z`; `networking/changes/radio-country.md`.
    Owner confirmed direct wired recovery equipment. Both country values are saved as AU;
    runtime AU, original WDS peer/channel153/80MHz/four-address mode, SSH, HTTP200,
    and three fresh ARP replies in each direction pass. Network config hash is unchanged.
    Only two country fields changed. Radio0 stays disabled. At this initial
    checkpoint, client observation and reboot checks were pending. The later
    accepted observation window and reboot gate below supersede that status.
  - The container depends on WDS. Use the Air on the main LAN for observation,
    with a studio-side wired recovery path prepared before the station change.
    Save the previous settings and define a supported local rollback if WDS fails.
- [x] Verify WDS association, fresh ARP forwarding, client access, and accepted stability window.
  - Latest evidence: private `network-reboot/20261010T132445Z-wax202`.
    Owner accepted a shortened observation window of about 23h49m. Reboot
    persistence passes: changed boot ID, AU domain, original peer, 80 MHz,
    four-address mode, bridge membership, SSH, HTTP 200, unchanged config hashes.
    Owner confirms NAS-file and authenticated browser acceptance after reboot pass.
    The earlier 24-hour deadline below is superseded by this owner decision.
  - Immediate WDS association and endpoint ARP tests passed after WAX202 AU.
    Owner confirms Air-to-NAS file access and WAX202 browser access pass.
    Owner also reports no visible interruption to the Air NAS connection or Studio
    live stream during the reload. This is user-observed continuity, not a packet-loss
    measurement. The earlier 12:27 UTC snapshot had only about 22h51m of
    observation. Its pending deadline and reboot status were superseded by the
    accepted 23h49m window and reboot evidence above. Preserve the initial
    snapshot in private `network-stability/20261010T122714Z` as history.
  - Record effective domain, channel, width, and link state. Keep SSID, key, and
    channel tuning outside this change unless the correct domain requires a change.

Rollback: restore the prior saved configuration only if it is valid for the site.
Do not restore an incorrect country as a permanent fix. If correct settings cannot
operate, stop the affected radio and use the prepared wired recovery path. Record
an unresolved driver or hardware limitation rather than forcing a foreign domain.

#### Studio OX connectivity — owner request 2026-10-18

- [x] Provide usable studio 2.4 GHz Wi-Fi for the OX Amp Top Box.
  - Evidence: `networking/changes/wax202-ox-wifi.md`. WAX202's `Moo Moo Farm`
    AP is enabled. Native security, LAN bridging, and continuous WDS checks
    passed. OX connection and app control passed by owner report.
    The SSID uses the owner-supplied private password. No other AP changed.

#### Stage 5: define firmware maintenance

WAX202 upgrade preparation passed backup, published image checksums, transfer
hash, storage, and native `sysupgrade -T` checks. The owner then authorized
installation. OpenWrt 25.12.5, original WDS peer, four-address mode, AU, SSH,
HTTP 200, and unchanged configuration hashes pass. Diagnostic tools restored;
three gateway ARP probes received three replies. Owner confirms NAS-file,
browser login, and off-LAN Tailscale checks pass. Later stability observation
remains open.
Evidence: private `network-firmware/20261010T143127Z-wax202`.
Procedure: `networking/changes/wax202-firmware.md`.
MikroTik owner acceptance after RouterBOOT also passes. Later observation stays open.

The initial source review, `networking/firmware-review-2026-10-11.md`, records
the earlier MikroTik 7.23.2 and WAX202 25.12.2 builds. The applied records above
supersede that installed-version table: MikroTik is 7.23.8 and WAX202 is 25.12.5.
Do not repeat completed upgrades. The later 2026-10-17 source comparison
is appended to that review. It identified uHTTPd remediation and vendor
patch-coverage gaps. Source comparison is complete; Stage 5 is not complete.
The earlier documentation closeout did not perform this source review.

- [x] Select an approved stable or long-term RouterOS update policy and change the channel separately.
  - Evidence: private `network-firmware/20261010T134518Z`. Selected long-term,
    verified offered 7.23.8, then downloaded and installed in separate steps.
    HTTPS certificate validation remains enabled. Owner authorized proceeding.
    `networking/changes/mikrotik-firmware.md` records recovery and results.
  - The original 7.23.2 package was stable despite its development channel.
    Channel selection, RouterOS installation, and RouterBOOT installation were
    separate approved actions. The retained channel is long-term.
- [x] Review official support, advisories, and release notes for all five exact installed builds.
  - Evidence: `networking/firmware-review-2026-10-11.md`, current checkpoint
    2026-10-17. Reconciled saved runtime identities and later applied versions.
    Recorded per-device retain, remediate, or defer decisions and review triggers.
    Public release/API/feed evidence and four candidate packages are preserved
    in the investigation workspace at `logs/firmware-review/20261017/`.
    This source-review outcome does not close the remediation items below.
- [ ] Correct the later uHTTPd defects on AXT1800 and WAX202.
  - Use `networking/changes/openwrt-uhttpd-security.md`. WAX202 now has
    `2026.08.24~373145f7-r1` for both packages. The owner approved its update,
    web-service activation, and original-firmware recovery fallback. Native
    checks, fresh SSH, the new running executable, LuCI login challenge,
    configuration/world hashes, and WDS state passed on 2026-10-17.
    The owner confirmed fresh Air SSH, browser login, and off-LAN Tailscale.
    WAX202 observation passed after about 26 hours on 2026-10-19 Sydney.
    AXT1800 was approved, updated, and activated on 2026-10-19 Sydney.
    The same technical checks and the owner's three client checks pass.
    Both endpoints now have the corrected pair. Review AXT1800's 24-hour
    observation no earlier than 2026-10-20 01:27 Sydney. Keep this gate open
    until that acceptance passes. No exploit test is authorized.

- [x] Decide the required depth of GL.iNet patch-coverage review.
  - Evidence: on 2026-10-19 the owner chose a home-network maintenance
    baseline based on the latest supported production firmware. This
    explicitly supersedes the earlier exact-patch-mapping closure gate.
    Mapping remains unknown. No security fix is claimed from this decision.
    The source comparison stays in `networking/firmware-review-2026-10-11.md`.
- [x] Record the disposition of later vendor findings under the accepted maintenance policy.
  - Evidence: the same owner decision defers detailed vendor research and
    the unsent enquiry. Preserve the findings for brief release/advisory
    checks. No vendor response is required for baseline closure. This does
    not establish that the findings are fixed or authorize a device change.
- [ ] Verify that the GL.iNet devices meet the production-firmware policy.
  - The last catalogue review identifies MT6000 4.11.0 as the stable update
    candidate and MT1300 4.3.25 as current. Recheck before an approved update.
    Use the existing per-device preparation and acceptance gates below.
    Record any clear remaining advisory issue briefly. Exact backport proof
    is outside this gate. Preserve MT1300's local NTP correction.
- [ ] Prepare a separate approved procedure for each firmware upgrade that is justified.
  - Include verified image hashes, storage requirements, packages, configuration
    compatibility, physical recovery, downtime, and rollback image. Upgrade one
    device at a time. Never upgrade both WDS endpoints in one maintenance batch.
- [ ] Verify each applied upgrade against its original role and a 24-hour observation period.
  - Check boot, management, DHCP/DNS role, service restrictions, client access,
    and fresh WDS ARP where applicable. Restore the paired firmware and private
    configuration through the documented recovery path if acceptance fails.

An evidence-backed retain decision can close the review. Use the owner's
production-firmware policy to bound this home-network audit. Record a clear
remaining advisory issue and its disposition. Do not infer that a defect is
fixed from a firmware version alone. Detailed vendor patch research is deferred.

#### Stage 6: make configuration reproducible

- [ ] Confirm and record exact cable ports and mark bridged WAN ports as LAN where applicable.
- [ ] Derive reviewed native templates under `networking/devices/<device>/`.
  - Preserve intended vendor AP mode. Separate secret placeholders from recoverable
    private values. Record firmware hashes, packages, custom files, and dependencies.
- [ ] Review residual WAX202 WAN protocols and vendor AP-mode routing controls (N09).
  - Disable only settings with no required role after runtime verification.
    Verify bridge forwarding and management; restore saved sections on regression.
- [ ] Verify a representative restore with physical recovery available.
  - Start with an isolated or spare target when available. If the production device
    must be used, obtain a specific outage and recovery approval. Record scope:
    a representative restore does not prove every device is recoverable.
- [ ] Record untested recovery cases and verify updated approved recovery copies after changes.
  - The owner accepted NAS-local-only storage in Stage 0. An off-host copy is
    deferred under that explicit risk acceptance. Refresh the approved copy;
    do not treat a second NAS directory as off-host protection.

Pass gate: documented steps recover the tested role, secrets are available privately,
and management plus representative client behavior pass. Retain each untested
model or procedure as an explicit recovery gap or accepted risk.

#### Stage 7: decide optional architecture and measured improvements

Current disposition, 2026-10-17: retain the accepted topology. Defer new APs,
AP consolidation, radio tuning, queueing changes, Pi-hole deployment, domain
migration, and the Bilibili-specific investigation. Review these only when
the owner requests an improvement or normal use no longer meets requirements.
The open items below are conditional review gates, not instructions to change
the working network now. Keep unresolved security and recovery requirements
separate from these optional deferrals.

Retain current `.lan` names and working Tailscale access. GL.iNet cloud access
is not required. Tailnet enrollment/access rules and IPv6 behavior have not
received a complete policy audit. The single LAN remains the current design;
guest/IoT isolation has not been implemented or verified. No second studio
uplink is planned. Revisit isolation or loop prevention when a concrete
requirement or topology change warrants it.

- [ ] Decide guest/IoT isolation and management-network requirements (N11).
  - Default: retain the working single LAN pending an approved design. If isolation
    is required, map switches, VLAN support, routing, firewall rules, and Bonjour
    exceptions end to end. A disabled guest SSID is not a verified isolation design.
- [ ] Decide intended IPv6, vendor cloud, and Tailscale access behavior.
  - Review actual enrollment and access policy before changing remote access.
    Review router advertisements on all interfaces before enabling Internet IPv6.
    Confirm how remote management survives earlier source restrictions.
- [ ] Measure radio airtime and client performance before optional channel or width changes (N10).
  - Deferred after owner acceptance. If resumed, record comparable workloads,
    location, and actual post-swap radio state. Do not treat the old MT6000
    channel 8 observation as current or change the accepted WDS channel by default.
- [ ] Measure latency under load before deciding on queueing or shaping (N12).
  - Scope the active test first. If shaping is justified, account for FastTrack,
    gateway CPU capacity, latency, and throughput. Do not enable SQM on a bridged AP
    as a substitute for a reviewed gateway design.
- [ ] Record loop-prevention requirements before adding any second studio uplink (N12).
  - No parallel Ethernet/WDS path is currently planned. Enable or redesign STP only
    for a defined topology need, with a verified rollback and client recovery.

For each decision, record implement, retain, or defer with the reason and review
trigger. For implemented designs, define pass criteria and the original topology
rollback before approval. Optional tuning does not block closure when the user
accepts the existing behavior. Unresolved required isolation or security needs do.

#### Stage 8: harden tools and close verified work

- [ ] Harden capture cleanup in the investigation repo before shared-tool promotion.
  - Expose stop failures. Verify process identity and artifact ownership. Mock
    startup, PID-file, interruption, retrieval, and stop failures. Keep one copy.
- [ ] Record unsupported runtime commands and verify collector behavior across device builds.
  - Distinguish command results from SSH success. Keep partial evidence and explicit
    omissions. Do not install tools on a router solely to make a report look complete.
- [ ] Run the approved final regression checks from the Air and representative clients.
  - Check idle IP access, DNS, fresh ARP across WDS, file access, required discovery,
    Tailscale access, large transfer, and printer behavior. Record workaround state,
    exact duration, file size, units, link-counter deltas, and test source.
- [ ] Observe at least 24 hours after the last applied change and record the results.
  - Include memory/storage trend, WDS reassociations, time alignment, and client
    reports. Regressions return to the relevant stage. Keep the original WDS fix
    evidence separate from acceptance of later changes.
- [ ] Record a disposition for N01 through N13 and each remaining recovery gap.
  - Attach evidence for corrected findings. Record the user's explicit acceptance
    for retained risks. Keep unresolved required work open and name its next action.
- [ ] Update design and recovery documents, scan for secrets, and commit reviewed work.
  - Run proportional script checks and local-link checks. Commit verified batches
    with their evidence. Do not mark the whole package complete while a required
    restore, acceptance test, or approved corrective action remains open.
