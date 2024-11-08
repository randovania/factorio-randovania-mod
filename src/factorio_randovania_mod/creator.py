from __future__ import annotations

import collections
import shutil
import typing
from pathlib import Path

from factorio_randovania_mod import schema
from factorio_randovania_mod.lua_util import wrap

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import (
        ConfigurationTechnologiesItem,
    )
    from factorio_randovania_mod.mod_lua_api import CustomTechTreeItem, GeneratedFiles

_TEMPLATE_PATH = Path(__file__).parent.joinpath("lua_src")


def process_technology(
    progressive_sources: dict[tuple[str, ...], list[str]],
    tech: ConfigurationTechnologiesItem,
) -> CustomTechTreeItem:
    """
    Process an entry of patch_data["technologies"]
    :param progressive_sources:
    :param tech:
    :return: A new entry for tech-tree.lua
    """
    tech_name = tech["tech_name"]

    new_tech: CustomTechTreeItem = {
        "name": tech_name,
        "localised_name": tech["locale_name"],
        "prerequisites": tech["prerequisites"] if tech["prerequisites"] else None,
        "cost_reference": tech["cost_reference"],
    }

    if len(tech["unlocks"]) == 1:
        new_tech["take_effects_from"] = tech["unlocks"][0]
    else:
        new_tech["visual_data"] = {
            "icon": tech["icon"],
            "icon_size": tech["icon_size"],
            "localised_description": tech["description"],
        }
        if tech["unlocks"]:
            # local_unlocks[tech_name] = tech["unlocks"]
            progressive_sources[tuple(tech["unlocks"])].append(tech_name)

    return new_tech


def generate_output(
    output_path: Path,
    generated_files: GeneratedFiles,
) -> None:
    """
    Generates all files for the mod.
    :param output_path: Where to place the output
    :param generated_files: Data for generating all lua files
    :param locale: Used as template
    :return:
    """
    shutil.copytree(_TEMPLATE_PATH, output_path)
    output_path.joinpath("generated").mkdir()

    def generate_file(name: str, content: str) -> None:
        output_path.joinpath("generated", name).write_text("return " + content)

    generate_file("json-data.lua", wrap(generated_files))
    # generate_file("tech-tree.lua", wrap_array_pretty(generated_files["tech_tree"]))
    # generate_file("local-unlocks.lua", wrap(generated_files["local_unlocks"]))
    # generate_file("existing-tree-repurpose.lua", wrap(generated_files["existing_tree_repurpose"]))
    #
    # generate_file("starting-tech.lua", wrap_array_pretty(generated_files["starting_tech"]))
    # generate_file("custom-recipes.lua", wrap_array_pretty(generated_files["custom_recipes"]))


def create(patch_data: dict, output_folder: Path) -> None:
    output_path = output_folder.joinpath("randovania-layout")
    shutil.rmtree(output_path, ignore_errors=True)

    configuration = schema.validate(patch_data)

    progressive_sources: dict[tuple[str, ...], list[str]] = collections.defaultdict(list)
    generated_files: GeneratedFiles = {
        "tech_tree": [],
        "progressive_data": [],
        "starting_tech": configuration["starting_tech"],
        "custom_recipes": configuration["recipes"],
    }

    for tech in configuration["technologies"]:
        generated_files["tech_tree"].append(
            process_technology(
                progressive_sources,
                tech,
            )
        )

    # TODO: add the offworld research to `existing_tree_repurpose`

    for progressive_sequence, sources in progressive_sources.items():
        generated_files["progressive_data"].append(
            {
                "locations": list(sources),
                "unlocked": list(progressive_sequence),
            }
        )

    generate_output(output_path, generated_files)
