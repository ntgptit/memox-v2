from __future__ import annotations

from functools import lru_cache
from pathlib import Path
import re

from .custom_matchers import run_custom_check
from .custom_matchers.ast_rule_helpers import _collect_allowed_callback_line_indexes
from .custom_matchers.ast_rule_helpers import _collect_annotated_provider_declarations
from .custom_matchers.ast_rule_helpers import _collect_family_params_for_provider
from .custom_matchers.ast_rule_helpers import _collect_provider_resource_hits
from .custom_matchers.ast_rule_helpers import _collect_declaration_signature
from .custom_matchers.ast_rule_helpers import _declaration_has_block
from .custom_matchers.ast_rule_helpers import _extract_block
from .custom_matchers.ast_rule_helpers import _find_annotated_block_ranges
from .custom_matchers.ast_rule_helpers import _find_async_block_start
from .custom_matchers.ast_rule_helpers import _find_async_provider_missing_mounted_check
from .custom_matchers.ast_rule_helpers import _find_async_ui_missing_context_guard
from .custom_matchers.ast_rule_helpers import _find_block_ranges
from .custom_matchers.ast_rule_helpers import _find_matching_parenthesis_index
from .custom_matchers.ast_rule_helpers import _is_stable_family_param
from .custom_matchers.ast_rule_helpers import _load_project_type_index
from .custom_matchers.ast_rule_helpers import _provider_resource_has_cleanup
from .custom_matchers.ast_rule_helpers import _statement_balance_delta
from .custom_matchers.ast_rule_helpers import _statement_is_terminated
from .custom_matchers.ast_rule_helpers import _summarize_single_field_usage
from .custom_matchers.ast_rule_helpers import _should_ignore_select_opportunity
from .custom_matchers.ast_shared_utils import _collect_async_identifiers
from .custom_matchers.ast_shared_utils import _collect_unique_pattern_matches
from .custom_matchers.ast_shared_utils import _find_risky_provider_signature
from .custom_matchers.ast_shared_utils import _has_allowed_spacing_context
from .custom_matchers.ast_shared_utils import _has_async_identifier_access
from .custom_matchers.ast_shared_utils import _has_async_state_builder_usage
from .custom_matchers.ast_shared_utils import _has_async_switch_usage
from .custom_matchers.ast_shared_utils import _has_async_when_usage
from .custom_matchers.ast_shared_utils import _has_context_pattern
from .custom_matchers.ast_shared_utils import _is_comment
from .custom_matchers.ast_shared_utils import _provider_block_has_review_marker
from .custom_matchers.ast_shared_utils import _strip_strings_and_comments_preserve_layout
from ..constants import UTF8_ENCODING
from ..models import Rule
from ..models import Violation

CONTENT_SEPARATOR = "\n"
OPENING_BRACE = "{"
CLOSING_BRACE = "}"
COMMENT_PREFIXES = ("//", "///", "/*", "*")
DEFAULT_STABLE_FAMILY_SCALAR_TYPES = {
    "BigInt",
    "DateTime",
    "DateTimeRange",
    "Duration",
    "Locale",
    "String",
    "ThemeMode",
    "TimeOfDay",
    "Uri",
    "bool",
    "double",
    "int",
    "num",
}
DEFAULT_UNSTABLE_COLLECTION_TYPES = {
    "Iterable",
    "List",
    "Map",
    "Queue",
    "Set",
}
DEFAULT_ASYNC_WRAPPER_FIELDS = {
    "asData",
    "asError",
    "error",
    "hasError",
    "hasValue",
    "isLoading",
    "requireValue",
    "value",
    "valueOrNull",
}


class AstMatcher:
    """Heuristic matcher for higher-order UI rules that need block awareness."""

    @staticmethod
    def check(rule: Rule, rel_path: str, lines: list[str]) -> list[Violation]:
        custom_result = run_custom_check(rule, rel_path, lines)
        if custom_result is not None:
            return custom_result

        check_id = rule.params.get("check_id", "")
        if check_id == "theme_semantic_palette_contract":
            return _check_theme_semantic_palette_contract(rule, rel_path, lines)
        if check_id == "theme_typography_contract":
            return _check_theme_typography_contract(rule, rel_path, lines)
        if check_id == "ui_try_count":
            return _check_ui_try_count(rule, rel_path, lines)
        if check_id == "ui_async_callback_await_count":
            return _check_ui_async_callback_await_count(rule, rel_path, lines)
        if check_id == "ui_build_collection_chain":
            return _check_ui_build_collection_chain(rule, rel_path, lines)
        if check_id == "ui_build_collection_processing_lines":
            return _check_ui_build_collection_processing_lines(rule, rel_path, lines)
        if check_id == "ui_build_ref_read":
            return _check_ui_build_ref_read(rule, rel_path, lines)
        if check_id == "ui_build_navigation_side_effects":
            return _check_ui_build_navigation_side_effects(rule, rel_path, lines)
        if check_id == "ui_context_after_await":
            return _check_ui_context_after_await(rule, rel_path, lines)
        if check_id == "ui_media_query_screen_percentage":
            return _check_ui_media_query_screen_percentage(rule, rel_path, lines)
        if check_id == "ui_text_style_copywith_typography_override":
            return _check_ui_text_style_copywith_typography_override(
                rule,
                rel_path,
                lines,
            )
        if check_id == "ui_display_font_size_literals":
            return _check_ui_display_font_size_literals(rule, rel_path, lines)
        if check_id == "ui_raw_font_size_literals":
            return _check_ui_raw_font_size_literals(rule, rel_path, lines)
        if check_id == "ui_raw_spacing_literals":
            return _check_ui_raw_spacing_literals(rule, rel_path, lines)
        if check_id == "ui_raw_size_literals":
            return _check_ui_raw_size_literals(rule, rel_path, lines)
        if check_id == "ui_raw_half_alpha_with_values":
            return _check_ui_raw_half_alpha_with_values(rule, rel_path, lines)
        if check_id == "ui_raw_alpha_with_values":
            return _check_ui_raw_alpha_with_values(rule, rel_path, lines)
        if check_id == "ui_child_screen_width_threshold":
            return _check_ui_child_screen_width_threshold(rule, rel_path, lines)
        if check_id == "ui_child_remaining_width_layout_signal":
            return _check_ui_child_remaining_width_layout_signal(
                rule,
                rel_path,
                lines,
            )
        if check_id == "large_layout_responsive_signal":
            return _check_large_layout_responsive_signal(rule, rel_path, lines)
        if check_id == "ui_watch_select_opportunity":
            return _check_ui_watch_select_opportunity(rule, rel_path, lines)
        if check_id == "screen_async_value_render":
            return _check_screen_async_value_render(rule, rel_path, lines)
        if check_id == "router_redirect_purity":
            return _check_router_redirect_purity(rule, rel_path, lines)
        if check_id == "provider_resource_cleanup":
            return _check_provider_resource_cleanup(rule, rel_path, lines)
        if check_id == "provider_retry_reviewed":
            return _check_provider_retry_reviewed(rule, rel_path, lines)
        if check_id == "provider_mounted_after_await":
            return _check_provider_mounted_after_await(rule, rel_path, lines)
        if check_id == "provider_family_param_stability":
            return _check_provider_family_param_stability(rule, rel_path, lines)
        return []


