from __future__ import annotations

from ..constants import KEY_BASE_PATH
from ..constants import KEY_EXPECTED_CHILDREN
from ..constants import KEY_PER_CHILD_REQUIRED
from ..constants import KEY_REQUIRED_DIRS
from ..constants import KEY_REQUIRED_FILES
from ..file_scanner import FileScanner
from ..models import Rule
from ..models import Violation

PATH_SEPARATOR = "/"
MISSING_DIRECTORY_TEMPLATE = "Required directory missing: {path}"
MISSING_FILE_TEMPLATE = "Required file missing: {path}"


class ProjectMatcher:
    @staticmethod
    def check_path_structure(rule: Rule, scanner: FileScanner) -> list[Violation]:
        violations: list[Violation] = []

        for missing_dir in scanner.check_paths_exist(
            rule.params.get(KEY_REQUIRED_DIRS, [])
        ):
            violations.append(
                ProjectMatcher._fs_violation(
                    rule,
                    missing_dir,
                    MISSING_DIRECTORY_TEMPLATE.format(path=missing_dir),
                )
            )

        base_path = rule.params.get(KEY_BASE_PATH)
        per_child_required = rule.params.get(KEY_PER_CHILD_REQUIRED, [])
        expected_children = rule.params.get(KEY_EXPECTED_CHILDREN, [])
        if base_path and per_child_required:
            base_dir = scanner.root / base_path
            if base_dir.exists():
                children = expected_children or [
                    child.name for child in base_dir.iterdir() if child.is_dir()
                ]
            else:
                children = expected_children

            for child in children:
                for sub_path in per_child_required:
                    expected_path = PATH_SEPARATOR.join((base_path, child, sub_path))
                    if not (scanner.root / expected_path).exists():
                        violations.append(
                            ProjectMatcher._fs_violation(
                                rule,
                                expected_path,
                                MISSING_DIRECTORY_TEMPLATE.format(
                                    path=expected_path
                                ),
                            )
                        )

        return violations

    @staticmethod
    def check_file_existence(rule: Rule, scanner: FileScanner) -> list[Violation]:
        return [
            ProjectMatcher._fs_violation(
                rule,
                path,
                MISSING_FILE_TEMPLATE.format(path=path),
            )
            for path in scanner.check_files_exist(rule.params.get(KEY_REQUIRED_FILES, []))
        ]

    @staticmethod
    def _fs_violation(rule: Rule, path: str, message: str) -> Violation:
        return Violation(
            rule_id=rule.id,
            code=rule.message_code or rule.id,
            family=rule.family,
            severity=rule.severity,
            confidence=rule.confidence,
            impact=rule.impact,
            file_path=path,
            message=message,
        )
