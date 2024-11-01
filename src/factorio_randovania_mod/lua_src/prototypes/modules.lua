for _, name in pairs {
    "efficiency-module",
    "efficiency-module-2",
    "efficiency-module-3",
    "speed-module",
    "speed-module-2",
    "speed-module-3",
    "productivity-module",
    "productivity-module-2",
    "productivity-module-3",
} do
    local recipe = data.raw["recipe"][name]
    for _, ingredient in pairs(recipe.ingredients) do
        ingredient.amount = math.floor(ingredient.amount / 2)
    end
end
