from __future__ import annotations

import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from engine.baseline import BaselineManager
from engine.constants import BASELINE_FILE_NAME
from engine.constants import KEY_VIOLATIONS
from engine.constants import UTF8_ENCODING


class BaselineManagerTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temp_dir = Path(tempfile.mkdtemp(prefix="memox_baseline_guard_"))
        self._baseline_path = self._temp_dir / BASELINE_FILE_NAME

    def tearDown(self) -> None:
        shutil.rmtree(self._temp_dir)

    def test_invalid_json_baseline_does_not_crash(self) -> None:
        self._baseline_path.write_text("{ invalid", encoding=UTF8_ENCODING)

        manager = BaselineManager(self._baseline_path)

        self.assertEqual(manager.baseline, set())

    def test_valid_json_baseline_is_loaded(self) -> None:
        payload = {
            KEY_VIOLATIONS: [
                {
                    "rule_id": "sample_rule",
                    "file_path": "lib/sample.dart",
                    "line_number": 10,
                    "code": "sample_code",
                }
            ]
        }
        self._baseline_path.write_text(
            json.dumps(payload),
            encoding=UTF8_ENCODING,
        )

        manager = BaselineManager(self._baseline_path)

        self.assertEqual(len(manager.baseline), 1)


if __name__ == "__main__":
    unittest.main()
