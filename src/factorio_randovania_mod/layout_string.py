from __future__ import annotations

import base64
import collections
import typing

from factorio_randovania_mod import schema
from factorio_randovania_mod.layout_data import LayoutData, LayoutDataConstruct, TechTreeEntry

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import (
        ConfigurationTechnologiesItem,
    )


def process_technology(
    progressive_sources: dict[tuple[str, ...], list[str]],
    tech: ConfigurationTechnologiesItem,
) -> TechTreeEntry:
    """
    Process an entry of patch_data["technologies"]
    :param progressive_sources:
    :param tech:
    :return: A new entry for tech-tree.lua
    """
    tech_name = tech["tech_name"]

    new_tech: TechTreeEntry = {
        "name": tech_name,
        "localised_name": tech["locale_name"],
        "prerequisites": tech["prerequisites"],
        "cost_reference": tech["cost_reference"],
        "take_effects_from": "",
        "visual_data": None,
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
            progressive_sources[tuple(tech["unlocks"])].append(tech_name)

    return new_tech


def create_string(patch_data: dict) -> str:
    """
    Creates the layout string to be used as mod setting, given the following json data.
    :param patch_data:
    :return:
    """
    configuration = schema.validate(patch_data)

    progressive_sources: dict[tuple[str, ...], list[str]] = collections.defaultdict(list)
    generated_files: LayoutData = {
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

    return base64.b64encode(LayoutDataConstruct().build(generated_files)).decode("ascii")
