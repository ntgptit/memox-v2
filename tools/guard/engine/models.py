from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum


class Severity(Enum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"

    @property
    def weight(self) -> int:
        return {"info": 0, "warning": 1, "error": 2, "critical": 3}[self.value]

    def __ge__(self, other: "Severity") -> bool:
        return self.weight >= other.weight

    def __gt__(self, other: "Severity") -> bool:
        return self.weight > other.weight


class Confidence(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class Impact(Enum):
    STYLE = "style"
    ARCHITECTURE = "architecture"
    DESIGN_SYSTEM = "design_system"
    DATA_INTEGRITY = "data_integrity"
    PERFORMANCE = "performance"
    SECURITY = "security"
    I18N = "i18n"
    TESTING = "testing"


@dataclass(frozen=True)
class RuleDocs:
    url: str = ""
    playbook: str = ""
    owner: str = ""
    examples: str = ""


@dataclass(frozen=True)
class RuleMeta:
    category: str = ""
    tags: tuple[str, ...] = ()
    auto_fixable: bool = False
    fix_type: str = ""
    requires_ast: bool = False
    supports_incremental: bool = True
    requires_project_scan: bool = False
    cost: str = "low"
    stable: bool = True
    applies_to: str = "*"
    schema_version: int = 1


@dataclass(frozen=True)
class Rule:
    id: str
    type: str
    family: str
    name: str = ""
    description: str = ""
    message_code: str = ""
    message_params: dict = field(default_factory=dict)
    severity: Severity = Severity.ERROR
    confidence: Confidence = Confidence.HIGH
    impact: Impact = Impact.STYLE
    enabled: bool = True
    scope: str = "all"
    targets: tuple[str, ...] = ()
    exclude: tuple[str, ...] = ()
    suggestion: str = ""
    fix_hint_code: str = ""
    params: dict = field(default_factory=dict)
    meta: RuleMeta = field(default_factory=RuleMeta)
    docs: RuleDocs = field(default_factory=RuleDocs)


@dataclass
class Violation:
    rule_id: str
    code: str
    family: str
    severity: Severity
    confidence: Confidence = Confidence.HIGH
    impact: Impact = Impact.STYLE
    file_path: str = ""
    line_number: int = 0
    column: int = 0
    symbol: str = ""
    message: str = ""
    message_params: dict = field(default_factory=dict)
    suggestion: str = ""
    fix_hint_code: str = ""
    autofix_available: bool = False
    docs_url: str = ""

    @property
    def location(self) -> str:
        if self.column > 0:
            return f"{self.file_path}:{self.line_number}:{self.column}"
        if self.line_number > 0:
            return f"{self.file_path}:{self.line_number}"
        return self.file_path


@dataclass
class GuardResult:
    rule_id: str
    rule_name: str
    family: str
    description: str
    severity: Severity
    violations: list[Violation] = field(default_factory=list)
    files_scanned: int = 0
    duration_ms: float = 0.0

    @property
    def error_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity >= Severity.ERROR)

    @property
    def warning_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.WARNING)

    @property
    def violation_count(self) -> int:
        return len(self.violations)
