# MikroTik RB760iGS

Reviewed: 2026-10-20. Kitchen gateway: `192.168.88.1`.
RouterOS and RouterBOOT: 7.23.8, long-term channel.

`rebuild.rsc.example` is the reviewed native text export. RouterOS omits
unchanged defaults and sensitive fields. Do not import it over a live configuration.
The private encrypted binary backup is the same-device recovery source.
It includes state that the text export omits. Its random password is inside
the outer encrypted bundle. Keep the original Air private key separately.

Use the [prepared recovery procedure](../../configuration-backup.md#prepared-device-recovery).
Match model and version before loading a binary backup. A replacement router,
Netinstall, certificate/key restoration, and an actual binary-backup restore
remain untested. The collected certificate inventory has no objects.
