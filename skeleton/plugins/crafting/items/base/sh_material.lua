ITEM.name = "Crafting Material Base"
ITEM.model = "models/mosi/fallout4/props/junk/blueprint.mdl"
ITEM.description = "A base crafting material."
ITEM.category = "Crafting Material"
ITEM.width = 1
ITEM.height = 1

function ITEM:GetColor()
    return self:GetData("color", self.color)
end

function ITEM:SetColor(color)
    self:SetData("color", color)
end

function ITEM:IsOre()
    return self:GetData("isOre", self.isOre)
end

function ITEM:GetOreChance()
    return self:GetData("oreChance", self.ore_chance)
end

function ITEM:SetOreChance(oreChance)
    self:SetData("oreChance", oreChance)
end

function ITEM:MINING_GetRequiredAttributes()
    return self:GetData("mine_required_attributes", self.mine_required_attributes)
end

function ITEM:MINING_SetRequiredAttributes(attributes)
    self:SetData("mine_required_attributes", attributes)
end



ITEM.functions.Break = {
    OnRun = function(item)
        local client = item.player

        local char = client:GetCharacter()
        if not char then return false end

        local can, err = char:BREAKDOWN_CanBreak(item.uniqueID)
        if !can then client:Notify(err) return false end
        
        char:BREAKDOWN_BreakItem(item)
    end,
    OnCanRun = function(item)
        local client = item.player

        local char = client:GetCharacter()
        if not char then return false end

        local can, err = char:BREAKDOWN_CanBreak(item.uniqueID)
        if !can then print(can, err) return false end

        return true
    end
}