import sqlite3
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from iphone_sync.manifest import SCHEMA_VERSION, Manifest, ManifestCounts


class ManifestTest(unittest.TestCase):
    def test_initialize_is_idempotent_and_counts_are_empty(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "staging #1" / "manifest.sqlite3"
            manifest = Manifest(path)

            manifest.initialize()
            manifest.initialize()

            self.assertTrue(path.is_file())
            self.assertEqual(manifest.counts(), ManifestCounts())
            with sqlite3.connect(path) as connection:
                version = connection.execute(
                    "SELECT version FROM schema_version"
                ).fetchone()
                foreign_keys = connection.execute(
                    "PRAGMA foreign_key_list(media_file)"
                ).fetchall()
            self.assertEqual(version, (SCHEMA_VERSION,))
            self.assertEqual(len(foreign_keys), 1)

    def test_rejects_unknown_schema_version(self) -> None:
        with TemporaryDirectory() as directory:
            path = Path(directory) / "manifest.sqlite3"
            manifest = Manifest(path)
            manifest.initialize()
            with sqlite3.connect(path) as connection:
                connection.execute("UPDATE schema_version SET version = 999")

            with self.assertRaisesRegex(RuntimeError, "unsupported manifest schema"):
                manifest.initialize()


if __name__ == "__main__":
    unittest.main()
