from __future__ import annotations

from functools import lru_cache
from pathlib import Path
import re

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
        check_id = rule.params.get("check_id", "")
        if check_id == "no_else_control_flow":
            return _check_no_else_control_flow(rule, rel_path, lines)
        if check_id == "theme_semantic_palette_contract":
            return _check_theme_semantic_palette_contract(rule, rel_path, lines)
        if check_id == "theme_typography_contract":
            return _check_theme_typography_contract(rule, rel_path, lines)
        if check_id == "ui_inline_locale_pair_strings":
            return _check_ui_inline_locale_pair_strings(rule, rel_path, lines)
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
        if check_id == "provider_generated_pairing":
            return _check_provider_generated_pairing(rule, rel_path, lines)
        return []


def _check_no_else_control_flow(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = _strip_strings_and_comments_preserve_layout(lines)
    else_pattern = re.compile(
        rule.params.get(
            "else_pattern",
            r"(?m)(?:^|[}\s])else(?:\s+if\b|\s*\{|\s*$)",
        )
    )

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for match in else_pattern.finditer(content):
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
                symbol="else",
                message=rule.description,
                message_params={"keyword": "else"},
            )
        )

    return violations


def _check_ui_inline_locale_pair_strings(
    rule: Rule,
    rel_path: str,
    lines: list[str],
) -> list[Violation]:
    content = CONTENT_SEPARATOR.join(lines)
    locale_patterns = [
        re.compile(pattern, re.S)
        for pattern in rule.params.get(
            "locale_patterns",
            [
                r"\b(?:vi|en)\s*:\s*'(?:[^']*[A-Za-zÀ-ỹ][^']*)'",
                r'\b(?:vi|en)\s*:\s*"(?:[^"]*[A-Za-zÀ-ỹ][^"]*)"',
            ],
        )
    ]

    violations: list[Violation] = []
    seen_lines: set[int] = set()
    for pattern in locale_patterns:
        for match in pattern.finditer(content):
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
                "repetitionFirst",
                "repetitionSecond",
                "repetitionThird",
                "repetitionAdvanced",
                "repetitionExpert",
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


def _check_provider_generated_pairing(
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
        annotation_pattern.search(line)
        for line in lines
        if not _is_comment(line)
    )
    if not has_annotation:
        return []

    if not any(expected_part in line for line in lines):
        return [
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=1,
                symbol=expected_part,
                message=rule.description,
                message_params={
                    "expected_part": expected_part,
                    "expected_generated_file": expected_generated_path.as_posix(),
                },
            )
        ]

    if not (workspace_root / expected_generated_path).exists():
        return [
            Violation(
                rule_id=rule.id,
                code=rule.message_code or rule.id,
                family=rule.family,
                severity=rule.severity,
                confidence=rule.confidence,
                impact=rule.impact,
                file_path=rel_path,
                line_number=1,
                symbol=expected_generated_path.name,
                message=rule.description,
                message_params={
                    "expected_part": expected_part,
                    "expected_generated_file": expected_generated_path.as_posix(),
                },
            )
        ]

    return []


def _find_async_block_start(
    lines: list[str],
    start_index: int,
    lookahead_lines: int,
) -> int:
    end_index = min(len(lines), start_index + lookahead_lines + 1)
    for index in range(start_index, end_index):
        if _is_comment(lines[index]):
            continue
        if "async" in lines[index] and OPENING_BRACE in lines[index]:
            return index
    return -1


def _find_block_ranges(
    lines: list[str],
    start_pattern: re.Pattern[str],
) -> list[tuple[int, int, list[str]]]:
    ranges: list[tuple[int, int, list[str]]] = []
    index = 0
    while index < len(lines):
        if not start_pattern.search(lines[index]):
            index += 1
            continue

        block = _extract_block(lines, index)
        end_index = index + len(block) - 1
        ranges.append((index, end_index, block))
        index = end_index + 1

    return ranges


