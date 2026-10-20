# Reviewed device configurations

Collected: 2026-10-20 at 03:16 UTC (14:16 Sydney).
Private source: `secrets/local/network/20261020T031655Z/`.
These are essential native templates. The full native archives retain credentials
and remaining vendor state. Use the [recovery procedure](../configuration-backup.md#prepared-device-recovery).
Do not apply a file that still has a `<PRIVATE_...>` placeholder.

| Device | Paired image in encrypted bundle | SHA-256 |
|---|---|---|
| [mt6000](mt6000/README.md) | `mt6000-4.11.0.bin` | `4004632eaf516fd2844be0e5595b6e4171d243181ff49b81569b986c79007dae` |
| [mt1300](mt1300/README.md) | `mt1300-4.3.25.bin` | `e906a213ed66027b8e801b9c621f7ce8c43f70098615c0278a8250cc3beeb82c` |
| [axt1800](axt1800/README.md) | `openwrt-25.12.5-qualcommax-ipq60xx-glinet_gl-axt1800-squashfs-sysupgrade.bin` | `fea31a77a9f84089badc4ff89f8751f4e73e574a4490adede69a8c18c9b04ef9` |
| [wax202](wax202/README.md) | `openwrt-25.12.5-ramips-mt7621-netgear_wax202-squashfs-sysupgrade.bin` | `ef3a66ea09ec2500b3f9f4572be235f63fc447e90517a04ca341a681eb894ac1` |
| [mikrotik](mikrotik/README.md) | `routeros-7.23.8-mmips.npk` | `1b73b1caf6f612b0d7b14d022f6d6fcd50d2e836e5200b31ee7d6dcbe2d062c7` |

All 33 AP templates passed each device's native UCI parser from a temporary
directory. No live configuration was imported or committed. The MikroTik export
was reviewed as text. It was not imported. Installed package manifests are
included per AP. AXT1800 and WAX202 also need the corrected web-service pair.
MT6000 and MT1300 need their separately tracked local fixes.

The current encrypted bundle is
`/sandbox/vincent/home_network_backup/20261020T033118Z/`.
Its `supplement/firmware-manifest.json` records the paired images.
The bundle passed decryption and plaintext hash verification. That does not
prove an actual device restore. Replacement devices and bootloader recovery
remain untested. See [the review](../baseline-review-2026-10-20.md).
