# MT1300 time-service recovery proposal

Status: one approved restart restored runtime synchronization on 2026-10-09.
The 24-hour runtime check passed on 2026-10-10. The reboot check remains open.

## Observations

Collector UTC is authoritative. The MT1300 clock is incorrect.
Private evidence: `secrets/local/network-time/20261009T100429Z/`
and `20261009T100608Z/`.
The configured peers are the four OpenWrt NTP pool names.
The service is enabled and runs inside an isolated `ujail` environment.
It has `CAP_SYS_TIME` and `CAP_NET_BIND_SERVICE`.
Its `/etc/resolv.conf` is an empty regular file of zero bytes.
The host resolver contains `nameserver 192.168.88.1` and resolves the pool name.
A 15-second `ntpd -w` probe outside the jail received four NTP replies.
Measured offset was about +1711687.74 seconds, or 19.81 days.
The `-w` option prohibits clock setting. Timeout exit 143 is expected.
These diagnostic probes did not change the clock, restart a service, or edit configuration.

## Conclusion and limits

The host DNS and NTP path work. A general upstream NTP block is not supported.
The daemon's empty resolver is a concrete fault in its runtime environment.
It is the leading explanation for failure with hostname-based peers.
The evidence does not yet prove why the jail received an empty file, whether a
restart will rebuild it correctly, or whether the fault recurs at boot.
Do not declare the root cause or persistent fix confirmed yet.

## Proposed bounded correction

Keep the current peers and service configuration. Restart only `sysntpd`:

```sh
/etc/init.d/sysntpd restart
```

This rebuilds the daemon environment and may let NTP correct the clock.
The clock may jump forward by about 20 days. Logs can have a discontinuity.
No radio, network, DHCP, or management-service restart is included.
Do not set the clock manually. Do not weaken the jail or replace pool names
with a fixed public address as a first step.

Before application, save `/etc/config/system`, the init script, resolver state,
process state, and current clock in private evidence. Record collector UTC.
After application, verify the new process, jail resolver content, NTP replies or
sync event, and offset against an independent clock. Target offset is <=5 seconds.
Check AP SSH and web access. Stop if the resolver remains empty or sync fails.
Do not repeat restarts without new evidence.

Rollback: no persistent configuration is changed by the proposed restart.
If the new instance fails, preserve its logs and use the unchanged service
configuration to restore service operation. A corrected clock is not rolled back.
Do not manually restore the known incorrect date.

Keep N13 open until a subsequent check after at least 24 hours passes.
Verify boot recovery in a planned maintenance window before closing persistence.
If this is a startup-order fault, prepare a persistent correction from fresh
evidence. A one-time successful restart is not a boot fix.

## Approved application and result

Private evidence: `secrets/local/network-time/20261009T100818Z/`.
Saved the original configuration, init script, resolver, process state, and clock.
Ran one approved `/etc/init.d/sysntpd restart`. No configuration was edited.
The new jailed daemon PID was 8381. Its resolver is a 51-byte file with
`nameserver 192.168.88.1` and `search lan`, instead of the prior zero-byte file.
The first post-restart clock check was still incorrect. About ten seconds later,
at collector UTC 2026-10-09 10:08:30, remote-minus-collector offset was -0.194 s.
The estimate uses the SSH request midpoint and whole-second remote time.
This is not a subsecond precision measurement, but it passes the five-second gate.
The same daemon remained running. SSH passed and web returned HTTP 200.
No manual clock set, network restart, or radio restart was performed.

The runtime fault and recovery are supported: an empty jailed resolver prevented
normal peer-name resolution; rebuilding it restored synchronization. The origin
of the empty file and recurrence at boot remain unconfirmed. Do not add a timer
that repeatedly restarts the service as a substitute for diagnosing persistence.

Next check: at or after 2026-10-10 10:08:30 UTC, inspect the same process, resolver,
and clock offset. A separate planned reboot test must verify startup recovery.
Keep N13 open until these checks pass or a persistent correction is validated.

## Subsequent runtime check: 2026-10-10