def _find_annotated_block_ranges(
    lines: list[str],
    annotation_pattern: re.Pattern[str],
) -> list[tuple[int, int, list[str]]]:
    ranges: list[tuple[int, int, list[str]]] = []
    index = 0
    while index < len(lines):
        if _is_comment(lines[index]) or not annotation_pattern.search(lines[index]):
            index += 1
            continue

        declaration_start = _find_annotated_declaration_start(lines, index + 1)
        if declaration_start < 0:
            index += 1
            continue
        if not _declaration_has_block(lines, declaration_start):
            index = declaration_start + 1
            continue

        block = _extract_block(lines, declaration_start)
        end_index = declaration_start + len(block) - 1
        ranges.append((declaration_start, end_index, block))
        index = end_index + 1

    return ranges


def _collect_allowed_callback_line_indexes(
    lines: list[str],
    callback_pattern: re.Pattern[str],
    lookahead_lines: int,
) -> set[int]:
    allowed: set[int] = set()

    for index, line in enumerate(lines):
        if _is_comment(line) or not callback_pattern.search(line):
            continue

        body_start = _find_callback_body_start(lines, index, lookahead_lines)
        if body_start >= 0:
            callback_block = _extract_block(lines, body_start)
            end_index = body_start + len(callback_block) - 1
            allowed.update(range(index, end_index + 1))
            continue

        expression_end = _find_callback_expression_end(lines, index, lookahead_lines)
        allowed.update(range(index, expression_end + 1))

    return allowed


def _find_annotated_declaration_start(
    lines: list[str],
    start_index: int,
) -> int:
    for index in range(start_index, len(lines)):
        stripped = lines[index].strip()
        if not stripped or _is_comment(lines[index]):
            continue
        if stripped.startswith("@"):
            continue
        return index
    return -1


def _declaration_has_block(lines: list[str], start_index: int) -> bool:
    for index in range(start_index, len(lines)):
        stripped = lines[index].strip()
        if not stripped or _is_comment(lines[index]):
            continue
        if index > start_index and stripped.startswith("@"):
            return False
        if OPENING_BRACE in lines[index]:
            return True
        if stripped.endswith(";") or "=>" in stripped:
            return False
    return False


def _find_callback_body_start(
    lines: list[str],
    start_index: int,
    lookahead_lines: int,
) -> int:
    end_index = min(len(lines), start_index + lookahead_lines + 1)
    for index in range(start_index, end_index):
        if _is_comment(lines[index]):
            continue
        if OPENING_BRACE in lines[index]:
            return index
    return -1


def _find_callback_expression_end(
    lines: list[str],
    start_index: int,
    lookahead_lines: int,
) -> int:
    end_index = min(len(lines) - 1, start_index + lookahead_lines)
    for index in range(start_index, end_index + 1):
        if _is_comment(lines[index]):
            continue
        stripped = lines[index].strip()
        if stripped.endswith(","):
            return index
    return end_index


def _summarize_single_field_usage(
    lines: list[str],
    start_index: int,
    variable_name: str,
) -> dict[str, str] | None:
    field_pattern = re.compile(
        rf"\b{re.escape(variable_name)}\s*(?:\?|\!)?\.\s*(?P<field_name>[A-Za-z_][A-Za-z0-9_]*)\b(?!\s*\()"
    )
    variable_pattern = re.compile(rf"\b{re.escape(variable_name)}\b")
    distinct_fields: set[str] = set()
    saw_usage = False

    for local_index in range(start_index, len(lines)):
        line = lines[local_index]
        if _is_comment(line):
            continue
        if not variable_pattern.search(line):
            continue

        saw_usage = True
        sanitized_line = field_pattern.sub("", line)
        for match in field_pattern.finditer(line):
            distinct_fields.add(match.group("field_name"))

        if variable_pattern.search(sanitized_line):
            return None

        if len(distinct_fields) > 1:
            return None

    if not saw_usage or len(distinct_fields) != 1:
        return None

    return {"field_name": next(iter(distinct_fields))}


