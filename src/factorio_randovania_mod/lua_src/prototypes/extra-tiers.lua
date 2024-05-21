local longer_item = table.deepcopy(data.raw["item"]["long-handed-inserter"])
-- FIXME: change icon
longer_item.name = "longer-handed-inserter"
longer_item.order = "c[longer-handed-inserter]"
longer_item.place_result = "longer-handed-inserter"

local longer_entity = table.deepcopy(data.raw["inserter"]["long-handed-inserter"])
longer_entity.name = "longer-handed-inserter"
longer_entity.minable.result = "longer-handed-inserter"
longer_entity.pickup_position = { 0, -3 }
longer_entity.insert_position = { 0, 3.2 }
longer_entity.fast_replaceable_group = "longer-handed-inserter"

---@param sprite data.Sprite|data.SpriteNWaySheet
local function apply_tint(sprite)
    sprite.tint = { r = 0.5, g = 0.5, b = 0.5, a = 1 }
    sprite.hr_version.tint = { r = 0.5, g = 0.5, b = 0.5, a = 1 }
end

apply_tint(longer_entity.hand_base_picture)
apply_tint(longer_entity.hand_closed_picture)
apply_tint(longer_entity.hand_open_picture)
apply_tint(longer_entity.hand_base_shadow)
apply_tint(longer_entity.hand_closed_shadow)
apply_tint(longer_entity.hand_open_shadow)
apply_tint(longer_entity.platform_picture.sheet)

local longer_recipe = table.deepcopy(data.raw["recipe"]["long-handed-inserter"])
longer_recipe.name = "longer-handed-inserter"
longer_recipe.ingredients = {
    { "iron-stick", 4 },
    { "inserter",   3 }
}
longer_recipe.result = "longer-handed-inserter"

data:extend {
    longer_item, longer_entity, longer_recipe
}
