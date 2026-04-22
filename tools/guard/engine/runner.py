from __future__ import annotations

import time
from pathlib import Path

from .baseline import BaselineManager
from .config_loader import ConfigLoader
from .constants import BASELINE_FILE_NAME
from .constants import COST_HIGH
from .constants import COST_ORDER
from .constants import DEFAULT_LOCALE
from .constants import KEY_EXCLUDE_RULES
from .constants import KEY_FAMILIES
from .constants import KEY_MAX_COST
from .constants import KEY_PROFILES
from .constants import KEY_SCOPES
from .constants import MESSAGES_FILE_NAME
from .constants import SUPPRESSIONS_FILE_NAME
from .file_scanner import FileScanner
from .message_catalog import MessageCatalog
from .models import GuardResult
from .rule_executor import RuleExecutor
from .suppression import SuppressionChecker


class Runner:
    def __init__(
        self,
        policy_dir: Path,
        project_root: Path,
        locale: str = DEFAULT_LOCALE,
    ):
        loader = ConfigLoader(policy_dir)
        self.config, self.all_rules, self.warnings = loader.load()
        self.scanner = FileScanner(project_root, self.config.get(KEY_SCOPES, {}))
        self.catalog = MessageCatalog(policy_dir / MESSAGES_FILE_NAME, locale)
        self.suppression = SuppressionChecker(policy_dir / SUPPRESSIONS_FILE_NAME)
        self.baseline = BaselineManager(policy_dir / BASELINE_FILE_NAME)
        self.executor = RuleExecutor(self.scanner, self.catalog)

    def run(
        self,
        family: str | None = None,
        rule_ids: list[str] | None = None,
        scope: str | None = None,
        max_cost: str = COST_HIGH,
        profile: str | None = None,
        baseline_diff: bool = False,
    ) -> list[GuardResult]:
        rules = [rule for rule in self.all_rules if rule.enabled]

        if profile:
            profile_config = self.config.get(KEY_PROFILES, {}).get(profile, {})
            if profile_config:
                families = profile_config.get(KEY_FAMILIES, [])
                rules = [rule for rule in rules if rule.family in families]
                max_cost = profile_config.get(KEY_MAX_COST, max_cost)
                excluded_rules = profile_config.get(KEY_EXCLUDE_RULES, [])
                rules = [rule for rule in rules if rule.id not in excluded_rules]

        if family:
            rules = [rule for rule in rules if rule.family == family]
        if rule_ids:
            rules = [rule for rule in rules if rule.id in rule_ids]

        rules = [
            rule
            for rule in rules
            if COST_ORDER.get(rule.meta.cost, 0) <= COST_ORDER.get(max_cost, 2)
        ]

        results: list[GuardResult] = []
        for rule in rules:
            effective_scope = scope or rule.scope
            files = self.scanner.resolve_scope(effective_scope)
            files = self.scanner.filter_by_targets(files, rule.targets, rule.exclude)

            started = time.perf_counter()
            violations = self.executor.execute(rule, files)

            filtered: list = []
            line_cache: dict[str, list[str]] = {}
            for violation in violations:
                if self.suppression.is_suppressed(violation.rule_id, violation.file_path):
                    continue

                if violation.file_path not in line_cache:
                    absolute_path = next(
                        (
                            candidate_abs
                            for candidate_abs, candidate_rel in files
                            if candidate_rel == violation.file_path
                        ),
                        None,
                    )
                    line_cache[violation.file_path] = FileScanner.read_file(absolute_path)

                if self.suppression.check_inline(
                    violation.rule_id,
                    line_cache[violation.file_path],
                    violation.line_number,
                ):
                    continue

                filtered.append(violation)

            duration_ms = (time.perf_counter() - started) * 1000
            results.append(
                GuardResult(
                    rule_id=rule.id,
                    rule_name=rule.name,
                    family=rule.family,
                    description=rule.description,
                    severity=rule.severity,
                    violations=filtered,
                    files_scanned=len(files),
                    duration_ms=duration_ms,
                )
            )

        if baseline_diff:
            results = self.baseline.filter_new_only(results)

        results.sort(key=lambda item: (item.family, item.rule_id))
        return results
