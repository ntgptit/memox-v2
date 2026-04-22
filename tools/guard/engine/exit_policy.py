from __future__ import annotations

from .constants import DEFAULT_ENVIRONMENT
from .constants import DEFAULT_MAX_WARNINGS
from .constants import KEY_EXIT_POLICY
from .constants import KEY_FAIL_ON
from .constants import KEY_MAX_WARNINGS
from .constants import KEY_REQUIRED_RULES
from .models import GuardResult
from .models import Severity

DEFAULT_FAIL_ON = (Severity.ERROR.value, Severity.CRITICAL.value)


class ExitPolicy:
    def __init__(self, config: dict, environment: str = DEFAULT_ENVIRONMENT):
        exit_policy = config.get(KEY_EXIT_POLICY, {})
        self.env_config = exit_policy.get(
            environment,
            exit_policy.get(DEFAULT_ENVIRONMENT, {}),
        )
        self.required_rules = exit_policy.get(KEY_REQUIRED_RULES, [])

    def should_fail(self, results: list[GuardResult]) -> bool:
        for rule_id in self.required_rules:
            for result in results:
                if result.rule_id == rule_id and result.violation_count > 0:
                    return True

        fail_on = {
            Severity(value)
            for value in self.env_config.get(KEY_FAIL_ON, DEFAULT_FAIL_ON)
        }
        for result in results:
            for violation in result.violations:
                if violation.severity in fail_on:
                    return True

        max_warnings = self.env_config.get(KEY_MAX_WARNINGS, DEFAULT_MAX_WARNINGS)
        if max_warnings >= 0:
            total_warnings = sum(result.warning_count for result in results)
            if total_warnings > max_warnings:
                return True

        return False
