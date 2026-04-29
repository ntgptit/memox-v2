from __future__ import annotations

from dataclasses import dataclass
import fnmatch
from pathlib import Path
import re

from ..constants import UTF8_ENCODING
from ..file_scanner import FileScanner
from ..models import Rule
from ..models import Violation

DEFAULT_SOURCE_SCOPE = "non_legacy_app_source"
DEFAULT_TEST_ROOTS = ("test",)
DEFAULT_DT_ROOTS = ("docs/decision-tables",)
DT_DOC_SKIP_NAMES = {"README.md"}
DT_MD_EVENT_PATTERN = re.compile(
    r"^\s*#{2,6}\s*(?:Decision table:\s*)?(?P<event>[A-Za-z][A-Za-z0-9_]*)\s*$",
)
DT_DOC_TEST_FILE_PATTERN = re.compile(
    r"^\s*Test file:\s*`(?P<test_path>(?:test|integration_test)/[^`]+_test\.dart)`\s*$",
)
DT_HEADER_PATTERN = re.compile(r"^\s*\|[^|]*\bID\b[^|]*\|")
DT_ROW_PATTERN = re.compile(r"^\s*\|\s*(?P<case_id>DT\d+)\s*\|(?P<cells>.*)$")
DT_TEST_PATTERN = re.compile(
    r"\btest(?:Widgets)?\s*\(\s*(?P<quote>['\"])(?P<case_id>DT\d+)\s+"
    r"(?P<event>[A-Za-z][A-Za-z0-9_]*):",
    re.S,
)
LOCAL_DART_IMPORT_PATTERN = re.compile(
    r"(?m)^\s*import\s+(?P<quote>['\"])(?P<path>(?!dart:|package:)[^'\"]+\.dart)(?P=quote)"
)
BRANCH_PATTERN = re.compile(r"\b(?:if|switch|case|catch|try)\b")
METHOD_PATTERN = re.compile(
    r"(?m)^\s*(?:static\s+)?(?:Future(?:<[^>]+>)?|void|bool|int|double|"
    r"String|Widget|[A-Z][A-Za-z0-9_<>?, ]*)\s+_?[A-Za-z][A-Za-z0-9_]*"
    r"\s*\([^;]*\)\s*(?:async\s*)?(?:\{|=>)"
)
CLASS_PATTERN = re.compile(r"\bclass\s+(?P<class_name>[A-Za-z_][A-Za-z0-9_]*)")
FUNCTION_PATTERN = re.compile(
    r"(?m)^\s*(?:Future(?:<[^>]+>)?|void|bool|int|double|String|"
    r"[A-Z][A-Za-z0-9_<>?, ]*)\s+(?P<function_name>[a-zA-Z_][A-Za-z0-9_]*)"
    r"\s*\("
)
PURE_DECLARATION_PATTERNS = (
    re.compile(r"^\s*(?:import|export)\s+"),
    re.compile(r"^\s*(?:abstract\s+final\s+)?class\s+\w+\s*\{\s*$"),
    re.compile(r"^\s*(?:enum|typedef)\s+"),
    re.compile(r"^\s*(?:static\s+)?const\s+"),
    re.compile(r"^\s*final\s+"),
    re.compile(r"^\s*[{});,]\s*$"),
)
EVENT_SPECS = (
    ("onInsert", re.compile(r"\b(?:onInsert|onCreate|create\w*|add\w*|insert\w*)\s*(?:[:=(])", re.I)),
    ("onUpdate", re.compile(r"\b(?:onUpdate|onEdit|onSave|update\w*|edit\w*|save\w*|rename\w*)\s*(?:[:=(])", re.I)),
    ("onDelete", re.compile(r"\b(?:onDelete|delete\w*|remove\w*)\s*(?:[:=(])", re.I)),
    ("onMove", re.compile(r"\b(?:onMove|onReorder|move\w*|reorder\w*)\s*(?:[:=(])", re.I)),
    ("onSelect", re.compile(r"\b(?:onSelect|onSelection|toggleSelection|bulk\w*)\s*(?:[:=(])", re.I)),
    ("onSearchFilterSort", re.compile(r"\b(?:onSearch|onFilter|onSort|search\w*|filter\w*|sort\w*)\s*(?:[:=(])", re.I)),
    ("onRefreshRetry", re.compile(r"\b(?:onRetry|onRefresh|refresh\w*|retry\w*|invalidate)\s*(?:[:=(])", re.I)),
    (
        "onNavigate",
        re.compile(r"\b(?:goNamed|pushNamed|pushReplacementNamed|pop\s*\(|RouteNames|Navigator|GoRouter)\b"),
    ),
    (
        "onExternalChange",
        re.compile(r"\b(?:Stream<|StreamController)\b"),
    ),
    ("onDispose", re.compile(r"\b(?:dispose|onDispose|Timer|Controller)\b")),
)
MIN_DT_CELL_WORDS = 2
MIN_DT_CELL_LENGTH = 8
DT_REQUIRED_CELL_COUNT = 6
DT_COVERAGE_CELL_INDEX = 5
COVERAGE_HEADER = "coverage"
COVERAGE_C0 = "C0"
COVERAGE_C1 = "C1"
COVERAGE_LEVELS = frozenset({COVERAGE_C0, COVERAGE_C1})
INCOMPLETE_CELL_VALUES = {
    "",
    "action",
    "action under test",
    "arranged state",
    "assert",
    "branch",
    "branch / condition",
    "condition",
    "expected behavior",
    "given",
    "n/a",
    "none",
    "state",
    "then",
    "todo",
    "tbd",
    "when",
}
INCOMPLETE_CELL_PHRASES = (
    "action under test",
    "arranged state",
    "assertions verify",
    "behavior under test is triggered",
    "behaves as specified",
    "branch for ",
    "command under test",
    "configured for this scenario",
    "delete/action-sheet path runs",
    "expected behavior",
    "for the branch",
    "insert/import flow runs",
    "matches the branch condition",
    "observable result proves",
    "query flow runs",
    "repository fixtures contain",
    "refresh or preview flow runs",
    "screen/provider enters",
    "selection gesture runs",
    "test fixture creates",
    "through the visible ui or returned state",
    "user triggers the navigation path",
    "widget tree renders",
    "widget or helper state matches",
)


