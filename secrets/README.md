# Secrets

Do not commit a plaintext secret. A private repository is not secret storage.

## File names

Use these names for local secret-bearing files:

- `.env` or `.env.<name>` for environment variables.
- `*.secret` for service secret files.
- `*.token` for access tokens.
- `*.key`, `*.pem`, or `*.p12` for private key material.
- `credentials.json`, `credentials.yaml`, or `credentials.yml` for credential sets.
- `secrets/local/` for local files that do not belong beside a service.

Append `.example` to a template name. Examples include `.env.example`,
`database.secret.example`, and `credentials.json.example`. Keep template values
empty. Add a comment that explains how to create each value.

Public keys, public certificates, hostnames, internal Internet Protocol (IP)
addresses, domains, service names, paths, and topology details are safe to commit.
Use `.pub` for a public key and `.crt` for a public certificate.

## Create a local secret

1. Copy the applicable template.
2. Set mode `0600` before you add a value.
3. Add the value from a trusted source.
4. Run the local secret scan before each commit.

```bash
install -m 0600 services/example/.env.example services/example/.env
./scripts/check-secrets.sh
```

Do not use a command-line argument for a secret. Command-line arguments can appear
in process lists and shell history.

## Store and back up secrets

Keep the working copy outside Git. Limit it to the account or service that needs it.
Do not copy a secret into an issue, log, diagnostic report, or example file.

Keep a recovery copy in an approved password manager or encrypted backup. The future
backup work package must include these recovery copies. It must not put plaintext
secrets in this repository.

## Rotate a secret

1. Create the replacement secret.
2. Install it with the required owner and mode.
3. Restart or reload the applicable service.
4. Verify the service from a representative client.
5. Revoke the old secret.
6. Update the recovery copy.

If a secret enters Git, revoke or rotate it first. Remove it from the current tree.
If it was pushed, treat the complete pushed history as exposed.

## Restore a secret

1. Restore the value from the approved recovery copy.
2. Set the documented owner and mode.
3. Restart or reload the applicable service.
4. Verify authentication and normal operation.

Test restoration with a non-production value when a service first adopts a secret.

## Current decisions

This personal repository uses ignored local files and committed example files. It
does not use repository encryption. The current services do not need a secret
template. Add a template with the service that first needs it.

The repository does not have continuous integration (CI). Do not add a CI secret
scan until the repository adopts CI. Reassess encrypted secrets if distribution or
one-command rebuild requirements make ignored local files insufficient.

The local scanner checks tracked filenames and common high-confidence content
patterns. It does not prove that a repository contains no secret. Review changes
before each commit.
