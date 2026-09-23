"""Configuration loading for iphone-sync."""

from __future__ import annotations

import tomllib
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

DEFAULT_CONFIG_PATH = Path("~/.config/iphone-sync/config.toml").expanduser()


class ConfigError(ValueError):
    """Report an invalid configuration."""


@dataclass(frozen=True)
class Config:
    staging_dir: Path
    nas_host: str
    photo_root: PurePosixPath
    video_root: PurePosixPath
    reserve_gib: int

    @property
    def manifest_path(self) -> Path:
        return self.staging_dir / "manifest.sqlite3"


def default_config() -> Config:
    return Config(
        staging_dir=Path("~/Pictures/iphone-sync").expanduser(),
        nas_host="nas",
        photo_root=PurePosixPath("/ocean/personal/photos/iphone"),
        video_root=PurePosixPath("/ocean/personal/videos/iphone"),
        reserve_gib=5,
    )


def load_config(path: Path | None = None) -> Config:
    """Load the per-Mac configuration or return the documented defaults."""

    config_path = path or DEFAULT_CONFIG_PATH
    if not config_path.exists():
        if path is not None:
            raise ConfigError(f"configuration file does not exist: {config_path}")
        return default_config()

    try:
        with config_path.open("rb") as stream:
            document = tomllib.load(stream)
    except (OSError, tomllib.TOMLDecodeError) as error:
        raise ConfigError(
            f"cannot read configuration {config_path}: {error}"
        ) from error

    section = document.get("iphone_sync")
    if not isinstance(section, dict):
        raise ConfigError("configuration must contain an [iphone_sync] table")

    defaults = default_config()
    staging_dir = _local_path(section.get("staging_dir", str(defaults.staging_dir)))
    nas_host = section.get("nas_host", defaults.nas_host)
    photo_root = _remote_path(
        section.get("photo_root", str(defaults.photo_root)), "photo_root"
    )
    video_root = _remote_path(
        section.get("video_root", str(defaults.video_root)), "video_root"
    )
    reserve_gib = section.get("reserve_gib", defaults.reserve_gib)

    if not isinstance(nas_host, str) or not nas_host.strip():
        raise ConfigError("nas_host must be a non-empty string")
    if (
        not isinstance(reserve_gib, int)
        or isinstance(reserve_gib, bool)
        or reserve_gib < 0
    ):
        raise ConfigError("reserve_gib must be a non-negative integer")

    return Config(
        staging_dir=staging_dir,
        nas_host=nas_host,
        photo_root=photo_root,
        video_root=video_root,
        reserve_gib=reserve_gib,
    )


def _local_path(value: object) -> Path:
    if not isinstance(value, str) or not value.strip():
        raise ConfigError("staging_dir must be a non-empty string")
    path = Path(value).expanduser()
    if not path.is_absolute():
        raise ConfigError("staging_dir must be an absolute path")
    return path


def _remote_path(value: object, name: str) -> PurePosixPath:
    if not isinstance(value, str) or not value.strip():
        raise ConfigError(f"{name} must be a non-empty string")
    path = PurePosixPath(value)
    if not path.is_absolute():
        raise ConfigError(f"{name} must be an absolute POSIX path")
    return path
