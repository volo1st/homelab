# GL.iNet MT1300

Reviewed: 2026-10-20. Role: Study wired AP. Management: `192.168.88.3`.
Firmware: GL.iNet 4.3.25. Keep this firmware family.

These files preserve the essential native settings from
`secrets/local/network/20261020T031655Z/mt1300/config.tar.gz`.
Wireless secrets use placeholders. Restore each original private value from
that archive. Root authentication, SSH host keys, authorized keys, certificates,
and vendor state remain in the private archive. They are not recreated here.
`packages.txt` records the installed package set. It is not a blanket install command.
Firmware image hashes and private storage are in the [device index](../README.md).

Restore the reviewed sysntpd resolver fix using [the procedure](../../changes/mt1300-time.md). Keep the resolver jail enabled.

1. Use the paired image and full native private archive for same-device recovery.
2. Follow [the recovery procedure](../../configuration-backup.md#prepared-device-recovery).
3. If you use these templates, replace every placeholder before native parsing.
4. Check management address, gateway, DNS, key access, browser login, and role.
5. Check the WDS bridge and affected clients when this device carries that path.
6. If verification fails, use the previous paired image/archive with physical recovery.

Native syntax is checked from a temporary directory. No template is applied
by that check. A real device restore remains untested. These essential files
are not a replacement for the full vendor archive or authentication material.