def _should_ignore_select_opportunity(
    variable_name: str,
    field_name: str,
    ignored_field_names: set[str],
) -> bool:
    if field_name not in ignored_field_names:
        return False

    return bool(re.search(r"(?:Async|State)$", variable_name))


def _collect_declaration_signature(
    lines: list[str],
    start_index: int,
) -> tuple[str, int]:
    collected: list[str] = []

    for index in range(start_index, len(lines)):
        line = lines[index]
        if not collected and (not line.strip() or _is_comment(line)):
            continue

        collected.append(line.strip())
        if "=>" in line or OPENING_BRACE in line or ";" in line:
            return (" ".join(collected).strip(), index)

    return (" ".join(collected).strip(), len(lines) - 1)


def _extract_block(lines: list[str], start: int) -> list[str]:
    brace_count = 0
    found_opening = False

    for index in range(start, len(lines)):
        brace_count += lines[index].count(OPENING_BRACE) - lines[index].count(
            CLOSING_BRACE
        )
        if OPENING_BRACE in lines[index]:
            found_opening = True
        if found_opening and brace_count <= 0:
            return lines[start : index + 1]

    return lines[start:]


def _find_matching_parenthesis_index(content: str, open_index: int) -> int:
    depth = 0
    for index in range(open_index, len(content)):
        char = content[index]
        if char == "(":
            depth += 1
            continue
        if char != ")":
            continue

        depth -= 1
        if depth == 0:
            return index

    return -1


def _collect_provider_resource_hits(
    lines: list[str],
    start_line_number: int,
    resource_specs: list[dict[str, object]],
) -> list[dict[str, object]]:
    hits: list[dict[str, object]] = []

    for local_index, line in enumerate(lines):
        if _is_comment(line):
            continue

        for spec in resource_specs:
            kind = str(spec.get("kind", "resource"))
            cleanup_methods = [
                str(method) for method in spec.get("cleanup_methods", [])
            ]
            patterns = spec.get("patterns", [])
            if not isinstance(patterns, list):
                continue

            for raw_pattern in patterns:
                pattern = re.compile(str(raw_pattern))
                match = pattern.search(line)
                if not match:
                    continue

                variable_name = _extract_named_group(match, "var_name")
                hits.append(
                    {
                        "kind": kind,
                        "cleanup_methods": cleanup_methods,
                        "variable_name": variable_name,
                        "line_number": start_line_number + local_index + 1,
                        "symbol": line.strip(),
                    }
                )
                break

    return hits


def _extract_named_group(match: re.Match[str], group_name: str) -> str | None:
    if group_name not in match.re.groupindex:
        return None

    value = match.group(group_name)
    if value is None:
        return None
    return value.strip()


def _provider_resource_has_cleanup(
    block_content: str,
    has_dispose_registration: bool,
    variable_name: str | None,
    cleanup_methods: list[object],
) -> bool:
    if not has_dispose_registration:
        return False

    cleanup_pattern = _build_cleanup_pattern(variable_name, cleanup_methods)
    if cleanup_pattern is None:
        return False

    return bool(cleanup_pattern.search(block_content))


def _build_cleanup_pattern(
    variable_name: str | None,
    cleanup_methods: list[object],
) -> re.Pattern[str] | None:
    methods = [re.escape(str(method)) for method in cleanup_methods if str(method)]
    if not methods:
        return None

    method_group = "|".join(methods)
    if variable_name:
        return re.compile(
            rf"\b{re.escape(variable_name)}\s*(?:\?\.|\.)\s*(?:{method_group})\b",
            re.DOTALL,
        )

    return re.compile(rf"\.(?:{method_group})\b", re.DOTALL)


