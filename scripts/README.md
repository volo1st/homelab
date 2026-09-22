# Scripts

Operational scripts belong here.

Expected script categories:

- Bootstrap
- Validation
- Backup
- Restore
- Health checks

Prefer idempotent scripts where practical.

Run the local secret scan before a commit:

```bash
./scripts/check-secrets.sh
```

Run the secret-control tests after a change to the scanner or `.gitignore`:

```bash
./scripts/test-secret-controls.sh
```

Run the complete read-only NAS host validation from a real host shell:

```bash
sudo ./scripts/validate-host.sh
sudo ./scripts/validate-host.sh --verbose
```

Check whether the committed configuration has an off-host Git copy:

```bash
./scripts/check-recovery-readiness.sh
```

Test a non-production restoration from the Git index:

```bash
./scripts/test-recovery.sh
```