def _check_theme_semantic_palette_contract(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    semantic_roles = [
        str(role)
        for role in rule.params.get(
            "semantic_roles",
            [
                "statusNew",
                "statusLearning",
                "statusReviewing",
                "statusMastered",
                "ratingAgain",
                "ratingHard",
                "ratingGood",
                "ratingEasy",
                "selfMissed",
                "selfPartial",
                "selfGotIt",
                "masteryLow",
                "masteryMid",
                "masteryHigh",
            ],
        )
    ]
    if not semantic_roles:
        return []

    if rel_path.endswith("lib/core/theme/color_schemes/custom_colors.dart"):
        return _check_custom_colors_semantic_palette(rule, rel_path, lines, semantic_roles)
    if rel_path.endswith("lib/core/theme/tokens/color_tokens.dart"):
        return _check_color_tokens_semantic_roles(rule, rel_path, lines, semantic_roles)
    if rel_path.endswith("lib/core/theme/app_theme.dart"):
        return _check_app_theme_semantic_palette_wiring(rule, rel_path, lines)

    return []


def _check_theme_typography_contract(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    if rel_path.endswith("lib/core/theme/text_themes/custom_text_styles.dart"):
        return _check_custom_text_styles_contract(rule, rel_path, lines)
    if rel_path.endswith("lib/core/theme/app_theme.dart"):
        return _check_app_theme_typography_wiring(rule, rel_path, lines)
    if rel_path.endswith("lib/core/theme/tokens/typography_tokens.dart"):
        return _check_typography_tokens_contract(rule, rel_path, lines)

    return []


def _check_custom_text_styles_contract(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = CONTENT_SEPARATOR.join(lines)
    create_signature_pattern = re.compile(
        rule.params.get(
            "create_signature_pattern",
            r"\bfactory\s+AppTextStyles\.create\s*\((?P<params>[^)]*)\)",
        ),
        re.S,
    )
    direct_google_fonts_pattern = re.compile(
        rule.params.get(
            "direct_google_fonts_pattern",
            r"\bGoogleFonts\.(?:plusJakartaSans|plusJakartaSansTextTheme)\b",
        )
    )
    derived_text_theme_usage_pattern = re.compile(
        rule.params.get(
            "derived_text_theme_usage_pattern",
            r"\btextTheme\.",
        )
    )

    violations: list[Violation] = []
    create_match = create_signature_pattern.search(content)
    if create_match is None:
        violations.append(
            _make_theme_contract_violation(
                rule,
                rel_path,
                1,
                "AppTextStyles.create",
                "`AppTextStyles.create` should exist as a semantic layer derived from `TextTheme`, but no matching factory signature was found.",
            )
        )
        return violations

    params = create_match.groupdict().get("params", "")
    signature_line = content.count("\n", 0, create_match.start()) + 1

    if "TextTheme" not in params:
        violations.append(
            _make_theme_contract_violation(
                rule,
                rel_path,
                signature_line,
                "AppTextStyles.create",
                "`AppTextStyles.create` must accept a `TextTheme` input so semantic styles derive from the base Material typography instead of forming a second independent system.",
            )
        )

    if direct_google_fonts_pattern.search(content):
        first_match = direct_google_fonts_pattern.search(content)
        line_number = content.count("\n", 0, first_match.start()) + 1 if first_match else 1
        violations.append(
            _make_theme_contract_violation(
                rule,
                rel_path,
                line_number,
                "GoogleFonts.plusJakartaSans",
                "`custom_text_styles.dart` still constructs typography directly with `GoogleFonts.plusJakartaSans`. Keep font-family construction in `AppTextTheme`, and derive `AppTextStyles` from the provided `TextTheme` instead.",
            )
        )

    if derived_text_theme_usage_pattern.search(content) is None:
        violations.append(
            _make_theme_contract_violation(
                rule,
                rel_path,
                signature_line,
                "textTheme",
                "`AppTextStyles.create` does not appear to derive any semantic styles from `TextTheme`. Keep `TextTheme` as the foundation and let `AppTextStyles` hold only truly domain/UI-specific aliases or variants.",
            )
        )

    return violations


def _check_app_theme_typography_wiring(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = CONTENT_SEPARATOR.join(lines)
    wiring_pattern = re.compile(
        rule.params.get(
            "app_theme_wiring_pattern",
            r"\bAppTextStyles\.create\s*\(\s*textTheme\s*\)",
        )
    )
    create_call_pattern = re.compile(r"\bAppTextStyles\.create\s*\(")

    if wiring_pattern.search(content):
        return []

    create_call = create_call_pattern.search(content)
    if create_call is None:
        return []

    return [
        _make_theme_contract_violation(
            rule,
            rel_path,
            content.count("\n", 0, create_call.start()) + 1,
            "AppTextStyles.create",
            "`app_theme.dart` should wire `AppTextStyles.create(textTheme)` so semantic styles derive from the built `TextTheme` instead of being created independently.",
        )
    ]


def _check_typography_tokens_contract(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    pattern = re.compile(
        rule.params.get(
            "global_step_reduction_pattern",
            r"\bglobalStepReduction\s*=\s*(?P<value>-?\d+)\s*;",
        )
    )
    max_allowed = int(rule.params.get("max_global_step_reduction", 0))

    for index, line in enumerate(lines):
        if _is_comment(line):
            continue

        match = pattern.search(line)
        if match is None:
            continue

        value = int(match.group("value"))
        if value <= max_allowed:
            return []

        return [
            _make_theme_contract_violation(
                rule,
                rel_path,
                index + 1,
                "globalStepReduction",
                f"`TypographyTokens.globalStepReduction` is `{value}`. Keep global downshifts out of the shared type scale by default, and verify any reduction on real screens before encoding it as a permanent token-layer override.",
            )
        ]

    return []


def _check_custom_colors_semantic_palette(
    rule: Rule,
    rel_path: str,
    lines: list[str],
    semantic_roles: list[str],
) -> list[Violation]:
    content = CONTENT_SEPARATOR.join(lines)
    factory_pattern = re.compile(
        rule.params.get(
            "factory_pattern",
            r"\b(?:factory|static)\s+(?:CustomColors|AppSemanticPalette)\.fromColorScheme\s*\(\s*ColorScheme\s+\w+\s*\)",
        )
    )
    static_palette_pattern = re.compile(
        rule.params.get(
            "static_palette_pattern",
            r"\bstatic\s+const\s+CustomColors\s+(?P<palette_name>light|dark)\s*=\s*CustomColors\s*\(",
        )
    )
    role_pattern = _build_semantic_role_pattern(semantic_roles)
    hardcoded_role_pattern = re.compile(
        rf"(?P<role>{role_pattern})\s*:\s*(?P<value>.+)"
    )
    hardcoded_source_pattern = re.compile(
        rule.params.get(
            "hardcoded_source_pattern",
            r"\bColorTokens\.[A-Za-z0-9_]+\b|\bColor\s*\(",
        )
    )

    violations: list[Violation] = []
    if factory_pattern.search(content) is None:
        violations.append(
            _make_theme_semantic_palette_violation(
                rule,
                rel_path,
                1,
                "fromColorScheme",
                "Add a `fromColorScheme(ColorScheme scheme)` factory so semantic colors derive from the active scheme or a full preset mapping instead of fixed light/dark tables.",
            )
        )

    for index, line in enumerate(lines):
        if _is_comment(line):
            continue

        palette_match = static_palette_pattern.search(line)
        if palette_match is not None:
            palette_name = palette_match.group("palette_name")
            violations.append(
                _make_theme_semantic_palette_violation(
                    rule,
                    rel_path,
                    index + 1,
                    f"CustomColors.{palette_name}",
                    f"`CustomColors.{palette_name}` is a fixed static semantic palette. Derive semantic colors from `ColorScheme` or a complete preset palette instead.",
                )
            )

        role_match = hardcoded_role_pattern.search(line)
        if role_match is None:
            continue

        value = role_match.group("value").strip()
        if hardcoded_source_pattern.search(value) is None:
            continue

        violations.append(
            _make_theme_semantic_palette_violation(
                rule,
                rel_path,
                index + 1,
                role_match.group("role"),
                f"Semantic role `{role_match.group('role')}` still maps directly from `{value.rstrip(',')}` in `custom_colors.dart`; derive it from `ColorScheme` or a full preset mapping instead.",
            )
        )

    return violations


def _check_color_tokens_semantic_roles(
    rule: Rule,
    rel_path: str,
    lines: list[str],
    semantic_roles: list[str],
) -> list[Violation]:
    role_pattern = _build_semantic_role_pattern(semantic_roles)
    token_declaration_pattern = re.compile(
        rf"\bstatic\s+const\s+Color\s+(?P<role>{role_pattern})\b"
    )

    violations: list[Violation] = []
    for index, line in enumerate(lines):
        if _is_comment(line):
            continue

        match = token_declaration_pattern.search(line)
        if match is None:
            continue

        role = match.group("role")
        violations.append(
            _make_theme_semantic_palette_violation(
                rule,
                rel_path,
                index + 1,
                role,
                f"`color_tokens.dart` still declares preset-dependent semantic role `{role}` as a hard-coded constant. Keep only seeds and absolute colors here, and derive or preset-map the semantic palette elsewhere.",
            )
        )

    return violations


def _check_app_theme_semantic_palette_wiring(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    usage_pattern = re.compile(
        rule.params.get(
            "from_color_scheme_usage_pattern",
            r"\bfromColorScheme\s*\(\s*\w+\s*\)",
        )
    )

    for index, line in enumerate(lines):
        if _is_comment(line):
            continue
        if usage_pattern.search(line):
            return []

    return [
        _make_theme_semantic_palette_violation(
            rule,
            rel_path,
            1,
            "fromColorScheme",
            "`app_theme.dart` does not build semantic colors from the active `ColorScheme`. Wire the theme through `fromColorScheme(...)` so changing preset seed also updates the semantic palette.",
        )
    ]


def _make_theme_semantic_palette_violation(
    rule: Rule,
    rel_path: str,
    line_number: int,
    symbol: str,
    detail: str,
) -> Violation:
    return Violation(
        rule_id=rule.id,
        code=rule.message_code or rule.id,
        family=rule.family,
        severity=rule.severity,
        confidence=rule.confidence,
        impact=rule.impact,
        file_path=rel_path,
        line_number=line_number,
        symbol=symbol,
        message=rule.description,
        message_params={"detail": detail},
    )


def _make_theme_contract_violation(
    rule: Rule,
    rel_path: str,
    line_number: int,
    symbol: str,
    detail: str,
) -> Violation:
    return Violation(
        rule_id=rule.id,
        code=rule.message_code or rule.id,
        family=rule.family,
        severity=rule.severity,
        confidence=rule.confidence,
        impact=rule.impact,
        file_path=rel_path,
        line_number=line_number,
        symbol=symbol,
        message=rule.description,
        message_params={"detail": detail},
    )


def _build_semantic_role_pattern(roles: list[str]) -> str:
    return "|".join(sorted((re.escape(role) for role in roles), key=len, reverse=True))


def _check_ui_try_count(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    try_pattern = re.compile(rule.params.get("try_pattern", r"\btry\s*\{"))
    max_count = rule.params.get("max_count", 1)
    try_lines = [
        index + 1
        for index, line in enumerate(lines)
        if not _is_comment(line) and try_pattern.search(line)
    ]
    if len(try_lines) <= max_count:
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
            line_number=try_lines[0],
            symbol="try",
            message=rule.description,
            message_params={
                "actual_count": str(len(try_lines)),
                "max_count": str(max_count),
            },
        )
    ]


def _check_ui_async_callback_await_count(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    callback_names = rule.params.get(
        "callback_names",
        ["onPressed", "onTap", "onRefresh", "onRetry"],
    )
    lookahead_lines = rule.params.get("lookahead_lines", 4)
    max_awaits = rule.params.get("max_awaits", 1)

    callback_pattern = re.compile(
        r"\b(?:" + "|".join(re.escape(name) for name in callback_names) + r")\b\s*:"
    )
    await_pattern = re.compile(r"\bawait\b")

    violations: list[Violation] = []
    for index, line in enumerate(lines):
        if _is_comment(line) or not callback_pattern.search(line):
            continue

        block_start = _find_async_block_start(lines, index, lookahead_lines)
        if block_start < 0:
            continue

        block = _extract_block(lines, block_start)
        await_count = sum(
            1
            for block_line in block
            if not _is_comment(block_line) and await_pattern.search(block_line)
        )
        if await_count <= max_awaits:
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
                    "actual_count": str(await_count),
                    "max_count": str(max_awaits),
                },
            )
        )

    return violations


def _check_ui_build_collection_chain(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    build_pattern = re.compile(
        rule.params.get(
            "build_pattern",
            r"\bWidget\s+build\s*\(\s*BuildContext\s+\w+(?:\s*,\s*WidgetRef\s+\w+)?\s*\)",
        )
    )
    operation_pattern = re.compile(
        rule.params.get(
            "operation_pattern",
            r"\.(?:map|where|fold|groupBy)\s*\(",
        )
    )
    max_operations = rule.params.get("max_operations", 3)
    max_span_chars = rule.params.get("max_span_chars", 120)

    build_start = next(
        (index for index, line in enumerate(lines) if build_pattern.search(line)),
        -1,
    )
    if build_start < 0:
        return []

    build_block = _extract_block(lines, build_start)
    content = CONTENT_SEPARATOR.join(build_block)
    matches = list(operation_pattern.finditer(content))
    if len(matches) < max_operations:
        return []

    for start_index in range(len(matches) - max_operations + 1):
        start = matches[start_index].start()
        end = matches[start_index + max_operations - 1].start()
        if end - start > max_span_chars:
            continue

        line_offset = content[:start].count("\n")
        return [
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=build_start + line_offset + 1,
                symbol=matches[start_index].group(0),
                message=rule.description,
                message_params={
                    "actual_count": str(max_operations),
                    "max_count": str(max_operations - 1),
                },
            )
        ]

    return []  


def _check_ui_build_collection_processing_lines(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    render_pattern = re.compile(
        rule.params.get(
            "render_method_pattern",
            r"\b(?:Widget|PreferredSizeWidget)\s+(?:_?build\w*|build)\s*\(",
        )
    )
    collection_line_pattern = re.compile(
        rule.params.get(
            "collection_line_pattern",
            r"\.(?:map|where|fold|groupBy|expand|reduce|sort)\s*\(",
        )
    )
    max_lines = rule.params.get("max_lines", 4)

    violations: list[Violation] = []
    for block_start, _, block in _find_block_ranges(lines, render_pattern):
        matching_lines = [
            (local_index, line)
            for local_index, line in enumerate(block)
            if not _is_comment(line) and collection_line_pattern.search(line)
        ]
        if len(matching_lines) <= max_lines:
            continue

        first_index, first_line = matching_lines[0]
        violations.append(
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=block_start + first_index + 1,
                symbol=first_line.strip(),
                message=rule.description,
                message_params={
                    "actual_count": str(len(matching_lines)),
                    "max_count": str(max_lines),
                },
            )
        )

    return violations


def _check_ui_watch_select_opportunity(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    render_pattern = re.compile(
        rule.params.get(
            "render_method_pattern",
            r"\b(?:Widget|PreferredSizeWidget)\s+(?:_?build\w*|build)\s*\(",
        )
    )
    assignment_pattern = re.compile(
        rule.params.get(
            "assignment_pattern",
            r"\b(?:final|var|const)\s+(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*ref\.watch\(\s*(?P<provider_expr>[^;]+?)\s*\)\s*;",
        )
    )
    ignored_provider_pattern = re.compile(
        rule.params.get(
            "ignored_provider_pattern",
            r"\.select\s*\(|\.notifier\b",
        )
    )
    ignored_field_names = {
        str(field_name)
        for field_name in rule.params.get(
            "ignored_field_names",
            sorted(DEFAULT_ASYNC_WRAPPER_FIELDS),
        )
    }

    violations: list[Violation] = []
    for block_start, _, block in _find_block_ranges(lines, render_pattern):
        for local_index, line in enumerate(block):
            if _is_comment(line):
                continue

            match = assignment_pattern.search(line)
            if not match:
                continue

            provider_expr = match.group("provider_expr").strip()
            if ignored_provider_pattern.search(provider_expr):
                continue

            usage_summary = _summarize_single_field_usage(
                block,
                local_index + 1,
                match.group("var_name"),
            )
            if usage_summary is None:
                continue
            if _should_ignore_select_opportunity(
                match.group("var_name"),
                usage_summary["field_name"],
                ignored_field_names,
            ):
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
                    line_number=block_start + local_index + 1,
                    symbol=line.strip(),
                    message=rule.description,
                    message_params={
                        "provider_expr": provider_expr,
                        "field_name": usage_summary["field_name"],
                    },
                )
            )

    return violations


def _check_ui_build_ref_read(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    build_pattern = re.compile(
        rule.params.get(
            "build_pattern",
            r"\bWidget\s+build\s*\(\s*BuildContext\s+\w+(?:\s*,\s*WidgetRef\s+\w+)?\s*\)",
        )
    )
    read_pattern = re.compile(
        rule.params.get("read_pattern", r"\bref\.read\s*\(")
    )
    callback_pattern = re.compile(
        rule.params.get(
            "allowed_callback_pattern",
            r"\bon[A-Z][A-Za-z0-9_]*\b\s*:",
        )
    )
    callback_lookahead_lines = rule.params.get("callback_lookahead_lines", 8)

    violations: list[Violation] = []
    for build_start, build_end, build_block in _find_block_ranges(lines, build_pattern):
        allowed_lines = _collect_allowed_callback_line_indexes(
            build_block,
            callback_pattern,
            callback_lookahead_lines,
        )
        for local_index, line in enumerate(build_block):
            if local_index in allowed_lines or _is_comment(line):
                continue
            if not read_pattern.search(line):
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
                    line_number=build_start + local_index + 1,
                    symbol=line.strip(),
                    message=rule.description,
                )
            )

    return violations


def _check_ui_build_navigation_side_effects(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    render_pattern = re.compile(
        rule.params.get(
            "render_method_pattern",
            r"\b(?:Widget|PreferredSizeWidget)\s+(?:_?build\w*|build)\s*\(",
        )
    )
    navigation_pattern = re.compile(
        rule.params.get(
            "navigation_pattern",
            r"\b(?:context\.(?:go|push|pushReplacement|replace)|GoRouter\.of\s*\([^)]*\)\.(?:go|push|pushReplacement|replace))\s*\(",
        )
    )
    callback_pattern = re.compile(
        rule.params.get(
            "allowed_callback_pattern",
            r"\bon[A-Z][A-Za-z0-9_]*\b\s*:",
        )
    )
    callback_lookahead_lines = rule.params.get("callback_lookahead_lines", 8)

    violations: list[Violation] = []
    for block_start, _, block in _find_block_ranges(lines, render_pattern):
        allowed_lines = _collect_allowed_callback_line_indexes(
            block,
            callback_pattern,
            callback_lookahead_lines,
        )
        for local_index, line in enumerate(block):
            if local_index in allowed_lines or _is_comment(line):
                continue
            if not navigation_pattern.search(line):
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
                    line_number=block_start + local_index + 1,
                    symbol=line.strip(),
                    message=rule.description,
                )
            )

    return violations