def _find_async_provider_missing_mounted_check(
    lines: list[str],
    start_line_number: int,
    await_pattern: re.Pattern[str],
    mounted_check_pattern: re.Pattern[str],
    sensitive_action_pattern: re.Pattern[str],
) -> dict[str, object] | None:
    pending_await_line: int | None = None
    awaiting_statement_line: int | None = None
    awaiting_statement_balance = 0

    for local_index, line in enumerate(lines):
        if _is_comment(line):
            continue

        absolute_line = start_line_number + local_index + 1

        if awaiting_statement_line is not None:
            awaiting_statement_balance += _statement_balance_delta(line)
            if _statement_is_terminated(line, awaiting_statement_balance):
                pending_await_line = awaiting_statement_line
                awaiting_statement_line = None
                awaiting_statement_balance = 0
            continue

        if mounted_check_pattern.search(line):
            pending_await_line = None
            continue

        has_await = bool(await_pattern.search(line))
        has_sensitive_action = bool(sensitive_action_pattern.search(line))

        if pending_await_line is not None and has_sensitive_action and not has_await:
            return {
                "await_line": pending_await_line,
                "line_number": absolute_line,
                "symbol": line.strip(),
            }

        if has_await:
            awaiting_statement_line = absolute_line
            awaiting_statement_balance = _statement_balance_delta(line)
            if _statement_is_terminated(line, awaiting_statement_balance):
                pending_await_line = awaiting_statement_line
                awaiting_statement_line = None
                awaiting_statement_balance = 0

    return None


def _find_async_ui_missing_context_guard(
    lines: list[str],
    start_line_number: int,
    await_pattern: re.Pattern[str],
    mounted_check_pattern: re.Pattern[str],
    context_usage_pattern: re.Pattern[str],
) -> dict[str, object] | None:
    pending_await_line: int | None = None
    awaiting_statement_line: int | None = None
    awaiting_statement_balance = 0

    for local_index, line in enumerate(lines):
        if _is_comment(line):
            continue

        absolute_line = start_line_number + local_index + 1

        if awaiting_statement_line is not None:
            awaiting_statement_balance += _statement_balance_delta(line)
            if _statement_is_terminated(line, awaiting_statement_balance):
                pending_await_line = awaiting_statement_line
                awaiting_statement_line = None
                awaiting_statement_balance = 0
            continue

        if mounted_check_pattern.search(line):
            pending_await_line = None
            continue

        has_await = bool(await_pattern.search(line))
        has_context_usage = bool(context_usage_pattern.search(line))

        if pending_await_line is not None and has_context_usage and not has_await:
            return {
                "await_line": pending_await_line,
                "line_number": absolute_line,
                "symbol": line.strip(),
            }

        if has_await:
            awaiting_statement_line = absolute_line
            awaiting_statement_balance = _statement_balance_delta(line)
            if _statement_is_terminated(line, awaiting_statement_balance):
                pending_await_line = awaiting_statement_line
                awaiting_statement_line = None
                awaiting_statement_balance = 0

    return None


def _statement_balance_delta(line: str) -> int:
    return (
        line.count("(")
        + line.count("{")
        + line.count("[")
        - line.count(")")
        - line.count("}")
        - line.count("]")
    )


def _statement_is_terminated(line: str, balance: int) -> bool:
    return ";" in line and balance <= 0


def _collect_annotated_provider_declarations(
    lines: list[str],
    annotation_pattern: re.Pattern[str],
) -> list[dict[str, object]]:
    providers: list[dict[str, object]] = []
    index = 0

    while index < len(lines):
        line = lines[index]
        if _is_comment(line) or not annotation_pattern.search(line):
            index += 1
            continue

        declaration_start = _find_annotated_declaration_start(lines, index + 1)
        if declaration_start < 0:
            index += 1
            continue

        signature, declaration_end = _collect_declaration_signature(lines, declaration_start)
        declaration_line = lines[declaration_start].strip()
        is_class_provider = bool(
            re.search(
                r"^(?:abstract\s+|base\s+|final\s+|interface\s+|sealed\s+)*class\s+\w+",
                declaration_line,
            )
        )

        provider_name = (
            _extract_class_name(signature)
            if is_class_provider
            else _extract_callable_name(signature)
        )
        provider_block: list[str] | None = None
        if is_class_provider and _declaration_has_block(lines, declaration_start):
            provider_block = _extract_block(lines, declaration_start)

        providers.append(
            {
                "name": provider_name or "provider",
                "declaration_start": declaration_start,
                "declaration_end": declaration_end,
                "signature": signature,
                "is_class_provider": is_class_provider,
                "block": provider_block,
            }
        )

        if provider_block is not None:
            index = declaration_start + len(provider_block)
            continue
        index = declaration_end + 1

    return providers


