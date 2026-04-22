from pathlib import Path

import yaml

from .constants import CONFIG_FILE_NAME
from .constants import COST_LOW
from .constants import DEFAULT_FILE_EXTENSION
from .constants import DEFAULT_SCOPE
from .constants import EMPTY
from .constants import KEY_APPLIES_TO
from .constants import KEY_AUTO_FIXABLE
from .constants import KEY_CATEGORY
from .constants import KEY_CONFIDENCE
from .constants import KEY_COST
from .constants import KEY_DESCRIPTION
from .constants import KEY_DOCS
from .constants import KEY_ENABLED
from .constants import KEY_EXAMPLES
from .constants import KEY_EXCLUDE
from .constants import KEY_FILE_EXTENSION
from .constants import KEY_FIX_HINT_CODE
from .constants import KEY_FIX_TYPE
from .constants import KEY_FAMILY
from .constants import KEY_ID
from .constants import KEY_IMPACT
from .constants import KEY_MESSAGE_CODE
from .constants import KEY_MESSAGE_PARAMS
from .constants import KEY_META
from .constants import KEY_NAME
from .constants import KEY_OVERRIDES
from .constants import KEY_OWNER
from .constants import KEY_PARAMS
from .constants import KEY_PLAYBOOK
from .constants import KEY_PROJECT
from .constants import KEY_REQUIRES_AST
from .constants import KEY_REQUIRES_PROJECT_SCAN
from .constants import KEY_RULE_FILES
from .constants import KEY_RULES
from .constants import KEY_SCOPE
from .constants import KEY_SCHEMA_VERSION
from .constants import KEY_SEVERITY
from .constants import KEY_STABLE
from .constants import KEY_SUGGESTION
from .constants import KEY_SUPPORTS_INCREMENTAL
from .constants import KEY_TAGS
from .constants import KEY_TARGETS
from .constants import KEY_TYPE
from .constants import KEY_URL
from .constants import UTF8_ENCODING
from .models import Confidence
from .models import Impact
from .models import Rule
from .models import RuleDocs
from .models import RuleMeta
from .models import Severity
from .schema_validator import SchemaValidator

NO_RULE_FILES_WARNING = "No rule_files declared in config.yaml. No rules will be loaded."
MISSING_RULE_FILE_WARNING = "Rule file not found: {filename}"
CONFIG_VALIDATION_ERROR = "Config validation failed:\n"
CONFIG_VALIDATION_ITEM = "  - {error}"
RULES_SUFFIX = "_rules"
READ_MODE = "r"
NEWLINE = "\n"
GLOB_PREFIX = "*"


class ConfigLoader:
    def __init__(self, policy_dir: Path):
        self.policy_dir = policy_dir
        self.config: dict = {}
        self.rules: list[Rule] = []
        self.warnings: list[str] = []

    def load(self) -> tuple[dict, list[Rule], list[str]]:
        self.config = self._load_yaml(self.policy_dir / CONFIG_FILE_NAME)
        self.rules = []
        self.warnings = []

        rule_files = self.config.get(KEY_RULE_FILES, [])
        if not rule_files:
            self.warnings.append(NO_RULE_FILES_WARNING)

        for filename in rule_files:
            path = self.policy_dir / filename
            if not path.exists():
                self.warnings.append(
                    MISSING_RULE_FILE_WARNING.format(filename=filename)
                )
                continue

            raw = self._load_yaml(path)
            family = raw.get(KEY_FAMILY, path.stem.replace(RULES_SUFFIX, EMPTY))
            for rule_data in raw.get(KEY_RULES, []):
                rule = self._parse_rule(rule_data, family)
                rule = self._apply_overrides(rule)
                self.rules.append(rule)

        errors = SchemaValidator.validate_config(self.config)
        errors += SchemaValidator.validate_rules(self.rules, self.config)
        if errors:
            raise ValueError(
                CONFIG_VALIDATION_ERROR
                + NEWLINE.join(
                    CONFIG_VALIDATION_ITEM.format(error=error) for error in errors
                )
            )

        return self.config, self.rules, self.warnings

    def _parse_rule(self, data: dict, family: str) -> Rule:
        meta_data = data.get(KEY_META, {})
        docs_data = data.get(KEY_DOCS, {})
        extension = self.config.get(KEY_PROJECT, {}).get(
            KEY_FILE_EXTENSION,
            DEFAULT_FILE_EXTENSION,
        )

        return Rule(
            id=data[KEY_ID],
            type=data[KEY_TYPE],
            family=family,
            name=data.get(KEY_NAME, data[KEY_ID]),
            description=data.get(KEY_DESCRIPTION, EMPTY),
            message_code=data.get(KEY_MESSAGE_CODE, EMPTY),
            message_params=data.get(KEY_MESSAGE_PARAMS, {}),
            severity=Severity(data.get(KEY_SEVERITY, Severity.ERROR.value)),
            confidence=Confidence(data.get(KEY_CONFIDENCE, Confidence.HIGH.value)),
            impact=Impact(data.get(KEY_IMPACT, Impact.STYLE.value)),
            enabled=data.get(KEY_ENABLED, True),
            scope=data.get(KEY_SCOPE, DEFAULT_SCOPE),
            targets=tuple(data.get(KEY_TARGETS, [])),
            exclude=tuple(data.get(KEY_EXCLUDE, [])),
            suggestion=data.get(KEY_SUGGESTION, EMPTY),
            fix_hint_code=data.get(KEY_FIX_HINT_CODE, EMPTY),
            params=data.get(KEY_PARAMS, {}),
            meta=RuleMeta(
                category=meta_data.get(KEY_CATEGORY, family),
                tags=tuple(meta_data.get(KEY_TAGS, [])),
                auto_fixable=meta_data.get(KEY_AUTO_FIXABLE, False),
                fix_type=meta_data.get(KEY_FIX_TYPE, EMPTY),
                requires_ast=meta_data.get(KEY_REQUIRES_AST, False),
                supports_incremental=meta_data.get(KEY_SUPPORTS_INCREMENTAL, True),
                requires_project_scan=meta_data.get(
                    KEY_REQUIRES_PROJECT_SCAN,
                    False,
                ),
                cost=meta_data.get(KEY_COST, COST_LOW),
                stable=meta_data.get(KEY_STABLE, True),
                applies_to=meta_data.get(KEY_APPLIES_TO, f"{GLOB_PREFIX}{extension}"),
                schema_version=meta_data.get(KEY_SCHEMA_VERSION, 1),
            ),
            docs=RuleDocs(
                url=docs_data.get(KEY_URL, EMPTY),
                playbook=docs_data.get(KEY_PLAYBOOK, EMPTY),
                owner=docs_data.get(KEY_OWNER, EMPTY),
                examples=docs_data.get(KEY_EXAMPLES, EMPTY),
            ),
        )

    def _apply_overrides(self, rule: Rule) -> Rule:
        overrides = self.config.get(KEY_OVERRIDES, {})
        override = overrides.get(rule.id)
        if not override:
            return rule

        values = {
            field_name: getattr(rule, field_name)
            for field_name in rule.__dataclass_fields__
        }
        if KEY_SEVERITY in override:
            values[KEY_SEVERITY] = Severity(override[KEY_SEVERITY])
        if KEY_ENABLED in override:
            values[KEY_ENABLED] = override[KEY_ENABLED]
        return Rule(**values)

    @staticmethod
    def _load_yaml(path: Path) -> dict:
        if not path.exists():
            return {}
        with open(path, READ_MODE, encoding=UTF8_ENCODING) as handle:
            return yaml.safe_load(handle) or {}
