import unittest
from pathlib import Path, PurePosixPath
from tempfile import TemporaryDirectory

from iphone_sync.config import ConfigError, load_config


class ConfigTest(unittest.TestCase):
    def test_loads_explicit_configuration(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory)
            config_path = root / "config.toml"
            config_path.write_text(
                "\n".join(
                    (
                        "[iphone_sync]",
                        f'staging_dir = "{root / "staging"}"',
                        'nas_host = "storage"',
                        'photo_root = "/archive/photos"',
                        'video_root = "/archive/videos"',
                        "reserve_gib = 7",
                    )
                ),
                encoding="utf-8",
            )

            config = load_config(config_path)

            self.assertEqual(config.staging_dir, root / "staging")
            self.assertEqual(
                config.manifest_path, root / "staging" / "manifest.sqlite3"
            )
            self.assertEqual(config.nas_host, "storage")
            self.assertEqual(config.photo_root, PurePosixPath("/archive/photos"))
            self.assertEqual(config.video_root, PurePosixPath("/archive/videos"))
            self.assertEqual(config.reserve_gib, 7)

    def test_rejects_relative_staging_directory(self) -> None:
        with TemporaryDirectory() as directory:
            config_path = Path(directory) / "config.toml"
            config_path.write_text(
                '[iphone_sync]\nstaging_dir = "relative/path"\n', encoding="utf-8"
            )

            with self.assertRaisesRegex(
                ConfigError, "staging_dir must be an absolute path"
            ):
                load_config(config_path)

    def test_rejects_relative_nas_root(self) -> None:
        with TemporaryDirectory() as directory:
            config_path = Path(directory) / "config.toml"
            config_path.write_text(
                '[iphone_sync]\nphoto_root = "relative/path"\n', encoding="utf-8"
            )

            with self.assertRaisesRegex(ConfigError, "photo_root must be an absolute"):
                load_config(config_path)

    def test_rejects_boolean_reserve(self) -> None:
        with TemporaryDirectory() as directory:
            config_path = Path(directory) / "config.toml"
            config_path.write_text(
                "[iphone_sync]\nreserve_gib = true\n", encoding="utf-8"
            )

            with self.assertRaisesRegex(ConfigError, "reserve_gib"):
                load_config(config_path)


if __name__ == "__main__":
    unittest.main()
