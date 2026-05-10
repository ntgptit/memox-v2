from __future__ import annotations

from pathlib import Path
import re

from ...models import Rule
from ...models import Violation

COMMENT_PREFIXES = ("//", "///", "/*", "*")
ROOT_MARKERS = (".git", "pubspec.yaml")


def check_provider_generated_pairing(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    annotation_pattern = re.compile(
        rule.params.get("annotation_pattern", r"^\s*@(?:riverpod|Riverpod)\b")
    )
    workspace_root = _find_workspace_root()
    rel_file_path = Path(rel_path)
    expected_part = f"part '{rel_file_path.stem}.g.dart';"
    expected_generated_path = rel_file_path.with_name(f"{rel_file_path.stem}.g.dart")

    has_annotation = any(
        annotation_pattern.search(line) for line in lines if not _is_comment(line)
    )
    if not has_annotation:
        return []

    if not any(expected_part in line for line in lines):
        return [
            _make_violation(
                rule,
                rel_path,
                expected_part,
                expected_generated_path,
            )
        ]

    if not (workspace_root / expected_generated_path).exists():
        return [
            _make_violation(
                rule,
                rel_path,
                expected_generated_path.name,
                expected_generated_path,
            )
        ]

    return []


def _make_violation(
    rule: Rule,
    rel_path: str,
    symbol: str,
    expected_generated_path: Path,
) -> Violation:
    expected_part = f"part '{expected_generated_path.stem}.g.dart';"
    return Violation(
        rule_id=rule.id,
        code=rule.message_code or rule.id,
        family=rule.family,
        severity=rule.severity,
        confidence=rule.confidence,
        impact=rule.impact,
        file_path=rel_path,
        line_number=1,
        symbol=symbol,
        message=rule.description,
        message_params={
            "expected_part": expected_part,
            "expected_generated_file": expected_generated_path.as_posix(),
        },
    )


def _is_comment(line: str) -> bool:
    stripped = line.strip()
    return any(stripped.startswith(prefix) for prefix in COMMENT_PREFIXES)


def _find_workspace_root() -> Path:
    current = Path.cwd().resolve()
    while True:
        if any((current / marker).exists() for marker in ROOT_MARKERS):
            return current
        if current.parent == current:
            return Path.cwd().resolve()
        current = current.parent
