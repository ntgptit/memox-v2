from __future__ import annotations

import re

from ..constants import EMPTY
from ..constants import KEY_FORBIDDEN
from ..constants import KEY_FORBIDDEN_EXACT
from ..constants import KEY_LEVEL
from ..constants import KEY_MIN_COUNT
from ..constants import KEY_PATTERN
from ..constants import KEY_PATTERNS
from ..constants import KEY_REQUIRED_ANY
from ..constants import KEY_SKIP_COMMENTS
from ..models import Rule
from ..models import Violation

FILE_LEVEL = "file"
PATH_LEVEL = "path"
UTF8_BOM = "\ufeff"
COMMENT_PREFIXES = ("//", "///", "/*", "*")


class TextMatcher:
    @staticmethod
    def find_forbidden_patterns(
        rule: Rule,
        rel_path: str,
        lines: list[str],
    ) -> list[Violation]:
        patterns = [re.compile(pattern) for pattern in rule.params.get(KEY_PATTERNS, [])]
        skip_comments = rule.params.get(KEY_SKIP_COMMENTS, True)
        violations: list[Violation] = []

        for index, line in enumerate(lines):
            if skip_comments and _is_comment(line):
                continue
            for pattern in patterns:
                if pattern.search(line):
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
                            symbol=pattern.pattern,
                            message=rule.description,
                            message_params={"pattern": pattern.pattern},
                        )
                    )
                    break

        return violations

    @staticmethod
    def find_forbidden_tokens(
        rule: Rule,
        rel_path: str,
        lines: list[str],
    ) -> list[Violation]:
        tokens = rule.params.get(KEY_FORBIDDEN, [])
        exact = rule.params.get(KEY_FORBIDDEN_EXACT, False)
        skip_comments = rule.params.get(KEY_SKIP_COMMENTS, True)
        compiled = None

        if exact:
            compiled = {
                token: re.compile(r"(?<![A-Za-z0-9_])" + re.escape(token))
                for token in tokens
            }

        violations: list[Violation] = []
        for index, line in enumerate(lines):
            if skip_comments and _is_comment(line):
                continue

            for token in tokens:
                if exact and compiled:
                    matched = compiled[token].search(line) is not None
                else:
                    matched = token in line

                if matched:
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
                            symbol=token,
                            message=rule.description,
                            message_params={"forbidden": token},
                        )
                    )
                    break

        return violations

    @staticmethod
    def find_missing_any_token(
        rule: Rule,
        rel_path: str,
        lines: list[str],
    ) -> list[Violation]:
        required_any = rule.params.get(KEY_REQUIRED_ANY, [])
        if not required_any:
            return []

        content = "\n".join(lines)
        if any(token in content for token in required_any):
            return []

        return [
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                message=rule.description,
                message_params={KEY_REQUIRED_ANY: ", ".join(required_any)},
            )
        ]

    @staticmethod
    def find_missing_patterns(
        rule: Rule,
        rel_path: str,
        lines: list[str],
    ) -> list[Violation]:
        content = "\n".join(lines)
        patterns = rule.params.get(KEY_PATTERNS, [])
        min_count = rule.params.get(KEY_MIN_COUNT, 1)
        missing = [
            pattern
            for pattern in patterns
            if len(re.findall(pattern, content)) < min_count
        ]
        if not missing:
            return []

        return [
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                message=rule.description,
                message_params={"missing_patterns": ", ".join(missing)},
            )
        ]

    @staticmethod
    def check_naming(rule: Rule, rel_path: str) -> list[Violation]:
        from pathlib import PurePosixPath

        level = rule.params.get(KEY_LEVEL, FILE_LEVEL)
        pattern_source = rule.params.get(KEY_PATTERN, EMPTY)
        pattern = re.compile(pattern_source)
        name = PurePosixPath(rel_path).name
        target = rel_path if level == PATH_LEVEL else name

        if not pattern.match(target):
            message_params = {"pattern": pattern_source}
            if level == PATH_LEVEL:
                message_params["path"] = rel_path
            else:
                message_params["file_name"] = name

            return [
                Violation(
                    rule_id=rule.id,
                    code=rule.message_code or rule.id,
                    family=rule.family,
                    severity=rule.severity,
                    confidence=rule.confidence,
                    impact=rule.impact,
                    file_path=rel_path,
                    symbol=target,
                    message=rule.description,
                    message_params=message_params,
                )
            ]
        return []


def _is_comment(line: str) -> bool:
    stripped = line.replace(UTF8_BOM, EMPTY).strip()
    return any(stripped.startswith(prefix) for prefix in COMMENT_PREFIXES)
