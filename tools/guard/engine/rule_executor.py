from __future__ import annotations

from pathlib import Path

from .constants import HANDLER_MODE_PROJECT
from .file_scanner import FileScanner
from .message_catalog import MessageCatalog
from .models import Rule
from .models import Violation
from .rule_registry import get_rule_handler


class RuleExecutor:
    def __init__(self, scanner: FileScanner, catalog: MessageCatalog):
        self.scanner = scanner
        self.catalog = catalog

    def execute(self, rule: Rule, files: list[tuple[Path, str]]) -> list[Violation]:
        handler_spec = get_rule_handler(rule.type)
        if handler_spec is None:
            return []

        if handler_spec.mode == HANDLER_MODE_PROJECT:
            project_handler = handler_spec.handler
            raw_violations = project_handler(rule, self.scanner)
            return self._decorate_violations(rule, raw_violations)

        violations: list[Violation] = []
        for abs_path, rel_path in files:
            lines = FileScanner.read_file(abs_path)
            file_handler = handler_spec.handler
            violations.extend(file_handler(rule, rel_path, lines))
        return self._decorate_violations(rule, violations)

    def _decorate_violations(
        self,
        rule: Rule,
        raw_violations: list[Violation],
    ) -> list[Violation]:
        for violation in raw_violations:
            violation.fix_hint_code = violation.fix_hint_code or rule.fix_hint_code
            violation.docs_url = violation.docs_url or rule.docs.url
            violation.autofix_available = rule.meta.auto_fixable

            violation.suggestion = violation.suggestion or rule.suggestion
            if not violation.suggestion and violation.fix_hint_code:
                violation.suggestion = self.catalog.resolve_fix_hint(
                    violation.fix_hint_code,
                )

            if rule.message_code:
                params = {**rule.message_params, **violation.message_params}
                resolved = self.catalog.resolve(rule.message_code, params)
                if resolved != rule.message_code:
                    violation.message = resolved

            if not violation.message:
                violation.message = rule.description

        return raw_violations
