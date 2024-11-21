import construct

from factorio_randovania_mod.mod_lua_api import mod_version

Short = construct.Int16ul
PrefixString = construct.PascalString(Short, "utf-8")
PrefixStringArray = construct.PrefixedArray(Short, PrefixString)
IngredientTypeEnum = construct.Enum(construct.Byte, item=0, fluid=1)

TechTreeEntry = construct.Struct(
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

LayoutData = construct.Struct(
    schema_version=construct.Const(1, Short),
    mod_version=construct.Const(mod_version(), PrefixString),
    tech_tree=construct.PrefixedArray(Short, TechTreeEntry),
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
)
