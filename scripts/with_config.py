"""Run a command with local settings.

Examples (from the repository root):
  python3 scripts/with_config.py dbt parse --project-dir dbt --profiles-dir dbt
"""

import os
import sys

from local_config import load_config


def main():
    load_config()
    args = sys.argv[1:]
    if not args:
        raise SystemExit("Usage: with_config.py COMMAND [ARGS...]")
    os.execvpe(args[0], args, os.environ)


if __name__ == "__main__":
    main()