@dataclass(frozen=True)
class DecisionTableRow:
    case_id: str
    line_number: int
    cells: tuple[str, ...]


@dataclass(frozen=True)
class DecisionTable:
    event: str
    line_number: int
    has_header: bool
    header_cells: tuple[str, ...]
    rows: tuple[DecisionTableRow, ...]

    @property
    def case_ids(self) -> tuple[str, ...]:
        return tuple(row.case_id for row in self.rows)


@dataclass(frozen=True)
class DecisionTableDoc:
    path: Path
    rel_path: str
    test_rel_path: str
    test_line_number: int
    tables: tuple[DecisionTable, ...]

    @property
    def events(self) -> set[str]:
        return {table.event for table in self.tables}

    @property
    def has_decision_table(self) -> bool:
        return bool(self.tables)


@dataclass(frozen=True)
class TestFileInfo:
    path: Path
    rel_path: str
    content: str
    test_cases: frozenset[tuple[str, str]]


def check_case_coverage(rule: Rule, scanner: FileScanner) -> list[Violation]:
    violations: list[Violation] = []
    test_infos = _read_test_infos(scanner, rule)
    test_infos_by_path = {test.rel_path: test for test in test_infos}
    docs = _read_dt_docs(scanner, rule)
    docs_by_test: dict[str, list[DecisionTableDoc]] = {}
    doc_cases_by_test: dict[str, set[tuple[str, str]]] = {}

    for doc in docs:
        if not doc.test_rel_path:
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    1,
                    "Test file",
                    {
                        "detail": (
                            "Decision Table markdown must declare its test file "
                            "with `Test file: `test/..._test.dart`` or "
                            "`Test file: `integration_test/..._test.dart``."
                        ),
                    },
                )
            )
            continue

        docs_by_test.setdefault(doc.test_rel_path, []).append(doc)
        test_info = test_infos_by_path.get(doc.test_rel_path)
        if test_info is None:
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    doc.test_line_number,
                    doc.test_rel_path,
                    {
                        "detail": (
                            f"Decision Table markdown points to missing test file "
                            f"`{doc.test_rel_path}`."
                        ),
                    },
                )
            )
            continue

        if not doc.has_decision_table:
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    1,
                    "Decision table",
                    {"detail": "Decision Table markdown contains no event table."},
                )
            )
            continue

        doc_cases = doc_cases_by_test.setdefault(doc.test_rel_path, set())
        for table in doc.tables:
            _check_table(rule, doc, table, test_info, doc_cases, violations)

    for test_info in test_infos:
        doc_cases = doc_cases_by_test.get(test_info.rel_path)
        if doc_cases is None:
            violations.append(
                _violation(
                    rule,
                    test_info.rel_path,
                    1,
                    Path(test_info.rel_path).name,
                    {
                        "detail": (
                            "Test file has no Decision Table markdown document "
                            "under `docs/decision-tables/**`."
                        ),
                    },
                )
            )
            continue

        for event, case_id in sorted(test_info.test_cases):
            if (event, case_id) in doc_cases:
                continue
            violations.append(
                _violation(
                    rule,
                    test_info.rel_path,
                    1,
                    f"{case_id} {event}",
                    {
                        "detail": (
                            f"Test `{case_id} {event}:` has no matching "
                            "Decision Table row in markdown."
                        ),
                    },
                )
            )

        if not test_info.test_cases:
            violations.append(
                _violation(
                    rule,
                    test_info.rel_path,
                    1,
                    Path(test_info.rel_path).name,
                    {
                        "detail": (
                            "Test file has no `DT<number> <eventName>:` test "
                            "case names to match its Decision Table markdown."
                        ),
                    },
                )
            )

    return violations


