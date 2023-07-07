function PLUGIN:CanPlayerTakeItem(character, item)
    character = character:GetCharacter(); item = item:GetItemTable();
    local item_weight = item:GetWeight()

    if (item_weight and !character:CanCarryWeight(item_weight)) then
        return false
    end
end

function PLUGIN:CanPlayerTradeWithVendor(character, entity, item, isSelling)
    character = character:GetCharacter(); item = ix.item.list[item]

    if (!isSelling and item_weight and !character:CanCarryWeight(item_weight)) then
        return false
    end
end
