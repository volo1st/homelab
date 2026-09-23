"""SQLite manifest for imported media."""

from __future__ import annotations

import sqlite3
from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path

SCHEMA_VERSION = 1
FILE_STATES = ("discovered", "local_complete", "nas_published", "cleared")


@dataclass(frozen=True)
class ManifestCounts:
    discovered: int = 0
    local_complete: int = 0
    nas_published: int = 0
    cleared: int = 0


class Manifest:
    def __init__(self, path: Path) -> None:
        self.path = path

    def initialize(self) -> None:
        """Create the manifest and its first schema version."""

        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self._connection() as connection:
            version_table_exists = connection.execute(
                """
                SELECT 1
                FROM sqlite_master
                WHERE type = 'table' AND name = 'schema_version'
                """
            ).fetchone()
            if version_table_exists:
                rows = connection.execute(
                    "SELECT version FROM schema_version"
                ).fetchall()
                if rows != [(SCHEMA_VERSION,)]:
                    found = ", ".join(str(row[0]) for row in rows) or "none"
                    raise RuntimeError(
                        f"unsupported manifest schema {found}; expected {SCHEMA_VERSION}"
                    )
                return

            connection.executescript(
                """
                CREATE TABLE IF NOT EXISTS schema_version (
                    version INTEGER NOT NULL
                );

                CREATE TABLE IF NOT EXISTS asset (
                    id INTEGER PRIMARY KEY,
                    device_udid TEXT NOT NULL,
                    source_asset_id TEXT NOT NULL,
                    media_kind TEXT NOT NULL CHECK (media_kind IN ('photo', 'video')),
                    capture_time TEXT,
                    discovered_at TEXT NOT NULL,
                    UNIQUE (device_udid, source_asset_id)
                );

                CREATE TABLE IF NOT EXISTS media_file (
                    id INTEGER PRIMARY KEY,
                    asset_id INTEGER NOT NULL REFERENCES asset(id) ON DELETE RESTRICT,
                    source_path TEXT NOT NULL,
                    original_name TEXT NOT NULL,
                    size_bytes INTEGER NOT NULL CHECK (size_bytes >= 0),
                    local_path TEXT,
                    content_hash TEXT,
                    imported_at TEXT,
                    nas_path TEXT,
                    published_at TEXT,
                    cleared_at TEXT,
                    state TEXT NOT NULL CHECK (
                        state IN ('discovered', 'local_complete', 'nas_published', 'cleared')
                    ),
                    UNIQUE (asset_id, source_path)
                );
                """
            )
            connection.execute(
                "INSERT INTO schema_version(version) VALUES (?)", (SCHEMA_VERSION,)
            )

    def counts(self) -> ManifestCounts:
        """Return one count for each file state."""

        values = {state: 0 for state in FILE_STATES}
        with self._connection(read_only=True) as connection:
            for state, count in connection.execute(
                "SELECT state, COUNT(*) FROM media_file GROUP BY state"
            ):
                values[state] = count
        return ManifestCounts(**values)

    @contextmanager
    def _connection(self, *, read_only: bool = False) -> Iterator[sqlite3.Connection]:
        if read_only:
            uri = f"{self.path.resolve().as_uri()}?mode=ro"
            connection = sqlite3.connect(uri, uri=True)
        else:
            connection = sqlite3.connect(self.path)
        try:
            connection.execute("PRAGMA foreign_keys = ON")
            with connection:
                yield connection
        finally:
            connection.close()
