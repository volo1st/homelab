"""Command-line interface for iphone-sync."""

from __future__ import annotations

import argparse
import sqlite3
import sys
from pathlib import Path

from iphone_sync.config import ConfigError, load_config
from iphone_sync.manifest import Manifest


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="iphone-sync")
    parser.add_argument(
        "--config",
        type=Path,
        help="path to a per-Mac TOML configuration file",
    )
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("init", help="create local staging and the manifest")
    commands.add_parser("status", help="show local manifest counts")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        config = load_config(args.config)
        manifest = Manifest(config.manifest_path)
        if args.command == "init":
            manifest.initialize()
            print(f"Initialized staging: {config.staging_dir}")
            print(f"Initialized manifest: {config.manifest_path}")
            return 0
        if args.command == "status":
            if not config.manifest_path.is_file():
                print(
                    "iphone-sync is not initialized. Run: iphone-sync init",
                    file=sys.stderr,
                )
                return 1
            counts = manifest.counts()
            print(f"Manifest: {config.manifest_path}")
            print(f"Discovered: {counts.discovered}")
            print(f"Local complete: {counts.local_complete}")
            print(f"NAS published: {counts.nas_published}")
            print(f"Cleared: {counts.cleared}")
            return 0
    except (ConfigError, OSError, sqlite3.Error, RuntimeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