def _collect_family_params_for_provider(
    provider: dict[str, object],
    file_lines: list[str],
) -> list[dict[str, object]]:
    if bool(provider["is_class_provider"]):
        return _collect_class_family_params(provider)
    return _collect_function_family_params(provider, file_lines)


def _collect_class_family_params(
    provider: dict[str, object],
) -> list[dict[str, object]]:
    block = provider.get("block")
    if not isinstance(block, list):
        return []

    build_signature, build_line_offset = _find_class_build_signature(block)
    if not build_signature:
        return []

    declaration_start = int(provider["declaration_start"])
    build_line_number = declaration_start + build_line_offset + 1
    return _extract_family_params(
        build_signature,
        build_line_number,
        skip_ref_param=False,
    )


def _collect_function_family_params(
    provider: dict[str, object],
    file_lines: list[str],
) -> list[dict[str, object]]:
    declaration_start = int(provider["declaration_start"])
    line_number = declaration_start + 1
    signature = str(provider["signature"])
    return _extract_family_params(
        signature,
        line_number,
        skip_ref_param=True,
    )


def _find_class_build_signature(block: list[str]) -> tuple[str | None, int]:
    build_pattern = re.compile(r"\bbuild\s*\(")

    for local_index, line in enumerate(block):
        if _is_comment(line) or not build_pattern.search(line):
            continue
        signature, _ = _collect_declaration_signature(block, local_index)
        return (signature, local_index)

    return (None, -1)


def _extract_family_params(
    signature: str,
    line_number: int,
    *,
    skip_ref_param: bool,
) -> list[dict[str, object]]:
    parameter_source = _extract_parameter_source(signature)
    if parameter_source is None:
        return []

    parameters = _split_parameters(parameter_source)
    if skip_ref_param and parameters:
        first_parameter = parameters[0].strip()
        if re.search(r"\b\w*Ref\b", first_parameter):
            parameters = parameters[1:]

    family_params: list[dict[str, object]] = []
    for raw_parameter in parameters:
        descriptor = _parse_family_parameter(raw_parameter)
        if descriptor is None:
            continue

        family_params.append(
            {
                "name": descriptor["name"],
                "type": descriptor["type"],
                "line_number": line_number,
                "symbol": raw_parameter.strip(),
            }
        )

    return family_params


def _extract_parameter_source(signature: str) -> str | None:
    start = signature.find("(")
    if start < 0:
        return None

    depth = 0
    content_start = -1
    for index in range(start, len(signature)):
        char = signature[index]
        if char == "(":
            depth += 1
            if depth == 1:
                content_start = index + 1
        elif char == ")":
            depth -= 1
            if depth == 0 and content_start >= 0:
                return signature[content_start:index]

    return None


def _split_parameters(parameter_source: str) -> list[str]:
    parameters: list[str] = []
    current: list[str] = []
    angle_depth = 0
    round_depth = 0
    square_depth = 0
    curly_depth = 0

    for char in parameter_source:
        if char == "," and all(
            depth == 0
            for depth in (angle_depth, round_depth, square_depth, curly_depth)
        ):
            candidate = "".join(current).strip()
            if candidate:
                parameters.append(candidate)
            current = []
            continue

        current.append(char)

        if char == "<":
            angle_depth += 1
        elif char == ">":
            angle_depth = max(0, angle_depth - 1)
        elif char == "(":
            round_depth += 1
        elif char == ")":
            round_depth = max(0, round_depth - 1)
        elif char == "[":
            square_depth += 1
        elif char == "]":
            square_depth = max(0, square_depth - 1)
        elif char == "{":
            curly_depth += 1
        elif char == "}":
            curly_depth = max(0, curly_depth - 1)

    trailing = "".join(current).strip()
    if trailing:
        parameters.append(trailing)

    return parameters


