# This file is generated. Manual changes will be lost
# fmt: off
# ruff: noqa
# mypy: disable-error-code="misc"
from __future__ import annotations

import typing_extensions as typ


# Schema entries

@typ.final
class ConfigurationTechnologiesItem(typ.TypedDict):
    tech_name: typ.NotRequired[str]
    """Internal name of the technology"""

    locale_name: str
    """Name of the technology"""

    description: str
    """Description of the technology"""

    icon: str
    """Factorio filepath for the icon to use"""

    icon_size: typ.NotRequired[int] = 256
    """Set the size of the icon image"""

    cost_reference: typ.NotRequired[str]
    """The technology to use for research cost and prerequisites"""

    prerequisites: list[str]
    """List of which technologies must be researched before"""

    unlocks: list[str]
    """List of which technologies are granted when this is researched."""

ConfigurationRecipesItemIngredientsItemType = typ.Literal[
    'item',
    'fluid'
]

@typ.final
class ConfigurationRecipesItemIngredientsItem(typ.TypedDict):
    name: str
    """Item name of this ingredient"""

    amount: int
    """How many copies of the ingredient are used"""

    type: typ.NotRequired[ConfigurationRecipesItemIngredientsItemType] = 'item'
    """What kind of ingredient it is"""


@typ.final
class ConfigurationRecipesItem(typ.TypedDict):
    recipe_name: str
    """Name of the recipe to modify"""

    category: str
    """New crafting category to use for the recipe"""

    ingredients: list[ConfigurationRecipesItemIngredientsItem]
    """The new costs of the recipe"""


@typ.final
class Configuration(typ.TypedDict):
    configuration_identifier: str
    """An unique identifier for this configuration. Only save files created with this identifier can be loaded."""

    layout_uuid: typ.Annotated[str, '/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/']
    """An UUID exposed via a global lua variable"""

    technologies: list[ConfigurationTechnologiesItem]
    """List of custom technologies to create."""

    recipes: list[ConfigurationRecipesItem]
    """Modify given recipes"""

    starting_tech: list[str]
    """List of technologies that you start the game with"""
