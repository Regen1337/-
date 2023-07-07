-- base consumeable item
-- can be used to heal or to craft or to damage
ITEM.name = "Base Consumable"
ITEM.description = "A consumable item."
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.weight = 1

--[[
ITEM.factions = {FACTION_POLICE} -- Only a certain faction can buy this.
ITEM.classes = {FACTION_POLICE_CHIEF} -- Only a certain class can buy this.
ITEM.flag = "z" -- Only a character having a certain flag can buy this.
ITEM.noBusiness = true
ITEM.price = 5

]]

ITEM.functions.Drink = {
	OnRun = function(item)
		-- IMPORTANT: Make sure you use "item" instead of "ITEM" here - these two are entirely different things!
		local client = item.player

		client:SetHealth(math.min(client:Health() + 10, client:GetMaxHealth()))
		-- Returning true will cause the item to be removed from the character's inventory.
		return true
	end
}