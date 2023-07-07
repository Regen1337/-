ITEM.name = "Gold Bar"
ITEM.model = "models/mosi/fallout4/props/junk/components/gold.mdl"
ITEM.description = "Gold used for crafting."
ITEM.category = "Crafting Material"
ITEM.width = 1
ITEM.height = 1

ITEM.craft_given_items = {
    ["gold_bar"] = {
        amount = 1
    }
}

ITEM.craft_delay_time = 5 -- time in seconds to delay crafting again
ITEM.breakdown_delay_time = 5 -- time in seconds to delay breaking down items

ITEM.craft_required_items = {
    ["glass"] = {
        amount = 2,
        remove_amount = 2
    }
}

ITEM.craft_required_entities = {
    ["ix_vendor"] = true
}

ITEM.craft_required_attributes = {
    ["str"] = 2
}

ITEM.craft_required_factions = {
    ["wastelander"] = true
}

ITEM.craft_required_classes = {
    ["wastelander"] = {
        ["scavenger"] = true
    }
}

ITEM.craft_required_blueprints = {
    ["gold_bar"] = true
}

-- requires the character to have the listed attributes
ITEM.breakdown_required_attributes = {
    ["str"] = 3, 
}

-- requires the character to be in the listed faction
ITEM.breakdown_required_factions = {
    ["wastelander"] = true -- unique id of the faction
}

-- requires the character to be in the listed faction, and the listed class
ITEM.breakdown_required_classes = {
    ["wastelander"] = { -- unique id of the faction
        ["scavenger"] = true -- unique id of the class
    }
}

-- requires all of the listed blueprints to be learned, to be able to break down the item
ITEM.breakdown_required_blueprints = {
    ["gold_bar"] = true  -- unique id of the learned item
}

-- requires all of the listed items to be in the players inventory, to be able to break down the item
ITEM.breakdown_required_items = {
    ["hammer"] = {
        amount = 1, -- amount of the item required
        remove_amount = 0 -- amount of the item to remove from the players inventory, caped at the first amount
    } 
}

-- if you're near any listed it will work
ITEM.breakdown_required_entities = {
    ["ix_vendor"] = true -- unique id of the entity
}

-- items to give to the player when the item is broken down
ITEM.breakdown_given_items = {
    ["glass"] = {
        amount = 2 -- amount of the item to give to the player
    }
}