def check_source_coverage(rule: Rule, scanner: FileScanner) -> list[Violation]:
    source_scope = rule.params.get("source_scope", DEFAULT_SOURCE_SCOPE)
    test_infos = _read_test_infos(scanner, rule)
    docs_by_test = _docs_by_test(_read_dt_docs(scanner, rule))
    violations: list[Violation] = []

    for source_path, rel_path in scanner.resolve_scope(source_scope):
        if _matches_any(rel_path, tuple(rule.params.get("exclude_source_paths", []))):
            continue

        content = _read_text(source_path)
        stripped = _strip_comments_and_strings(content)
        if not _is_behavioral_source(rel_path, stripped, rule):
            continue

        matching_tests = _find_matching_tests(rel_path, content, test_infos)
        matching_docs = [
            doc
            for test_info in matching_tests
            for doc in docs_by_test.get(test_info.rel_path, ())
        ]
        if not matching_docs:
            violations.append(
                _violation(
                    rule,
                    rel_path,
                    1,
                    _primary_symbol(content, source_path),
                    {
                        "detail": (
                            "Behavioral source file has no matching Decision "
                            "Table markdown document under `docs/decision-tables/**`."
                        ),
                    },
                )
            )
            continue

        required_events = _required_events(rel_path, stripped)
        if not required_events:
            continue

        available_events = set().union(*(doc.events for doc in matching_docs))
        missing_events = sorted(required_events - available_events)
        if not missing_events:
            continue

        violations.append(
            _violation(
                rule,
                rel_path,
                1,
                _primary_symbol(content, source_path),
                {
                    "detail": (
                        "Matching Decision Table markdown is missing required "
                        f"event table(s): {', '.join(missing_events)}."
                    ),
                },
            )
        )

    return violations