def _parse_family_parameter(raw_parameter: str) -> dict[str, str] | None:
    parameter = raw_parameter.strip().strip("{}[]").strip()
    if not parameter:
        return None

    parameter = re.sub(r"\s*=\s*.+$", "", parameter).strip()
    parameter = re.sub(
        r"^(?:required|covariant|final|const|var)\s+",
        "",
        parameter,
    ).strip()
    if not parameter:
        return None

    if parameter.startswith("this."):
        name = parameter.split(".", maxsplit=1)[1].strip()
        return {"name": name, "type": ""}

    name_match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*$", parameter)
    if name_match is None:
        return None

    name = name_match.group(1)
    type_source = parameter[: name_match.start()].strip()
    return {"name": name, "type": type_source}


def _extract_class_name(signature: str) -> str:
    match = re.search(
        r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)",
        signature,
    )
    if match is None:
        return "provider"
    return match.group(1)


def _extract_callable_name(signature: str) -> str:
    prefix = signature.split("(", maxsplit=1)[0]
    identifiers = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", prefix)
    if not identifiers:
        return "provider"
    return identifiers[-1]


def _is_stable_family_param(
    type_source: str,
    stable_scalar_types: set[str],
    unstable_collection_types: set[str],
    type_index: dict[str, dict[str, object]],
) -> bool:
    normalized_type = _normalize_family_type(type_source)
    if not normalized_type:
        return False

    if _is_record_type(normalized_type):
        return True

    if _is_function_type(normalized_type):
        return False

    base_type = _extract_base_type(normalized_type)
    if not base_type:
        return False

    if base_type in stable_scalar_types:
        return True

    if base_type in unstable_collection_types:
        return False

    metadata = type_index.get(base_type)
    if metadata is None:
        return True

    return bool(metadata.get("stable", False))


def _normalize_family_type(type_source: str) -> str:
    cleaned = re.sub(
        r"\b(?:required|covariant|final|const|var)\b",
        "",
        type_source,
    ).strip()
    return cleaned.rstrip("?").strip()


def _is_record_type(type_source: str) -> bool:
    return type_source.startswith("(") and ")" in type_source


def _is_function_type(type_source: str) -> bool:
    return "Function" in type_source or "=>" in type_source


def _extract_base_type(type_source: str) -> str:
    token = re.split(r"[<\s?]", type_source, maxsplit=1)[0].strip()
    if not token:
        return ""
    return token.split(".")[-1]


@lru_cache(maxsize=1)
def _load_project_type_index() -> dict[str, dict[str, object]]:
    workspace_root = _find_workspace_root()
    lib_root = workspace_root / "lib"
    if not lib_root.exists():
        return {}

    type_index: dict[str, dict[str, object]] = {}
    for file_path in lib_root.rglob("*.dart"):
        normalized_path = file_path.as_posix()
        if normalized_path.endswith((".g.dart", ".freezed.dart", ".config.dart")):
            continue
        if "/gen/" in normalized_path:
            continue

        try:
            lines = file_path.read_text(encoding=UTF8_ENCODING).splitlines()
        except OSError:
            continue

        for index, line in enumerate(lines):
            if _is_comment(line):
                continue

            stripped = line.strip()
            enum_match = re.search(r"\benum\s+([A-Za-z_][A-Za-z0-9_]*)", stripped)
            if enum_match:
                type_index[enum_match.group(1)] = {
                    "kind": "enum",
                    "stable": True,
                }
                continue

            class_match = re.search(
                r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)",
                stripped,
            )
            if not class_match:
                continue

            signature, _ = _collect_declaration_signature(lines, index)
            block = _extract_block(lines, index)
            block_content = CONTENT_SEPARATOR.join(block)
            lookbehind = CONTENT_SEPARATOR.join(
                line.strip()
                for line in lines[max(0, index - 4) : index]
                if line.strip() and not _is_comment(line)
            )
            is_freezed = "@freezed" in lookbehind
            is_immutable = "@immutable" in lookbehind
            uses_equatable = bool(
                re.search(
                    r"\b(?:extends|with)\s+[^;{]*\bEquatable(?:Mixin)?\b",
                    signature,
                )
            )
            has_operator_equality = "operator ==" in block_content
            has_hash_code = bool(re.search(r"\bhashCode\b", block_content))
            is_stable = is_freezed or uses_equatable or (
                is_immutable and has_operator_equality and has_hash_code
            ) or (has_operator_equality and has_hash_code)

            type_index[class_match.group(1)] = {
                "kind": "class",
                "stable": is_stable,
            }

    return type_index


