local PLUGIN = PLUGIN

PLUGIN.name = "Crafting System"
PLUGIN.author = "regen"
PLUGIN.description = "Adds a crafting system to Helix, allowing players to craft items, break down items and learn blueprints for items."

do
    function PLUGIN.GetOres()
        local ores = {}

        for _, item in next, (ix.item.list) do
            if (item.IsOre and item:IsOre()) then
                ores[#ores + 1] = item
            end
        end

        return ores
    end

    function PLUGIN.GetOre(uniqueID)
        for _, item in next, (ix.item.list) do
            if (item.uniqueID == uniqueID and item.IsOre and item:IsOre()) then
                return item
            end
        end
    end

    function PLUGIN:GetRandomOre()
        local ores = self.GetOres()
        local totalChance = 0

        for _, item in pairs(ores) do
            totalChance = totalChance + item:GetOreChance()
        end

        local random = math.random(0, totalChance)
        local currentChance = 0

        for _, item in pairs(ores) do
            currentChance = currentChance + item:GetOreChance()

            if (random <= currentChance) then
                return item
            end
        end
    end

    function PLUGIN:TestOreGeneration(amount)
        local ores = {}

        for i = 1, amount do
            local ore = self:GetRandomOre()
            ores[#ores + 1] = ore
        end

        local oreTable = {}

        for _, ore in pairs(ores) do
            if (oreTable[ore.uniqueID]) then
                oreTable[ore.uniqueID].amount = oreTable[ore.uniqueID].amount + 1
            else
                oreTable[ore.uniqueID] = {
                    name = ore.name,
                    amount = 1,
                    chance = ore:GetOreChance()
                }
            end
        end

        for _, ore in next, (oreTable) do
            print(ore.name, ore.amount, ore.chance)
        end
    end

    ix.command.Add("testoregen", {
        description = "Test ore generation.",
        adminOnly = true,
        OnRun = function(self, client)
            PLUGIN:TestOreGeneration(100)
        end
    })
    
end

do
    function PLUGIN.ConvertEntityClassToName(entity_class)
        local entity = scripted_ents.Get(entity_class)

        if (entity and entity.PrintName) then
            return entity.PrintName
        end

        return false
    end

    function PLUGIN.ConvertUniqueIDsToItems(uniqueids)
        local items = {}
    
        for uniqueid, _ in next, (uniqueids) do
            local item = ix.item.list[uniqueid]
    
            if (item) then
                table.insert(items, table.Copy(item))
            end
        end
    
        return items
    end
end

do
    PLUGIN.rocks = {
        ["large"] = {
            name = "Large",
            mdl = "models/props_mining/sky1_1.mdl",
            min = 26,
            max = 50
        },
        ["medium"] = {
            name = "Medium",
            mdl = "models/props_mining/sky4_1.mdl",
            min = 11,
            max = 25
        },
        ["small"] = {
            name = "Small",
            mdl = "models/props_mining/sky5_1.mdl",
            min = 0,
            max = 10
        }
    }
    
    function PLUGIN:GetRockTypeByNumber(number)
        for k, v in pairs(self.rocks) do
            if (number >= v.min and number <= v.max) then
                return v
            end
        end
    end
    
    function PLUGIN:CacheRock(entity)
        self.cachedRocks = self.cachedRocks or {}

        for _, v in pairs(self.cachedRocks) do
            if (v.position == entity:GetPos() and v.angles == entity:GetAngles()) then
                return false, "This rock is already cached."
            end
        end

        local rockData = {
            position = entity:GetPos() or entity.position,
            angles = entity:GetAngles() or entity.angles,
        }
        table.insert(self.cachedRocks, rockData)
    end
    
    function PLUGIN:GetCachedRocks()
        return self.cachedRocks or {}
    end

    function PLUGIN:RemoveCachedRock(entity)
        self.cachedRocks = self.cachedRocks or {}

        for k, v in pairs(self.cachedRocks) do
            if (v.position == entity:GetPos() and v.angles == entity:GetAngles()) then
                table.remove(self.cachedRocks, k)
            end
        end
    end
end

do
    PLUGIN.nextThink = PLUGIN.nextThink or 0
    PLUGIN.hasPostEntInit = PLUGIN.hasPostEntInit or false

    if (SERVER) then

        function PLUGIN:InitPostEntity()
            if (self.hasPostEntInit) then return end
            self.hasPostEntInit = true
        end

        function PLUGIN:SaveData()
            local data = {}

            for _, entity in next, (ents.GetAll()) do
                if (entity:GetClass() == "ix_resource_node") then
                    local position = entity:GetPos()
                    local angles = entity:GetAngles()

                    data[#data + 1] = {
                        position = position,
                        angles = angles,
                    }
                end
            end

            for _, rock in next, (self:GetCachedRocks()) do
                data[#data + 1] = rock
            end

            self:SetData(data)
        end

        function PLUGIN:LoadData()
            local data = self:GetData()

            if (data) then
                for _, d in next, (data) do
                    local entity = ents.Create("ix_resource_node")
                    if entity != NULL then
                        entity:Spawn()
                        entity:SetPos(d.position)
                        entity:SetAngles(d.angles)
                        entity:Activate()
                        entity:DropToFloor()
                    else
                        self:CacheRock(d)
                    end
                end
            end
        end

        function PLUGIN:Think()
            if (CurTime() >= self.nextThink and self.hasPostEntInit) then
                self.nextThink = CurTime() + 60
    
                for _, rock in next, (self:GetCachedRocks()) do
                    local entity = ents.Create("ix_resource_node")
                    if IsValid(entity) then
                        entity:Spawn()
                        entity:SetPos(rock.position)
                        entity:SetAngles(rock.angles)
                        entity:Activate()
                        entity:DropToFloor()
                        self:RemoveCachedRock(entity)
                    end
                end
            end
        end
    end

end

ix.util.Include("sh_meta.lua")
ix.util.Include("sh_networking.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_plugin.lua")