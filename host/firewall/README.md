# Host Firewall

## Policy

Trust traffic from `192.168.88.0/24` and IPv6 link-local clients on `enp5s0`. Deny
other unsolicited inbound host traffic. Trust a direct `tailscale0` interface if the
NAS later runs Tailscale itself.

UFW controls host input. Docker-published ports bypass normal UFW input processing.
The `homelab-docker-firewall` service therefore installs equivalent rules in the
Docker `DOCKER-USER` chains for IPv4 and IPv6.

The Docker rules permit:

- Established and related traffic.
- New traffic from the trusted home network.
- Traffic from a direct `tailscale0` interface.
- Loopback traffic.
- Docker bridge-originated traffic.

The final rule drops other new Docker ingress. It does not remove Docker's own
network rules.

The Apple TV is the current Tailscale subnet router. Its userspace router opens LAN
connections from the Apple TV address. Thus, the trusted LAN rule also permits daily
remote access.

## Operations

Run the root-only preflight from a real host shell:

```bash
sudo ./host/firewall/apply.sh --check
```

Install the policy only during an approved maintenance period. Keep an existing SSH
session open while you test a second connection.

```bash
sudo ./host/firewall/apply.sh --install
```

The install operation backs up the UFW and systemd files. It then replaces the UFW
user rules with this repository policy. It keeps the ten newest firewall backups.
It installs the Docker filter and enables UFW. It restores the prior files and active
state if validation fails.

Run the read-only check separately with:

```bash
sudo ./host/firewall/check.sh
```

## Client validation

After installation, test all of these paths:

1. Keep the original SSH session open.
2. Open a second SSH session from the home LAN.
3. Open Samba and one web service from the home LAN.
4. Disable local Wi-Fi on a Tailscale client.
5. Open Samba and one web service through the Apple TV subnet route.
6. Confirm outbound network access from `dde-vincent`.

The wireless distribution system (WDS) bridge has a separate known Address Resolution
Protocol (ARP) discovery problem after the Apple TV address changes. If a remote test
produces no packet on `enp5s0`, ping the current Apple TV LAN address from the NAS to
refresh the path. The separate WDS project owns the permanent correction.

## Emergency rollback

If LAN or Tailscale access fails, use the original SSH or local console session:

```bash
sudo systemctl disable --now homelab-docker-firewall.service
sudo /usr/local/sbin/homelab-docker-firewall --remove
sudo ufw --force disable
```

This restores the effective pre-package firewall state. If automatic rollback
reported an error, restore the exact files from the backup directory that
`apply.sh` printed. Then run:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```
