from __future__ import annotations

import re

from ..constants import KEY_CLASS_PATTERN
from ..constants import KEY_FORBIDDEN_IMPORT_PATHS
from ..constants import KEY_FORBIDDEN_IMPORTS
from ..constants import KEY_IMPORT_PATTERN
from ..constants import KEY_LAYER_DETECTION_PATTERN
from ..constants import KEY_METHOD_PATTERN
from ..constants import KEY_REQUIRED_MEMBERS
from ..models import Rule
from ..models import Violation

DEFAULT_IMPORT_PATTERN = r"import\s+'[^']*/(app|core|data|domain|presentation)/"
DIRECT_IMPORT_PATTERN = r"^\s*import\s+'(?P<import_path>[^']+)';"
CONTENT_SEPARATOR = "\n"
OPENING_BRACE = "{"
CLOSING_BRACE = "}"


class StructuralMatcher:
    @staticmethod
    def check(rule: Rule, rel_path: str, lines: list[str]) -> list[Violation]:
        check_id = rule.params.get("check_id", "")
        if check_id == "cross_feature_presentation_imports":
            return _check_cross_feature_presentation_imports(rule, rel_path, lines)
        if check_id == "forbidden_import_paths":
            return _check_forbidden_import_paths(rule, rel_path, lines)
        return []

    @staticmethod
    def check_import_direction(
        rule: Rule,
        rel_path: str,
        lines: list[str],
    ) -> list[Violation]:
        layer_re = re.compile(rule.params.get(KEY_LAYER_DETECTION_PATTERN, ""))
        forbidden_map = rule.params.get(KEY_FORBIDDEN_IMPORTS, {})

        match = layer_re.search(rel_path)
        if not match:
            return []

        current_layer = match.group(1)
        forbidden = forbidden_map.get(current_layer, [])
        if not forbidden:
            return []

        import_pattern = re.compile(
            rule.params.get(
                KEY_IMPORT_PATTERN,
                DEFAULT_IMPORT_PATTERN,
            )
        )

        violations: list[Violation] = []
        for index, line in enumerate(lines):
            match_import = import_pattern.search(line)
            if not match_import:
                continue
            imported_layer = match_import.group(1)
            if imported_layer in forbidden:
                violations.append(
                    Violation(
                        rule_id=rule.id,
                        code=rule.message_code or rule.id,
                        family=rule.family,
                        severity=rule.severity,
                        confidence=rule.confidence,
                        impact=rule.impact,
                        file_path=rel_path,
                        line_number=index + 1,
                        symbol=imported_layer,
                        message=rule.description,
                        message_params={
                            "current_layer": current_layer,
                            "imported_layer": imported_layer,
                        },
                    )
                )

        return violations

    @staticmethod
    def check_class_members(
        rule: Rule,
        rel_path: str,
        lines: list[str],
    ) -> list[Violation]:
        class_pattern = re.compile(rule.params.get(KEY_CLASS_PATTERN, ""))
        required_members = rule.params.get(KEY_REQUIRED_MEMBERS, [])
        max_lines = rule.params.get("max_lines")
        method_pattern_str = rule.params.get(KEY_METHOD_PATTERN)

        class_start = -1
        for index, line in enumerate(lines):
            if class_pattern.search(line):
                class_start = index
                break

        if class_start < 0:
            return []

        class_body = _extract_block(lines, class_start)
        class_content = CONTENT_SEPARATOR.join(class_body)
        violations: list[Violation] = []

        for member_pattern in required_members:
            if not re.search(member_pattern, class_content):
                violations.append(
                    Violation(
                        rule_id=rule.id,
                        code=rule.message_code or rule.id,
                        family=rule.family,
                        severity=rule.severity,
                        confidence=rule.confidence,
                        impact=rule.impact,
                        file_path=rel_path,
                        line_number=class_start + 1,
                        message=rule.description,
                        message_params={"member_pattern": member_pattern},
                    )
                )

        if max_lines and method_pattern_str:
            method_pattern = re.compile(method_pattern_str)
            for index, line in enumerate(class_body):
                if method_pattern.search(line):
                    block_length = _measure_block_length(class_body, index)
                    if block_length > max_lines:
                        violations.append(
                            Violation(
                                rule_id=rule.id,
                                code=rule.message_code or rule.id,
                                family=rule.family,
                                severity=rule.severity,
                                confidence=rule.confidence,
                                impact=rule.impact,
                                file_path=rel_path,
                                line_number=class_start + index + 1,
                                message=rule.description,
                                message_params={
                                    "actual_lines": str(block_length),
                                    "max_lines": str(max_lines),
                                },
                            )
                        )

        return violations


