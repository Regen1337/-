-- soda blueprint
ITEM.name = "Soda Blueprint"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A blueprint that teaches you how to make a soda."
ITEM.category = "Blueprints"

ITEM.bp_required_attributes = {
    ["str"] = 2
}

ITEM.bp_required_factions = {
    ["wastelander"] = true
}

ITEM.bp_required_classes = {
    ["wastelander"] = {
        ["scavenger"] = true
    }
}

ITEM.bp_learn_to_craft = {
    ["soda"] = true
}