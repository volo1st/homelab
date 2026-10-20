# Bind mounts and workspace sharing

Status: reference only. No workspace mount is installed or verified by this note.
Preserved on 2026-10-21 from `TODO/symlink-bind-mount.md` in the retired-workspace
closeout. The original note did not contain a host test result.

A bind mount makes an existing directory accessible at a second path. Both paths
refer to the same data. It does not copy files or provide a backup. A symlink stores
a target pathname; application policy can restrict following that link.

A mount hides existing contents at its target until unmounted. File permissions
still apply. Plain `--bind` does not include nested mounts; `--rbind` does.
See the [util-linux mount manual](https://man7.org/linux/man-pages/man8/mount.8.html).

## Original example — not an installed configuration

The source proposed making a workspace visible below an existing Samba share.
These are historical example paths. They are not verified host paths or approval
to expose every repository, private file or credential in the workspace.

```bash
sudo mkdir -p /ocean/workspace
sudo mount --bind /sandbox/vincent/workspace /ocean/workspace
findmnt /ocean/workspace
sudo umount /ocean/workspace
```

The source proposed this persistent entry:

```fstab
/sandbox/vincent/workspace /ocean/workspace none bind 0 0
```

The example does not define mount ordering or failure handling for the `/ocean`
pool. Do not add it to the host configuration without a separate scoped change.
That change must check the real host source path, pool dependency, intended share
access and permissions. It must also define rollback and client verification.
Follow [host-work rules](../../working-with-host.md).

The source mentioned `sudo mount -a`. This acts on eligible entries across fstab;
it is not a validation command limited to this example. No mount command was run
for this documentation change.

## Container connection

The source also used `docker run -v /host/path:/container/path ubuntu` to illustrate
host-directory sharing with a container. That is a separate example, not this
host's deployment. Mount namespaces control the container's view; a container
path is not evidence that the same path exists on the NAS host. The source's
OverlayFS aside was background about layered filesystems, not a required part of
the proposed Samba bind mount.

## Reassessment

Revisit this idea only when there is a current sharing requirement. The original
note is preserved as reference material. No host change or new work package is
started. Use [Samba operations](README.md) for the deployed share configuration.
