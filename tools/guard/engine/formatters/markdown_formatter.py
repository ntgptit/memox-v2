from __future__ import annotations

from ..constants import EMPTY
from ..models import GuardResult
from .base_formatter import BaseFormatter

REPORT_TITLE = "# Guard Report"
RULES_TEMPLATE = "- Rules: {count}"
VIOLATIONS_TEMPLATE = "- Violations: {count}"
WARNINGS_TEMPLATE = "- Warnings: {count}"
ERRORS_TEMPLATE = "- Errors: {count}"
RESULT_HEADER_TEMPLATE = "## `{rule_id}` [{severity}] ({family})"
FILES_SCANNED_TEMPLATE = "- Files scanned: {count}"
RULE_VIOLATIONS_TEMPLATE = "- Violations: {count}"
DURATION_TEMPLATE = "- Duration: {duration:.2f} ms"
VIOLATION_DETAIL_TEMPLATE = "- `{location}` {message}"
SUGGESTION_SUFFIX_TEMPLATE = " Suggestion: {suggestion}"
TRAILING_NEWLINE = "\n"


class MarkdownFormatter(BaseFormatter):
    def format(self, results: list[GuardResult], verbose: bool = False) -> str:
        lines = [
            REPORT_TITLE,
            EMPTY,
            RULES_TEMPLATE.format(count=len(results)),
            VIOLATIONS_TEMPLATE.format(
                count=sum(result.violation_count for result in results)
            ),
            WARNINGS_TEMPLATE.format(
                count=sum(result.warning_count for result in results)
            ),
            ERRORS_TEMPLATE.format(count=sum(result.error_count for result in results)),
            EMPTY,
        ]

        for result in results:
            lines.append(
                RESULT_HEADER_TEMPLATE.format(
                    rule_id=result.rule_id,
                    severity=result.severity.value,
                    family=result.family,
                )
            )
            if result.description:
                lines.append(result.description)
            lines.append(FILES_SCANNED_TEMPLATE.format(count=result.files_scanned))
            lines.append(RULE_VIOLATIONS_TEMPLATE.format(count=result.violation_count))
            lines.append(DURATION_TEMPLATE.format(duration=result.duration_ms))

            if result.violations:
                lines.append(EMPTY)
                for violation in result.violations:
                    detail = VIOLATION_DETAIL_TEMPLATE.format(
                        location=violation.location,
                        message=violation.message,
                    )
                    if verbose and violation.suggestion:
                        detail += SUGGESTION_SUFFIX_TEMPLATE.format(
                            suggestion=violation.suggestion
                        )
                    lines.append(detail)
            lines.append(EMPTY)

        return "\n".join(lines).rstrip() + TRAILING_NEWLINE
