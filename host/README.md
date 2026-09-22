# NAS Host Build

## Scope

This procedure rebuilds the implemented host layer on Ubuntu 24.04 Long Term Support
(LTS). It covers packages, storage, Samba, Docker, the firewall, and validation. It
does not migrate the existing Compose files. Work package 9 owns that migration.

The tested host release is Ubuntu 24.04.5 LTS. [`packages.tsv`](packages.tsv) records
the tested package versions and purposes. Install supported updates during a rebuild.
Do not force an old version only to match the table.

## Network requirements

Use these network values:

- Hostname: `nas`.
- Primary interface: `enp5s0`.
- NAS address: `192.168.88.6/24`.
- Default gateway: `192.168.88.1`.
- Trusted home network: `192.168.88.0/24`.
- Samba discovery name: `nas.local` through multicast DNS (mDNS).

Keep `192.168.88.6` stable with a router reservation or a static address. Do not add
a router port forward to the NAS. Use the Apple TV Tailscale subnet router for remote
access. Its userspace router opens LAN connections from the Apple TV. Remote traffic
therefore appears from its trusted LAN address.

The current LAN services use TCP ports `22`, `139`, `445`, `3000`, `5201`, `8096`,
`9090`, `9100`, and `9115`. Avahi and Jellyfin also use User Datagram Protocol (UDP)
discovery. The firewall trusts the complete home network instead of maintaining a
port list.

## Accounts

Create the interactive administrator during Ubuntu installation:

- `vincent` has a home directory and Bash shell.
- `vincent` is a member of `sudo`.

Create the non-interactive media account before Samba access setup:

```bash
sudo adduser --system --no-create-home --home /nonexistent \
  --shell /usr/sbin/nologin nas
```

Do not add `nas` to `sudo` or `docker`. The access setup script creates and manages
the Samba role groups.

The current `vincent` account is a member of `docker` because it manages the
`dde-vincent` development container. Docker group membership is equivalent to host
administrator access. Do not add a low-privilege account to this group.

## Package installation

Install the Ubuntu packages:

```bash
sudo apt update
sudo apt install avahi-daemon ca-certificates curl git iptables mergerfs \
  openssh-server samba ufw
```

Install Docker Engine, Buildx, and Compose from Docker's official Ubuntu repository.
Do not use Docker's convenience script for this host. After the repository is
configured, install these packages:

```bash
sudo apt install containerd.io docker-buildx-plugin docker-ce docker-ce-cli \
  docker-compose-plugin
```

Add only the interactive administrator to the Docker group:

```bash
sudo usermod -aG docker vincent
```

Start a new login session before you use Docker without `sudo`.

## Configuration sequence

Clone this repository. Then run these steps from the repository root.

1. Check and install the storage configuration.

   ```bash
   ./host/storage/apply.sh --check
   sudo ./host/storage/apply.sh --install
   ```

2. Reboot and verify storage before you create share directories.

   ```bash
   ./host/storage/check.sh
   ./host/storage/check-generated.sh
   ```

3. Create the Samba role groups and directory metadata.

   ```bash
   ./host/samba/setup-access.sh --check
   ./host/samba/setup-access.sh
   ```

4. Create Samba credentials. Do not put these passwords in Git.

   ```bash
   sudo smbpasswd -a vincent
   sudo smbpasswd -a nas
   ```

5. Check and install the Samba configuration.

   ```bash
   ./host/samba/apply.sh --check
   sudo ./host/samba/apply.sh --install
   ```

6. Check and install the firewall during an approved maintenance period.

   ```bash
   sudo ./host/firewall/apply.sh --check
   sudo ./host/firewall/apply.sh --install
   ```

7. Run the complete read-only validation.

   ```bash
   sudo ./scripts/validate-host.sh
   ```

Each install step is idempotent. Review its preflight output before installation.
Keep the backup path that each script prints.

## Current Docker services

The host currently runs these containers:

- `dde-vincent`
- `jellyfin`
- `grafana`
- `prometheus`
- `node-exporter`
- `blackbox-exporter`

The `dde-vincent` container is the development environment. It uses host networking.
It sets `seccomp=unconfined` and `apparmor=unconfined`. It does not use Docker's full
privileged mode. These settings reduce container isolation and are an accepted risk
for the required development workload. The firewall permits established and
container-originated traffic, so it does not block outbound access.

The active Compose file is currently outside this repository at
`/home/vincent/homelab/docker/docker-compose.yml`. Work package 9 must move the
service definitions into this repository, pin images, and add service-specific
recovery instructions.
