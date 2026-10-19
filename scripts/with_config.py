"""Run a command with local settings, or render a SQL template to stdout.

Examples (from the repository root):
  python3 scripts/with_config.py dbt parse --project-dir dbt --profiles-dir dbt
  python3 scripts/with_config.py --render path/to/query.sql
"""

import os
import sys
from pathlib import Path

from local_config import load_config


def main():
    load_config()
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == "--render":
        print(Path(args[1]).read_text().replace("__F1_GCP_PROJECT__", os.environ["F1_GCP_PROJECT"]), end="")
    elif args and args[0] != "--render":
        os.execvpe(args[0], args, os.environ)
    else:
        raise SystemExit("Usage: with_config.py COMMAND [ARGS...] | --render FILE")


if __name__ == "__main__":
    main()
