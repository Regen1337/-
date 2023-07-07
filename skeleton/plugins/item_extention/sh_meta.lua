do
    local ITEM = ix.meta.item

    do
        function ITEM:GetWeight()
            return self:GetData("weight", self.weight or 0)
        end

        function ITEM:SetWeight(weight)
            self:SetData("weight", weight)
        end

        function ITEM:AddWeight(weight)
            self:SetWeight(self:GetWeight() + weight)
        end

        function ITEM:RemoveWeight(weight)
            self:SetWeight(math.max(self:GetWeight() - weight, 0))
        end
    end

    do
        function ITEM:IsSoulBound()
            return self:GetData("soulbound", self.default_soulbound or false)
        end    

        function ITEM:SetSoulBound(bSoulBound)
            self:SetData("soulbound", bSoulBound)
        end
    end

    ix.meta.item = ITEM
end

do
    local CHAR = ix.meta.character

    function CHAR:GetWeight()
        local weight = 0

        for _, v in next, (self:GetInventory():GetItems()) do
            weight = weight + (v:GetWeight())
        end

        return weight
    end

    function CHAR:GetMaxWeight()
        local class = ix.class.list[self:GetClass()]
        local faction = ix.faction.indices[self:GetFaction()]

        if (class) then
            return class.weight or 0
        elseif (faction) then
            return faction.weight or 0
        end

        return 0
    end

    function CHAR:GetRemainingWeight()
        return self:GetMaxWeight() - self:GetWeight()
    end

    function CHAR:CanCarryWeight(weight)
        return self:GetMaxWeight() == 0 and true or self:GetRemainingWeight() >= weight
    end

    function CHAR:IsOverWeight()
        return self:GetWeight() > self:GetMaxWeight()
    end

    ix.meta.character = CHAR
end