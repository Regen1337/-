-- soda blueprint
ITEM.name = "Gold Bar Blueprint"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A blueprint that teaches you how to make gold bars."
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
    ["gold_bar"] = true
}