def _check_ui_context_after_await(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    async_block_start_pattern = re.compile(
        rule.params.get("async_block_start_pattern", r"\basync\b[^\n{]*\{")
    )
    await_pattern = re.compile(rule.params.get("await_pattern", r"\bawait\b"))
    mounted_check_pattern = re.compile(
        rule.params.get(
            "mounted_check_pattern",
            r"\bif\s*\(\s*!(?:context\.)?mounted\b",
        )
    )
    context_usage_pattern = re.compile(
        rule.params.get("context_usage_pattern", r"\bcontext\b")
    )

    violations: list[Violation] = []
    for async_start, _, async_block in _find_block_ranges(
        lines,
        async_block_start_pattern,
    ):
        violation = _find_async_ui_missing_context_guard(
            async_block,
            async_start,
            await_pattern,
            mounted_check_pattern,
            context_usage_pattern,
        )
        if violation is None:
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
                line_number=violation["line_number"],
                symbol=violation["symbol"],
                message=rule.description,
                message_params={
                    "await_line": str(violation["await_line"]),
                },
            )
        )

    return violations


def _check_ui_media_query_screen_percentage(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    normalized_path = rel_path.replace("\\", "/")
    allowed_path_pattern = re.compile(
        rule.params.get("allowed_path_pattern", r"$^")
    )
    if allowed_path_pattern.search(normalized_path):
        return []

    percentage_pattern = re.compile(
        rule.params.get(
            "percentage_pattern",
            (
                r"MediaQuery(?:\.of\([^)]*\)\.size|\.sizeOf\([^)]*\))"
                r"\.(?:width|height)\s*\*\s*(?:0?\.\d+)"
            ),
        )
    )

    violations: list[Violation] = []
    for index, line in enumerate(lines):
        if _is_comment(line):
            continue
        if not percentage_pattern.search(line):
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
            )
        )

    return violations


