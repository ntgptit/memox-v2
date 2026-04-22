from __future__ import annotations

import sys
from pathlib import Path

from .constants import FORMAT_JSON
from .constants import FORMAT_MARKDOWN
from .constants import FORMAT_TERMINAL
from .constants import UTF8_ENCODING
from .formatters.json_formatter import JsonFormatter
from .formatters.markdown_formatter import MarkdownFormatter
from .formatters.terminal_formatter import TerminalFormatter
from .models import GuardResult

UNSUPPORTED_FORMAT_MESSAGE = "Unsupported format: {fmt}"


class Reporter:
    _FORMATTERS = {
        FORMAT_TERMINAL: TerminalFormatter,
        FORMAT_JSON: JsonFormatter,
        FORMAT_MARKDOWN: MarkdownFormatter,
    }

    @classmethod
    def output(
        cls,
        results: list[GuardResult],
        fmt: str = FORMAT_TERMINAL,
        output_path: Path | None = None,
        verbose: bool = False,
    ) -> None:
        formatter_cls = cls._FORMATTERS.get(fmt)
        if formatter_cls is None:
            raise ValueError(UNSUPPORTED_FORMAT_MESSAGE.format(fmt=fmt))

        formatter = formatter_cls()
        content = formatter.format(results, verbose=verbose)

        if output_path:
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(content, encoding=UTF8_ENCODING)
            return

        sys.stdout.write(content)
