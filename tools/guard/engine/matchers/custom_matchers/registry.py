from __future__ import annotations

from .provider_generated_pairing_matcher import check_provider_generated_pairing
from ...models import Rule
from ...models import Violation

CUSTOM_CHECK_HANDLERS = {
    "provider_generated_pairing": check_provider_generated_pairing,
}


def run_custom_check(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation] | None:
    check_id = str(rule.params.get("check_id", ""))
    handler = CUSTOM_CHECK_HANDLERS.get(check_id)
    if handler is None:
        return None
    return handler(rule, rel_path, lines)
