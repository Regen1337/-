local PLUGIN = PLUGIN
PLUGIN.name = "XP System"
PLUGIN.author = "regen"
PLUGIN.desc = "A level system for Helix."
PLUGIN.schema = "Any"
PLUGIN.version = 1.0

ix.util.Include("sv_plugin.lua")
-- the level system is based on the amount of XP you have + the amount of attributes you have
-- ix.log to log the amount of XP set/added/removed and level set/added/removed etc

do
    ix.char.RegisterVar("XP", {
        field = "XP",
        fieldType = ix.type.number,
        default = 0,
        isLocal = true,
        bNoDisplay = true,
    })

    ix.char.RegisterVar("Level", {
        field = "Level",
        fieldType = ix.type.number,
        default = 0,
        isLocal = true,
        bNoDisplay = true,
    })
end

do
    local META = ix.meta.character

    PLUGIN.getXPForLevel = function(level)
        local xpScale = ix.config.Get("xpScale", 1.5)

        return math.floor(level ^ xpScale ^ 2.7)
    end

    PLUGIN.getLevelForXP = function(xp)
        local xpScale = ix.config.Get("xpScale", 1.5)

        return math.ceil(xp ^ (1 / xpScale ^ 2.7))
    end

    function META:GetXPFromAttributes()
        local xp = 0
        local attribute

        for k, v in pairs(ix.attributes.list) do
            attribute = self:GetAttribute(k, 0)
            if (attribute == 0) then continue end
            xp = xp + attribute
        end

        return xp
    end

    function META:GetMaxLevel()
        return ix.config.Get("maxLevel", 100)
    end

    function META:GetMaxXP()
        return PLUGIN.getXPForLevel(self:GetMaxLevel())
    end

    function META:GetNextLevel()
        local level = ix.config.Get("attributeXP", false) and self:GetTotalLevel() or self:GetLevel()
        local configXP = ix.config.Get("attributeXP", false)
        local configLevelMax = ix.config.Get("attributeLevelMax", false)

        if (configXP and not configLevelMax) then
            return true, level + 1
        else
            if (level >= self:GetMaxLevel()) then return false end
            return true, level + 1
        end
    end

    function META:GetNextXP()
        local xp = ix.config.Get("attributeXP", false) and self:GetTotalXP() or self:GetXP()
        local level = ix.config.Get("attributeXP", false) and self:GetTotalLevel() or self:GetLevel()
        local configXP = ix.config.Get("attributeXP", false)
        local configLevelMax = ix.config.Get("attributeLevelMax", false)

        if (configXP and not configLevelMax) then
            return PLUGIN.getXPForLevel(level + 1) - xp
        else
            if (level >= self:GetMaxLevel()) then return false end
            return PLUGIN.getXPForLevel(level + 1) - xp
        end
    end


    function META:AddLevel(amount)
        local level = self:GetLevel()
        local newLevel = math.min(level + amount, self:GetMaxLevel())

        self:SetLevel(newLevel)
    end

    function META:AddXP(amount)
        local xp = self:GetXP()
        local level = ix.config.Get("attributeXP", false) and self:GetTotalLevel() or self:GetLevel()

        if (xp == nil or not tonumber(xp)) then return end
        if (level == nil or not tonumber(level)) then return end

        if (ix.config.Get("attributeLevelMax", false)) then
            if (ix.config.Get("attributeLevelReset", false)) then
                if (level > self:GetMaxLevel()) then
                    self:SetLevel(self:GetMaxLevel())
                end

                if (xp > self:GetMaxXP()) then
                    self:SetXP(self:GetMaxXP())
                end
            end
        end

        local configXP = ix.config.Get("attributeXP", false)
        local configLevelMax = ix.config.Get("attributeLevelMax", false)
        local newXP

        if (configXP and not configLevelMax) then
            newXP = xp + amount
        else
            newXP = math.min(xp + amount, self:GetMaxXP())
        end

        local newLevel = PLUGIN.getLevelForXP(newXP)

        if (newLevel > level) then
            self:SetLevel(newLevel)
        end

        if (newXP > xp) then
            self:SetXP(newXP)
        end
    end

    function META:RemoveXP(amount)
        local xp = self:GetXP()
        local level = ix.config.Get("attributeXP", false) and self:GetTotalLevel() or self:GetLevel()

        if (xp == nil or not tonumber(xp)) then return end
        if (level == nil or not tonumber(level)) then return end

        local newXP = math.max(xp - amount, 0)
        local newLevel = PLUGIN.getLevelForXP(newXP)

        if (newLevel < 0) then return end
        if (newXP < 0) then return end

        if (newLevel < level) then
            self:SetLevel(newLevel)
        end

        if (newXP < xp) then
            self:SetXP(newXP)
        end
    end

    function META:GetTotalXP()
        local xp = self:GetXP()
        local attributeXP = self:GetXPFromAttributes()

        if (ix.config.Get("attributeXP", true)) then
            return xp + attributeXP
        else
            return xp
        end
    end

    function META:GetTotalLevel()
        local level = self:GetLevel()
        local attributeLevel = PLUGIN.getLevelForXP(self:GetXPFromAttributes())

        if (ix.config.Get("attributeXP", true)) then
            return level + attributeLevel
        else
            return level
        end
    end


