import typing

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
    prerequisites: list[str] | None
    take_effects_from: typing.NotRequired[str]
    visual_data: typing.NotRequired[TechTreeVisualData]
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
    starting_tech: list[str]
    custom_recipes: list[ConfigurationRecipesItem]
