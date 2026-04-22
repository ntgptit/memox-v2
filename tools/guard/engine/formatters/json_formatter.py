from __future__ import annotations

import json

from ..constants import KEY_AUTOFIX_AVAILABLE
from ..constants import KEY_CODE
from ..constants import KEY_COLUMN
from ..constants import KEY_CONFIDENCE
from ..constants import KEY_DESCRIPTION
from ..constants import KEY_DOCS_URL
from ..constants import KEY_DURATION_MS
from ..constants import KEY_ERROR_COUNT
from ..constants import KEY_ERRORS
from ..constants import KEY_FAMILY
from ..constants import KEY_FILE_PATH
from ..constants import KEY_FILES_SCANNED
from ..constants import KEY_FIX_HINT_CODE
from ..constants import KEY_IMPACT
from ..constants import KEY_LINE_NUMBER
from ..constants import KEY_MESSAGE
from ..constants import KEY_MESSAGE_PARAMS
from ..constants import KEY_RESULTS
from ..constants import KEY_RULE_ID
from ..constants import KEY_RULE_NAME
from ..constants import KEY_SEVERITY
from ..constants import KEY_SUGGESTION
from ..constants import KEY_SUMMARY
from ..constants import KEY_SYMBOL
from ..constants import KEY_VIOLATION_COUNT
from ..constants import KEY_VIOLATIONS
from ..constants import KEY_VIOLATIONS_PREVIEW
from ..constants import KEY_WARNING_COUNT
from ..constants import KEY_WARNINGS
from ..constants import KEY_RULES
from ..models import GuardResult
from ..models import Violation
from .base_formatter import BaseFormatter

JSON_INDENT = 2


class JsonFormatter(BaseFormatter):
    def format(self, results: list[GuardResult], verbose: bool = False) -> str:
        payload = {
            KEY_SUMMARY: {
                KEY_RULES: len(results),
                KEY_VIOLATIONS: sum(result.violation_count for result in results),
                KEY_WARNINGS: sum(result.warning_count for result in results),
                KEY_ERRORS: sum(result.error_count for result in results),
            },
            KEY_RESULTS: [self._result_record(result, verbose) for result in results],
        }
        return json.dumps(payload, indent=JSON_INDENT, ensure_ascii=False)

    def _result_record(self, result: GuardResult, verbose: bool) -> dict:
        record = {
            KEY_RULE_ID: result.rule_id,
            KEY_RULE_NAME: result.rule_name,
            KEY_FAMILY: result.family,
            KEY_SEVERITY: result.severity.value,
            KEY_DESCRIPTION: result.description,
            KEY_VIOLATION_COUNT: result.violation_count,
            KEY_WARNING_COUNT: result.warning_count,
            KEY_ERROR_COUNT: result.error_count,
            KEY_FILES_SCANNED: result.files_scanned,
            KEY_DURATION_MS: round(result.duration_ms, 2),
            KEY_VIOLATIONS: [self._violation_record(item) for item in result.violations],
        }
        if verbose:
            record[KEY_VIOLATIONS_PREVIEW] = [
                item.location for item in result.violations[:10]
            ]
        return record

    @staticmethod
    def _violation_record(violation: Violation) -> dict:
        return {
            KEY_RULE_ID: violation.rule_id,
            KEY_CODE: violation.code,
            KEY_FAMILY: violation.family,
            KEY_SEVERITY: violation.severity.value,
            KEY_CONFIDENCE: violation.confidence.value,
            KEY_IMPACT: violation.impact.value,
            KEY_FILE_PATH: violation.file_path,
            KEY_LINE_NUMBER: violation.line_number,
            KEY_COLUMN: violation.column,
            KEY_SYMBOL: violation.symbol,
            KEY_MESSAGE: violation.message,
            KEY_MESSAGE_PARAMS: violation.message_params,
            KEY_SUGGESTION: violation.suggestion,
            KEY_FIX_HINT_CODE: violation.fix_hint_code,
            KEY_AUTOFIX_AVAILABLE: violation.autofix_available,
            KEY_DOCS_URL: violation.docs_url,
        }
