from __future__ import annotations

from typing import TYPE_CHECKING

from factorio_randovania_mod import layout_string, mod_lua_api, mod_zip

if TYPE_CHECKING:
    from pathlib import Path

    from factorio_randovania_mod.configuration import Configuration


def export_mod(config: Configuration, mods_folder: Path) -> tuple[Path, str] | None:
    """
    Creates the mod zip file, enables the mod, configures the layout string in mod settings.
    :param config:
    :param mods_folder:
    :return: None if the assets mod is ok, a path and url if it's necessary to download it.
    """
    s = layout_string.create_string(config)
    mod_lua_api.add_layout_string_to_mod_settings(s, mods_folder)
    mod_zip.create_zip_package(mods_folder)

    assets_version = mod_zip.get_minimum_assets_mod_version()
    assets_path = mods_folder.joinpath(mod_zip.get_assets_mod_file_name(assets_version))

    mod_lua_api.enable_mods_in_list(
        mods_folder, {mod_zip.MAIN_MOD_NAME: mod_lua_api.mod_version(), mod_zip.ASSETS_MOD_NAME: None}
    )

    if assets_path.is_file():
        return None
    else:
        return assets_path, mod_zip.get_assets_mod_url(assets_version)


__all__ = ["export_mod"]