def _check_table(
    rule: Rule,
    doc: DecisionTableDoc,
    table: DecisionTable,
    test_info: TestFileInfo,
    doc_cases: set[tuple[str, str]],
    violations: list[Violation],
) -> None:
    if not table.has_header:
        violations.append(
            _violation(
                rule,
                doc.rel_path,
                table.line_number,
                table.event,
                {
                    "detail": (
                        f"Decision table `{table.event}` is missing "
                        "the `| ID |` header."
                    ),
                },
            )
        )
    elif not _header_has_coverage(table.header_cells):
        violations.append(
            _violation(
                rule,
                doc.rel_path,
                table.line_number,
                table.event,
                {
                    "detail": (
                        f"Decision table `{table.event}` is missing the "
                        "`Coverage` header for C0/C1 declaration."
                    ),
                },
            )
        )

    seen_in_table: set[str] = set()
    table_coverage: set[str] = set()
    has_row_validation_error = False
    for row in table.rows:
        key = (table.event, row.case_id)
        if row.case_id in seen_in_table:
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    row.line_number,
                    row.case_id,
                    {
                        "detail": (
                            f"Decision table `{table.event}` declares "
                            f"`{row.case_id}` more than once."
                        ),
                    },
                )
            )
        seen_in_table.add(row.case_id)

        if key in doc_cases:
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    row.line_number,
                    row.case_id,
                    {
                        "detail": (
                            f"Decision table case `{row.case_id} {table.event}` "
                            f"is declared more than once for `{doc.test_rel_path}`."
                        ),
                    },
                )
            )
        doc_cases.add(key)

        if key not in test_info.test_cases:
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    row.line_number,
                    row.case_id,
                    {
                        "detail": (
                            f"Decision table case `{row.case_id} {table.event}` "
                            f"has no matching test name in `{doc.test_rel_path}`."
                        ),
                    },
                )
            )

        incomplete_detail = _row_incomplete_detail(table.event, row)
        if incomplete_detail:
            has_row_validation_error = True
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    row.line_number,
                    row.case_id,
                    {"detail": incomplete_detail},
                )
            )
            continue

        coverage_detail = _coverage_detail(table.event, row)
        if coverage_detail:
            has_row_validation_error = True
            violations.append(
                _violation(
                    rule,
                    doc.rel_path,
                    row.line_number,
                    row.case_id,
                    {"detail": coverage_detail},
                )
            )
            continue
        table_coverage.update(_coverage_levels(row.cells[DT_COVERAGE_CELL_INDEX]))

    missing_coverage = sorted(COVERAGE_LEVELS - table_coverage)
    if table.rows and missing_coverage and not has_row_validation_error:
        violations.append(
            _violation(
                rule,
                doc.rel_path,
                table.line_number,
                table.event,
                {
                    "detail": (
                        f"Decision table `{table.event}` must declare both "
                        f"C0 and C1 coverage; missing: {', '.join(missing_coverage)}."
                    ),
                },
            )
        )


def _read_test_infos(scanner: FileScanner, rule: Rule) -> list[TestFileInfo]:
    infos: list[TestFileInfo] = []
    for test_root in tuple(rule.params.get("test_roots", DEFAULT_TEST_ROOTS)):
        root = scanner.root / test_root
        if not root.exists():
            continue

        for test_path in sorted(root.rglob("*_test.dart")):
            rel_path = _normalize(test_path, scanner.root)
            if _matches_any(rel_path, tuple(rule.params.get("exclude_test_paths", []))):
                continue

            content = _read_test_content(test_path, scanner.root)
            infos.append(
                TestFileInfo(
                    path=test_path,
                    rel_path=rel_path,
                    content=content,
                    test_cases=frozenset(_parse_test_cases(content)),
                )
            )
    return infos


def _read_dt_docs(scanner: FileScanner, rule: Rule) -> list[DecisionTableDoc]:
    docs: list[DecisionTableDoc] = []
    for doc_root in tuple(rule.params.get("decision_table_roots", DEFAULT_DT_ROOTS)):
        root = scanner.root / doc_root
        if not root.exists():
            continue

        for doc_path in sorted(root.rglob("*.md")):
            if doc_path.name in DT_DOC_SKIP_NAMES:
                continue
            rel_path = _normalize(doc_path, scanner.root)
            if _matches_any(rel_path, tuple(rule.params.get("exclude_decision_table_paths", []))):
                continue
            docs.append(_parse_markdown_doc(doc_path, scanner.root))
    return docs


