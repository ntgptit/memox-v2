from __future__ import annotations

from ..constants import EMPTY
from ..constants import STATUS_FAIL
from ..constants import STATUS_PASS
from ..models import GuardResult
from .base_formatter import BaseFormatter

REPORT_TITLE = "Guard Report"
RULES_LABEL = "Rules"
VIOLATIONS_LABEL = "Violations"
WARNINGS_LABEL = "Warnings"
ERRORS_LABEL = "Errors"
DESCRIPTION_PREFIX = "  "
VIOLATION_PREFIX = "  - "
HINT_PREFIX = "    hint: "
RESULT_TEMPLATE = (
    "[{status}] {rule_id} [{severity}] family={family} "
    "scanned={files_scanned} violations={violations}"
)
DESCRIPTION_TEMPLATE = f"{DESCRIPTION_PREFIX}{{description}}"
VIOLATION_TEMPLATE = f"{VIOLATION_PREFIX}{{location}}: {{message}}"
HINT_TEMPLATE = f"{HINT_PREFIX}{{suggestion}}"
REMAINING_TEMPLATE = "  ... and {remaining} more"
TRAILING_NEWLINE = "\n"


class TerminalFormatter(BaseFormatter):
    def format(self, results: list[GuardResult], verbose: bool = False) -> str:
        lines = [
            REPORT_TITLE,
            f"{RULES_LABEL}: {len(results)}",
            f"{VIOLATIONS_LABEL}: {sum(result.violation_count for result in results)}",
            f"{WARNINGS_LABEL}: {sum(result.warning_count for result in results)}",
            f"{ERRORS_LABEL}: {sum(result.error_count for result in results)}",
            EMPTY,
        ]

        for result in results:
            status = STATUS_PASS if result.violation_count == 0 else STATUS_FAIL
            lines.append(
                RESULT_TEMPLATE.format(
                    status=status,
                    rule_id=result.rule_id,
                    severity=result.severity.value,
                    family=result.family,
                    files_scanned=result.files_scanned,
                    violations=result.violation_count,
                )
            )
            if result.description:
                lines.append(
                    DESCRIPTION_TEMPLATE.format(description=result.description)
                )

            violations = result.violations if verbose else result.violations[:20]
            for violation in violations:
                message = violation.message or result.description or result.rule_name
                lines.append(
                    VIOLATION_TEMPLATE.format(
                        location=violation.location,
                        message=message,
                    )
                )
                if verbose and violation.suggestion:
                    lines.append(
                        HINT_TEMPLATE.format(suggestion=violation.suggestion)
                    )

            remaining = result.violation_count - len(violations)
            if remaining > 0:
                lines.append(REMAINING_TEMPLATE.format(remaining=remaining))
            lines.append(EMPTY)

        return "\n".join(lines).rstrip() + TRAILING_NEWLINE