def _check_ui_child_screen_width_threshold(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    numeric_threshold_pattern = rule.params.get(
        "numeric_threshold_pattern",
        r"\d+(?:\.\d+)?",
    )
    comparison_operator_pattern = rule.params.get(
        "comparison_operator_pattern",
        r"(?:[<>]=?)",
    )

    tracked_expressions = set(
        rule.params.get(
            "direct_width_expressions",
            [
                "context.screenWidth",
                "MediaQuery.of(context).size.width",
                "MediaQuery.sizeOf(context).width",
            ],
        )
    )

    alias_width_assignment_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "alias_width_assignment_patterns",
            [
                (
                    r"\b(?:final|var|const|double|num|int)\s+"
                    r"(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
                    r"context\.screenWidth\s*;"
                ),
                (
                    r"\b(?:final|var|const|double|num|int)\s+"
                    r"(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
                    r"MediaQuery\.of\(context\)\.size\.width\s*;"
                ),
                (
                    r"\b(?:final|var|const|double|num|int)\s+"
                    r"(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
                    r"MediaQuery\.sizeOf\(context\)\.width\s*;"
                ),
            ],
        )
    ]
    alias_size_assignment_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "alias_size_assignment_patterns",
            [
                (
                    r"\b(?:final|var|const|Size)\s+"
                    r"(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
                    r"MediaQuery\.of\(context\)\.size\s*;"
                ),
                (
                    r"\b(?:final|var|const|Size)\s+"
                    r"(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
                    r"MediaQuery\.sizeOf\(context\)\s*;"
                ),
            ],
        )
    ]
    alias_media_query_assignment_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "alias_media_query_assignment_patterns",
            [
                (
                    r"\b(?:final|var|const|MediaQueryData)\s+"
                    r"(?P<var_name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
                    r"MediaQuery\.of\(context\)\s*;"
                ),
            ],
        )
    ]

    for pattern in alias_width_assignment_patterns:
        for match in pattern.finditer(content):
            tracked_expressions.add(match.group("var_name"))

    for pattern in alias_size_assignment_patterns:
        for match in pattern.finditer(content):
            tracked_expressions.add(f"{match.group('var_name')}.width")

    for pattern in alias_media_query_assignment_patterns:
        for match in pattern.finditer(content):
            tracked_expressions.add(f"{match.group('var_name')}.size.width")

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for expression in tracked_expressions:
        comparison_pattern = re.compile(
            (
                rf"{re.escape(expression)}\s*{comparison_operator_pattern}\s*"
                rf"{numeric_threshold_pattern}"
                rf"|{numeric_threshold_pattern}\s*{comparison_operator_pattern}\s*"
                rf"{re.escape(expression)}"
            )
        )

        for match in comparison_pattern.finditer(content):
            line_number = content.count("\n", 0, match.start()) + 1
            if line_number in seen_lines:
                continue

            seen_lines.add(line_number)
            violations.append(
                Violation(
                    rule_id=rule.id,
                    code=rule.message_code or rule.id,
                    family=rule.family,
                    severity=rule.severity,
                    confidence=rule.confidence,
                    impact=rule.impact,
                    file_path=rel_path,
                    line_number=line_number,
                    symbol=lines[line_number - 1].strip(),
                    message=rule.description,
                )
            )

    return violations


