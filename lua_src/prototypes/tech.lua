local function make_tech(param)
    param.type = "technology"
    param.order = param.order or "d-b"
    param.unit = {
        count = 10,
        ingredients = {{"automation-science-pack", 1}},
        time = 15
    }
    return param
end

data:extend {
    make_tech {
        name = "long-handed-inserter",
        effects = {
            {
                recipe = "long-handed-inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/fast-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "oil-cracking",
        effects = {
            {
                recipe = "chemical-plant",
                type = "unlock-recipe"
            },
            {
                recipe = "heavy-oil-cracking",
                type = "unlock-recipe"
            },
            {
                recipe = "light-oil-cracking",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/oil-processing.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "solid-fuel",
        effects = {
            {
                recipe = "solid-fuel-from-heavy-oil",
                type = "unlock-recipe"
            },
            {
                recipe = "solid-fuel-from-light-oil",
                type = "unlock-recipe"
            },
            {
                recipe = "solid-fuel-from-petroleum-gas",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/oil-processing.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "light-armor",
        effects = {
            {
                recipe = "light-armor",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/heavy-armor.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "big-electric-pole",
        effects = {
            {
                recipe = "big-electric-pole",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/electric-energy-distribution-1.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "inserter",
        effects = {
            {
                recipe = "inserter",
                type = "unlock-recipe"
            }
        },
        icon = "__base__/graphics/technology/fast-inserter.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "steam-power",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "offshore-pump"
            },
            {
                type = "unlock-recipe",
                recipe = "boiler"
            },
            {
                type = "unlock-recipe",
                recipe = "steam-engine"
            }
        },
        icon = "__base__/graphics/technology/electric-energy-acumulators.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "automation-science-pack",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "automation-science-pack"
            }
        },
        icon = "__base__/graphics/technology/automation-science-pack.png",
        icon_mipmaps = 4,
        icon_size = 256
    },
    make_tech {
        name = "regular-inserter-capacity-bonus",
        effects = {
            {
                type = "inserter-stack-size-bonus",
                modifier = 1
            }
        },
        icon = "__base__/graphics/technology/inserter-capacity.png",
        icon_mipmaps = 4,
        icon_size = 256,
        upgrade = true
    }
}
