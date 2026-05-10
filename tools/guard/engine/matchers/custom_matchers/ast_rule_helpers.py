from __future__ import annotations

from functools import lru_cache
from pathlib import Path
import re

from ...constants import UTF8_ENCODING
from .ast_shared_utils import _is_comment

CONTENT_SEPARATOR = "\n"
OPENING_BRACE = "{"
CLOSING_BRACE = "}"


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
            cleanup_methods = [str(method) for method in spec.get("cleanup_methods", [])]
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
    del file_lines
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
            depth == 0 for depth in (angle_depth, round_depth, square_depth, curly_depth)
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
                type_index[enum_match.group(1)] = {"kind": "enum", "stable": True}
                continue

            class_match = re.search(r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)", stripped)
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

            type_index[class_match.group(1)] = {"kind": "class", "stable": is_stable}

    return type_index


def _find_workspace_root() -> Path:
    current = Path.cwd().resolve()
    for candidate in (current, *current.parents):
        if (candidate / "pubspec.yaml").exists():
            return candidate
    return current