def _find_workspace_root() -> Path:
    current = Path.cwd().resolve()
    for candidate in (current, *current.parents):
        if (candidate / "pubspec.yaml").exists():
            return candidate
    return current


def _provider_block_has_review_marker(
    lines: list[str],
    block: list[str],
    block_start: int,
    review_marker_pattern: re.Pattern[str],
    lookbehind_lines: int,
) -> bool:
    block_content = CONTENT_SEPARATOR.join(block)
    if review_marker_pattern.search(block_content):
        return True

    prefix_start = max(0, block_start - lookbehind_lines)
    prefix_content = CONTENT_SEPARATOR.join(lines[prefix_start:block_start])
    return bool(review_marker_pattern.search(prefix_content))


def _find_risky_provider_signature(
    block: list[str],
    block_start: int,
    risky_signature_pattern: re.Pattern[str],
) -> dict[str, object] | None:
    for local_index, line in enumerate(block):
        if _is_comment(line):
            continue

        match = risky_signature_pattern.search(line)
        if not match:
            continue

        member_name = _extract_named_group(match, "member_name") or match.group(0)
        return {
            "member_name": member_name,
            "line_number": block_start + local_index + 1,
            "symbol": line.strip(),
        }

    return None


def _collect_async_identifiers(
    lines: list[str],
    start_line_number: int,
    async_name_pattern: re.Pattern[str],
) -> dict[str, int]:
    identifiers: dict[str, int] = {}
    typed_async_pattern = re.compile(
        r"AsyncValue<.*>\s+(\w+)\s*(?:=|,|\)|\{)"
    )
    watched_async_pattern = re.compile(
        r"(?:final|var|const)\s+(\w+)\s*=\s*ref\.watch\s*\("
    )

    for local_index, line in enumerate(lines):
        if _is_comment(line):
            continue

        typed_match = typed_async_pattern.search(line)
        if typed_match:
            identifiers.setdefault(
                typed_match.group(1),
                start_line_number + local_index + 1,
            )

        watched_match = watched_async_pattern.search(line)
        if watched_match and async_name_pattern.match(watched_match.group(1)):
            identifiers.setdefault(
                watched_match.group(1),
                start_line_number + local_index + 1,
            )

    return identifiers


def _has_async_identifier_access(
    lines: list[str],
    identifier: str,
    access_pattern: str,
) -> bool:
    pattern = re.compile(rf"\b{re.escape(identifier)}{access_pattern}")
    return any(not _is_comment(line) and pattern.search(line) for line in lines)


def _has_async_when_usage(lines: list[str], identifier: str) -> bool:
    pattern = re.compile(
        rf"\b{re.escape(identifier)}\.(?:when|maybeWhen)\s*\("
    )
    return any(not _is_comment(line) and pattern.search(line) for line in lines)


def _has_async_state_builder_usage(lines: list[str], identifier: str) -> bool:
    state_pattern = re.compile(rf"\bstate\s*:\s*{re.escape(identifier)}\b")
    for index, line in enumerate(lines):
        if _is_comment(line) or not state_pattern.search(line):
            continue
        window_start = max(0, index - 3)
        window_end = min(len(lines), index + 4)
        window = CONTENT_SEPARATOR.join(lines[window_start:window_end])
        if "SLAsyncStateBuilder" in window:
            return True
    return False


