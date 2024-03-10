import configparser
from pathlib import Path
import shutil
import typing

from factorio_randovania_mod.configuration import Configuration


def wrap_array_pretty(data: list) -> str:
    return "{\n" + ",\n".join(wrap(item, "    ") for item in data) + "}\n"


def wrap(data: typing.Any, indent: str = "") -> str:
    if isinstance(data, list):
        return "{" + ", ".join(wrap(item, indent) for item in data) + "}"

    if isinstance(data, dict):
        return (
            "{\n"
            + "\n".join(
                f"{indent}    {key} = {wrap(value, f'{indent}    ')},"
                for key, value in data.items()
            )
            + f"\n{indent}}}"
        )

    if isinstance(data, bool):
        return "true" if data else "false"

    if data is None:
        return "nil"

    if isinstance(data, str):
        return f'"{data}"'

    return str(data)


template_path = Path(__file__).parent.joinpath("lua_src")


def create(factorio_path: Path, patch_data: Configuration, output_folder: Path) -> None:
    output_path = output_folder.joinpath("randovania-layout")
    shutil.rmtree(output_path, ignore_errors=True)

    locale = configparser.ConfigParser()
    locale.read(
        [
            template_path.joinpath("locale/en/strings.cfg"),
        ]
    )

    tech_tree_lua = []
    local_unlock_lines = ["return {"]
    for tech in patch_data["technologies"]:
        tech_name = tech["tech_name"]
        locale["technology-name"][tech_name] = tech["locale_name"]
        locale["technology-description"][tech_name] = tech["description"]

        tech_tree_lua.append(
            {
                "name": tech_name,
                "icon": tech["icon"],
                "costs": {
                    "count": tech["cost"]["count"],
                    "time": tech["cost"]["time"],
                    "ingredients": [[it, 1] for it in tech["cost"]["ingredients"]],
                },
                "prerequisites": tech["prerequisites"]
                if tech["prerequisites"]
                else None,
                "replicate": tech["unlocks"][0] if len(tech["unlocks"]) == 1 else None,
            }
        )
        if tech["unlocks"]:
            local_unlock_lines.append(f'["{tech_name}"] = {wrap(tech["unlocks"])},')

    local_unlock_lines.append("}")

    shutil.copytree(template_path, output_path)
    output_path.joinpath("generated", "tech-tree.lua").write_text(
        "return " + wrap_array_pretty(tech_tree_lua)
    )
    output_path.joinpath("generated", "local-unlocks.lua").write_text(
        "\n".join(local_unlock_lines)
    )
    output_path.joinpath("generated", "starting-tech.lua").write_text(
        "return " + wrap_array_pretty(patch_data["starting_tech"])
    )
    with output_path.joinpath("locale/en/strings.cfg").open("w") as f:
        locale.write(f, space_around_delimiters=False)
