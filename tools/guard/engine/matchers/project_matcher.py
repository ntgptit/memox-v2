from __future__ import annotations

import fnmatch
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
DECISION_TABLE_CASE_CHECK_ID = "decision_table_case_coverage"
DECISION_TABLE_SOURCE_CHECK_ID = "decision_table_source_coverage"
LAZY_LIST_RENDERING_CHECK_ID = "lazy_list_rendering"
DEFAULT_CONTROLLER_PATTERN = (
    r"class\s+(?P<class_name>[A-Za-z_][A-Za-z0-9_]*ActionController)"
    r"\s+extends\s+_\$[A-Za-z_][A-Za-z0-9_]*"
)
DEFAULT_SOURCE_SCOPE = "provider_files"
DEFAULT_TEST_ROOTS = ("test",)
PROVIDER_SUFFIX = "Provider"
DEFAULT_LAZY_LIST_SOURCE_SCOPE = "feature_ui"
DEFAULT_LAZY_LIST_CANDIDATE_PATTERNS = (
    "lib/presentation/features/**/screens/*_screen.dart",
    "lib/presentation/features/**/widgets/*list*.dart",
    "lib/presentation/features/**/widgets/**/*list*.dart",
    "lib/presentation/features/**/widgets/*tree_section.dart",
    "lib/presentation/features/**/widgets/**/*tree_section.dart",
    "lib/presentation/features/**/widgets/*preview_section.dart",
    "lib/presentation/features/**/widgets/**/*preview_section.dart",
    "lib/presentation/features/**/widgets/*reorder_section.dart",
    "lib/presentation/features/**/widgets/**/*reorder_section.dart",
)
DEFAULT_LAZY_LIST_EXCLUDE_PATTERNS = (
    "**/*_skeleton.dart",
)
EAGER_CHILDREN_PATTERN = re.compile(
    r"\bchildren\s*:\s*(?:const\s*)?\[[\s\S]*?(?:\bfor\s*\(|\.\s*map\s*\()",
    re.MULTILINE,
)


class ProjectMatcher:
    @staticmethod
    def check(rule: Rule, scanner: FileScanner) -> list[Violation]:
        check_id = rule.params.get("check_id", "")
        if check_id == ACTION_CONTROLLER_CHECK_ID:
            return _check_presentation_action_controller_tests(rule, scanner)
        if check_id == DECISION_TABLE_SOURCE_CHECK_ID:
            from .decision_table_matcher import check_source_coverage

            return check_source_coverage(rule, scanner)
        if check_id == DECISION_TABLE_CASE_CHECK_ID:
            from .decision_table_matcher import check_case_coverage

            return check_case_coverage(rule, scanner)
        if check_id == LAZY_LIST_RENDERING_CHECK_ID:
            return _check_lazy_list_rendering(rule, scanner)
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


def _check_lazy_list_rendering(
    rule: Rule,
    scanner: FileScanner,
) -> list[Violation]:
    source_scope = rule.params.get(
        "source_scope",
        DEFAULT_LAZY_LIST_SOURCE_SCOPE,
    )
    candidate_patterns = tuple(
        rule.params.get(
            "candidate_path_patterns",
            DEFAULT_LAZY_LIST_CANDIDATE_PATTERNS,
        )
    )
    exclude_patterns = tuple(
        rule.params.get(
            "exclude_path_patterns",
            DEFAULT_LAZY_LIST_EXCLUDE_PATTERNS,
        )
    )

    violations: list[Violation] = []
    for source_path, rel_path in scanner.resolve_scope(source_scope):
        if not _matches_any(rel_path, candidate_patterns):
            continue
        if _matches_any(rel_path, exclude_patterns):
            continue

        content = source_path.read_text(encoding=UTF8_ENCODING)
        for constructor in ("ListView", "Column"):
            violations.extend(
                _find_eager_dynamic_list_violations(
                    rule=rule,
                    rel_path=rel_path,
                    content=content,
                    constructor=constructor,
                )
            )

    return violations


def _find_eager_dynamic_list_violations(
    *,
    rule: Rule,
    rel_path: str,
    content: str,
    constructor: str,
) -> list[Violation]:
    violations: list[Violation] = []
    for start, block in _constructor_blocks(content, constructor):
        if not EAGER_CHILDREN_PATTERN.search(block):
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
                line_number=content[:start].count("\n") + 1,
                symbol=constructor,
                message=rule.description,
                message_params={
                    "detail": (
                        f"`{constructor}` builds dynamic list rows eagerly. "
                        "Use `CustomScrollView` with `SliverList.builder`/"
                        "`SliverList.separated`, or a bounded builder-based "
                        "list for nested panels."
                    )
                },
            )
        )

    return violations


def _constructor_blocks(content: str, constructor: str) -> list[tuple[int, str]]:
    blocks: list[tuple[int, str]] = []
    pattern = re.compile(rf"\b{re.escape(constructor)}\s*\(")
    for match in pattern.finditer(content):
        open_paren = content.find("(", match.start())
        close_paren = _find_matching_paren(content, open_paren)
        if close_paren == -1:
            continue
        blocks.append((match.start(), content[match.start() : close_paren + 1]))
    return blocks


def _find_matching_paren(content: str, open_paren: int) -> int:
    if open_paren < 0:
        return -1

    depth = 0
    quote: str | None = None
    in_line_comment = False
    in_block_comment = False
    index = open_paren
    while index < len(content):
        char = content[index]
        next_char = content[index + 1] if index + 1 < len(content) else ""

        if in_line_comment:
            if char == "\n":
                in_line_comment = False
            index += 1
            continue
        if in_block_comment:
            if char == "*" and next_char == "/":
                in_block_comment = False
                index += 2
                continue
            index += 1
            continue
        if quote is not None:
            if char == "\\":
                index += 2
                continue
            if char == quote:
                quote = None
            index += 1
            continue

        if char == "/" and next_char == "/":
            in_line_comment = True
            index += 2
            continue
        if char == "/" and next_char == "*":
            in_block_comment = True
            index += 2
            continue
        if char in ("'", '"'):
            quote = char
            index += 1
            continue
        if char == "(":
            depth += 1
        if char == ")":
            depth -= 1
            if depth == 0:
                return index
        index += 1

    return -1


def _matches_any(rel_path: str, patterns: tuple[str, ...]) -> bool:
    return any(fnmatch.fnmatch(rel_path, pattern) for pattern in patterns)


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
