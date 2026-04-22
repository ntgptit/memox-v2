from __future__ import annotations

import fnmatch
from pathlib import Path

from .constants import DEFAULT_INCLUDE_PATTERN
from .constants import KEY_EXCLUDE
from .constants import KEY_INCLUDE
from .constants import KEY_ROOTS
from .constants import UTF8_ENCODING
from .path_utils import normalize_rel_path


class FileScanner:
    def __init__(self, project_root: Path, scopes_config: dict):
        self.root = project_root
        self.scopes = scopes_config

    def resolve_scope(self, scope_id: str) -> list[tuple[Path, str]]:
        """Return `(absolute_path, relative_posix_path)` tuples for a scope."""
        scope = self.scopes.get(scope_id)
        if not scope:
            return []

        files: list[tuple[Path, str]] = []
        for root_path in scope.get(KEY_ROOTS, []):
            abs_root = self.root / root_path
            if not abs_root.exists():
                continue

            include = scope.get(KEY_INCLUDE, [DEFAULT_INCLUDE_PATTERN])
            exclude = scope.get(KEY_EXCLUDE, [])

            for file_path in abs_root.rglob("*"):
                if not file_path.is_file():
                    continue

                rel_path = normalize_rel_path(file_path, self.root)
                if not any(fnmatch.fnmatch(rel_path, pattern) for pattern in include):
                    continue
                if any(fnmatch.fnmatch(rel_path, pattern) for pattern in exclude):
                    continue

                files.append((file_path, rel_path))

        return sorted(files, key=lambda item: item[1])

    def filter_by_targets(
        self,
        files: list[tuple[Path, str]],
        targets: tuple[str, ...],
        exclude: tuple[str, ...],
    ) -> list[tuple[Path, str]]:
        result = files
        if targets:
            result = [
                (abs_path, rel_path)
                for abs_path, rel_path in result
                if any(fnmatch.fnmatch(rel_path, pattern) for pattern in targets)
            ]
        if exclude:
            result = [
                (abs_path, rel_path)
                for abs_path, rel_path in result
                if not any(fnmatch.fnmatch(rel_path, pattern) for pattern in exclude)
            ]
        return result

    def check_paths_exist(self, required_dirs: list[str]) -> list[str]:
        return [path for path in required_dirs if not (self.root / path).exists()]

    def check_files_exist(self, required_files: list[str]) -> list[str]:
        return [path for path in required_files if not (self.root / path).exists()]

    @staticmethod
    def read_file(path: Path | None) -> list[str]:
        if path is None:
            return []
        try:
            return path.read_text(encoding=UTF8_ENCODING).splitlines()
        except (OSError, UnicodeDecodeError):
            return []