def _check_ui_text_style_copywith_typography_override(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    receiver_pattern = re.compile(
        rule.params.get(
            "receiver_pattern",
            r"\b(?:[A-Za-z_][A-Za-z0-9_]*\.)*(?:textTheme\.[A-Za-z_][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_]*Style|titleTextStyle|subtitleTextStyle|labelStyle|subtitleStyle)\??\s*\.\s*copyWith\s*\(",
        )
    )
    typography_property_pattern = re.compile(
        rule.params.get(
            "typography_property_pattern",
            r"\b(?P<property>fontSize|fontWeight|height|letterSpacing|fontStyle)\s*:",
        )
    )
    allowed_context_pattern = re.compile(
        rule.params.get(
            "allowed_context_pattern",
            r"guard:typography-copywith-reviewed",
        ),
        re.IGNORECASE,
    )
    context_radius = int(rule.params.get("context_radius", 2))

    violations: list[Violation] = []
    seen_lines: set[int] = set()

    for match in receiver_pattern.finditer(content):
        open_paren_index = match.end() - 1
        close_paren_index = _find_matching_parenthesis_index(
            content,
            open_paren_index,
        )
        if close_paren_index < 0:
            continue

        body = content[open_paren_index + 1 : close_paren_index]
        property_match = typography_property_pattern.search(body)
        if not property_match:
            continue

        line_number = content.count("\n", 0, match.start()) + 1
        if line_number in seen_lines:
            continue
        if _has_context_pattern(
            lines,
            line_number,
            allowed_context_pattern,
            context_radius,
        ):
            continue

        property_name = property_match.groupdict().get("property") or "typography"
        seen_lines.add(line_number)
        violations.append(
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=line_number,
                symbol=lines[line_number - 1].strip(),
                message=rule.description,
                message_params={"property": property_name},
            )
        )

    return violations


