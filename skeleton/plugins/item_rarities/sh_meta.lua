local PLUGIN = PLUGIN
local rarities = ix.item.rarities

do
    local ITEM = ix.meta.item

    function ITEM:GetRarity()
        return self:GetData("rarity", "Common")
    end

    function ITEM:GetRarityTable()
        return ix.item.rarities.list[self:GetRarity()]
    end

    function ITEM:GetRarityColor()
        if !(self:GetRarityTable()) then return false, "no rarity table" end
        return self:GetRarityTable().color
    end

    function ITEM:GetRarityName()
        if !(self:GetRarityTable()) then return false, "no rarity table" end
        return self:GetRarityTable().name
    end

    function ITEM:GetRarityChance()
        if !(self:GetRarityTable()) then return false, "no rarity table" end
        return self:GetRarityTable().chance
    end

    function ITEM:GetRarityScales()
        if !(self:GetRarityTable()) then return false, "no rarity table" end
        return self:GetRarityTable().scales
    end

    function ITEM:GetRarityScale(scale)
        if !(self:GetRarityTable()) then return false, "no rarity table" end
        if !(self:GetRarityScales()[scale]) then return false, "invalid scale" end
        return self:GetRarityScales()[scale]
    end

    function ITEM:SetRarity(rarity)
        if !(rarities.get(rarity)) then return false, "invalid rarity" end
        self:SetData("rarity", rarity)
    end

    function ITEM:GenerateRarity()
        --local rarity = rarities.generate()
        self:SetRarity(rarity)
    end
    
    function ITEM:GetName()
        local name = self.name
        local rarity = self:GetRarityName()
        if (rarity != "Common") then
            name = rarity.." "..name
        end
        return name
    end

    ix.meta.item = ITEM
end