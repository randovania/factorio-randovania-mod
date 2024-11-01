data:extend {
    {
        type = "recipe-category",
        name = "hand-crafting"
    }
}
table.insert(
    data.raw["character"]["character"].crafting_categories, "hand-crafting"
)

local handcraftIcon = {
    icon = "__core__/graphics/icons/mip/slot-item-in-hand.png",
    icon_size = 64,
    scale = 0.25,
    shift = { 8, 8 }
}

---comment
---@param params data.RecipePrototype
---@return data.RecipePrototype
local function addHandcraftingTweaks(params)
    assert(params.icon == nil)
    table.insert(params.icons, handcraftIcon)
    params.category = "hand-crafting"
    params.allow_decomposition = false
    params.allow_as_intermediate = false
    params.always_show_made_in = true
    return params
end


data:extend {
    addHandcraftingTweaks {
        type = "recipe",
        name = "construction-robot-handcraft",
        localised_name = "Construction Robot (Handcraft)",
        enabled = false,
        energy_required = 30,
        ingredients =
        {
            { type = "item", name = "iron-gear-wheel",    amount = 1 },
            { type = "item", name = "pipe",               amount = 2 },
            { type = "item", name = "iron-plate",         amount = 2 },
            { type = "item", name = "steel-plate",        amount = 2 },
            { type = "item", name = "coal",               amount = 20 },
            { type = "item", name = "electronic-circuit", amount = 7 },
        },
        results = {
            { type = "item", name = "construction-robot", amount = 1},
        },

        icons = {
            { icon = "__base__/graphics/icons/construction-robot.png" },
        },
        order = "a[robot]-b[construction-robot]"
    },
    addHandcraftingTweaks {
        type = "recipe",
        name = "logistic-robot-handcraft",
        localised_name = "Logistic Robot (Handcraft)",
        enabled = false,
        energy_required = 30,
        ingredients =
        {
            { type = "item", name = "iron-gear-wheel",    amount = 1 },
            { type = "item", name = "pipe",               amount = 2 },
            { type = "item", name = "iron-plate",         amount = 2 },
            { type = "item", name = "steel-plate",        amount = 2 },
            { type = "item", name = "coal",               amount = 20 },
            { type = "item", name = "electronic-circuit", amount = 5 },
            { type = "item", name = "advanced-circuit",   amount = 2 }
        },
        results = {
            { type = "item", name = "logistic-robot",     amount = 1},
        },

        icons = {
            {
                icon = "__base__/graphics/icons/logistic-robot.png",
            }
        },
        order = "a[robot]-b[logistic-robot]"
    },
}


table.insert(
    data.raw["technology"]["construction-robotics"]["effects"],
    5,
    {
        recipe = "construction-robot-handcraft",
        type = "unlock-recipe"
    }
)
table.insert(
    data.raw["technology"]["logistic-robotics"]["effects"],
    5,
    {
        recipe = "logistic-robot-handcraft",
        type = "unlock-recipe"
    }
)
