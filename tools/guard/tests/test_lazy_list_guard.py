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
RULE_ID = "lazy_list_rendering"


class LazyListGuardTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temp_dir = Path(tempfile.mkdtemp(prefix="memox_lazy_list_guard_"))

    def tearDown(self) -> None:
        shutil.rmtree(self._temp_dir)

    def test_column_for_loop_in_list_widget_fails(self) -> None:
        self._write(
            "lib/presentation/features/demo/widgets/demo_list.dart",
            """
import 'package:flutter/widgets.dart';

class DemoList extends StatelessWidget {
  const DemoList({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Text(item),
      ],
    );
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 1)
        self.assertIn("builds dynamic list rows eagerly", result.violations[0].message_params["detail"])

    def test_list_view_for_loop_in_screen_fails(self) -> None:
        self._write(
            "lib/presentation/features/demo/screens/demo_screen.dart",
            """
import 'package:flutter/widgets.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final item in items)
          Text(item),
      ],
    );
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 1)
        self.assertEqual(result.violations[0].symbol, "ListView")

    def test_static_list_view_screen_passes(self) -> None:
        self._write(
            "lib/presentation/features/demo/screens/demo_screen.dart",
            """
import 'package:flutter/widgets.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text('Header'),
        Text('Footer'),
      ],
    );
  }
}
""",
        )

        result = self._run_rule()

        self.assertEqual(result.violation_count, 0)

    def test_sliver_list_builder_passes(self) -> None:
        self._write(
            "lib/presentation/features/demo/widgets/demo_list.dart",
            """
import 'package:flutter/widgets.dart';

class DemoList extends StatelessWidget {
  const DemoList({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Text(items[index]),
    );
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