end

do
    ix.config.Add("passiveXP", 1, "How much XP is gained passively.", nil, {
        category = PLUGIN.name,
        data = {min = 1, max = 1000}
    })

    ix.config.Add("maxLevel", 100, "The maximum level a character can reach.", nil, {
        category = PLUGIN.name,
        data = {min = 1, max = 1000}
    })

    ix.config.Add("xpScale", 2.5, "The scaling of XP required to level up.", nil, {
        category = PLUGIN.name,
        data = {min = 0.1, max = 10}
    })

    ix.config.Add("attributeXP", true, "Should attributes add to total XP?", nil, {
        category = PLUGIN.name,
    })

    ix.config.Add("attributeLevelMax", true, "Should attributes abide to max level?", nil, {
        category = PLUGIN.name,
    })

    ix.config.Add("attributeLevelReset", true, "Should characters past max XP reset to max XP? Only If Attribute Level Max was enabled", nil, {
        category = PLUGIN.name,
    })

    ix.config.Add("attributeXPScale", 0.5, "The scaling of XP gained from attributes.", nil, {
        category = PLUGIN.name,
        data = {min = 0.1, max = 10}
    })

    -- add a command to set a character's XP
    ix.command.Add("CharSetXP", {
        description = "Set a character's XP.",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, amount)
            local char = target

            if (char) then
                char:SetXP(amount)
                client:Notify("You have set " .. char:GetName() .. "'s XP to " .. amount .. ".")
            end
        end
    })

    -- command to add XP to a character
    ix.command.Add("CharAddXP", {
        description = "Add XP to a character.",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, amount)
            local char = target

            if (char) then
                char:AddXP(amount)
                client:Notify("You have added " .. amount .. " XP to " .. char:GetName() .. ".")
            end
        end
    })

    -- command to remove XP from a character
    ix.command.Add("CharRemoveXP", {
        description = "Remove XP from a character.",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, amount)
            local char = target

            if (char) then
                char:RemoveXP(amount)
                client:Notify("You have removed " .. amount .. " XP from " .. char:GetName() .. ".")
            end
        end
    })

    -- command to set a character's level
    ix.command.Add("CharSetLevel", {
        description = "Set a character's level.",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, amount)
            local char = target

            if (char) then
                char:SetLevel(amount)
                client:Notify("You have set " .. char:GetName() .. "'s level to " .. amount .. ".")
            end
        end
    })

    -- command to add a level to a character
    ix.command.Add("CharAddLevel", {
        description = "Add a level to a character.",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, amount)
            local char = target

            if (char) then
                char:AddLevel(amount)
                client:Notify("You have added " .. amount .. " levels to " .. char:GetName() .. ".")
            end
        end
    })

    -- command to remove a level from a character
    ix.command.Add("CharRemoveLevel", {
        description = "Remove a level from a character.",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, amount)
            local char = target

            if (char) then
                char:RemoveLevel(amount)
                client:Notify("You have removed " .. amount .. " levels from " .. char:GetName() .. ".")
            end
        end
    })
end