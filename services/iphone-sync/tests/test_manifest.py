import sqlite3
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from iphone_sync.manifest import (
    SCHEMA_VERSION,
    DiscoveredFile,
    Manifest,
    ManifestCounts,
    ManifestError,
)


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

    def test_discovery_is_idempotent_and_rejects_conflicting_metadata(self) -> None:
        with TemporaryDirectory() as directory:
            manifest = Manifest(Path(directory) / "manifest.sqlite3")
            manifest.initialize()
            files = [DiscoveredFile("/DCIM/A.HEIC", "A.HEIC", 123)]

            first_id = manifest.discover_asset(
                device_udid="phone-1",
                source_asset_id="asset-1",
                media_kind="photo",
                capture_time="2026-09-24T10:00:00Z",
                discovered_at="2026-09-24T11:00:00Z",
                files=files,
            )
            second_id = manifest.discover_asset(
                device_udid="phone-1",
                source_asset_id="asset-1",
                media_kind="photo",
                capture_time="2026-09-24T10:00:00Z",
                discovered_at="2026-09-24T12:00:00Z",
                files=files,
            )

            self.assertEqual(first_id, second_id)
            self.assertEqual(len(manifest.files_for_asset(first_id)), 1)
            with self.assertRaisesRegex(ManifestError, "conflicts"):
                manifest.discover_asset(
                    device_udid="phone-1",
                    source_asset_id="asset-1",
                    media_kind="photo",
                    capture_time="2026-09-24T10:00:00Z",
                    discovered_at="2026-09-24T13:00:00Z",
                    files=[DiscoveredFile("/DCIM/A.HEIC", "A.HEIC", 999)],
                )

    def test_complete_group_moves_through_all_states(self) -> None:
        with TemporaryDirectory() as directory:
            manifest = Manifest(Path(directory) / "manifest.sqlite3")
            manifest.initialize()
            asset_id = manifest.discover_asset(
                device_udid="phone-1",
                source_asset_id="live-photo-1",
                media_kind="photo",
                capture_time="2026-09-24T10:00:00Z",
                discovered_at="2026-09-24T11:00:00Z",
                files=(
                    DiscoveredFile("/DCIM/A.HEIC", "A.HEIC", 123),
                    DiscoveredFile("/DCIM/A.MOV", "A.MOV", 456),
                ),
            )
            files = manifest.files_for_asset(asset_id)

            for item in files:
                manifest.mark_local_complete(
                    item.id,
                    local_path=f"/staging/{item.original_name}",
                    imported_at="2026-09-24T11:10:00Z",
                )
                manifest.mark_nas_published(
                    item.id,
                    nas_path=f"/archive/{item.original_name}",
                    published_at="2026-09-24T11:20:00Z",
                )

            self.assertTrue(manifest.asset_is_clear_eligible(asset_id))
            manifest.mark_asset_cleared(asset_id, cleared_at="2026-09-24T11:30:00Z")
            manifest.mark_asset_cleared(asset_id, cleared_at="2026-09-24T11:30:00Z")

            self.assertFalse(manifest.asset_is_clear_eligible(asset_id))
            self.assertEqual(
                manifest.counts(),
                ManifestCounts(
                    discovered=0, local_complete=0, nas_published=0, cleared=2
                ),
            )
            self.assertEqual(
                {item.state for item in manifest.files_for_asset(asset_id)}, {"cleared"}
            )

    def test_rejects_out_of_order_and_incomplete_group_transitions(self) -> None:
        with TemporaryDirectory() as directory:
            manifest = Manifest(Path(directory) / "manifest.sqlite3")
            manifest.initialize()
            asset_id = manifest.discover_asset(
                device_udid="phone-1",
                source_asset_id="live-photo-1",
                media_kind="photo",
                capture_time=None,
                discovered_at="2026-09-24T11:00:00Z",
                files=(
                    DiscoveredFile("/DCIM/A.HEIC", "A.HEIC", 123),
                    DiscoveredFile("/DCIM/A.MOV", "A.MOV", 456),
                ),
            )
            first, second = manifest.files_for_asset(asset_id)

            with self.assertRaisesRegex(ManifestError, "cannot publish discovered"):
                manifest.mark_nas_published(
                    first.id,
                    nas_path="/archive/A.HEIC",
                    published_at="2026-09-24T11:20:00Z",
                )

            manifest.mark_local_complete(
                first.id,
                local_path="/staging/A.HEIC",
                imported_at="2026-09-24T11:10:00Z",
            )
            manifest.mark_nas_published(
                first.id,
                nas_path="/archive/A.HEIC",
                published_at="2026-09-24T11:20:00Z",
            )

            self.assertFalse(manifest.asset_is_clear_eligible(asset_id))
            with self.assertRaisesRegex(ManifestError, "not eligible"):
                manifest.mark_asset_cleared(asset_id, cleared_at="2026-09-24T11:30:00Z")
            self.assertEqual(second.state, "discovered")

    def test_rejects_conflicting_repeated_transition(self) -> None:
        with TemporaryDirectory() as directory:
            manifest = Manifest(Path(directory) / "manifest.sqlite3")
            manifest.initialize()
            asset_id = manifest.discover_asset(
                device_udid="phone-1",
                source_asset_id="asset-1",
                media_kind="video",
                capture_time=None,
                discovered_at="2026-09-24T11:00:00Z",
                files=[DiscoveredFile("/DCIM/A.MOV", "A.MOV", 456)],
            )
            (item,) = manifest.files_for_asset(asset_id)
            manifest.mark_local_complete(
                item.id,
                local_path="/staging/A.MOV",
                imported_at="2026-09-24T11:10:00Z",
            )

            with self.assertRaisesRegex(ManifestError, "conflicts"):
                manifest.mark_local_complete(
                    item.id,
                    local_path="/other/A.MOV",
                    imported_at="2026-09-24T11:10:00Z",
                )


if __name__ == "__main__":
    unittest.main()