def _has_async_switch_usage(lines: list[str], identifier: str) -> bool:
    joined = CONTENT_SEPARATOR.join(lines)
    if not re.search(rf"switch\s*\(\s*{re.escape(identifier)}\s*\)", joined):
        return False
    return all(
        token in joined for token in ("AsyncLoading", "AsyncError", "AsyncData")
    )


def _strip_strings_and_comments_preserve_layout(lines: list[str]) -> str:
    content = CONTENT_SEPARATOR.join(lines)
    stripped: list[str] = []
    index = 0
    in_line_comment = False
    in_block_comment = False
    in_single_quote = False
    in_double_quote = False
    in_triple_single_quote = False
    in_triple_double_quote = False

    while index < len(content):
        char = content[index]
        next_two = content[index:index + 2]
        next_three = content[index:index + 3]

        if in_line_comment:
            if char == "\n":
                in_line_comment = False
                stripped.append("\n")
            else:
                stripped.append(" ")
            index += 1
            continue

        if in_block_comment:
            if next_two == "*/":
                stripped.extend("  ")
                index += 2
                in_block_comment = False
                continue
            stripped.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_triple_single_quote:
            if next_three == "'''":
                stripped.extend("   ")
                index += 3
                in_triple_single_quote = False
                continue
            stripped.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_triple_double_quote:
            if next_three == '"""':
                stripped.extend("   ")
                index += 3
                in_triple_double_quote = False
                continue
            stripped.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_single_quote:
            if char == "\\" and index + 1 < len(content):
                stripped.append(" ")
                stripped.append("\n" if content[index + 1] == "\n" else " ")
                index += 2
                continue
            if char == "'":
                stripped.append(" ")
                index += 1
                in_single_quote = False
                continue
            stripped.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_double_quote:
            if char == "\\" and index + 1 < len(content):
                stripped.append(" ")
                stripped.append("\n" if content[index + 1] == "\n" else " ")
                index += 2
                continue
            if char == '"':
                stripped.append(" ")
                index += 1
                in_double_quote = False
                continue
            stripped.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if next_two == "//":
            stripped.extend("  ")
            index += 2
            in_line_comment = True
            continue

        if next_two == "/*":
            stripped.extend("  ")
            index += 2
            in_block_comment = True
            continue

        if next_three == "'''":
            stripped.extend("   ")
            index += 3
            in_triple_single_quote = True
            continue

        if next_three == '"""':
            stripped.extend("   ")
            index += 3
            in_triple_double_quote = True
            continue

        if char == "'":
            stripped.append(" ")
            index += 1
            in_single_quote = True
            continue

        if char == '"':
            stripped.append(" ")
            index += 1
            in_double_quote = True
            continue

        stripped.append(char)
        index += 1

    return "".join(stripped)


def _collect_unique_pattern_matches(
    content: str,
    lines: list[str],
    patterns: list[re.Pattern[str]],
) -> list[tuple[int, str]]:
    matches: list[tuple[int, str]] = []
    seen_lines: set[int] = set()

    for pattern in patterns:
        for match in pattern.finditer(content):
            line_number = content.count("\n", 0, match.start()) + 1
            if line_number in seen_lines:
                continue

            seen_lines.add(line_number)
            matches.append((line_number, lines[line_number - 1].strip()))

    return matches


def _has_allowed_spacing_context(
    lines: list[str],
    line_number: int,
    allowed_context_pattern: re.Pattern[str],
    context_radius: int,
) -> bool:
    return _has_context_pattern(
        lines,
        line_number,
        allowed_context_pattern,
        context_radius,
    )


def _has_context_pattern(
    lines: list[str],
    line_number: int,
    pattern: re.Pattern[str],
    context_radius: int,
) -> bool:
    start_index = max(0, line_number - 1 - context_radius)
    end_index = min(len(lines), line_number + context_radius)
    for index in range(start_index, end_index):
        if pattern.search(lines[index]):
            return True
    return False


def _is_comment(line: str) -> bool:
    stripped = line.strip()
    return any(stripped.startswith(prefix) for prefix in COMMENT_PREFIXES)
