from .constants import CONFIG_FILE_NAME
from .constants import KEY_FAMILIES
from .constants import KEY_ROOTS
from .constants import KEY_SCOPES
from .models import Rule
from .rule_registry import supported_rule_types

MISSING_SECTION_TEMPLATE = f"{CONFIG_FILE_NAME} missing '{{section}}' section"
MISSING_SCOPE_ROOTS_TEMPLATE = "scope '{scope_id}' missing 'roots'"
RULE_MISSING_ID_MESSAGE = "Rule missing 'id'"
DUPLICATE_RULE_ID_TEMPLATE = "Duplicate rule id: '{rule_id}'"
MISSING_RULE_TYPE_TEMPLATE = "Rule '{rule_id}' missing 'type'"
UNSUPPORTED_RULE_TYPE_TEMPLATE = "Rule '{rule_id}' has unsupported type: '{rule_type}'"
UNKNOWN_SCOPE_TEMPLATE = "Rule '{rule_id}' references unknown scope: '{scope_id}'"
UNKNOWN_FAMILY_TEMPLATE = (
    "Rule '{rule_id}' references unknown family: '{family}'"
)


class SchemaValidator:
    @staticmethod
    def validate_config(config: dict) -> list[str]:
        errors: list[str] = []
        if KEY_SCOPES not in config:
            errors.append(MISSING_SECTION_TEMPLATE.format(section=KEY_SCOPES))
        if KEY_FAMILIES not in config:
            errors.append(MISSING_SECTION_TEMPLATE.format(section=KEY_FAMILIES))

        for scope_id, scope in config.get(KEY_SCOPES, {}).items():
            if KEY_ROOTS not in scope:
                errors.append(MISSING_SCOPE_ROOTS_TEMPLATE.format(scope_id=scope_id))
        return errors

    @staticmethod
    def validate_rules(rules: list[Rule], config: dict) -> list[str]:
        errors: list[str] = []
        seen_ids: set[str] = set()
        valid_scopes = set(config.get(KEY_SCOPES, {}).keys())
        valid_families = set(config.get(KEY_FAMILIES, {}).keys())
        valid_types = supported_rule_types()

        for rule in rules:
            if not rule.id:
                errors.append(RULE_MISSING_ID_MESSAGE)
                continue
            if rule.id in seen_ids:
                errors.append(DUPLICATE_RULE_ID_TEMPLATE.format(rule_id=rule.id))
            seen_ids.add(rule.id)

            if not rule.type:
                errors.append(MISSING_RULE_TYPE_TEMPLATE.format(rule_id=rule.id))
            elif rule.type not in valid_types:
                errors.append(
                    UNSUPPORTED_RULE_TYPE_TEMPLATE.format(
                        rule_id=rule.id,
                        rule_type=rule.type,
                    )
                )

            if rule.scope not in valid_scopes:
                errors.append(
                    UNKNOWN_SCOPE_TEMPLATE.format(
                        rule_id=rule.id,
                        scope_id=rule.scope,
                    )
                )

            if rule.family not in valid_families:
                errors.append(
                    UNKNOWN_FAMILY_TEMPLATE.format(
                        rule_id=rule.id,
                        family=rule.family,
                    )
                )

        return errors
