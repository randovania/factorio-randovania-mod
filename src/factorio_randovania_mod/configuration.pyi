# This file is generated. Manual changes will be lost
# fmt: off
# ruff: noqa
from __future__ import annotations

import typing_extensions as typ




# Schema entries
class ConfigurationTechnologiesItemResearchTrigger(typ.TypedDict, total=False):
    entity: str
    item: str
    count: int

@typ.final
class ConfigurationTechnologiesItemCost(typ.TypedDict):
    count: int
    time: int
    ingredients: list[str]

@typ.final
class ConfigurationTechnologiesItem(typ.TypedDict):
    tech_name: typ.NotRequired[str]
    locale_name: str
    description: str
    icon: str
    icon_size: typ.NotRequired[int]
    research_trigger: typ.NotRequired[ConfigurationTechnologiesItemResearchTrigger]
    cost: typ.NotRequired[ConfigurationTechnologiesItemCost]
    prerequisites: list[str]
    unlocks: list[str]

@typ.final
class ConfigurationRecipesItemIngredientsItem(typ.TypedDict):
    name: str
    amount: int
    type: typ.NotRequired[str]

@typ.final
class ConfigurationRecipesItem(typ.TypedDict):
    recipe_name: str
    category: str
    ingredients: list[ConfigurationRecipesItemIngredientsItem]

@typ.final
class Configuration(typ.TypedDict):
    configuration_identifier: str
    layout_uuid: str
    technologies: list[ConfigurationTechnologiesItem]
    recipes: list[ConfigurationRecipesItem]
    starting_tech: list[str]