def _parse_markdown_doc(path: Path, root: Path) -> DecisionTableDoc:
    content = _read_text(path)
    test_rel_path = ""
    test_line_number = 1
    tables: list[DecisionTable] = []
    current_event = ""
    current_line = 0
    current_has_header = False
    current_header_cells: tuple[str, ...] = ()
    current_rows: list[DecisionTableRow] = []

    def flush() -> None:
        nonlocal current_event
        nonlocal current_line
        nonlocal current_has_header
        nonlocal current_header_cells
        nonlocal current_rows
        if not current_event:
            return
        tables.append(
            DecisionTable(
                event=current_event,
                line_number=current_line,
                has_header=current_has_header,
                header_cells=current_header_cells,
                rows=tuple(current_rows),
            )
        )
        current_event = ""
        current_line = 0
        current_has_header = False
        current_header_cells = ()
        current_rows = []

    for index, line in enumerate(content.splitlines(), start=1):
        test_match = DT_DOC_TEST_FILE_PATTERN.match(line)
        if test_match is not None:
            test_rel_path = test_match.group("test_path")
            test_line_number = index
            continue

        event_match = DT_MD_EVENT_PATTERN.match(line)
        if event_match is not None:
            flush()
            current_event = event_match.group("event")
            current_line = index
            continue

        if not current_event:
            continue

        if DT_HEADER_PATTERN.match(line):
            current_has_header = True
            current_header_cells = _split_table_cells(line)
            continue

        row_match = DT_ROW_PATTERN.match(line)
        if row_match is not None:
            current_rows.append(
                DecisionTableRow(
                    case_id=row_match.group("case_id"),
                    line_number=index,
                    cells=_split_table_cells(line),
                )
            )

    flush()
    return DecisionTableDoc(
        path=path,
        rel_path=_normalize(path, root),
        test_rel_path=test_rel_path,
        test_line_number=test_line_number,
        tables=tuple(tables),
    )


def _split_table_cells(line: str) -> tuple[str, ...]:
    stripped = line.strip()
    if stripped.startswith("|"):
        stripped = stripped[1:]
    if stripped.endswith("|"):
        stripped = stripped[:-1]
    return tuple(cell.strip() for cell in stripped.split("|"))


def _header_has_coverage(cells: tuple[str, ...]) -> bool:
    return any(cell.strip().lower() == COVERAGE_HEADER for cell in cells)


def _row_incomplete_detail(event: str, row: DecisionTableRow) -> str:
    if len(row.cells) < DT_REQUIRED_CELL_COUNT:
        return (
            f"Decision table `{event}` row `{row.case_id}` must include "
            "`ID`, `Branch / condition`, `Given`, `When`, `Then`, and "
            "`Coverage` cells."
        )

    content_cells = row.cells[1:DT_COVERAGE_CELL_INDEX]
    for index, cell in enumerate(content_cells, start=2):
        normalized = re.sub(r"\s+", " ", cell).strip().lower()
        if normalized in INCOMPLETE_CELL_VALUES:
            return (
                f"Decision table `{event}` row `{row.case_id}` has an "
                f"incomplete placeholder in column {index}: `{cell}`."
            )
        incomplete_phrase = next(
            (phrase for phrase in INCOMPLETE_CELL_PHRASES if phrase in normalized),
            "",
        )
        if incomplete_phrase:
            return (
                f"Decision table `{event}` row `{row.case_id}` column {index} "
                f"still uses generic DT filler: `{incomplete_phrase}`."
            )
        if len(normalized) < MIN_DT_CELL_LENGTH:
            return (
                f"Decision table `{event}` row `{row.case_id}` column {index} "
                "is too short to describe a real branch, setup, action, or expectation."
            )
        if len(re.findall(r"[A-Za-zÀ-ỹ0-9_]+", normalized)) < MIN_DT_CELL_WORDS:
            return (
                f"Decision table `{event}` row `{row.case_id}` column {index} "
                "must describe the branch, setup, action, or expectation with more detail."
            )

    return ""


