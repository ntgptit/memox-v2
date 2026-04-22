from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from .constants import DEFAULT_LOCALE
from .constants import EMPTY
from .constants import KEY_FIX_HINTS
from .constants import KEY_LOCALE
from .constants import KEY_MESSAGES
from .constants import KEY_TEXT
from .constants import UTF8_ENCODING


class MessageCatalog:
    def __init__(self, messages_path: Path, locale: str = DEFAULT_LOCALE):
        self.locale = locale
        self.messages: dict[str, dict[str, str]] = {}
        self.fix_hints: dict[str, dict] = {}

        if messages_path.exists():
            raw = yaml.safe_load(messages_path.read_text(encoding=UTF8_ENCODING)) or {}
            self.locale = raw.get(KEY_LOCALE, locale)
            self.messages = raw.get(KEY_MESSAGES, {})
            self.fix_hints = raw.get(KEY_FIX_HINTS, {})

    def resolve(self, code: str, params: dict[str, Any] | None = None) -> str:
        templates = self.messages.get(code, {})
        template = templates.get(self.locale) or templates.get(DEFAULT_LOCALE)
        if not template:
            return code
        if not params:
            return template
        try:
            return template.format(**params)
        except (IndexError, KeyError):
            return template

    def resolve_fix_hint(self, code: str, locale: str | None = None) -> str:
        resolved_locale = locale or self.locale
        hint = self.fix_hints.get(code, {})
        texts = hint.get(KEY_TEXT, {})
        return texts.get(resolved_locale) or texts.get(DEFAULT_LOCALE, EMPTY)
