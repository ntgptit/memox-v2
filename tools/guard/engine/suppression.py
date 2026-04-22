from __future__ import annotations

from dataclasses import dataclass
from datetime import date
import fnmatch
from pathlib import Path

import yaml

from .constants import EMPTY
from .constants import INLINE_SUPPRESSION_FILE_PREFIX
from .constants import INLINE_SUPPRESSION_NEXT_LINE_PREFIX
from .constants import INLINE_SUPPRESSION_PREFIX
from .constants import KEY_AUTHOR
from .constants import KEY_EXPIRES_AT
from .constants import KEY_FILES
from .constants import KEY_PATHS
from .constants import KEY_REASON
from .constants import KEY_RULE_ID
from .constants import KEY_SUPPRESSIONS
from .constants import TOP_OF_FILE_INLINE_SCAN_LIMIT
from .constants import UTF8_ENCODING


@dataclass
class Suppression:
    rule_id: str
    paths: list[str]
    files: list[str]
    reason: str
    author: str
    expires_at: date | None

    @property
    def is_expired(self) -> bool:
        if self.expires_at is None:
            return False
        return date.today() > self.expires_at


class SuppressionChecker:
    def __init__(self, suppressions_path: Path):
        self.suppressions: list[Suppression] = []

        if suppressions_path.exists():
            raw = yaml.safe_load(suppressions_path.read_text(encoding=UTF8_ENCODING)) or {}
            for item in raw.get(KEY_SUPPRESSIONS, []):
                expires_at = item.get(KEY_EXPIRES_AT)
                self.suppressions.append(
                    Suppression(
                        rule_id=item[KEY_RULE_ID],
                        paths=item.get(KEY_PATHS, []),
                        files=item.get(KEY_FILES, []),
                        reason=item.get(KEY_REASON, EMPTY),
                        author=item.get(KEY_AUTHOR, EMPTY),
                        expires_at=date.fromisoformat(expires_at)
                        if expires_at
                        else None,
                    )
                )

    def is_suppressed(self, rule_id: str, file_path: str) -> bool:
        for suppression in self.suppressions:
            if suppression.rule_id != rule_id:
                continue
            if suppression.is_expired:
                continue
            if any(fnmatch.fnmatch(file_path, pattern) for pattern in suppression.paths):
                return True
            if file_path in suppression.files:
                return True
        return False

    def check_inline(self, rule_id: str, lines: list[str], line_number: int) -> bool:
        if not lines:
            return False

        for index in range(min(TOP_OF_FILE_INLINE_SCAN_LIMIT, len(lines))):
            if f"{INLINE_SUPPRESSION_FILE_PREFIX}{rule_id}" in lines[index]:
                return True

        if line_number <= 0:
            return False

        if line_number <= len(lines):
            if f"{INLINE_SUPPRESSION_PREFIX}{rule_id}" in lines[line_number - 1]:
                return True

        if 2 <= line_number <= len(lines):
            if (
                f"{INLINE_SUPPRESSION_NEXT_LINE_PREFIX}{rule_id}"
                in lines[line_number - 2]
            ):
                return True

        return False

    def get_expired(self) -> list[Suppression]:
        return [suppression for suppression in self.suppressions if suppression.is_expired]
