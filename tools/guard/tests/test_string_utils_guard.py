from __future__ import annotations

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from engine.constants import UTF8_ENCODING
from engine.runner import Runner


POLICY_DIR = Path(__file__).resolve().parents[1] / "policies" / "memox"
RULE_ID = "app_string_normalization_uses_string_utils"


class StringUtilsGuardTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temp_dir = Path(tempfile.mkdtemp(prefix="memox_string_utils_guard_"))

    def tearDown(self) -> None:
        shutil.rmtree(self._temp_dir)

    def test_direct_to_lower_case_in_app_source_fails(self) -> None:
        self._write(
            "lib/demo/demo_matcher.dart",
            """
final class DemoMatcher {
  bool matches(String left, String right) {
    return left.trim().toLowerCase() == right.trim().toLowerCase();
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 1)
        self.assertEqual(result.violations[0].rule_id, RULE_ID)

    def test_direct_trim_in_app_source_fails(self) -> None:
        self._write(
            "lib/demo/demo_matcher.dart",
            """
final class DemoMatcher {
  bool hasValue(String value) {
    return value.trim().isNotEmpty;
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 1)
        self.assertEqual(result.violations[0].rule_id, RULE_ID)

    def test_direct_to_upper_case_in_app_source_fails(self) -> None:
        self._write(
            "lib/demo/demo_avatar.dart",
            """
final class DemoAvatar {
  String initials(String value) {
    return value.toUpperCase();
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 1)
        self.assertEqual(result.violations[0].rule_id, RULE_ID)

    def test_drift_table_trim_expression_is_excluded(self) -> None:
        self._write(
            "lib/data/datasources/local/tables/demo_table.dart",
            """
final class DemoTable {
  Object build(Object name) {
    return name.trim();
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 0)

    def test_string_utils_usage_passes(self) -> None:
        self._write(
            "lib/demo/demo_matcher.dart",
            """
import 'package:memox/core/utils/string_utils.dart';

final class DemoMatcher {
  bool matches(String left, String right) {
    return StringUtils.equalsNormalized(left, right);
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 0)

    def test_string_utils_source_may_define_lowercase_primitive(self) -> None:
        self._write(
            "lib/core/utils/string_utils.dart",
            """
abstract final class StringUtils {
  static String normalizedForComparison(String value) {
    return value.trim().toLowerCase();
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 0)

    def _run_rule(self):
        runner = Runner(POLICY_DIR, self._temp_dir)
        results = runner.run(rule_ids=[RULE_ID])
        self.assertEqual(len(results), 1)
        return results[0]

    def _write(self, rel_path: str, content: str) -> None:
        path = self._temp_dir / rel_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content.strip() + "\n", encoding=UTF8_ENCODING)


if __name__ == "__main__":
    unittest.main()