def _coverage_detail(event: str, row: DecisionTableRow) -> str:
    coverage = row.cells[DT_COVERAGE_CELL_INDEX].strip()
    if not coverage:
        return (
            f"Decision table `{event}` row `{row.case_id}` must declare "
            "C0, C1, or C0+C1 coverage."
        )
    levels = _coverage_levels(coverage)
    if not levels:
        return (
            f"Decision table `{event}` row `{row.case_id}` has invalid "
            f"coverage `{coverage}`; use C0, C1, or C0+C1."
        )
    return ""


def _coverage_levels(raw: str) -> set[str]:
    parts = {
        part.strip().upper()
        for part in re.split(r"[+,/ ]+", raw)
        if part.strip()
    }
    if not parts or not parts.issubset(COVERAGE_LEVELS):
        return set()
    return parts


def _parse_test_cases(content: str) -> set[tuple[str, str]]:
    return {
        (match.group("event"), match.group("case_id"))
        for match in DT_TEST_PATTERN.finditer(content)
    }


def _docs_by_test(docs: list[DecisionTableDoc]) -> dict[str, list[DecisionTableDoc]]:
    result: dict[str, list[DecisionTableDoc]] = {}
    for doc in docs:
        if not doc.test_rel_path:
            continue
        result.setdefault(doc.test_rel_path, []).append(doc)
    return result


def _is_behavioral_source(rel_path: str, stripped_content: str, rule: Rule) -> bool:
    if _looks_like_pure_declaration(stripped_content):
        return False

    forced_patterns = tuple(rule.params.get("behavior_path_patterns", []))
    if forced_patterns and _matches_any(rel_path, forced_patterns):
        return True

    if BRANCH_PATTERN.search(stripped_content):
        return True
    if "@riverpod" in stripped_content:
        return True
    if re.search(r"\b(?:Notifier|AsyncNotifier|ViewModel|Controller|Action)\b", stripped_content):
        return True
    return bool(METHOD_PATTERN.search(stripped_content))


def _looks_like_pure_declaration(content: str) -> bool:
    meaningful_lines = [
        line.strip()
        for line in content.splitlines()
        if line.strip() and not line.strip().startswith("@")
    ]
    if not meaningful_lines:
        return True
    return all(
        any(pattern.search(line) for pattern in PURE_DECLARATION_PATTERNS)
        for line in meaningful_lines
    )


def _required_events(rel_path: str, stripped_content: str) -> set[str]:
    events: set[str] = set()
    is_screen = "/screens/" in rel_path and rel_path.endswith("_screen.dart")
    is_feature_widget = "/widgets/" in rel_path and rel_path.startswith(
        "lib/presentation/features/"
    )

    if is_screen:
        events.update({"onOpen", "onDisplay"})

    if not (is_screen or is_feature_widget):
        return events

    for event_name, pattern in EVENT_SPECS:
        if pattern.search(stripped_content):
            events.add(event_name)
    return events


def _find_matching_tests(
    rel_path: str,
    content: str,
    test_infos: list[TestFileInfo],
) -> list[TestFileInfo]:
    source_stem = Path(rel_path).stem
    expected_test_name = f"{source_stem}_test.dart"
    symbols = _source_symbols(content, Path(rel_path))
    directory_hints = _directory_test_hints(rel_path)

    matches: list[TestFileInfo] = []
    for test_info in test_infos:
        test_name = Path(test_info.rel_path).name
        if test_name == expected_test_name:
            matches.append(test_info)
            continue

        if any(symbol and symbol in test_info.content for symbol in symbols):
            matches.append(test_info)
            continue

        if any(hint in test_info.rel_path for hint in directory_hints):
            matches.append(test_info)

    return matches


def _source_symbols(content: str, source_path: Path) -> set[str]:
    symbols = {_pascal_case(source_path.stem), source_path.stem}
    symbols.update(match.group("class_name") for match in CLASS_PATTERN.finditer(content))
    symbols.update(
        match.group("function_name")
        for match in FUNCTION_PATTERN.finditer(content)
        if not match.group("function_name").startswith("_")
    )
    return symbols


