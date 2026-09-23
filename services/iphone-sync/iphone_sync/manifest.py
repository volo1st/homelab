"""SQLite manifest for imported media."""

from __future__ import annotations

import sqlite3
from collections.abc import Iterable, Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path

SCHEMA_VERSION = 1
FILE_STATES = ("discovered", "local_complete", "nas_published", "cleared")


class ManifestError(RuntimeError):
    """Report invalid manifest data or a prohibited state transition."""


@dataclass(frozen=True)
class DiscoveredFile:
    source_path: str
    original_name: str
    size_bytes: int


@dataclass(frozen=True)
class ManifestFile:
    id: int
    asset_id: int
    source_path: str
    original_name: str
    size_bytes: int
    local_path: str | None
    content_hash: str | None
    imported_at: str | None
    nas_path: str | None
    published_at: str | None
    cleared_at: str | None
    state: str


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

    def discover_asset(
        self,
        *,
        device_udid: str,
        source_asset_id: str,
        media_kind: str,
        capture_time: str | None,
        discovered_at: str,
        files: Iterable[DiscoveredFile],
    ) -> int:
        """Record one asset group and its source files without overwriting data."""

        discovered_files = tuple(files)
        if not discovered_files:
            raise ManifestError("an asset must contain at least one file")
        if media_kind not in ("photo", "video"):
            raise ManifestError(f"unsupported media kind: {media_kind}")
        if not device_udid or not source_asset_id or not discovered_at:
            raise ManifestError("device, asset, and discovery identifiers are required")
        for item in discovered_files:
            if not item.source_path or not item.original_name or item.size_bytes < 0:
                raise ManifestError("discovered file data is invalid")

        with self._connection() as connection:
            connection.execute(
                """
                INSERT INTO asset(
                    device_udid, source_asset_id, media_kind, capture_time, discovered_at
                ) VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(device_udid, source_asset_id) DO NOTHING
                """,
                (
                    device_udid,
                    source_asset_id,
                    media_kind,
                    capture_time,
                    discovered_at,
                ),
            )
            asset_row = connection.execute(
                """
                SELECT id, media_kind, capture_time
                FROM asset
                WHERE device_udid = ? AND source_asset_id = ?
                """,
                (device_udid, source_asset_id),
            ).fetchone()
            if asset_row is None:
                raise ManifestError("cannot read the discovered asset")
            asset_id, stored_kind, stored_capture_time = asset_row
            if (stored_kind, stored_capture_time) != (media_kind, capture_time):
                raise ManifestError(
                    "the discovered asset conflicts with stored metadata"
                )

            for item in discovered_files:
                connection.execute(
                    """
                    INSERT INTO media_file(
                        asset_id, source_path, original_name, size_bytes, state
                    ) VALUES (?, ?, ?, ?, 'discovered')
                    ON CONFLICT(asset_id, source_path) DO NOTHING
                    """,
                    (asset_id, item.source_path, item.original_name, item.size_bytes),
                )
                stored_file = connection.execute(
                    """
                    SELECT original_name, size_bytes
                    FROM media_file
                    WHERE asset_id = ? AND source_path = ?
                    """,
                    (asset_id, item.source_path),
                ).fetchone()
                if stored_file != (item.original_name, item.size_bytes):
                    raise ManifestError(
                        f"the discovered file conflicts with stored metadata: {item.source_path}"
                    )
            return asset_id

    def files_for_asset(self, asset_id: int) -> tuple[ManifestFile, ...]:
        """Return all files in one asset group in source-path order."""

        with self._connection(read_only=True) as connection:
            rows = connection.execute(
                """
                SELECT id, asset_id, source_path, original_name, size_bytes,
                       local_path, content_hash, imported_at, nas_path,
                       published_at, cleared_at, state
                FROM media_file
                WHERE asset_id = ?
                ORDER BY source_path
                """,
                (asset_id,),
            ).fetchall()
        return tuple(ManifestFile(*row) for row in rows)

    def mark_local_complete(
        self,
        file_id: int,
        *,
        local_path: str,
        imported_at: str,
        content_hash: str | None = None,
    ) -> None:
        """Move a discovered file to the local-complete state."""

        if not local_path or not imported_at:
            raise ManifestError("local path and import time are required")
        with self._connection() as connection:
            row = self._file_state(connection, file_id)
            if row[0] == "local_complete":
                if row[1:4] == (local_path, content_hash, imported_at):
                    return
                raise ManifestError(
                    "local-complete metadata conflicts with the manifest"
                )
            if row[0] != "discovered":
                raise ManifestError(f"cannot mark {row[0]} file as local complete")
            connection.execute(
                """
                UPDATE media_file
                SET state = 'local_complete', local_path = ?, content_hash = ?, imported_at = ?
                WHERE id = ?
                """,
                (local_path, content_hash, imported_at, file_id),
            )

    def mark_nas_published(
        self, file_id: int, *, nas_path: str, published_at: str
    ) -> None:
        """Move a local-complete file to the NAS-published state."""

        if not nas_path or not published_at:
            raise ManifestError("NAS path and publication time are required")
        with self._connection() as connection:
            row = self._file_state(connection, file_id)
            if row[0] == "nas_published":
                if row[4:6] == (nas_path, published_at):
                    return
                raise ManifestError(
                    "NAS-publication metadata conflicts with the manifest"
                )
            if row[0] != "local_complete":
                raise ManifestError(f"cannot publish {row[0]} file")
            connection.execute(
                """
                UPDATE media_file
                SET state = 'nas_published', nas_path = ?, published_at = ?
                WHERE id = ?
                """,
                (nas_path, published_at, file_id),
            )

    def asset_is_clear_eligible(self, asset_id: int) -> bool:
        """Check recorded eligibility; the clear command must also check local files."""

        with self._connection(read_only=True) as connection:
            count, ineligible = connection.execute(
                """
                SELECT COUNT(*),
                       SUM(CASE
                           WHEN state = 'nas_published' AND local_path IS NOT NULL THEN 0
                           ELSE 1
                       END)
                FROM media_file
                WHERE asset_id = ?
                """,
                (asset_id,),
            ).fetchone()
        return count > 0 and ineligible == 0

    def mark_asset_cleared(self, asset_id: int, *, cleared_at: str) -> None:
        """Mark a complete published asset group as cleared from the phone."""

        if not cleared_at:
            raise ManifestError("clear time is required")
        with self._connection() as connection:
            count, eligible, already_cleared = connection.execute(
                """
                SELECT COUNT(*),
                       SUM(state = 'nas_published' AND local_path IS NOT NULL),
                       SUM(state = 'cleared')
                FROM media_file
                WHERE asset_id = ?
                """,
                (asset_id,),
            ).fetchone()
            if count == 0:
                raise ManifestError(f"asset does not exist: {asset_id}")
            if already_cleared == count:
                return
            if eligible != count:
                raise ManifestError("the complete asset group is not eligible to clear")
            connection.execute(
                """
                UPDATE media_file
                SET state = 'cleared', cleared_at = ?
                WHERE asset_id = ? AND state = 'nas_published'
                """,
                (cleared_at, asset_id),
            )

    @staticmethod
    def _file_state(connection: sqlite3.Connection, file_id: int) -> tuple[object, ...]:
        row = connection.execute(
            """
            SELECT state, local_path, content_hash, imported_at, nas_path, published_at
            FROM media_file
            WHERE id = ?
            """,
            (file_id,),
        ).fetchone()
        if row is None:
            raise ManifestError(f"file does not exist: {file_id}")
        return row

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
