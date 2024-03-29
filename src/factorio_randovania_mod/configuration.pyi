# This file is generated. Manual changes will be lost
# fmt: off
# ruff: noqa
from __future__ import annotations

import typing


# The root object

class ConfigurationTechnologiesItemCost(typing.TypedDict):
    count: typing.Required[int]
    time: typing.Required[int]
    ingredients: typing.Required[list[str]]


class ConfigurationTechnologiesItem(typing.TypedDict):
    tech_name: typing.NotRequired[str]
    locale_name: typing.Required[str]
    description: typing.Required[str]
    icon: typing.Required[str]
    icon_size: typing.NotRequired[int]
    cost: typing.Required[ConfigurationTechnologiesItemCost]
    prerequisites: typing.Required[list[str]]
    unlocks: typing.Required[list[str]]


class ConfigurationRecipesItemIngredientsItem(typing.TypedDict):
    name: typing.Required[str]
    amount: typing.Required[int]
    type: typing.NotRequired[str]


class ConfigurationRecipesItem(typing.TypedDict):
    recipe_name: typing.Required[str]
    category: typing.Required[str]
    result_amount: typing.Required[int]
    ingredients: typing.Required[list[ConfigurationRecipesItemIngredientsItem]]


class Configuration(typing.TypedDict):
    configuration_identifier: typing.Required[str]
    layout_uuid: typing.Required[str]
    technologies: typing.Required[list[ConfigurationTechnologiesItem]]
    recipes: typing.Required[list[ConfigurationRecipesItem]]
    starting_tech: typing.Required[list[str]]


Configuration = Configuration
