import argparse
import json
import logging
import logging.config
from pathlib import Path

from factorio_randovania_mod import layout_string, mod_lua_api, mod_zip


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--quiet", action="store_true", help="Disables all info and debug logs.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    zip_parser = subparsers.add_parser("generate-zip", help="Generates a zip file with the mod's lua code.")
    zip_parser.add_argument(
        "--output-path",
        required=True,
        type=Path,
        help="Path to directory where the zip file is added.",
    )

    layout_parser = subparsers.add_parser("generate-layout", help="Generates the string to be used in the mod settings")
    layout_parser.add_argument("--input-json", required=True, type=Path, help="Path to the configuration json.")
    layout_parser.add_argument(
        "--apply-to-mod-settings",
        required=False,
        type=Path,
        help="If provided, the mod-settings.dat in the given folder is modified.",
    )
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


def generate_zip(args: argparse.Namespace) -> None:
    mod_zip.create_zip_package(args.output_path)


def generate_layout(args: argparse.Namespace) -> None:
    with args.input_json.open() as f:
        configuration = json.load(f)

    s = layout_string.create_string(configuration)
    print(s)

    if args.apply_to_mod_settings:
        mods_folder: Path = args.apply_to_mod_settings
        mod_lua_api.add_layout_string_to_mod_settings(s, mods_folder)
        mod_lua_api.enable_mods_in_list(
            mods_folder,
            {
                mod_zip.MAIN_MOD_NAME: mod_lua_api.mod_version(),
                mod_zip.ASSETS_MOD_NAME: None,
            },
        )


def main() -> None:
    setup_logging()
    parser = create_parser()
    args = parser.parse_args()
    if args.quiet:
        logging.getLogger().setLevel(logging.WARNING)

    if args.command == "generate-zip":
        generate_zip(args)
    elif args.command == "generate-layout":
        generate_layout(args)
