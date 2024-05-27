import argparse
import json
import logging
import logging.config
import time
from pathlib import Path

from factorio_randovania_mod import creator


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--factorio-path",
        required=True,
        type=Path,
        help="Path to where a Factorio installation can be found.",
    )
    parser.add_argument(
        "--output-path",
        required=True,
        type=Path,
        help="Path to where the mod files will be written to.",
    )
    parser.add_argument("--input-json", required=True, type=Path, help="Path to the configuration json.")
    parser.add_argument("-q", "--quiet", action="store_true", help="Disables all info and debug logs.")
    return parser


def setup_logging() -> None:
    handlers = {
        "default": {
            "level": "DEBUG",
            "formatter": "default",
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stdout",  # Default is stderr
        },
    }
    logging.config.dictConfig(
        {
            "version": 1,
            "formatters": {
                "default": {
                    "format": "[%(asctime)s] [%(levelname)s] [%(name)s] %(funcName)s: %(message)s",
                }
            },
            "handlers": handlers,
            "disable_existing_loggers": False,
            "loggers": {
                "default": {
                    "level": "DEBUG",
                },
            },
            "root": {
                "level": "DEBUG",
                "handlers": list(handlers.keys()),
            },
        }
    )


def main() -> None:
    setup_logging()
    parser = create_parser()
    args = parser.parse_args()
    if args.quiet:
        logging.getLogger().setLevel(logging.WARNING)

    with args.input_json.open() as f:
        configuration = json.load(f)

    start = time.time()
    creator.create(
        args.factorio_path,
        configuration,
        args.output_path,
    )
    end = time.time()
    print(f"Patcher took {end - start:.03f} seconds")