def _check_ui_display_font_size_literals(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    return _check_ui_font_size_literals(
        rule,
        rel_path,
        lines,
        display_only=True,
    )


def _check_ui_raw_font_size_literals(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    return _check_ui_font_size_literals(
        rule,
        rel_path,
        lines,
        display_only=False,
    )


def _check_ui_font_size_literals(
    rule: Rule,
    rel_path: str,
    lines: list[str],
    *,
    display_only: bool,
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    font_size_pattern = re.compile(
        rule.params.get(
            "font_size_pattern",
            r"\bfontSize\s*:\s*(?P<value>\d+(?:\.\d+)?)\b",
        )
    )
    display_context_pattern = re.compile(
        rule.params.get(
            "display_context_pattern",
            r"\b(?:score|badge|percent|percentage|number|count|counter|stat|display|hero|headline|current|completed|total)\b|%",
        ),
        re.IGNORECASE,
    )
    display_path_pattern = re.compile(
        rule.params.get(
            "display_path_pattern",
            r"(?:score|badge|stat)",
        ),
        re.IGNORECASE,
    )
    large_font_threshold = float(rule.params.get("large_font_threshold", 32))
    context_radius = int(rule.params.get("context_radius", 3))
    normalized_path = rel_path.replace("\\", "/")

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for match in font_size_pattern.finditer(content):
        raw_value = match.groupdict().get("value")
        if raw_value is None:
            continue

        try:
            numeric_value = float(raw_value)
        except ValueError:
            continue

        line_number = content.count("\n", 0, match.start()) + 1
        if line_number in seen_lines:
            continue

        has_display_context = numeric_value >= large_font_threshold
        if not has_display_context and display_path_pattern.search(normalized_path):
            has_display_context = True
        if not has_display_context:
            has_display_context = _has_context_pattern(
                lines,
                line_number,
                display_context_pattern,
                context_radius,
            )

        if has_display_context != display_only:
            continue

        seen_lines.add(line_number)
        violations.append(
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=line_number,
                symbol=lines[line_number - 1].strip(),
                message=rule.description,
                message_params={"value": raw_value},
            )
        )

    return violations


def _check_ui_raw_spacing_literals(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    literal_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "literal_patterns",
            [
                r"\bEdgeInsets\.all\(\s*(?P<value>\d+(?:\.\d+)?)\s*\)",
                (
                    r"\bEdgeInsets\.symmetric\([^)]*"
                    r"(?:horizontal|vertical)\s*:\s*(?P<value>\d+(?:\.\d+)?)"
                ),
                (
                    r"\bEdgeInsets\.only\([^)]*"
                    r"(?:left|top|right|bottom)\s*:\s*(?P<value>\d+(?:\.\d+)?)"
                ),
                (
                    r"\bSizedBox\([^)]*"
                    r"(?:height|width)\s*:\s*(?P<value>\d+(?:\.\d+)?)"
                ),
            ],
        )
    ]
    max_allowed_literal = float(rule.params.get("max_allowed_literal", 2))
    allowed_context_pattern = re.compile(
        rule.params.get(
            "allowed_context_pattern",
            (
                r"guard:raw-spacing-reviewed|hairline|divider|pixel|pixel-fix|"
                r"workaround|third[- ]party|animation tweak|tweak"
            ),
        ),
        re.IGNORECASE,
    )
    context_radius = int(rule.params.get("context_radius", 1))

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for pattern in literal_patterns:
        for match in pattern.finditer(content):
            raw_value = match.groupdict().get("value")
            if raw_value is None:
                continue

            try:
                numeric_value = float(raw_value)
            except ValueError:
                continue

            if numeric_value <= max_allowed_literal:
                continue

            line_number = content.count("\n", 0, match.start()) + 1
            if line_number in seen_lines:
                continue

            if _has_allowed_spacing_context(
                lines,
                line_number,
                allowed_context_pattern,
                context_radius,
            ):
                continue

            seen_lines.add(line_number)
            violations.append(
                Violation(
                    rule_id=rule.id,
                    code=rule.message_code or rule.id,
                    family=rule.family,
                    severity=rule.severity,
                    confidence=rule.confidence,
                    impact=rule.impact,
                    file_path=rel_path,
                    line_number=line_number,
                    symbol=lines[line_number - 1].strip(),
                    message=rule.description,
                    message_params={"value": raw_value},
                )
            )

    return violations


def _check_ui_raw_size_literals(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    literal_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "literal_patterns",
            [
                (
                    r"\b(?:width|height|minWidth|minHeight|maxWidth|maxHeight)"
                    r"\s*:\s*(?P<value>\d+(?:\.\d+)?)"
                ),
            ],
        )
    ]
    max_allowed_literal = float(rule.params.get("max_allowed_literal", 2))
    allowed_context_pattern = re.compile(
        rule.params.get(
            "allowed_context_pattern",
            (
                r"guard:raw-size-reviewed|hairline|divider|pixel|pixel-fix|"
                r"workaround|third[- ]party|animation tweak|tweak"
            ),
        ),
        re.IGNORECASE,
    )
    context_radius = int(rule.params.get("context_radius", 1))

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for pattern in literal_patterns:
        for match in pattern.finditer(content):
            raw_value = match.groupdict().get("value")
            if raw_value is None:
                continue

            try:
                numeric_value = float(raw_value)
            except ValueError:
                continue

            if numeric_value <= max_allowed_literal:
                continue

            line_number = content.count("\n", 0, match.start()) + 1
            if line_number in seen_lines:
                continue

            if _has_context_pattern(
                lines,
                line_number,
                allowed_context_pattern,
                context_radius,
            ):
                continue

            seen_lines.add(line_number)
            violations.append(
                Violation(
                    rule_id=rule.id,
                    code=rule.message_code or rule.id,
                    family=rule.family,
                    severity=rule.severity,
                    confidence=rule.confidence,
                    impact=rule.impact,
                    file_path=rel_path,
                    line_number=line_number,
                    symbol=lines[line_number - 1].strip(),
                    message=rule.description,
                    message_params={"value": raw_value},
                )
            )

    return violations


def _check_ui_raw_half_alpha_with_values(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    half_alpha_pattern = re.compile(
        rule.params.get(
            "half_alpha_pattern",
            r"\.withValues\s*\([^)]*\balpha\s*:\s*0\.5(?:0+)?\b[^)]*\)",
        )
    )
    matches = _collect_unique_pattern_matches(
        content,
        lines,
        [half_alpha_pattern],
    )

    violations: list[Violation] = []
    for line_number, symbol in matches:
        violations.append(
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=line_number,
                symbol=symbol,
                message=rule.description,
                message_params={
                    "value": "0.5",
                    "token": "OpacityTokens.half",
                },
            )
        )

    return violations


