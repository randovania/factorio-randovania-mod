from __future__ import annotations

import json
from typing import TYPE_CHECKING

import construct

from factorio_randovania_mod import version
from factorio_randovania_mod.factorio_formats import ModSettings

if TYPE_CHECKING:
    from pathlib import Path


def mod_version() -> str:
    """Returns the required mod version for this version of the package"""
    base_version = version.__version_tuple__
    return f"{base_version[0]}.{base_version[1]}.{base_version[2]}"


def default_mod_settings() -> construct.Container:
    """
    A reasonable default mod-settings.dat, in case the user doesn't have one.
    """
    return construct.Container(
        game_version=construct.Container(main=2, major=0, minor=7, developer=0),
        tree=construct.Container(
            [
                ("startup", construct.Container()),
                ("runtime-global", construct.Container()),
                ("runtime-per-user", construct.Container()),
            ]
        ),
    )


def add_layout_string_to_mod_settings(layout_string: str, mods_folder: Path) -> None:
    """
    Adds the given layout string to the user's mod-settings.dat in the given mods folder.
    :param layout_string:
    :param mods_folder:
    :return:
    """
    path = mods_folder.joinpath("mod-settings.dat")
    try:
        settings = ModSettings.parse_file(path)
    except FileNotFoundError:
        settings = default_mod_settings()

    settings["tree"]["startup"]["randovania-layout-string"] = construct.Container(
        value=layout_string,
    )
    path.write_bytes(ModSettings.build(settings))


def enable_mods_in_list(mods_folder: Path, to_enable: set[str]) -> None:
    """
    If any of the given mods are disabled in the given mods folder, enable them.
    :param mods_folder:
    :param to_enable:
    :return:
    """
    path = mods_folder.joinpath("mod-list.json")

    try:
        with path.open() as f:
            mod_list = json.load(f)

    except (FileNotFoundError, json.JSONDecodeError):
        # If the file doesn't exist, leave it alone. The game defaults all mods as enabled.
        # If the file is not valid, we'll let the game worry about that.
        return

    update_file = False

    for mod in mod_list["mods"]:
        if not mod["enabled"] and mod["name"] in to_enable:
            mod["enabled"] = True
            update_file = True

    if update_file:
        path.write_text(
            json.dumps(
                mod_list,
                indent=4,
            )
        )