def _check_cross_feature_presentation_imports(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    current_feature_pattern = re.compile(
        rule.params.get(
            "current_feature_pattern",
            r"^lib/presentation/features/(?P<feature>[a-z0-9_]+)/",
        )
    )
    import_pattern = re.compile(
        rule.params.get(
            "import_pattern",
            r"^import\s+'package:memox/presentation/features/(?P<feature>[a-z0-9_]+)/",
        )
    )

    current_feature_match = current_feature_pattern.search(rel_path)
    if current_feature_match is None:
        return []

    current_feature = current_feature_match.group("feature")
    violations: list[Violation] = []

    for index, line in enumerate(lines):
        import_match = import_pattern.search(line)
        if import_match is None:
            continue

        imported_feature = import_match.group("feature")
        if imported_feature == current_feature:
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
                line_number=index + 1,
                symbol=line.strip(),
                message=rule.description,
                message_params={
                    "current_feature": current_feature,
                    "imported_feature": imported_feature,
                },
            )
        )

    return violations


def _check_forbidden_import_paths(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    import_pattern = re.compile(
        rule.params.get(
            KEY_IMPORT_PATTERN,
            DIRECT_IMPORT_PATTERN,
        )
    )
    forbidden_import_paths = rule.params.get(KEY_FORBIDDEN_IMPORT_PATHS, [])
    if not forbidden_import_paths:
        return []

    violations: list[Violation] = []

    for index, line in enumerate(lines):
        import_match = import_pattern.search(line)
        if import_match is None:
            continue

        import_path = import_match.groupdict().get("import_path", "")
        if not import_path:
            continue

        forbidden_import = next(
            (
                forbidden_path
                for forbidden_path in forbidden_import_paths
                if _matches_forbidden_import_path(import_path, forbidden_path)
            ),
            None,
        )
        if forbidden_import is None:
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
                line_number=index + 1,
                symbol=import_path,
                message=rule.description,
                message_params={
                    "forbidden_import": forbidden_import,
                    "import_path": import_path,
                },
            )
        )

    return violations


def _matches_forbidden_import_path(import_path: str, forbidden_path: str) -> bool:
    if forbidden_path.endswith("/"):
        return forbidden_path in import_path
    return import_path.endswith(forbidden_path)


def _extract_block(lines: list[str], start: int) -> list[str]:
    brace_count = 0
    found_opening = False

    for index in range(start, len(lines)):
        brace_count += lines[index].count(OPENING_BRACE) - lines[index].count(
            CLOSING_BRACE
        )
        if OPENING_BRACE in lines[index]:
            found_opening = True
        if found_opening and brace_count <= 0:
            return lines[start : index + 1]

    return lines[start:]


def _measure_block_length(lines: list[str], start: int) -> int:
    brace_count = 0
    found_opening = False

    for index in range(start, len(lines)):
        brace_count += lines[index].count(OPENING_BRACE) - lines[index].count(
            CLOSING_BRACE
        )
        if OPENING_BRACE in lines[index]:
            found_opening = True
        if found_opening and brace_count <= 0:
            return index - start + 1

    return len(lines) - start
