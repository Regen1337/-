ITEM.name = "Base Blueprint"
ITEM.desc = "A blueprint that can be used to learn how to craft another item if you have the required skills."
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.category = "Blueprints"
ITEM.width = 1
ITEM.height = 1

ITEM.bp_required_attributes = {}
ITEM.bp_required_factions = {}
ITEM.bp_required_classes = {}

ITEM.bp_learn_to_craft = {}

--[==[
    Eg: ITEM.bp_required_attributes = {
        ["stm"] = 1,
        ["medical"] = 2
    }

    This means that the player needs to have at least 1 point in gunsmithing and 2 points in crafting to be able to use this item.

    Eg: ITEM.bp_required_factions = {
        ["citizen"] = true
    }

    This means that the player needs to be in the FACTION_INDEX faction to be able to use this item.

    Eg: ITEM.bp_required_classes = {
        ["citizen"] = {
            ["rebel"] = true
        }
    }

    Eg: ITEM.bp_learn_to_craft = {
        ["bandage"] = true
    }

]==]

do
    function ITEM:BP_GetRequiredAttributes()
        local attributes = self:GetData("bp_required_attributes", self.bp_required_attributes) 
        return attributes, table.Count(attributes )
    end

    function ITEM:BP_GetRequiredFactions()
        local factions = self:GetData("bp_required_factions", self.bp_required_factions) 
        return factions, table.Count(factions)
    end

    function ITEM:BP_GetRequiredClasses()
        local classes = self:GetData("bp_required_classes", self.bp_required_classes) 
        return classes, table.Count(classes)
    end

    function ITEM:BP_GetLearnToCraft()
        local learn_to_craft = self:GetData("bp_learn_to_craft", self.bp_learn_to_craft) 
        return learn_to_craft, table.Count(learn_to_craft)
    end

    function ITEM:BP_SetRequiredAttributes(attributes)
        self:SetData("bp_required_attributes", attributes)
    end

    function ITEM:BP_SetRequiredFactions(factions)
        self:SetData("bp_required_factions", factions)
    end

    function ITEM:BP_SetRequiredClasses(classes)
        self:SetData("bp_required_classes", classes)
    end

    function ITEM:BP_SetLearnToCraft(learn_to_craft)
        self:SetData("bp_learn_to_craft", learn_to_craft)
    end

    function ITEM:BP_AddRequiredAttribute(attribute, level)
        local attributes = self:GetRequiredAttributes()
        attributes[attribute] = level
        self:BP_SetRequiredAttributes(attributes)
    end

    function ITEM:BP_AddRequiredFaction(faction)
        local factions = self:BP_GetRequiredFactions()
        factions[faction] = true
        self:BP_SetRequiredFactions(factions)
    end

    function ITEM:BP_AddRequiredClass(faction, class)
        local classes = self:BP_GetRequiredClasses()
        classes[faction] = classes[faction] or {}
        classes[faction][class] = true
        self:BP_SetRequiredClasses(classes)
    end

    function ITEM:BP_AddLearnToCraft(item_class)
        local learn_to_craft = self:BP_GetLearnToCraft()
        learn_to_craft[item_class] = true
        self:BP_SetLearnToCraft(learn_to_craft)
    end

    function ITEM:BP_RemoveRequiredAttribute(attribute)
        local attributes = self:BP_GetRequiredAttributes()
        attributes[attribute] = nil
        self:BP_SetRequiredAttributes(attributes)
    end

    function ITEM:BP_RemoveRequiredFaction(faction)
        local factions = self:BP_GetRequiredFactions()
        factions[faction] = nil
        self:BP_SetRequiredFactions(factions)
    end

    function ITEM:BP_RemoveRequiredClass(faction, class)
        local classes = self:BP_GetRequiredClasses()
        classes[faction] = classes[faction] or {}
        classes[faction][class] = nil
        self:BP_SetRequiredClasses(classes)
    end

    function ITEM:BP_RemoveLearnToCraft(item_class)
        local learn_to_craft = self:BP_GetLearnToCraft()
        learn_to_craft[item_class] = nil
        self:BP_SetLearnToCraft(learn_to_craft)
    end
end

ITEM.functions.Learn = {
	OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local char = client:GetCharacter()
        if not char then return false end

        local can, err = char:BP_UseBlueprint(item)

        if !can then ix.util.Notify(err, client) return false end
	end,
    OnCanRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local char = client:GetCharacter()
        if not char then return false end

        local can, err = char:BP_CanUseBlueprint(item)

        if !can then return false end

        return true
    end
}

ITEM.functions.Break = {
    OnRun = function(item)
        local client = item.player

        local char = client:GetCharacter()
        if not char then return false end

        local can, err = char:BREAKDOWN_CanBreak(item.uniqueID)
        if !can then ix.util.Notify(err, client) return false end
        
        char:BREAKDOWN_BreakItem(item)
    end,
    OnCanRun = function(item)
        local client = item.player

        local char = client:GetCharacter()
        if not char then return false end

        local can, err = char:BREAKDOWN_CanBreak(item.uniqueID)
        if !can then return false end

        return true
    end
}