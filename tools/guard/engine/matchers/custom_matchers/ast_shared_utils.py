from __future__ import annotations

import re

CONTENT_SEPARATOR = "\n"
COMMENT_PREFIXES = ("//", "///", "/*", "*")


def _is_comment(line: str) -> bool:
    stripped = line.strip()
    return any(stripped.startswith(prefix) for prefix in COMMENT_PREFIXES)


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
    typed_async_pattern = re.compile(r"AsyncValue<.*>\s+(\w+)\s*(?:=|,|\)|\{)")
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
    pattern = re.compile(rf"\b{re.escape(identifier)}\.(?:when|maybeWhen)\s*\(")
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
    return all(token in joined for token in ("AsyncLoading", "AsyncError", "AsyncData"))


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
        next_two = content[index : index + 2]
        next_three = content[index : index + 3]

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


def _extract_named_group(match: re.Match[str], group_name: str) -> str | None:
    if group_name not in match.re.groupindex:
        return None
    value = match.group(group_name)
    if value is None:
        return None
    return value.strip()
