import typing

from factorio_randovania_mod.configuration import ConfigurationRecipesItem


class TechCosts(typing.TypedDict):
    count: int
    time: int
    ingredients: list[tuple[str, int]]


class CustomTechTreeItem(typing.TypedDict):
    name: str
    icon_size: typing.NotRequired[int]
    icon: str
    costs: TechCosts
    prerequisites: list[str] | None
    take_effects_from: typing.NotRequired[str]


class TechRepurpose(typing.TypedDict):
    science_pack: str
    prerequisites: list[str]


class GeneratedFiles(typing.TypedDict):
    tech_tree: list[CustomTechTreeItem]
    local_unlocks: dict[str, list[str]]
    existing_tree_repurpose: dict[str, TechRepurpose]
    starting_tech: list[str]
    custom_recipes: list[ConfigurationRecipesItem]