At 12:27 UTC, more than 26 hours after recovery, the clock offset was about
-0.637 seconds against the collector SSH midpoint. Whole-second remote time
limits precision. The result passes the five-second target. The same daemon PID8381
is running. Its jailed resolver remains51bytes and contains the gateway nameserver
and LAN search domain. No service restart or configuration edit occurred.
Evidence: private `network-stability/20261010T122714Z`.
The 24-hour runtime gate passes. Boot recovery and the origin of the stale resolver
remain unverified. Keep N13 persistence open until the planned reboot test.

## Planned reboot test: 2026-10-10

The owner explicitly authorized MT1300 and MT6000 reboots. Changed boot IDs
prove both restarted. MT1300 key-only SSH, Wi-Fi, and HTTP200 recovered.
Automatic time recovery failed. The actual NTP daemon UID 123/PID 4137 received
a zero-byte `/etc/resolv.conf`. The host resolver was 51 bytes with the gateway
nameserver. Inodes differed. This reproduces the earlier stale-resolver fault
after boot. Host DNS queries work. The clock remained about 92832 seconds behind.

The initial polling check incorrectly accepted the root ujail supervisor's resolver
as evidence for the jailed daemon. Failed-state inspection separated the processes
by UID. Preserve the polling output, but do not use its resolver boolean as proof.

After preserving failed state, ran one `/etc/init.d/sysntpd restart` under the
standing audit authorization. The actual UID 123 daemon then had the correct resolver.
Within the first five-second check, clock offset was about -0.593 seconds.
Runtime recovered. No persistent config edit or manual clock set occurred.
Wireless, network, and Dropbear file hashes match the pre-reboot state.
Evidence: private `network-reboot/20261010T124012Z`, including boot IDs, failed-state
capture, recovery result, and `acceptance.json`.

The reboot persistence gate fails and remains open. Prepare a boot-safe resolver
correction from this evidence. Do not add repeated timer restarts. The exact
startup event that replaces the resolver remains to be traced. A second reboot
test belongs after a reviewed persistent correction. Owner client acceptance
after these reboots remains pending.


## Persistent correction and reboot acceptance: 2026-10-10

Current result: automatic boot recovery passes. This result supersedes the failed
persistence gate above. Private evidence: `secrets/local/network-time/20261010T125426Z/`.

The old jail retained an empty resolver while the host resolver had been replaced.
The existing network-event trigger reloads sysntpd. Its service definition did not
track resolver content. Added `procd_set_param file /etc/resolv.conf` after the
respawn setting. A reload can now detect changed resolver content and recreate
the jail. An unchanged reload kept the same daemon and supervisor PIDs.
The NTP peers, restricted user, jail, and privilege controls remain in place.
No timer or repeated restart job was added.

The guarded scripts and native init template are in [mt1300-ntp](mt1300-ntp/).
Run `sh apply.sh` in that directory on MT1300 for a read-only preflight.
Use `sh apply.sh --apply` only for the reviewed original build.
The script saves `/root/sysntpd-before-resolver-tracking` before installation.
Run `sh rollback.sh` for a read-only rollback preflight.
Use `sh rollback.sh --apply` to restore the saved original and reload the service.
Rollback also restores the known boot-time fault.

The controlled reboot changed the boot ID from
`52c9d61b-d738-485f-8cf0-34a86778a5c0` to
`e1501d5e-38a5-411c-8ce3-f681bc7f3929`.
The actual UID 123 NTP daemon had the correct gateway resolver after boot.
The clock then synchronized automatically. The measured remote-minus-collector
offset was about -0.149 seconds. Whole-second remote time limits precision.
No post-boot service restart or manual clock change occurred.
SSH passed. The web interface returned HTTP 200. Wi-Fi returned to the bridge.
System, wireless, network, and Dropbear file hashes matched the pre-reboot state.
SSH password login remains disabled. The patched init script survived reboot.
Native shell syntax, guarded apply and rollback preflights, and local ShellCheck
for both helper scripts passed. Owner client acceptance after the AP reboots
remains open.

The failed-before and passed-after reboot results support this correction.
The exact boot event that replaces the resolver was not directly traced.
A firmware upgrade can replace this init script. Review the new native service
before an upgrade. Do not preserve or reinstall this old template blindly.
The scripts reject an unexpected original hash. Repeat the reboot test after
any upgrade that changes the time service.
