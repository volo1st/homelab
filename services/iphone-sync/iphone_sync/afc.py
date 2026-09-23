"""Read-only Apple File Conduit discovery."""

from __future__ import annotations

import re
import shutil
import subprocess
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import PurePosixPath


class AfcError(RuntimeError):
    """Report an Apple File Conduit command or output failure."""


@dataclass(frozen=True)
class AfcEntry:
    source_path: PurePosixPath
    name: str
    size_bytes: int
    is_directory: bool


RunCommand = Callable[..., subprocess.CompletedProcess[str]]

_LISTING_LINE = re.compile(
    r"^(?P<mode>\S+)\s+\d+\s+\S+\s+\S+\s+(?P<size>\d+)\s+"
    r"\d{1,2}\s+\S+\s+\d{4}\s+\d{2}:\d{2}:\d{2}\s+(?P<name>.+)$"
)


class AfcClient:
    def __init__(self, run_command: RunCommand = subprocess.run) -> None:
        self._run = run_command

    def preflight(self) -> str:
        """Return the identifier of the only connected and paired iPhone."""

        for command in ("idevice_id", "afcclient"):
            if shutil.which(command) is None:
                raise AfcError(f"required command is not available: {command}")

        result = self._run(
            ["idevice_id", "-l"],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            raise AfcError(_command_error("idevice_id", result))
        device_ids = tuple(
            line.strip() for line in result.stdout.splitlines() if line.strip()
        )
        if not device_ids:
            raise AfcError("no iPhone is available through libimobiledevice")
        if len(device_ids) > 1:
            raise AfcError(
                "more than one iPhone is connected; select one before import"
            )
        return device_ids[0]

    def list_directory(
        self, device_id: str, path: PurePosixPath
    ) -> tuple[AfcEntry, ...]:
        """List one AFC directory without invoking a shell."""

        if not device_id:
            raise AfcError("device identifier is required")
        if not path.is_absolute():
            raise AfcError("AFC directory must be an absolute path")
        result = self._run(
            ["afcclient", "-u", device_id, "--", "ls", "-l", str(path)],
            check=False,
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode != 0:
            raise AfcError(_command_error("afcclient", result))
        return parse_listing(result.stdout, path)

    def discover_dcim(self) -> tuple[AfcEntry, ...]:
        """Return all regular files one directory below the iPhone DCIM root."""

        device_id = self.preflight()
        root = PurePosixPath("/DCIM")
        directories = self.list_directory(device_id, root)
        files: list[AfcEntry] = []
        for entry in directories:
            if not entry.is_directory or entry.name in (".", ".."):
                continue
            for child in self.list_directory(device_id, entry.source_path):
                if not child.is_directory:
                    files.append(child)
        return tuple(sorted(files, key=lambda entry: str(entry.source_path)))


def parse_listing(output: str, directory: PurePosixPath) -> tuple[AfcEntry, ...]:
    """Parse the long listing format emitted by afcclient 1.4.0."""

    entries: list[AfcEntry] = []
    for line_number, line in enumerate(output.splitlines(), start=1):
        if not line.strip():
            continue
        match = _LISTING_LINE.fullmatch(line)
        if match is None:
            raise AfcError(f"cannot parse afcclient listing line {line_number}: {line}")
        name = match.group("name")
        if "/" in name or name in ("", ".", ".."):
            if name in (".", ".."):
                continue
            raise AfcError(f"unsafe AFC entry name: {name}")
        mode = match.group("mode")
        if mode[0] not in ("-", "d"):
            raise AfcError(f"unsupported AFC entry type: {mode}")
        entries.append(
            AfcEntry(
                source_path=directory / name,
                name=name,
                size_bytes=int(match.group("size")),
                is_directory=mode.startswith("d"),
            )
        )
    return tuple(entries)


def _command_error(command: str, result: subprocess.CompletedProcess[str]) -> str:
    detail = (
        result.stderr.strip() or result.stdout.strip() or f"exit {result.returncode}"
    )
    return f"{command} failed: {detail}"
