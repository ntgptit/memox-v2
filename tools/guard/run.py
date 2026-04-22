import argparse
import sys
from pathlib import Path

from engine.constants import CONFIG_FILE_NAME
from engine.constants import COST_HIGH
from engine.constants import DEFAULT_ENVIRONMENT
from engine.constants import DEFAULT_LOCALE
from engine.constants import DEFAULT_ROOT_MARKER
from engine.constants import FORMAT_TERMINAL
from engine.constants import KEY_PROJECT
from engine.constants import KEY_ROOT_MARKER
from engine.constants import MAX_COST_CHOICES
from engine.constants import STATUS_DISABLED
from engine.constants import STATUS_ENABLED
from engine.constants import SUPPORTED_FORMATS
from engine.exit_policy import ExitPolicy
from engine.reporter import Reporter
from engine.runner import Runner

ARGUMENT_PARSER_DESCRIPTION = "Guard Engine v3"
POLICY_DIR_NAME = "policies"
RULE_ID_SEPARATOR = ","
POLICY_NOT_FOUND_MESSAGE = "Policy not found: {policy_dir}"
WARNING_TEMPLATE = "[warn] {warning}"
RULE_LIST_TEMPLATE = "[{status}] [{family}] {rule_id} [{severity}] {name}"
BASELINE_SAVED_TEMPLATE = "Baseline saved: {total} violations"
ARG_POLICY = "--policy"
ARG_FAMILY = "--family"
ARG_FAMILY_SHORT = "-f"
ARG_RULE = "--rule"
ARG_RULE_SHORT = "-r"
ARG_SCOPE = "--scope"
ARG_SCOPE_SHORT = "-s"
ARG_PROFILE = "--profile"
ARG_PROFILE_SHORT = "-p"
ARG_ENV = "--env"
ARG_ENV_SHORT = "-e"
ARG_MAX_COST = "--max-cost"
ARG_FORMAT = "--format"
ARG_OUTPUT = "--output"
ARG_OUTPUT_SHORT = "-o"
ARG_VERBOSE = "--verbose"
ARG_VERBOSE_SHORT = "-v"
ARG_LIST = "--list"
ARG_LIST_SHORT = "-l"
ARG_BASELINE_SAVE = "--baseline-save"
ARG_BASELINE_DIFF = "--baseline-diff"
ARG_PROJECT_ROOT = "--project-root"
ARG_LOCALE = "--locale"
MAIN_MODULE_NAME = "__main__"


def main() -> None:
    parser = argparse.ArgumentParser(description=ARGUMENT_PARSER_DESCRIPTION)
    parser.add_argument(ARG_POLICY, required=True)
    parser.add_argument(ARG_FAMILY, ARG_FAMILY_SHORT)
    parser.add_argument(ARG_RULE, ARG_RULE_SHORT)
    parser.add_argument(ARG_SCOPE, ARG_SCOPE_SHORT)
    parser.add_argument(ARG_PROFILE, ARG_PROFILE_SHORT)
    parser.add_argument(ARG_ENV, ARG_ENV_SHORT, default=DEFAULT_ENVIRONMENT)
    parser.add_argument(
        ARG_MAX_COST,
        default=COST_HIGH,
        choices=MAX_COST_CHOICES,
    )
    parser.add_argument(
        ARG_FORMAT,
        default=FORMAT_TERMINAL,
        choices=SUPPORTED_FORMATS,
    )
    parser.add_argument(ARG_OUTPUT, ARG_OUTPUT_SHORT)
    parser.add_argument(ARG_VERBOSE, ARG_VERBOSE_SHORT, action="store_true")
    parser.add_argument(ARG_LIST, ARG_LIST_SHORT, action="store_true")
    parser.add_argument(ARG_BASELINE_SAVE, action="store_true")
    parser.add_argument(ARG_BASELINE_DIFF, action="store_true")
    parser.add_argument(ARG_PROJECT_ROOT, type=str)
    parser.add_argument(ARG_LOCALE, default=DEFAULT_LOCALE)
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    policy_dir = script_dir / POLICY_DIR_NAME / args.policy
    if not policy_dir.exists():
        print(POLICY_NOT_FOUND_MESSAGE.format(policy_dir=policy_dir))
        sys.exit(1)

    project_root = (
        Path(args.project_root).resolve()
        if args.project_root
        else _find_root(script_dir, policy_dir)
    )

    runner = Runner(policy_dir, project_root, locale=args.locale)

    for warning in runner.warnings:
        print(WARNING_TEMPLATE.format(warning=warning))

    if args.list:
        for rule in runner.all_rules:
            status = STATUS_ENABLED if rule.enabled else STATUS_DISABLED
            print(
                RULE_LIST_TEMPLATE.format(
                    status=status,
                    family=rule.family,
                    rule_id=rule.id,
                    severity=rule.severity.value,
                    name=rule.name,
                )
            )
        return

    rule_ids = args.rule.split(RULE_ID_SEPARATOR) if args.rule else None
    results = runner.run(
        family=args.family,
        rule_ids=rule_ids,
        scope=args.scope,
        max_cost=args.max_cost,
        profile=args.profile,
        baseline_diff=args.baseline_diff,
    )

    if args.baseline_save:
        runner.baseline.save_snapshot(results)
        total = sum(result.violation_count for result in results)
        print(BASELINE_SAVED_TEMPLATE.format(total=total))
        sys.exit(0)

    Reporter.output(
        results,
        fmt=args.format,
        output_path=Path(args.output) if args.output else None,
        verbose=args.verbose,
    )

    exit_policy = ExitPolicy(runner.config, args.env)
    sys.exit(1 if exit_policy.should_fail(results) else 0)


def _find_root(script_dir: Path, policy_dir: Path) -> Path:
    from engine.config_loader import ConfigLoader

    config = ConfigLoader._load_yaml(policy_dir / CONFIG_FILE_NAME)
    marker = config.get(KEY_PROJECT, {}).get(KEY_ROOT_MARKER, DEFAULT_ROOT_MARKER)

    current = script_dir
    while current != current.parent:
        if (current / marker).exists():
            return current
        current = current.parent
    return script_dir.parent.parent


if __name__ == MAIN_MODULE_NAME:
    main()
