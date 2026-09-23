import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory

from iphone_sync.cli import main


class CliTest(unittest.TestCase):
    def test_init_then_status(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory)
            staging = root / "staging"
            config_path = root / "config.toml"
            config_path.write_text(
                f'[iphone_sync]\nstaging_dir = "{staging}"\n', encoding="utf-8"
            )
            output = StringIO()

            with redirect_stdout(output):
                init_result = main(["--config", str(config_path), "init"])
                status_result = main(["--config", str(config_path), "status"])

            self.assertEqual(init_result, 0)
            self.assertEqual(status_result, 0)
            self.assertIn("Initialized manifest:", output.getvalue())
            self.assertIn("NAS published: 0", output.getvalue())

    def test_status_does_not_create_manifest(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory)
            staging = root / "staging"
            config_path = root / "config.toml"
            config_path.write_text(
                f'[iphone_sync]\nstaging_dir = "{staging}"\n', encoding="utf-8"
            )
            error = StringIO()

            with redirect_stderr(error):
                result = main(["--config", str(config_path), "status"])

            self.assertEqual(result, 1)
            self.assertFalse(staging.exists())
            self.assertIn("not initialized", error.getvalue())


if __name__ == "__main__":
    unittest.main()
