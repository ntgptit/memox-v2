from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

from .constants import EMPTY
from .constants import KEY_CODE
from .constants import KEY_FILE_PATH
from .constants import KEY_GENERATED_AT
from .constants import KEY_LINE_NUMBER
from .constants import KEY_RULE_ID
from .constants import KEY_SCHEMA_VERSION
from .constants import KEY_VIOLATION_COUNT
from .constants import KEY_VIOLATIONS
from .constants import UTF8_ENCODING
from .models import GuardResult
from .models import Violation

BASELINE_SCHEMA_VERSION = 1
JSON_INDENT = 2
BASELINE_KEY_TEMPLATE = "{rule_id}:{file_path}:{line_number}:{code}"


class BaselineManager:
    def __init__(self, baseline_path: Path):
        self.path = baseline_path
        self.baseline: set[str] = set()

        if baseline_path.exists():
            data = json.loads(baseline_path.read_text(encoding=UTF8_ENCODING))
            self.baseline = {
                self._key(item) for item in data.get(KEY_VIOLATIONS, [])
            }

    def save_snapshot(self, results: list[GuardResult]) -> None:
        violations: list[dict[str, str | int]] = []
        for result in results:
            for violation in result.violations:
                violations.append(
                    {
                        KEY_RULE_ID: violation.rule_id,
                        KEY_FILE_PATH: violation.file_path,
                        KEY_LINE_NUMBER: violation.line_number,
                        KEY_CODE: violation.code,
                    }
                )

        data = {
            KEY_SCHEMA_VERSION: BASELINE_SCHEMA_VERSION,
            KEY_GENERATED_AT: datetime.now().isoformat(),
            KEY_VIOLATION_COUNT: len(violations),
            KEY_VIOLATIONS: violations,
        }
        self.path.write_text(
            json.dumps(data, indent=JSON_INDENT, ensure_ascii=False),
            encoding=UTF8_ENCODING,
        )

    def filter_new_only(self, results: list[GuardResult]) -> list[GuardResult]:
        filtered: list[GuardResult] = []
        for result in results:
            new_violations = [
                violation
                for violation in result.violations
                if self._key_from_violation(violation) not in self.baseline
            ]
            filtered.append(
                GuardResult(
                    rule_id=result.rule_id,
                    rule_name=result.rule_name,
                    family=result.family,
                    description=result.description,
                    severity=result.severity,
                    violations=new_violations,
                    files_scanned=result.files_scanned,
                    duration_ms=result.duration_ms,
                )
            )
        return filtered

    @staticmethod
    def _key(item: dict) -> str:
        return BASELINE_KEY_TEMPLATE.format(
            rule_id=item[KEY_RULE_ID],
            file_path=item[KEY_FILE_PATH],
            line_number=item.get(KEY_LINE_NUMBER, 0),
            code=item.get(KEY_CODE, EMPTY),
        )

    @staticmethod
    def _key_from_violation(violation: Violation) -> str:
        return BASELINE_KEY_TEMPLATE.format(
            rule_id=violation.rule_id,
            file_path=violation.file_path,
            line_number=violation.line_number,
            code=violation.code,
        )
