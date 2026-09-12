# Agent Instructions

## Scope

These instructions apply to the complete repository.

## Sources of truth

- Use `plan.md` for standing architecture and collaboration rules.
- Use `intial-plan-after-audit.md` as the single source of truth for audit work.
- Use `audit-results.md` as a fixed record of the 2026-09-12 audit.
- Use `working-with-host.md` for all work that reads or changes NAS host state.
- Keep detailed service decisions in the applicable service directory.
- Do not create a second audit task list.

## Writing standard

Use ASD-STE100 style for repository documentation and operational instructions.

- Use short, direct sentences.
- Use active voice.
- Use one instruction in each sentence.
- Use one term for one object or action.
- Use simple and approved common words when possible.
- Define an abbreviation at its first use.
- Put conditions before actions when this improves safety.
- Use numbered steps for ordered work.
- Use bullets for unordered facts.
- Do not change commands, paths, configuration keys, identifiers, or quoted output to
  satisfy the writing style.
- Do not remove necessary technical detail to make text shorter.

## Work environment

Development runs in a Docker container on the Ubuntu NAS host. The host root is
available at `/host` as a read-only mount.

- Use the container to edit files and run repository tests.
- Use `/host` only for read-only host inspection.
- Do not assume that container `/etc`, `/proc`, `/run`, `/sys`, `systemctl`, or
  `/ocean` represents the host.
- Use a direct host shell or an approved Secure Shell (SSH) session for host changes.
- Get explicit approval before a host change, package installation, service restart,
  mount change, user or group change, firewall change, or destructive test.
- Keep `/host` read-only.
- Do not use `chroot`, `nsenter`, or the Docker socket as the normal host-control
  method.

## Change procedure

1. Read the applicable documents and current configuration.
2. Confirm the execution environment.
3. Make the change in the repository.
4. Review the diff.
5. Run applicable static checks and tests.
6. Run a preflight check or dry run when available.
7. Identify the rollback procedure before a host change.
8. Apply an approved host change from a real host context.
9. Verify the result on the host.
10. Verify the result on a representative client when necessary.
11. Update the audit plan with completion evidence.

## Repository rules

- Prefer executable configuration and scripts to long instructions.
- Keep host configuration below `host/`.
- Keep service configuration below `services/`.
- Keep shared operational tools below `scripts/`.
- Do not commit a plaintext secret.
- Preserve user changes that are outside the current task.
- Do not make a major architecture, storage, backup, secret, service-layout, or tooling
  decision without user approval.
- Make scripts idempotent when practical.
- Separate read-only checks from changes.
- Make a host script stop in an incorrect environment.
- Verify a required mount before a write below its mount point.
- Validate configuration before installation.
- Define backup and rollback behavior for an applied configuration.

## Validation

Run checks that are proportional to the change.

- Run `git diff --check` for repository changes.
- Run `bash -n` for each changed shell script.
- Run ShellCheck for each changed shell script when ShellCheck is available.
- Run service-specific tests for changed executable code.
- Validate a host configuration with the host tool before application.
- Keep validation read-only unless the user approves a change.
- Report each check that was not available or not run.

## Plan maintenance

- Add a new checkbox when the audit reveals new work.
- Do not silently increase the scope of an existing checkbox.
- Mark a checkbox complete only after implementation and validation.
- Add an `Evidence:` note to each important completed checkbox.
- Record an accepted risk when the user decides not to correct a finding.
