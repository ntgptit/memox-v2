from pathlib import Path


def normalize_rel_path(path: Path, root: Path) -> str:
    """Return a stable POSIX-style relative path when possible."""
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()
