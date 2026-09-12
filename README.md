# Homelab

Source of truth for recreating this homelab setup.

The repo favors executable configuration and scripts over long-form documentation. Docs are kept high-level or placed next to the config they explain.

## Layout

- `AGENTS.md` - Required instructions for agents that work in this repository.
- `host/` - Ubuntu host configuration that should run outside containers.
- `services/` - Docker Compose based services and their supporting config.
- `scripts/` - Bootstrap, validation, backup, restore, and operational helpers.
- `secrets/` - Secret handling conventions and templates. Real secrets must not be committed.
- `plan.md` - Standing assumptions and collaboration rules.
- `working-with-host.md` - Safe methodology for inspecting and changing the NAS host
  from the Docker development environment.
- `audit-results.md` - Point-in-time findings from the 2026-09-12 repository audit.
- `intial-plan-after-audit.md` - SSOT checklist for work arising from that audit.

## Priorities

Optimize decisions in this order:

1. Stability
2. Performance
3. Maintenance
