from __future__ import annotations

from abc import ABC
from abc import abstractmethod

from ..models import GuardResult


class BaseFormatter(ABC):
    @abstractmethod
    def format(self, results: list[GuardResult], verbose: bool = False) -> str:
        raise NotImplementedError
