AddCSLuaFile()
local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Resource"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "OreName")
    self:NetworkVar("Int", 0, "OreAmount")
end

if (SERVER) then
    function ENT:Initialize()
        local random_rock = table.Random(PLUGIN.rocks)

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PrecacheGibs()

        self:ChangeRockType(random_rock, true)

        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:Wake()
        end
    end


    do
        function ENT:GetRockType()
            return self.rockType
        end

        function ENT:SetRockType(rockType)
            self.rockType = rockType
        end

        function ENT:ChangeRockType(rockType, bInit)
            self:SetRockType(rockType)
            self:SetModel(rockType.mdl)
            if !(bInit) then self:SetOreName(string.format("%s %s", rockType.name, self:GetOreName())) end

            if (bInit) then
                local random_ore = PLUGIN:GetRandomOre().uniqueID
                self:SetOre(random_ore)
                self:SetOreAmount(math.floor(math.random(rockType.min, rockType.max)))
                self:SetColor(self:GetOreColor())
                self:SetMaterial("rockpack/rock")
            end
        end
    end

    do
        function ENT:GetOre()
            return self.ore
        end

        function ENT:SetOre(ore)
            self.ore = ore
            self:SetOreName(string.format("%s %s", self:GetRockType().name, PLUGIN.GetOre(ore):GetName()))
        end

        function ENT:GetOreColor()
            return PLUGIN.GetOre(self:GetOre()).color or Color(255, 255, 255)
        end

        function ENT:GetOreTable()
            return PLUGIN.GetOre(self:GetOre())
        end
    end

    do
        function ENT:GetNextUseTime()
            return self.nextUseTime or 0
        end

        function ENT:SetNextUseTime(nextUseTime)
            self.nextUseTime = nextUseTime
        end

        function ENT:IncNextUseTime(inc)
            self:SetNextUseTime(self:GetNextUseTime() + inc)
        end
    end

    -- on mined effect
    function ENT:OnMinedEffect()
        local effectData = EffectData()
            effectData:SetOrigin(self:LocalToWorld(self:OBBCenter()))
            effectData:SetMagnitude(20)
            effectData:SetScale(4)
            effectData:SetRadius(4)
        util.Effect("Sparks", effectData)
        self:EmitSound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", 60, math.random(80, 120))
    end

    function ENT:SpawnOre(ply)
        if !(IsValid(ply) and ply:IsPlayer()) then return end
        if !(ply:GetCharacter()) then return end

        if (math.random(1, 7) == 1) then
            ix.item.Spawn(self:GetOre(), Vector(0,0,0), function(item, entity)
                entity:SetPos(ply:GetItemDropPos(entity))
                entity:SetAngles(AngleRand())
                entity:SetVelocity(VectorRand() * 100)
            end)
        end
    end

    -- random chance to update a players attribute to a amount that is lower the higher level you are, the attribute is "mining"
    -- attributes are a 0.0 to 100.0 scale so we need to base it off of that, and the higher the level the lower the chance
    function ENT:UpdateMiningAttribute(ply)
        if !(IsValid(ply) and ply:IsPlayer()) then return end
        if !(ply:GetCharacter()) then return end

        if (math.random(1, 42) == 1) then
            ply:GetCharacter():UpdateAttrib("mining", 0.1)
        end

        if (math.random(1, 42) == 1) then
            ply:GetCharacter():UpdateAttrib("str", 0.1)
        end
    end

    function ENT:OnMined(ply)
        if !(IsValid(ply) and ply:IsPlayer()) then return end
        if !(ply:GetCharacter()) then return end

        local oreAmount = self:GetOreAmount()
        local rock_type = PLUGIN:GetRockTypeByNumber(oreAmount)

        if (oreAmount > 0) then
            self:SetOreAmount(oreAmount - 1)
            self:OnMinedEffect()
            self:SpawnOre(ply)
            self:UpdateMiningAttribute(ply)

            if (oreAmount - 1 < rock_type.min) then
                self:ChangeRockType(PLUGIN:GetRockTypeByNumber(oreAmount - 1))
            end
        else
            PLUGIN:CacheRock(self)
            self:Remove()
        end
    end

end 