def _check_ui_raw_alpha_with_values(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    alpha_pattern = re.compile(
        rule.params.get(
            "alpha_pattern",
            (
                r"\.withValues\s*\([^)]*\balpha\s*:\s*"
                r"(?P<value>(?:0?\.\d+|1(?:\.0+)?|0))\b[^)]*\)"
            ),
        )
    )

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for match in alpha_pattern.finditer(content):
        raw_value = match.groupdict().get("value")
        if raw_value is None:
            continue

        line_number = content.count("\n", 0, match.start()) + 1
        if line_number in seen_lines:
            continue

        seen_lines.add(line_number)
        violations.append(
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=line_number,
                symbol=lines[line_number - 1].strip(),
                message=rule.description,
                message_params={"value": raw_value},
            )
        )

    return violations


def _check_ui_child_remaining_width_layout_signal(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    required_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "required_patterns",
            [
                r"\bLayoutBuilder\b",
                r"\bconstraints\.maxWidth\b",
            ],
        )
    ]
    if any(pattern.search(content) for pattern in required_patterns):
        return []

    structural_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "structural_patterns",
            [
                r"\bWrap\s*\(",
                r"\bRow\s*\(",
                r"\bGridView(?:\.[A-Za-z]+)?\s*\(",
                r"\bSliverGrid\b",
            ],
        )
    ]
    width_signal_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "width_signal_patterns",
            [
                r"\bitemWidth\b",
                r"\bcrossAxisCount\b",
                r"\bchildAspectRatio\b",
                r"\b(?:card|cell|column|detail|item|tile)[A-Za-z0-9_]*Width\b",
            ],
        )
    ]
    parent_responsive_input_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "parent_responsive_input_patterns",
            [
                r"\bfinal\s+bool\s+(?:isSmallScreen|isCompact|isMedium|isExpanded)\s*;",
                r"\bfinal\s+ScreenType\s+screenType\s*;",
            ],
        )
    ]
    local_width_contract_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "local_width_contract_patterns",
            [
                r"\bitemWidth\b",
                r"\b(?:card|cell|column|detail|item|tile)[A-Za-z0-9_]*Width\b",
            ],
        )
    ]
    min_structural_matches = rule.params.get("min_structural_matches", 1)
    min_width_signal_matches = rule.params.get("min_width_signal_matches", 1)

    structural_matches = _collect_unique_pattern_matches(content, lines, structural_patterns)
    if len(structural_matches) < min_structural_matches:
        return []

    width_signal_matches = _collect_unique_pattern_matches(
        content,
        lines,
        width_signal_patterns,
    )
    if len(width_signal_matches) < min_width_signal_matches:
        return []

    has_parent_responsive_input = any(
        pattern.search(content) for pattern in parent_responsive_input_patterns
    )
    has_local_width_contract = any(
        pattern.search(content) for pattern in local_width_contract_patterns
    )
    if has_parent_responsive_input and not has_local_width_contract:
        return []

    line_number, symbol = width_signal_matches[0]
    return [
        Violation(
            rule_id=rule.id,
            code=rule.message_code or rule.id,
            family=rule.family,
            severity=rule.severity,
            confidence=rule.confidence,
            impact=rule.impact,
            file_path=rel_path,
            line_number=line_number,
            symbol=symbol or rel_path,
            message=rule.description,
            message_params={
                "structural_count": str(len(structural_matches)),
                "width_signal_count": str(len(width_signal_matches)),
            },
        )
    ]


def _check_large_layout_responsive_signal(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    min_significant_lines = rule.params.get("min_significant_lines", 120)
    significant_line_count = sum(
        1 for line in lines if line.strip() and not _is_comment(line)
    )
    if significant_line_count < min_significant_lines:
        return []

    required_patterns = [
        re.compile(pattern)
        for pattern in rule.params.get(
            "required_patterns",
            [
                r"\bLayoutBuilder\b",
                r"\bscreenType\b",
                r"\bconstraints\.maxWidth\b",
                r"\bResponsive\b",
                r"\bSliverGridDelegateWithMaxCrossAxisExtent\b",
                r"\bWrap\s*\(",
            ],
        )
    ]

    content = CONTENT_SEPARATOR.join(lines)
    if any(pattern.search(content) for pattern in required_patterns):
        return []

    first_line_number = next(
        (
            index + 1
            for index, line in enumerate(lines)
            if line.strip() and not _is_comment(line)
        ),
        1,
    )

    return [
        Violation(
            rule_id=rule.id,
            code=rule.message_code or rule.id,
            family=rule.family,
            severity=rule.severity,
            confidence=rule.confidence,
            impact=rule.impact,
            file_path=rel_path,
            line_number=first_line_number,
            symbol=rel_path,
            message=rule.description,
            message_params={"min_lines": str(min_significant_lines)},
        )
    ]


def _check_screen_async_value_render(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    render_pattern = re.compile(
        rule.params.get(
            "render_method_pattern",
            r"\b(?:Widget|PreferredSizeWidget)\s+(?:_?build\w*|build)\s*\(",
        )
    )
    direct_flatten_pattern = re.compile(
        rule.params.get(
            "direct_flatten_pattern",
            r"ref\.watch\([^)]*\)\.(?:value|valueOrNull|requireValue|hasValue|hasError|error)\b",
        )
    )
    async_name_pattern = re.compile(
        rule.params.get("async_name_pattern", r"^\w+Async$")
    )

    violations: list[Violation] = []
    for block_start, _, block in _find_block_ranges(lines, render_pattern):
        for local_index, line in enumerate(block):
            if _is_comment(line):
                continue
            if direct_flatten_pattern.search(line):
                violations.append(
                    Violation(
                        rule_id=rule.id,
                        code=rule.message_code or rule.id,
                        family=rule.family,
                        severity=rule.severity,
                        confidence=rule.confidence,
                        impact=rule.impact,
                        file_path=rel_path,
                        line_number=block_start + local_index + 1,
                        symbol=line.strip(),
                        message=rule.description,
                    )
                )

        async_identifiers = _collect_async_identifiers(
            block,
            block_start,
            async_name_pattern,
        )
        if not async_identifiers:
            continue

        for identifier, line_number in async_identifiers.items():
            loading_access = _has_async_identifier_access(
                block,
                identifier,
                r"\.isLoading\b",
            )
            error_access = _has_async_identifier_access(
                block,
                identifier,
                r"\.(?:hasError|error|asError)\b",
            )
            data_access = _has_async_identifier_access(
                block,
                identifier,
                r"\.(?:value|valueOrNull|requireValue|hasValue|asData)\b",
            )
            suspicious = error_access or data_access
            if not suspicious:
                continue

            compliant = (
                _has_async_when_usage(block, identifier)
                or _has_async_state_builder_usage(block, identifier)
                or _has_async_switch_usage(block, identifier)
                or (loading_access and error_access and data_access)
            )
            if compliant:
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
                    line_number=line_number,
                    symbol=identifier,
                    message=rule.description,
                )
            )

    return violations


