
for name, tech in pairs(data.raw["technology"]) do
    tech.hidden = true
end

function add_randovania_tech(param)
    data:extend(
        {
            {
                type = "technology",
                name = param.name,
                icon_size = 256,
                icon_mipmaps = 4,
                icon = param.icon,
                effects = {},
                unit = param.costs,
                order = param.order or param.name,
                prerequisites = param.prerequisites,
            },
        })
end

add_randovania_tech {
    name = "randovania-red-a",
    icon = "__base__/graphics/technology/steel-processing.png",
    costs = {
        count = 50,
        ingredients = {{"automation-science-pack", 1}},
        time = 5
    }
}
