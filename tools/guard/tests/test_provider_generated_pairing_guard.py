from __future__ import annotations

import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from engine.constants import UTF8_ENCODING
from engine.runner import Runner


POLICY_DIR = Path(__file__).resolve().parents[1] / "policies" / "memox"
RULE_ID = "provider_generated_pairing"


class ProviderGeneratedPairingGuardTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temp_dir = Path(tempfile.mkdtemp(prefix="memox_provider_pairing_guard_"))

    def tearDown(self) -> None:
        shutil.rmtree(self._temp_dir)

    def test_riverpod_annotation_without_part_fails(self) -> None:
        self._write(
            "lib/presentation/features/demo/providers/demo_provider.dart",
            """
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
Future<int> demoCounter(DemoCounterRef ref) async {
  return 1;
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 1)

    def test_riverpod_annotation_with_part_and_generated_file_passes(self) -> None:
        self._write(
            "lib/presentation/features/demo/providers/demo_provider.dart",
            """
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'demo_provider.g.dart';

@riverpod
Future<int> demoCounter(DemoCounterRef ref) async {
  return 1;
}
""",
        )
        self._write(
            "lib/presentation/features/demo/providers/demo_provider.g.dart",
            """
// generated file for test
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 0)

    def _run_rule(self):
        previous_cwd = Path.cwd()
        os.chdir(self._temp_dir)
        try:
            runner = Runner(POLICY_DIR, self._temp_dir)
            results = runner.run(rule_ids=[RULE_ID])
        finally:
            os.chdir(previous_cwd)
        self.assertEqual(len(results), 1)
        return results[0]

    def _write(self, rel_path: str, content: str) -> None:
        path = self._temp_dir / rel_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content.strip() + "\n", encoding=UTF8_ENCODING)


if __name__ == "__main__":
    unittest.main()