def _check_router_redirect_purity(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    redirect_pattern = re.compile(
        rule.params.get(
            "redirect_pattern",
            r"\bredirect\s*:\s*\([^)]*\)\s*\{",
        )
    )
    disallowed_pattern = re.compile(
        rule.params.get(
            "disallowed_pattern",
            r"\bawait\b|\.notifier\b|\w+RepositoryProvider\b|\brepo\.\w|\bdio\.\w|\bhttp\.\w",
        )
    )

    violations: list[Violation] = []
    for block_start, _, block in _find_block_ranges(lines, redirect_pattern):
        for local_index, line in enumerate(block):
            if _is_comment(line):
                continue

            match = disallowed_pattern.search(line)
            if not match:
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
                    line_number=block_start + local_index + 1,
                    symbol=line.strip(),
                    message=rule.description,
                    message_params={"pattern": match.group(0)},
                )
            )
            break

    return violations


def _check_provider_resource_cleanup(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    annotation_pattern = re.compile(
        rule.params.get("annotation_pattern", r"^\s*@(?:riverpod|Riverpod)\b")
    )
    dispose_registration_pattern = re.compile(
        rule.params.get("dispose_registration_pattern", r"\bref\.onDispose\s*\("),
        re.DOTALL,
    )
    resource_specs = rule.params.get("resource_specs", [])

    violations: list[Violation] = []
    seen_signatures: set[tuple[int, str]] = set()

    for block_start, _, block in _find_annotated_block_ranges(lines, annotation_pattern):
        resource_hits = _collect_provider_resource_hits(
            block,
            block_start,
            resource_specs,
        )
        if not resource_hits:
            continue

        block_content = CONTENT_SEPARATOR.join(block)
        has_dispose_registration = bool(
            dispose_registration_pattern.search(block_content)
        )

        for resource_hit in resource_hits:
            if _provider_resource_has_cleanup(
                block_content,
                has_dispose_registration,
                resource_hit["variable_name"],
                resource_hit["cleanup_methods"],
            ):
                continue

            signature = (resource_hit["line_number"], resource_hit["kind"])
            if signature in seen_signatures:
                continue
            seen_signatures.add(signature)

            violations.append(
                Violation(
                    rule_id=rule.id,
                    code=rule.message_code or rule.id,
                    family=rule.family,
                    severity=rule.severity,
                    confidence=rule.confidence,
                    impact=rule.impact,
                    file_path=rel_path,
                    line_number=resource_hit["line_number"],
                    symbol=resource_hit["symbol"],
                    message=rule.description,
                    message_params={
                        "resource": resource_hit["kind"],
                        "cleanup_methods": ", ".join(
                            resource_hit["cleanup_methods"]
                        ),
                    },
                )
            )

    return violations


def _check_provider_retry_reviewed(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    annotation_pattern = re.compile(
        rule.params.get("annotation_pattern", r"^\s*@(?:riverpod|Riverpod)\b")
    )
    review_marker_pattern = re.compile(
        rule.params.get(
            "review_marker_pattern",
            r"guard:retry-reviewed|@NoAutoRetry\b|@RetryPolicy\b",
        )
    )
    risky_signature_pattern = re.compile(
        rule.params.get("risky_signature_pattern", r"$^")
    )
    marker_lookbehind_lines = rule.params.get("marker_lookbehind_lines", 3)

    violations: list[Violation] = []

    for block_start, _, block in _find_annotated_block_ranges(lines, annotation_pattern):
        if _provider_block_has_review_marker(
            lines,
            block,
            block_start,
            review_marker_pattern,
            marker_lookbehind_lines,
        ):
            continue

        risky_hit = _find_risky_provider_signature(
            block,
            block_start,
            risky_signature_pattern,
        )
        if risky_hit is None:
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
                line_number=risky_hit["line_number"],
                symbol=risky_hit["symbol"],
                message=rule.description,
                message_params={"member_name": risky_hit["member_name"]},
            )
        )

    return violations


def _check_provider_mounted_after_await(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    annotation_pattern = re.compile(
        rule.params.get("annotation_pattern", r"^\s*@(?:riverpod|Riverpod)\b")
    )
    async_block_start_pattern = re.compile(
        rule.params.get("async_block_start_pattern", r"\basync\b[^{]*\{")
    )
    await_pattern = re.compile(rule.params.get("await_pattern", r"\bawait\b"))
    mounted_check_pattern = re.compile(
        rule.params.get("mounted_check_pattern", r"\bif\s*\(\s*!ref\.mounted\b")
    )
    sensitive_action_pattern = re.compile(
        rule.params.get("sensitive_action_pattern", r"$^")
    )

    violations: list[Violation] = []

    for provider_start, _, provider_block in _find_annotated_block_ranges(
        lines,
        annotation_pattern,
    ):
        for async_start, _, async_block in _find_block_ranges(
            provider_block,
            async_block_start_pattern,
        ):
            violation = _find_async_provider_missing_mounted_check(
                async_block,
                provider_start + async_start,
                await_pattern,
                mounted_check_pattern,
                sensitive_action_pattern,
            )
            if violation is None:
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
                    line_number=violation["line_number"],
                    symbol=violation["symbol"],
                    message=rule.description,
                    message_params={
                        "await_line": str(violation["await_line"]),
                    },
                )
            )

    return violations


def _check_provider_family_param_stability(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    annotation_pattern = re.compile(
        rule.params.get("annotation_pattern", r"^\s*@(?:riverpod|Riverpod)\b")
    )
    stable_scalar_types = {
        str(value)
        for value in rule.params.get(
            "stable_scalar_types",
            sorted(DEFAULT_STABLE_FAMILY_SCALAR_TYPES),
        )
    }
    unstable_collection_types = {
        str(value)
        for value in rule.params.get(
            "collection_base_types",
            sorted(DEFAULT_UNSTABLE_COLLECTION_TYPES),
        )
    }
    type_index = _load_project_type_index()

    violations: list[Violation] = []

    for provider in _collect_annotated_provider_declarations(lines, annotation_pattern):
        family_params = _collect_family_params_for_provider(provider, lines)
        if not family_params:
            continue

        for parameter in family_params:
            if _is_stable_family_param(
                parameter["type"],
                stable_scalar_types,
                unstable_collection_types,
                type_index,
            ):
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
                    line_number=parameter["line_number"],
                    symbol=parameter["symbol"],
                    message=rule.description,
                    message_params={
                        "provider_name": provider["name"],
                        "param_name": parameter["name"],
                        "param_type": parameter["type"] or "dynamic",
                    },
                )
            )

    return violations




