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

local function addHandcraftingTweaks(params)
    params.icons = {
        params.icon,
        handcraftIcon
    }
    params.icon = nil
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
            { "iron-gear-wheel",    1 },
            { "pipe",               2 },
            { "iron-plate",         2 },
            { "steel-plate",        2 },
            { "coal",               20 },
            { "electronic-circuit", 7 },
        },
        result = "construction-robot",

        icon =
        {
            icon = "__base__/graphics/icons/construction-robot.png",
            icon_size = 64,
            icon_mipmaps = 4
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
            { "iron-gear-wheel",    1 },
            { "pipe",               2 },
            { "iron-plate",         2 },
            { "steel-plate",        2 },
            { "coal",               20 },
            { "electronic-circuit", 5 },
            { "advanced-circuit",   2 }
        },
        result = "logistic-robot",

        icon =
        {
            icon = "__base__/graphics/icons/logistic-robot.png",
            icon_size = 64,
            icon_mipmaps = 4
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
