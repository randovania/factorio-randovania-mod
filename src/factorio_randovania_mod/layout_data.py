from __future__ import annotations

import typing

import construct

from factorio_randovania_mod import mod_lua_api

if typing.TYPE_CHECKING:
    from factorio_randovania_mod.configuration import ConfigurationRecipesItem

Short = construct.Int16ul
PrefixString = construct.PascalString(Short, "utf-8")
PrefixStringArray = construct.PrefixedArray(Short, PrefixString)
IngredientTypeEnum = construct.Enum(construct.Byte, item=0, fluid=1)


class TechTreeVisualData(typing.TypedDict):
    icon: str
    icon_size: int
    localised_description: str


class TechTreeEntry(typing.TypedDict):
    name: str
    localised_name: str
    prerequisites: list[str]
    take_effects_from: str
    visual_data: TechTreeVisualData | None
    cost_reference: str


class ProgressiveEntry(typing.TypedDict):
    locations: list[str]
    unlocked: list[str]


class LayoutData(typing.TypedDict):
    tech_tree: list[TechTreeEntry]
    progressive_data: list[ProgressiveEntry]
    custom_recipes: list[ConfigurationRecipesItem]
    starting_tech: list[str]


TechTreeEntryConstruct = construct.Struct(
    name=PrefixString,
    localised_name=PrefixString,
    prerequisites=PrefixStringArray,
    take_effects_from=PrefixString,
    visual_data=construct.If(
        construct.len_(construct.this.take_effects_from) == 0,
        construct.Struct(
            icon=PrefixString,
            icon_size=Short,
            localised_description=PrefixString,
        ),
    ),
    cost_reference=PrefixString,
)


def LayoutDataConstruct():
    return construct.FocusedSeq(
        "data",
        schema_version=construct.Const(1, Short),
        mod_version=construct.Const(mod_lua_api.mod_version(), PrefixString),
        data=construct.Prefixed(
            construct.Int32ul,
            construct.Compressed(
                construct.Struct(
                    tech_tree=construct.PrefixedArray(Short, TechTreeEntryConstruct),
                    progressive_data=construct.PrefixedArray(
                        Short,
                        construct.Struct(
                            locations=PrefixStringArray,
                            unlocked=PrefixStringArray,
                        ),
                    ),
                    custom_recipes=construct.PrefixedArray(
                        Short,
                        construct.Struct(
                            recipe_name=PrefixString,
                            category=PrefixString,
                            ingredients=construct.PrefixedArray(
                                Short,
                                construct.Struct(
                                    type=IngredientTypeEnum,
                                    name=PrefixString,
                                    amount=Short,
                                ),
                            ),
                        ),
                    ),
                    starting_tech=PrefixStringArray,
                ),
                "zlib",
            ),
        ),
    )
