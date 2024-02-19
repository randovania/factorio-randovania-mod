
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

local tech_tree = require("generated.tech-tree")

for _, tech in ipairs(tech_tree) do
    add_randovania_tech(tech)
end