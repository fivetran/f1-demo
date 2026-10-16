"""Load the ignored root .env without overriding exported environment variables."""

import os
import re
import shlex
from pathlib import Path


def load_config():
    path = Path(__file__).resolve().parents[1] / ".env"
    if not path.exists():
        return
    for number, line in enumerate(path.read_text().splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        key, separator, value = line.partition("=")
        if not separator or not re.fullmatch(r"[A-Z][A-Z0-9_]*", key):
            raise ValueError(f"Invalid .env assignment on line {number}")
        parts = shlex.split(value, comments=True)
        if len(parts) > 1:
            raise ValueError(f"Quote .env values containing spaces on line {number}")
        os.environ.setdefault(key, parts[0] if parts else "")
