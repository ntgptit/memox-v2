from __future__ import annotations

import re

from ..constants import KEY_BASE_PATH
from ..constants import KEY_EXPECTED_CHILDREN
from ..constants import KEY_PER_CHILD_REQUIRED
from ..constants import KEY_REQUIRED_DIRS
from ..constants import KEY_REQUIRED_FILES
from ..constants import UTF8_ENCODING
from ..file_scanner import FileScanner
from ..models import Rule
from ..models import Violation

PATH_SEPARATOR = "/"
MISSING_DIRECTORY_TEMPLATE = "Required directory missing: {path}"
MISSING_FILE_TEMPLATE = "Required file missing: {path}"
ACTION_CONTROLLER_CHECK_ID = "presentation_action_controller_tests"
DEFAULT_CONTROLLER_PATTERN = (
    r"class\s+(?P<class_name>[A-Za-z_][A-Za-z0-9_]*ActionController)"
    r"\s+extends\s+_\$[A-Za-z_][A-Za-z0-9_]*"
)
DEFAULT_SOURCE_SCOPE = "provider_files"
DEFAULT_TEST_ROOTS = ("test",)
PROVIDER_SUFFIX = "Provider"


class ProjectMatcher:
    @staticmethod
    def check(rule: Rule, scanner: FileScanner) -> list[Violation]:
        check_id = rule.params.get("check_id", "")
        if check_id == ACTION_CONTROLLER_CHECK_ID:
            return _check_presentation_action_controller_tests(rule, scanner)
        return []

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


def _check_presentation_action_controller_tests(
    rule: Rule,
    scanner: FileScanner,
) -> list[Violation]:
    source_scope = rule.params.get("source_scope", DEFAULT_SOURCE_SCOPE)
    controller_pattern = re.compile(
        rule.params.get("controller_pattern", DEFAULT_CONTROLLER_PATTERN),
        re.MULTILINE,
    )
    test_blob = _read_test_content(
        scanner,
        tuple(rule.params.get("test_roots", DEFAULT_TEST_ROOTS)),
    )

    violations: list[Violation] = []
    for source_path, rel_path in scanner.resolve_scope(source_scope):
        content = source_path.read_text(encoding=UTF8_ENCODING)
        for match in controller_pattern.finditer(content):
            class_name = match.group("class_name")
            provider_name = f"{_lower_first(class_name)}{PROVIDER_SUFFIX}"
            if provider_name in test_blob:
                continue

            violations.append(
                Violation(
                    rule_id=rule.id,
                    code=rule.message_code or rule.id,
                    family=rule.family,
                    severity=rule.severity,
                    confidence=rule.confidence,
                    impact=rule.impact,
                    file_path=rel_path,
                    line_number=content[: match.start()].count("\n") + 1,
                    symbol=provider_name,
                    message=rule.description,
                    message_params={
                        "controller_class": class_name,
                        "provider_name": provider_name,
                    },
                )
            )

    return violations


def _read_test_content(scanner: FileScanner, test_roots: tuple[str, ...]) -> str:
    contents: list[str] = []
    for test_root in test_roots:
        root = scanner.root / test_root
        if not root.exists():
            continue
        for test_file in sorted(root.rglob("*_test.dart")):
            try:
                contents.append(test_file.read_text(encoding=UTF8_ENCODING))
            except (OSError, UnicodeDecodeError):
                continue
    return "\n".join(contents)


def _lower_first(value: str) -> str:
    if not value:
        return value
    return f"{value[0].lower()}{value[1:]}"
