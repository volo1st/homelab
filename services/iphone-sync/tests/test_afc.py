import subprocess
import unittest
from pathlib import PurePosixPath
from unittest.mock import patch

from iphone_sync.afc import AfcClient, AfcError, parse_listing

FILE_LISTING = """\
-rw-r--r--    1 mobile mobile   34471252 23 Jul 2026 11:05:14 IMG_9677.MOV
-rw-r--r--    1 mobile mobile     405190 13 Jul 2026 13:18:24 IMG_9609.JPG
-rw-r--r--    1 mobile mobile     339422 14 Jul 2026 13:39:25 IMG 9621.JPG
"""


class AfcParserTest(unittest.TestCase):
    def test_parses_real_afcclient_listing_shape(self) -> None:
        entries = parse_listing(FILE_LISTING, PurePosixPath("/DCIM/139APPLE"))

        self.assertEqual(len(entries), 3)
        self.assertEqual(entries[0].size_bytes, 34471252)
        self.assertEqual(
            entries[0].source_path, PurePosixPath("/DCIM/139APPLE/IMG_9677.MOV")
        )
        self.assertEqual(entries[2].name, "IMG 9621.JPG")

    def test_rejects_unknown_output(self) -> None:
        with self.assertRaisesRegex(AfcError, "cannot parse"):
            parse_listing("unexpected output", PurePosixPath("/DCIM"))


class AfcClientTest(unittest.TestCase):
    @patch("iphone_sync.afc.shutil.which", return_value="/opt/homebrew/bin/tool")
    def test_preflight_returns_only_device(self, _which: object) -> None:
        runner = unittest.mock.Mock(
            return_value=subprocess.CompletedProcess(
                ["idevice_id", "-l"], 0, "device-1\n", ""
            )
        )

        device_id = AfcClient(runner).preflight()

        self.assertEqual(device_id, "device-1")
        runner.assert_called_once_with(
            ["idevice_id", "-l"],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )

    @patch("iphone_sync.afc.shutil.which", return_value="/opt/homebrew/bin/tool")
    def test_preflight_rejects_multiple_devices(self, _which: object) -> None:
        runner = unittest.mock.Mock(
            return_value=subprocess.CompletedProcess(
                ["idevice_id", "-l"], 0, "device-1\ndevice-2\n", ""
            )
        )

        with self.assertRaisesRegex(AfcError, "more than one"):
            AfcClient(runner).preflight()

    def test_list_directory_uses_argument_vector_and_separator(self) -> None:
        runner = unittest.mock.Mock(
            return_value=subprocess.CompletedProcess(["afcclient"], 0, FILE_LISTING, "")
        )

        entries = AfcClient(runner).list_directory(
            "device-1", PurePosixPath("/DCIM/139APPLE")
        )

        self.assertEqual(len(entries), 3)
        runner.assert_called_once_with(
            [
                "afcclient",
                "-u",
                "device-1",
                "--",
                "ls",
                "-l",
                "/DCIM/139APPLE",
            ],
            check=False,
            capture_output=True,
            text=True,
            timeout=60,
        )

    def test_discover_lists_only_files_below_dcim_directories(self) -> None:
        runner = unittest.mock.Mock(
            side_effect=(
                subprocess.CompletedProcess(["idevice_id"], 0, "device-1\n", ""),
                subprocess.CompletedProcess(
                    ["afcclient"],
                    0,
                    "drwxr-xr-x 1 mobile mobile 0 23 Jul 2026 11:05:14 139APPLE\n",
                    "",
                ),
                subprocess.CompletedProcess(["afcclient"], 0, FILE_LISTING, ""),
            )
        )
        with patch(
            "iphone_sync.afc.shutil.which", return_value="/opt/homebrew/bin/tool"
        ):
            files = AfcClient(runner).discover_dcim()

        self.assertEqual(len(files), 3)
        self.assertTrue(all(not item.is_directory for item in files))


if __name__ == "__main__":
    unittest.main()
