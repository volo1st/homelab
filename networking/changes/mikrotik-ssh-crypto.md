# MikroTik stronger SSH crypto

Applied on 2026-10-09 under the user's authorization to continue SSH hardening.
Exact native apply and rollback files are in `mikrotik-management/`:
`ssh-strong-crypto.rsc` and `ssh-restore-crypto.rsc`.

Changed only `/ip ssh strong-crypto` from `no` to `yes`.
Preserved the keyed `admin` account, `password-authentication=yes-if-no-key`,
host-key type and size, host keys, forwarding policy, and management sources.
The existing password policy rejects password login for users with assigned SSH
keys. Do not describe this as globally disabling SSH passwords for all users.
Replacing the administrator remains a separate undecided policy item.

Private evidence: `secrets/local/network-management/20261009T105452Z/`.
An interactive key-only session with login suffix `admin+ct80w` entered Safe Mode.
Saved fresh SSH settings and key inventory. The single-line native apply parsed
successfully before execution through a second SSH session.
A fresh public-key-only session passed. Negotiated algorithms were
`curve25519-sha256`, `rsa-sha2-256`, `aes192-ctr`, and `hmac-sha2-256`.
Existing host-key verification passed. WebFig returned HTTP 200.
The owner released Safe Mode successfully and closed. A later key-only session
reported `strong-crypto=yes` and the unchanged password policy.

Rollback: set `/ip ssh strong-crypto=no` from a verified management session.
The rollback file is prepared but was not needed or deliberately tested.
Do not rotate host keys to recover a client compatibility failure.
Remote Tailscale and post-change Air compatibility remain client checks.

Reference: [RouterOS SSH](https://help.mikrotik.com/docs/spaces/ROS/pages/132350014/SSH).
