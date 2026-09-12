# Homelab Repo Plan

## Current work

Open [`intial-plan-after-audit.md`](intial-plan-after-audit.md#current-status). Its
Current status section identifies the active package, blocker, resume steps, and next
available focus.

This document records standing principles and collaboration rules. Actionable work
arising from the 2026-09-12 repository audit is tracked only in
[`intial-plan-after-audit.md`](intial-plan-after-audit.md).

Development runs in a Docker container on the NAS. Follow
[`working-with-host.md`](working-with-host.md) whenever work inspects or changes host
state.

## Purpose

This repository is the source of truth for recreating the homelab setup.
It should track configuration files, scripts, and service definitions needed to rebuild the environment as closely as practical.

Documentation should stay lightweight. Prefer self-documenting code, clear file names, and explicit configuration. Use prose documentation only for high-level overview, bootstrap/recovery flow, and places where context is necessary.

## Current Setup

- One core machine running Ubuntu.
- Services should generally run with Docker Compose.
- The machine has four M.2 SSD slots and acts as the main homelab host.
- Network setup is intentionally not a major design input for now, because it is situation-dependent and likely to change.

## Stack Preferences

- Prefer Docker Compose for services.
- Use host-native configuration when it is clearly a better fit, such as:
  - Samba shares
  - Storage setup
  - Firewall or kernel-level configuration
  - Hardware-specific tooling
  - System services that should not be containerized

## Commit Boundary

Everything except secrets may be committed, including real hostnames, internal IPs, domains, service names, storage paths, and topology details.

Do not commit plaintext secrets, including:

- Passwords
- API tokens
- Private keys
- OAuth or client secrets
- Database credentials
- VPN private keys
- Recovery keys

Default approach for now: commit examples or templates for secret-bearing files, and keep real secret files ignored. Consider encrypted secrets later if one-command rebuilds become a priority.

## Optimization Priorities

Optimize decisions in this order:

1. Stability
2. Performance
3. Maintenance

Practical implications:

- Compare each design with current engineering best practice for its purpose.
- Use authoritative sources when they are available.
- Evaluate the actual workload and failure model before implementation.
- Record important tradeoffs and accepted risks.
- Prefer boring, proven components.
- Avoid unnecessary orchestration layers.
- Keep service boundaries explicit.
- Make storage, backup, and recovery choices conservative.
- Tune performance where useful, but not at the expense of reliability.
- Keep maintenance simple through predictable layout and clear scripts.

## Collaboration Style

Small implementation details can be handled directly.

Ask before major structural choices, including:

- Top-level repository layout
- Secrets strategy
- Storage and filesystem layout
- Backup architecture
- Reverse proxy choice
- Service organization conventions
- CI, linting, or tooling choices
- Changes that would be painful to unwind later

## Validation

Docker and Docker Compose commands may be used for validation.

Ask before installing dependencies, making system-level changes, or applying changes outside the repository.
