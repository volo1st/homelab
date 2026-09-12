# Work With the NAS Host

## Purpose

The development environment is a Docker container on the NAS host. The host uses
Ubuntu 24.04. It runs systemd, Samba, data-disk mounts, and mergerfs.

The container mounts the host root at `/host`. This mount is read-only. It permits
inspection. It does not make the container a host execution environment.

## Primary rule

Use `/host` for read-only inspection. Make configuration changes in Git. Apply each
change from a host shell or an SSH session. Get approval before a system change.
Verify the result on the host and on applicable clients.

## Execution environments

### Development container

Use the container to edit files, run static checks, run tests, read `/host`, and
prepare apply and rollback scripts.

Process 1 in the container is not host systemd. `systemctl` can show container state.
`/etc` refers to the container. Always identify the target environment.

### NAS host

Use a host shell for these tasks:

- Install or remove a package.
- Change a host configuration file.
- Change a user or group.
- Mount or unmount a filesystem.
- Reload systemd.
- Restart a host service.
- Change firewall rules.
- Run a namespace-dependent check.

Use repository scripts when available. Use a dedicated administration account when
practical. Give the account only the necessary `sudo` permissions.

### External client

Use the applicable client to test macOS Samba behavior, application locking, iPhone
AFC operation, Apple TV access, and network performance. Record important results.

## Path meanings

| Resource | Container path | Host path |
| --- | --- | --- |
| Host root | `/host` | `/` |
| Host configuration | `/host/etc` | `/etc` |
| Host process data | `/host/proc` | `/proc` |
| Host system data | `/host/sys` | `/sys` |
| Host runtime data | `/host/run` | `/run` |
| NAS pool | Do not assume container `/ocean` is the host pool | `/ocean` |

Where practical, configure a host inspection tool with an explicit root option. Keep
alternate-root operation read-only by default. Do not add `/host` without an explicit
option.

## Work procedure

### Inspect

Collect read-only data from `/host`. Identify the data as host-mount data.

```bash
sed -n '1,200p' /host/etc/fstab
findmnt --tab-file /host/etc/fstab --verify
```

Namespace-sensitive runtime data can be inaccurate. Confirm important data from a
host shell.

### Prepare

1. Make the change in Git.
2. Review the diff.
3. Run static checks and tests.
4. Run a preflight check or dry run.
5. Identify the rollback procedure.
6. State the expected service interruption.

### Apply

Run the reviewed command in a host shell or an approved SSH session.

```bash
cd /path/to/homelab
./host/samba/check.sh
sudo ./host/samba/apply.sh
```

Keep each command visible. Do not enter host namespaces automatically.

### Verify

1. Parse the installed configuration.
2. Check host mounts, users, permissions, and services.
3. Compare the result with the read-only container view.
4. Test from a representative client.
5. Test rollback when the risk requires it.

Add evidence to the applicable item in
[`intial-plan-after-audit.md`](intial-plan-after-audit.md).

## Script requirements

A host management script must:

- Stop with a clear message in an incorrect environment.
- Keep checks separate from changes.
- Provide a preflight or dry-run mode when practical.
- Verify required mounts before a write.
- Validate configuration before installation.
- Back up replaced data.
- Define a rollback procedure.
- Return a nonzero status after failure.
- Avoid privilege prompts in unattended checks.
- Show target paths and services before a change.

## Safety limits

- Keep `/host` read-only.
- Do not mount the complete host root as read-write.
- Do not use `chroot /host` as a host shell.
- Do not use `nsenter` as the normal application method.
- Do not use the Docker socket as a host control interface.
- Do not run destructive tests with production data.

A chroot does not provide the host namespaces. `nsenter` removes isolation. Docker
socket access is equivalent to host root access.

## Environment check

```bash
findmnt -T /host -o TARGET,SOURCE,FSTYPE,OPTIONS
sed -n '1,12p' /host/etc/os-release
ps -p 1 -o pid,comm,args
```

Stop work if `/host` is absent, writable, or connected to an unexpected host. Stop
work if the execution environment is not clear. Correct the environment first.
