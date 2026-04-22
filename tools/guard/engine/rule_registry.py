from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

from .constants import HANDLER_MODE_FILE
from .constants import HANDLER_MODE_PROJECT
from .constants import RULE_TYPE_AST_CHECK
from .constants import RULE_TYPE_FILE_EXISTENCE
from .constants import RULE_TYPE_FORBIDDEN_PATTERN
from .constants import RULE_TYPE_FORBIDDEN_TOKEN
from .constants import RULE_TYPE_IMPORT_DIRECTION
from .constants import RULE_TYPE_NAMING_CONVENTION
from .constants import RULE_TYPE_PATH_STRUCTURE
from .constants import RULE_TYPE_REQUIRED_ANY_TOKEN
from .constants import RULE_TYPE_REQUIRED_IN_CLASS
from .constants import RULE_TYPE_REQUIRED_PATTERN
from .constants import RULE_TYPE_STRUCTURAL_CHECK
from .file_scanner import FileScanner
from .matchers.ast_matcher import AstMatcher
from .matchers.project_matcher import ProjectMatcher
from .matchers.structural_matcher import StructuralMatcher
from .matchers.text_matcher import TextMatcher
from .models import Rule
from .models import Violation

ProjectHandler = Callable[[Rule, FileScanner], list[Violation]]
FileHandler = Callable[[Rule, str, list[str]], list[Violation]]


@dataclass(frozen=True)
class RuleHandlerSpec:
    mode: str
    handler: ProjectHandler | FileHandler


def _check_naming(rule: Rule, rel_path: str, lines: list[str]) -> list[Violation]:
    del lines
    return TextMatcher.check_naming(rule, rel_path)


RULE_HANDLERS: dict[str, RuleHandlerSpec] = {
    RULE_TYPE_FORBIDDEN_PATTERN: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=TextMatcher.find_forbidden_patterns,
    ),
    RULE_TYPE_FORBIDDEN_TOKEN: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=TextMatcher.find_forbidden_tokens,
    ),
    RULE_TYPE_REQUIRED_PATTERN: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=TextMatcher.find_missing_patterns,
    ),
    RULE_TYPE_REQUIRED_ANY_TOKEN: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=TextMatcher.find_missing_any_token,
    ),
    RULE_TYPE_NAMING_CONVENTION: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=_check_naming,
    ),
    RULE_TYPE_IMPORT_DIRECTION: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=StructuralMatcher.check_import_direction,
    ),
    RULE_TYPE_REQUIRED_IN_CLASS: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=StructuralMatcher.check_class_members,
    ),
    RULE_TYPE_STRUCTURAL_CHECK: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=StructuralMatcher.check,
    ),
    RULE_TYPE_AST_CHECK: RuleHandlerSpec(
        mode=HANDLER_MODE_FILE,
        handler=AstMatcher.check,
    ),
    RULE_TYPE_PATH_STRUCTURE: RuleHandlerSpec(
        mode=HANDLER_MODE_PROJECT,
        handler=ProjectMatcher.check_path_structure,
    ),
    RULE_TYPE_FILE_EXISTENCE: RuleHandlerSpec(
        mode=HANDLER_MODE_PROJECT,
        handler=ProjectMatcher.check_file_existence,
    ),
}


def get_rule_handler(rule_type: str) -> RuleHandlerSpec | None:
    return RULE_HANDLERS.get(rule_type)


def supported_rule_types() -> set[str]:
    return set(RULE_HANDLERS)
