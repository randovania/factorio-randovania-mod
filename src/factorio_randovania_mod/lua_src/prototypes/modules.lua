for _, name in pairs {
    "effectivity-module",
    "effectivity-module-2",
    "effectivity-module-3",
    "speed-module",
    "speed-module-2",
    "speed-module-3",
    "productivity-module",
    "productivity-module-2",
    "productivity-module-3",
} do
    local recipe = data.raw["recipe"][name]
    for _, ingredient in pairs(recipe.ingredients) do
        ingredient[2] = math.floor(ingredient[2] / 2)
    end
end
