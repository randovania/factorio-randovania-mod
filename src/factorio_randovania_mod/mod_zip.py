import json
import typing
import zipfile
from pathlib import Path

from factorio_randovania_mod.mod_lua_api import mod_version

_TEMPLATE_PATH = Path(__file__).parent.joinpath("lua_src")
_ASSETS_MOD_URL = (
    "https://github.com/randovania/factorio-assets-mod/releases/download/{version}/randovania-assets-{version}.zip"
)
MAIN_MOD_NAME = "randovania"
ASSETS_MOD_NAME = "randovania-assets"


def create_zip_package(output_path: Path) -> None:
    """
    Creates the zip file with the mod code at the given path.
    :param output_path:
    :return:
    """
    output_path.mkdir(parents=True, exist_ok=True)

    info_json = json.loads(_TEMPLATE_PATH.joinpath("info.json").read_text())
    info_json["version"] = mod_version()

    folder_name = f"{info_json['name']}_{info_json['version']}"

    with zipfile.ZipFile(output_path.joinpath(folder_name + ".zip"), "w") as target_zip:
        for entry in _TEMPLATE_PATH.rglob("*"):
            assert isinstance(entry, Path)
            relative = entry.relative_to(_TEMPLATE_PATH)
            if relative.name == "info.json":
                target_zip.writestr(
                    f"{folder_name}/{relative}",
                    json.dumps(info_json, indent=4),
                )
            else:
                target_zip.write(
                    entry,
                    arcname=f"{folder_name}/{relative}",
                )


def get_minimum_assets_mod_version() -> str:
    """
    Gets the minimum version of the assets mod required to run this version of the randomizer.
    :return:
    """
    info_json = json.loads(_TEMPLATE_PATH.joinpath("info.json").read_text())

    for dependency in typing.cast(list[str], info_json["dependencies"]):
        if dependency.startswith("randovania-assets"):
            version = dependency.split(" >= ")[1]
            return version

    raise RuntimeError("Could not find the randovania-assets dependency")


def get_assets_mod_url(version: str | None) -> str:
    """
    Gets a URL for downloading the provided version of the assets mod.
    :param version: The version to download for. Defaults to `get_assets_mod_version`
    :return:
    """
    if version is None:
        version = get_minimum_assets_mod_version()
    return _ASSETS_MOD_URL.format(version=version)


def get_assets_mod_file_name(version: str | None) -> str:
    """
    Gets the name of the zip file of the assets mod for the provided version.
    :param version: The version to download for. Defaults to `get_assets_mod_version`
    :return:
    """
    if version is None:
        version = get_minimum_assets_mod_version()
    return f"randovania-assets_{version}.zip"
