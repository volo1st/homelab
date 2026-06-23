# Homelab

Source of truth for recreating this homelab setup.

The repo favors executable configuration and scripts over long-form documentation. Docs are kept high-level or placed next to the config they explain.

## Layout

- `host/` - Ubuntu host configuration that should run outside containers.
- `services/` - Docker Compose based services and their supporting config.
- `scripts/` - Bootstrap, validation, backup, restore, and operational helpers.
- `secrets/` - Secret handling conventions and templates. Real secrets must not be committed.
- `plan.md` - Current working assumptions and collaboration rules.

## Priorities

Optimize decisions in this order:

1. Stability
2. Performance
3. Maintenance