def _primary_symbol(content: str, source_path: Path) -> str:
    for symbol in _source_symbols(content, source_path):
        if symbol and symbol != source_path.stem:
            return symbol
    return source_path.stem


def _directory_test_hints(rel_path: str) -> tuple[str, ...]:
    parts = rel_path.split("/")
    if len(parts) < 2:
        return ()

    hints: list[str] = []
    if rel_path.startswith("lib/core/theme/"):
        hints.append("test/core/theme/")
    elif rel_path.startswith("lib/core/errors/"):
        hints.append("test/core/errors/")
    elif rel_path.startswith("lib/core/network/"):
        hints.append("test/core/network/")
    elif rel_path.startswith("lib/data/datasources/local/"):
        hints.append("test/data/datasources/local/")
    elif rel_path.startswith("lib/data/mappers/"):
        hints.append("test/data/")
    elif rel_path.startswith("lib/data/repositories/"):
        hints.append("test/data/repositories/")
    elif rel_path.startswith("lib/data/settings/"):
        hints.append("test/data/")
    elif rel_path.startswith("lib/domain/"):
        hints.append("test/domain/")
    elif rel_path.startswith("lib/app/"):
        hints.append("test/app/")
    elif len(parts) > 3 and parts[:3] == ["lib", "presentation", "features"]:
        feature = parts[3]
        hints.append(f"test/presentation/{feature}")
        hints.append(f"test/presentation/{feature.rstrip('s')}")
    elif rel_path.startswith("lib/presentation/shared/"):
        hints.append("test/presentation/")
        hints.append("test/widget_test.dart")
    return tuple(hints)


def _matches_any(rel_path: str, patterns: tuple[str, ...]) -> bool:
    return any(fnmatch.fnmatch(rel_path, pattern) for pattern in patterns)


def _strip_comments_and_strings(content: str) -> str:
    result: list[str] = []
    index = 0
    in_line_comment = False
    in_block_comment = False
    in_single = False
    in_double = False

    while index < len(content):
        char = content[index]
        pair = content[index : index + 2]

        if in_line_comment:
            if char == "\n":
                in_line_comment = False
                result.append("\n")
            else:
                result.append(" ")
            index += 1
            continue

        if in_block_comment:
            if pair == "*/":
                result.extend("  ")
                index += 2
                in_block_comment = False
                continue
            result.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_single:
            if char == "\\" and index + 1 < len(content):
                result.extend("  ")
                index += 2
                continue
            if char == "'":
                in_single = False
            result.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_double:
            if char == "\\" and index + 1 < len(content):
                result.extend("  ")
                index += 2
                continue
            if char == '"':
                in_double = False
            result.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if pair == "//":
            result.extend("  ")
            index += 2
            in_line_comment = True
            continue
        if pair == "/*":
            result.extend("  ")
            index += 2
            in_block_comment = True
            continue
        if char == "'":
            in_single = True
            result.append(" ")
            index += 1
            continue
        if char == '"':
            in_double = True
            result.append(" ")
            index += 1
            continue

        result.append(char)
        index += 1

    return "".join(result)


def _read_text(path: Path) -> str:
    return path.read_text(encoding=UTF8_ENCODING)


def _read_test_content(path: Path, root: Path) -> str:
    content = _read_text(path)
    if not _normalize(path, root).startswith("integration_test/"):
        return content

    module_contents: list[str] = []
    for match in LOCAL_DART_IMPORT_PATTERN.finditer(content):
        module_path = (path.parent / match.group("path")).resolve()
        if not _is_inside(module_path, root):
            continue
        if not module_path.exists() or module_path.name.endswith("_test.dart"):
            continue
        module_contents.append(_read_text(module_path))

    if not module_contents:
        return content
    return "\n".join([content, *module_contents])


def _is_inside(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root.resolve())
    except ValueError:
        return False
    return True


def _normalize(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def _pascal_case(value: str) -> str:
    return "".join(part.capitalize() for part in value.split("_") if part)


def _violation(
    rule: Rule,
    rel_path: str,
    line_number: int,
    symbol: str,
    message_params: dict[str, str],
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
        message_params=message_params,
    )
