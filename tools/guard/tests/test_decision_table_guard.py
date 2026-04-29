from __future__ import annotations

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from engine.constants import FORMAT_MARKDOWN
from engine.constants import UTF8_ENCODING
from engine.runner import Runner


POLICY_DIR = Path(__file__).resolve().parents[1] / "policies" / "memox"
SOURCE_RULE = "decision_table_source_coverage"
CASE_RULE = "decision_table_case_coverage"


class DecisionTableGuardTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temp_dir = Path(tempfile.mkdtemp(prefix="memox_dt_guard_"))
        (self._temp_dir / "lib").mkdir()
        (self._temp_dir / "test").mkdir()
        (self._temp_dir / "docs" / "decision-tables").mkdir(parents=True)

    def tearDown(self) -> None:
        shutil.rmtree(self._temp_dir)

    def test_source_with_branch_without_decision_table_markdown_fails(self) -> None:
        self._write(
            "lib/foo.dart",
            """
class Foo {
  int value(bool enabled) {
    if (enabled) {
      return 1;
    }
    return 0;
  }
}
""",
        )

        result = self._run_rule(SOURCE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("Behavioral source file", result.violations[0].message_params["detail"])
        self.assertIn(FORMAT_MARKDOWN, result.violations[0].message_params["detail"])

    def test_dart_comment_decision_table_without_markdown_fails(self) -> None:
        self._write(
            "lib/foo.dart",
            """
class Foo {
  int value(bool enabled) {
    if (enabled) {
      return 1;
    }
    return 0;
  }
}
""",
        )
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/foo.dart';

void main() {
  // Decision table: value
  // | ID | Branch / condition | Given | When | Then |
  // | DT1 | enabled flag is true | value receives true | function runs | one is returned |
  test('DT1 value: returns one for enabled flag', () {});
}
""",
        )

        result = self._run_rule(SOURCE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn(FORMAT_MARKDOWN, result.violations[0].message_params["detail"])

    def test_pure_token_source_without_decision_table_passes(self) -> None:
        self._write(
            "lib/tokens.dart",
            """
abstract final class Tokens {
  static const double gap = 8;
}
""",
        )

        result = self._run_rule(SOURCE_RULE)

        self.assertEqual(result.violation_count, 0)

    def test_screen_delete_signal_requires_on_delete_table(self) -> None:
        self._write(
            "lib/presentation/features/demo/screens/demo_screen.dart",
            """
class DemoScreen {
  void deleteItem() {}
}
""",
        )
        self._write(
            "test/demo_screen_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/features/demo/screens/demo_screen.dart';

void main() {
  test('DT1 onOpen: loads initial state', () {});
  test('DT1 onDisplay: renders content', () {});
}
""",
        )
        self._write_dt_doc(
            "demo_screen_test.md",
            "test/demo_screen_test.dart",
            """
## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | route contains a valid demo id | demo route is opened with an id | screen opens | initial state is requested | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | query returns display data | demo state has loaded content | screen renders | content is visible | C0+C1 |
""",
        )

        result = self._run_rule(SOURCE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("onDelete", result.violations[0].message_params["detail"])

    def test_decision_table_row_without_matching_test_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | raw content contains one structured row | parser runs with structured text format | one preview item is returned | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 2)
        self.assertTrue(
            any(
                "has no matching test" in violation.message_params["detail"]
                for violation in result.violations
            )
        )

    def test_dt_named_test_without_matching_markdown_row_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
  test('DT2 parseRows: rejects invalid row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | raw content contains one structured row | parser runs with structured text format | one preview item is returned | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("has no matching Decision Table row", result.violations[0].message_params["detail"])

    def test_dt_ids_can_restart_per_event(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 onOpen: loads route data', () {});
  test('DT1 onDisplay: renders data', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid route branch | route exists with an entity id | screen is opened by router | initial data is requested | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded data branch | query returns display data | screen renders loaded state | content appears in the page | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 0)

    def test_integration_test_file_path_is_allowed(self) -> None:
        self._write(
            "integration_test/app_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DT1 onOpen: boots integration app shell', (tester) async {});
}
""",
        )
        self._write_dt_doc(
            "integration_test/app_test.md",
            "integration_test/app_test.dart",
            """
## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | integration binding opens the app shell | app test starts with an integration root | widget test pumps the app shell | app shell is visible to the tester | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 0)

    def test_integration_entrypoint_reads_imported_case_modules(self) -> None:
        self._write(
            "integration_test/app_test.dart",
            """
import 'package:integration_test/integration_test.dart';

import 'cases/folder_flow_case.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  folderFlowTests();
}
""",
        )
        self._write(
            "integration_test/cases/folder_flow_case.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void folderFlowTests() {
  testWidgets('DT1 onInsert: creates a folder from the app entrypoint', (tester) async {});
}
""",
        )
        self._write_dt_doc(
            "integration_test/app_test.md",
            "integration_test/app_test.dart",
            """
## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | integration entrypoint imports a folder flow case module | app test calls the folder flow registration function | the guard reads app test metadata | imported case test name satisfies the markdown row | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 0)

    def test_generated_source_is_ignored(self) -> None:
        self._write(
            "lib/foo.g.dart",
            """
class FooGenerated {
  int value(bool enabled) {
    if (enabled) {
      return 1;
    }
    return 0;
  }
}
""",
        )

        result = self._run_rule(SOURCE_RULE)

        self.assertEqual(result.violation_count, 0)

    def test_markdown_document_without_test_file_fails(self) -> None:
        self._write_dt_doc(
            "missing_test.md",
            "test/missing_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | raw content contains one structured row | parser runs with structured text format | one preview item is returned | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("missing test file", result.violations[0].message_params["detail"])

    def test_test_file_without_markdown_document_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
}
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("no Decision Table markdown", result.violations[0].message_params["detail"])

    def test_placeholder_decision_table_row_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | parses row | arranged state | action under test | expected behavior | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("incomplete placeholder", result.violations[0].message_params["detail"])

    def test_generic_decision_table_filler_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | branch for valid row | raw content contains a front and back pair | parser runs with structured text format | observable result proves the parser branch behaves as specified | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("generic DT filler", result.violations[0].message_params["detail"])

    def test_generated_fixture_decision_table_filler_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | test fixture creates the valid row scenario with required input state | parser runs with structured text format | one preview item is returned | C0+C1 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("test fixture creates", result.violations[0].message_params["detail"])

    def test_markdown_table_without_coverage_header_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then |
| --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | raw content contains one structured row | parser runs with structured text format | one preview item is returned |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertTrue(
            any(
                "Coverage" in violation.message_params["detail"]
                for violation in result.violations
            )
        )

    def test_table_missing_c1_coverage_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | raw content contains one structured row | parser runs with structured text format | one preview item is returned | C0 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertEqual(result.violation_count, 1)
        self.assertIn("missing: C1", result.violations[0].message_params["detail"])

    def test_invalid_coverage_level_fails(self) -> None:
        self._write(
            "test/foo_test.dart",
            """
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DT1 parseRows: parses valid row', () {});
}
""",
        )
        self._write_dt_doc(
            "foo_test.md",
            "test/foo_test.dart",
            """
## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | valid row contains a front and back pair | raw content contains one structured row | parser runs with structured text format | one preview item is returned | C2 |
""",
        )

        result = self._run_rule(CASE_RULE)

        self.assertTrue(
            any(
                "invalid coverage" in violation.message_params["detail"]
                for violation in result.violations
            )
        )

    def _run_rule(self, rule_id: str):
        runner = Runner(POLICY_DIR, self._temp_dir)
        results = runner.run(rule_ids=[rule_id])
        self.assertEqual(len(results), 1)
        return results[0]

    def _write(self, rel_path: str, content: str) -> None:
        path = self._temp_dir / rel_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content.strip() + "\n", encoding=UTF8_ENCODING)

    def _write_dt_doc(self, rel_path: str, test_rel_path: str, body: str) -> None:
        self._write(
            f"docs/decision-tables/{rel_path}",
            f"""
# Decision Tables: {Path(test_rel_path).stem}

Test file: `{test_rel_path}`

{body.strip()}
""",
        )


if __name__ == "__main__":
    unittest.main()
