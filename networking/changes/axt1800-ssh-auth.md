# AXT1800 SSH password-authentication proposal

Status: applied to AXT1800 after explicit approval on 2026-10-09.
Workspace verification passed. The user subsequently confirmed Air SSH and
authenticated browser verification passed.
Apply to AXT1800 only. Do not reuse this device-specific script on another AP.

The user confirms successful browser login on all four OpenWrt devices.
Workspace and Air key-based SSH already passed. A fresh public-key-only workspace
session passed with password and keyboard-interactive authentication disabled.
Evidence: private `secrets/local/network-management/20261009T104004Z/`.
The native script's read-only `--check` mode also passed.

## Exact change

Set `dropbear.main.PasswordAuth=off` and `dropbear.main.RootPasswordAuth=off`.
Keep root public-key login, port 22, authorized keys, host keys, and source settings.
Keep the root password and browser authentication unchanged.
Reload only Dropbear after committing these two values. No network or radio reload.
Current values are both `on`. The script stops if identity or expected state differs,
if multiple Dropbear sections exist, or if uncommitted Dropbear edits exist.

`axt1800-key-only.sh` defaults to read-only `--check`.
After explicit approval, send it through the existing key-authenticated session:

```sh
ssh -o BatchMode=yes -o StrictHostKeyChecking=yes axt1800 'sh -s -- --apply' < networking/changes/axt1800-key-only.sh
```

Before application, save `/etc/config/dropbear` in private collector evidence.
The apply mode also preserves the original file at
`/root/dropbear-before-key-only.conf` on the AP. It refuses to overwrite it.
Keep a separate existing SSH session available. Do not assume a reload preserves it.

After application, open a fresh public-key-only SSH connection. Verify the saved
flags and live Dropbear password-disabling options. Check the server's offered
authentication methods without sending a password. Confirm password authentication
is not offered. Verify the browser interface still responds and have the user
confirm browser login if needed. Preserve required access through Tailscale;
no source restriction is part of this batch. Remote-path verification stays open.

## Recovery

Browser authentication uses the existing root password. SSH password settings do
not remove that password or disable LuCI login. If a private key is lost, log into
LuCI and add a replacement public key or re-enable SSH password authentication
under System > Administration. Do not put a private key on the router.

From a working key session, restore the original configuration:

```sh
cp /root/dropbear-before-key-only.conf /etc/config/dropbear
/etc/init.d/dropbear reload
```

If both network management paths fail, physical OpenWrt failsafe is the last
recovery option. Its procedure has not been tested in this session.
Do not change the remaining APs until fresh AXT1800 access is verified.

Reference: [OpenWrt Dropbear settings](https://openwrt.org/docs/guide-user/base-system/dropbear).

## Application evidence

Private evidence: `secrets/local/network-management/20261009T104446Z/`.
Preserved a separate key-authenticated SSH session before application.
Saved the original config in collector evidence and
`/root/dropbear-before-key-only.conf` on the AP.
Changed only `PasswordAuth` and `RootPasswordAuth` to `off`, then reloaded Dropbear.
The first immediate new connection was refused during the reload. Its failed
output remains in evidence. The preserved session still worked and showed a new
listener with `-s -g`. A later fresh public-key-only session passed.
The server offered only `publickey` when the client disabled all authentication
methods. That probe sent no password and exited 255 as expected.
The AP web page returned HTTP 200. The browser password was not changed.
The collector did not perform an authenticated browser login after the change.
The preserved old session was closed only after the new-session checks passed.
No network, radio, host-key, authorized-key, or other-device change occurred.

Next have the user verify `ssh axt1800 'echo SSH_OK'` and browser login from
the Air. Prepare WAX202 separately only after AXT1800 client acceptance.
