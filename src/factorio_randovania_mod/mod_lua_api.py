from __future__ import annotations

import typing

from factorio_randovania_mod import version

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import ConfigurationRecipesItem


class TechCosts(typing.TypedDict):
    count: int
    time: int
    ingredients: list[tuple[str, int]]


class TechTreeVisualData(typing.TypedDict):
    icon: str
    icon_size: int
    localised_description: str


class CustomTechTreeItem(typing.TypedDict):
    name: str
    localised_name: str
    prerequisites: list[str]
    take_effects_from: str
    visual_data: TechTreeVisualData | None
    cost_reference: str


class TechRepurpose(typing.TypedDict):
    science_pack: str
    prerequisites: list[str]


class ProgressiveEntry(typing.TypedDict):
    locations: list[str]
    unlocked: list[str]


class GeneratedFiles(typing.TypedDict):
    tech_tree: list[CustomTechTreeItem]
    progressive_data: list[ProgressiveEntry]
    custom_recipes: list[ConfigurationRecipesItem]
    starting_tech: list[str]


def mod_version() -> str:
    """Returns the required mod version for this version of the package"""
    base_version = version.__version_tuple__
    return f"{base_version[0]}.{base_version[1]}.{base_version[2]}"
