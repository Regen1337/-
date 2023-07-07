local PLUGIN = PLUGIN

    --[==[     Example blueprint item
        Can be applied to blueprints only:
        only mandatory fields are: ITEM.bp_learn_to_craft

        Eg: ITEM.bp_required_attributes = {
            ["stm"] = 1,
            ["medical"] = 2
        }

        Eg: ITEM.bp_required_factions = {
            ["citizen"] = true
        }

        Eg: ITEM.bp_required_classes = {
            ["citizen"] = {
                ["rebel"] = true
            }
        }

        Eg: ITEM.bp_learn_to_craft = {
            ["bandage"] = true
        }

    ]==]

    --[==[     Example craftable item
        Can be applied to any item
        only mandatory fields are: ITEM.craft_given_items

        ITEM.name = "Example Craftable"
        ITEM.description = "A example item for crafting.
        ITEM.category = "Example"
        ITEM.model = "Whatever model you want"
        ITEM.width = 1
        ITEM.height = 1

        ITEM.craft_delay_time = 5 -- time in seconds to craft the item

        -- requires the character to have the listed attributes
        ITEM.craft_required_attributes = {
            ["stm"] = 1, 
            ["medical"] = 2 -- unique id of the attribute, and the amount required
        }

        -- requires the character to be in the listed faction
        ITEM.craft_required_factions = {
            ["citizen"] = true -- unique id of the faction
        }

        -- requires the character to be in the listed faction, and the listed class
        ITEM.craft_required_classes = {
            ["citizen"] = { -- unique id of the faction
                ["rebel"] = true -- unique id of the class
            }
        }

        -- requires all of the listed blueprints to be learned, to be able to craft the item
        ITEM.craft_required_blueprints = {
            ["bandage"] = true  -- unique id of the learned item
        }

        -- requires all of the listed items to be in the players inventory, to be able to craft the item
        ITEM.craft_required_items = {
            ["bandage"] = {
                amount = 1, -- amount of the item required
                remove_amount = 1 -- amount of the item to remove from the players inventory, caped at the first amount
            } 
        }

        -- if you're near any listed it will work
        ITEM.craft_required_entities = {
            ["ix_workbench"] = true -- unique id of the entity
        }

        ITEM.craft_given_items = {
            ["bandage"] = {
                amount = 1 -- amount of the item to give to the player
            }
        }
    ]==]

    --[==[     Example of a breakable item:

        Can be applied to any item:
        only mandatory fields are: ITEM.breakdown_given_items

        ITEM.breakdown_delay_time = 5 -- time in seconds to break down the item

        -- requires the character to have the listed attributes
        ITEM.breakdown_required_attributes = {
            ["stm"] = 1, 
            ["medical"] = 2 -- unique id of the attribute, and the amount required
        }

        -- requires the character to be in the listed faction
        ITEM.breakdown_required_factions = {
            ["citizen"] = true -- unique id of the faction
        }

        -- requires the character to be in the listed faction, and the listed class
        ITEM.breakdown_required_classes = {
            ["citizen"] = { -- unique id of the faction
                ["rebel"] = true -- unique id of the class
            }
        }

        -- requires all of the listed blueprints to be learned, to be able to break down the item
        ITEM.breakdown_required_blueprints = {
            ["bandage"] = true  -- unique id of the learned item
        }

        -- requires all of the listed items to be in the players inventory, to be able to break down the item
        ITEM.breakdown_required_items = {
            ["bandage"] = {
                amount = 1, -- amount of the item required
                remove_amount = 1 -- amount of the item to remove from the players inventory, caped at the first amount
            } 
        }

        -- if you're near any listed it will work
        ITEM.breakdown_required_entities = {
            ["ix_workbench"] = true -- unique id of the entity
        }

        -- items to give to the player when the item is broken down
        ITEM.breakdown_given_items = {
            ["bandage"] = {
                amount = 1 -- amount of the item to give to the player
            }
        }

        -- add to the item base
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

    ]==]

do -- inventory meta
    local INV = ix.meta.inventory

    do
        function INV:CanItemsFit(items, onlyMain)
            local slots = {}
            local blacklist = {}
        
            for _, item in ipairs(items) do
                local w, h = item.width, item.height
                local x, y
        
                for y2 = 1, self.h - (h - 1) do
                    for x2 = 1, self.w - (w - 1) do
                        if (!blacklist[x2] or !blacklist[x2][y2]) then
                            if (self:CanItemFit(x2, y2, w, h)) then
                                x, y = x2, y2
        
                                break
                            end
                        end
                    end
        
                    if (x and y) then
                        break
                    end
                end
        
                if (!x or !y) then
                    if (onlyMain != true) then
                        local bags = self:GetBags()
        
                        if (#bags > 0) then
                            for _, invID in ipairs(bags) do
                                local bagInv = ix.item.inventories[invID]
        
                                if (bagInv) then
                                    local x, y = bagInv:FindEmptySlot(w, h)
        
                                    if (x and y) then
                                        table.insert(slots, {x = x, y = y, inv = bagInv})
        
                                        break
                                    end
                                end
                            end
                        end
                    end
                else
                    table.insert(slots, {x = x, y = y, inv = self})
        
                    for x2 = 0, w - 1 do
                        for y2 = 0, h - 1 do
                            blacklist[x + x2] = blacklist[x + x2] or {}
                            blacklist[x + x2][y + y2] = true
                        end
                    end
                end
            end
        
            return (#slots == #items) and true or false, "Inventory cannot fit all of these items!"
        end
    end

    ix.meta.inventory = INV
end

do -- character meta
    local CHAR = ix.meta.character

    do -- blueprints character meta
        function CHAR:BP_GetBlueprints()
            local blueprints = self:GetData("blueprints", {{}})[1]
            return blueprints, table.Count(blueprints)
        end

        function CHAR:BP_AddBlueprint(item_id)
            local blueprints = self:BP_GetBlueprints()
            blueprints[item_id] = true

            self:SetData("blueprints", {blueprints})

            local client = self:GetPlayer()
            if (SERVER and client) then
                client:Notify("You learned a blueprint for a " .. ix.item.list[item_id].name .. ".")
            end
        end

        function CHAR:BP_HasBlueprint(item_id)
            local blueprints = self:BP_GetBlueprints()
            return blueprints[item_id] or false
        end

        function CHAR:BP_RemoveBlueprint(item_id)
            local blueprints = self:BP_GetBlueprints()
            blueprints[item_id] = nil

            self:SetData("blueprints", {blueprints})
        end

        function CHAR:BP_ClearBlueprints()
            self:SetData("blueprints", {{}})
        end

        function CHAR:BP_PrintBlueprints()
            local blueprints = self:BP_GetBlueprints()
            local str = "Blueprints: \n"

            for k, v in next, (blueprints) do
                str = str .. k .. "\n"
            end

            print(str)
        end

        function CHAR:BP_HasRequiredAttributes(item)
            local required_attributes, attributes_count = item:BP_GetRequiredAttributes()
            local attributes = self:GetAttributes()

            if (attributes_count == 0) then
                return true
            end

            for k, v in next, (required_attributes) do
                if (attributes[k] < v) then
                    return false
                end
            end

            return true
        end

        function CHAR:BP_HasRequiredFaction(item)
            local required_factions, factions_count = item:BP_GetRequiredFactions()
            local faction = (self:GetFaction() and ix.faction.indices) and ix.faction.indices[self:GetFaction()].uniqueID or false

            if (factions_count == 0) then
                return true
            end

            if (required_factions[faction]) then
                return true
            end

            return false
        end

        function CHAR:BP_HasRequiredClass(item)
            local required_classes, classes_count = item:BP_GetRequiredClasses()


            local faction = self:GetFaction()
            local class = self:GetClass()
            faction = (faction and ix.faction.indices) and ix.faction.indices[faction].uniqueID or false
            class = (class and ix.class.list) and ix.class.list[class].uniqueID or false

            if (classes_count == 0) then
                return true
            end

            if (required_classes[faction] and required_classes[faction][class]) then
                return true
            end

            return false
        end

        function CHAR:BP_HasLearnedBlueprints(item)
            local learn_to_craft, learn_count = item:BP_GetLearnToCraft()

            if (learn_count == 0) then
                return true
            end

            for k, v in next, (learn_to_craft) do
                if (!self:BP_HasBlueprint(k)) then
                    return true
                end
            end

            return false
        end

        -- can use blueprint
        function CHAR:BP_CanUseBlueprint(item)
            print(string.format("%s %s %s %s", self:BP_HasRequiredAttributes(item), self:BP_HasRequiredFaction(item), self:BP_HasRequiredClass(item), self:BP_HasLearnedBlueprints(item)))

            if (!self:BP_HasRequiredAttributes(item)) then
                return false, "You do not have the required attributes to use this blueprint."
            end

            if (!self:BP_HasRequiredFaction(item)) then
                return false,  "You do not have the required faction to use this blueprint."
            end

            if (!self:BP_HasRequiredClass(item)) then
                return false, "You do not have the required class to use this blueprint."
            end

            if (!self:BP_HasLearnedBlueprints(item)) then
                return false, "You have learned all the blueprints that this item teaches."
            end

            return true
        end

        function CHAR:BP_UseBlueprint(item)
            local can, err = self:BP_CanUseBlueprint(item)
            local learn_to_craft = item:BP_GetLearnToCraft()

            if (!can) then
                return false, err
            end

            for k, v in next, (learn_to_craft) do
                if (!self:BP_HasBlueprint(k)) then
                    self:BP_AddBlueprint(k)
                end
            end

            return true
        end
    end

    do -- crafting character meta
        function CHAR:CRAFT_GetNextAllowedCraftTime()
            return self:GetData("nextAllowedCraftTime", 0)
        end

        function CHAR:CRAFT_SetNextAllowedCraftTime(time)
            self:SetData("nextAllowedCraftTime", time)
        end

        function CHAR:CRAFT_GetElapsedTime()
            local next_allowed_time = self:CRAFT_GetNextAllowedCraftTime()

            if (next_allowed_time > 0) then
                return SysTime() - next_allowed_time
            end

            return 0
        end

        function CHAR:CRAFT_IncreaseNextAllowedCraftTime(item)
            local craft_time = item:CRAFT_GetDelayTime()

            self:CRAFT_SetNextAllowedCraftTime(SysTime() + craft_time + 1)
        end

        function CHAR:CRAFT_IsTimeOK()
            local next_allowed_time = self:CRAFT_GetNextAllowedCraftTime()

            if (next_allowed_time > 0) then
                return SysTime() >= next_allowed_time and true or false, string.format("You must wait %s seconds before crafting again.", math.abs(math.Round(self:CRAFT_GetElapsedTime())))
            end

            return true
        end

        function CHAR:CRAFT_HasRequiredAttributes(item)
            local required_attributes, attributes_count = item:CRAFT_GetRequiredAttributes()
            local attributes = self:GetAttributes()

            if (attributes_count == 0) then
                return true
            end

            for k, v in next, (required_attributes) do
                if (attributes[k] < v) then
                    return false, "You do not have the required attributes to craft this item."
                end
            end

            return true
        end

        function CHAR:CRAFT_CanShow(item_id)
            local item = ix.item.list[item_id]
            if !(item_id and item) then
                return false, "This item doesn't fucking exist I will kill you"
            end

            local client = self:GetPlayer()
            if !(client and IsValid(client) and client:Alive()) then return false, "Not A Valid Player" end

            local can, err = item:CRAFT_HasGivenItems()
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredFaction(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredClass(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredBlueprints(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_IsNearbyEntities(item)
            if (!can) then return false, err end

            return true
        end

        function CHAR:CRAFT_ShowRequirements(item_id)
            local item = ix.item.list[item_id]
            if !(item_id and item) then return end

            local requirements = {}

            local name, can, msg = "Items: ", self:CRAFT_HasRequiredItems(item), item:CRAFT_GetRequiredItemsString()
            -- Check the length of the msg, if it's 0 then we don't want to add it to the table
            if (string.len(msg) > 0) then
                table.insert(requirements, {name, can, msg})
            end

            name, can, msg = "Attributes: ",  self:CRAFT_HasRequiredAttributes(item), item:CRAFT_GetRequiredAttributesString()
            if (string.len(msg) > 0) then
                table.insert(requirements, {name, can, msg})
            end

            name, can, msg = "Blueprints: ", self:CRAFT_HasRequiredBlueprints(item), item:CRAFT_GetRequiredBlueprintsString()
            if (string.len(msg) > 0) then
                table.insert(requirements, {name, can, msg})
            end

            name, can, msg = "Nearby Entities: ", self:CRAFT_IsNearbyEntities(item), item:CRAFT_GetRequiredEntitiesString()
            if (string.len(msg) > 0) then
                table.insert(requirements, {name, can, msg})
            end

            name, can, msg = "Weight: ", self:CRAFT_HasRequiredWeight(item), item:CRAFT_GetWeightString()
            if (string.len(msg) > 0) then
                table.insert(requirements, {name, can, msg})
            end
            
            name, can, msg = "Space: ", self:CRAFT_HasSpaceForItems(item), self:CRAFT_HasSpaceForItems(item) and "You have enough space." or "You do not have enough space."
            if (string.len(msg) > 0) then
                table.insert(requirements, {name, can, msg})
            end

            return requirements
        end

        function CHAR:CRAFT_CanCraft(item_id)
            if !(item_id and ix.item.list[item_id]) then
                return false, "This item doesn't fucking exist I will kill you"
            end

            local item = ix.item.list[item_id]
            local client = self:GetPlayer()

            if !(client and IsValid(client) and client:Alive()) then return false, "Not A Valid Player" end            

            local can, err = item:CRAFT_HasGivenItems()
            if (!can) then return false, err end

            can, err = self:CRAFT_IsTimeOK()
            if (!can) then return false, err end
            
            can, err = self:CRAFT_HasRequiredAttributes(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredFaction(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredClass(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredItems(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredBlueprints(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_HasRequiredWeight(item)
            if (!can) then return false, err end
            
            can, err = self:CRAFT_HasSpaceForItems(item)
            if (!can) then return false, err end

            can, err = self:CRAFT_IsNearbyEntities(item)
            if (!can) then return false, err end

            return true
        end

        function CHAR:CRAFT_HasRequiredFaction(item)
            local required_factions, factions_count = item:CRAFT_GetRequiredFactions()
            local faction = (self:GetFaction() and ix.faction.indices) and ix.faction.indices[self:GetFaction()].uniqueID or false

            if (factions_count == 0) then
                return true
            end

            if (required_factions[faction]) then
                return true
            end

            return false, "You do not have the required faction to craft this item."
        end

        function CHAR:CRAFT_HasRequiredClass(item)
            local required_classes, classes_count = item:CRAFT_GetRequiredClasses()

            local faction = self:GetFaction()
            local class = self:GetClass()
            faction = (faction and ix.faction.indices) and ix.faction.indices[faction].uniqueID or false
            class = (class and ix.class.list) and ix.class.list[class].uniqueID or false

            if (classes_count == 0) then
                return true
            end

            if (required_classes[faction] and required_classes[faction][class]) then
                return true
            end

            return false, "You do not have the required class to craft this item."
        end

        function CHAR:CRAFT_HasRequiredItems(item)
            local required_items, items_count = item:CRAFT_GetRequiredItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            for k, v in next, (required_items) do
                local amount = inventory:GetItemCount(k)
                if (amount < v.amount) then return false, "You do not have the required items to craft this item." end
            end

            return true
        end

        function CHAR:CRAFT_HasRequiredBlueprints(item)
            local required_blueprints, blueprints_count = item:CRAFT_GetRequiredBlueprints()

            if (blueprints_count == 0) then
                return true
            end

            for k, v in next, (required_blueprints or {}) do
                if (!self:BP_HasBlueprint(k)) then
                    return false, "You do not have the required blueprints to craft this item."
                end
            end

            return true
        end

        function CHAR:CRAFT_HasSpaceForItems(items)
            local given_items, items_count = items:CRAFT_GetGivenItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            local real_item_cache = {}
            local real_items_count = 0

            for k, v in next, (given_items) do
                local item = ix.item.list[k]
                if (item) then
                    for i = 1, v.amount do
                        real_items_count = real_items_count + 1
                        real_item_cache[real_items_count] = item
                    end
                end
            end

            local can, err = inventory:CanItemsFit(real_item_cache)
            return can, err
        end        

        function CHAR:CRAFT_HasRequiredWeight(item)
            local given_items, items_count = item:CRAFT_GetGivenItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            local real_item_cache = {}
            local real_items_count = 0

            for k, v in next, (given_items) do
                local item = ix.item.list[k]
                if (item) then
                    for i = 1, v.amount do
                        real_items_count = real_items_count + 1
                        real_item_cache[real_items_count] = item
                    end
                end
            end

            local weight = self:GetWeight()
            local max_weight = self:GetMaxWeight()

            for k, v in next, (real_item_cache) do
                weight = weight + v:GetWeight()
            end

            if (weight > max_weight) then
                return false, "You do not have enough weight to craft this item."
            end

            return true
        end

        function CHAR:CRAFT_IsNearbyEntities(item)
            local required_entities, entities_count = item:CRAFT_GetRequiredEntities()
            local owner = self:GetPlayer()
            local found

            if !(owner and IsValid(owner) and owner:Alive()) then
                return false, "You do not have a valid owner or your owner is not alive."
            end

            if (entities_count == 0) then
                return true
            end

            local entities = ents.FindInSphere(owner:GetPos(), 100)
            for k, v in next, (entities) do
                if (required_entities[v:GetClass()]) then
                    found = true
                    break
                end
            end

            return found and true or false, string.format("You need to be near any of the following entities: %s.", item:CRAFT_GetRequiredEntitiesString())
        end

        function CHAR:CRAFT_RemoveRequiredItems(item)
            local required_items, items_count = item:CRAFT_GetRequiredItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            for k, v in next, (required_items or {}) do
                local remove_amount = math.Clamp(v.remove_amount, 0, v.amount)
                if remove_amount > 0 then
                    for i = 1, remove_amount do
                        local item = inventory:HasItem(k)
                        if (item) then
                            item:Remove()
                        end
                    end
                end 
            end

            return true
        end

        function CHAR:CRAFT_GiveItems(item)
            local given_items, items_count = item:CRAFT_GetGivenItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            local real_item_cache = {}
            local real_items_count = 0

            local items = PLUGIN.ConvertUniqueIDsToItems(given_items)

            for k, v in next, (given_items) do
                local item = ix.item.list[k]
                if (item) then
                    for i = 1, v.amount do
                        real_items_count = real_items_count + 1
                        real_item_cache[real_items_count] = item.uniqueID
                    end
                end
            end

            for k, v in next, (real_item_cache) do
                local item = inventory:Add(v)

                if (!item) then
                    local _, _, bag = inventory:FindEmptySlot(v.width, v.height)

                    if (bag) then
                        item = bag:Add(v)
                    end
                end
            end

            return true
        end

        function CHAR:CRAFT_CraftItem(item)
            local can, err = self:CRAFT_CanCraft(item.uniqueID)
            if (!can) then return can, err end            
            
            self:CRAFT_RemoveRequiredItems(item)
            self:CRAFT_GiveItems(item)
            self:CRAFT_IncreaseNextAllowedCraftTime(item)

            local client = self:GetPlayer()
            if (SERVER and client) then
                client:Notify("You have successfully crafted a " .. item.name .. ".")
            end

            return true
        end
    end

    do -- breaking down character meta

        function CHAR:BREAKDOWN_GetNextAllowedBreakdownTime()
            return self:GetData("nextAllowedBreakdownTime", 0)
        end

        function CHAR:BREAKDOWN_SetNextAllowedBreakdownTime(time)
            self:SetData("nextAllowedBreakdownTime", time)
        end 

        function CHAR:BREAKDOWN_GetElapsedTime()
            local nextAllowedBreakdownTime = self:BREAKDOWN_GetNextAllowedBreakdownTime()

            if (nextAllowedBreakdownTime > 0) then
                return nextAllowedBreakdownTime - SysTime()
            end

            return 0
        end

        function CHAR:BREAKDOWN_IsTimeOK()
            local nextAllowedBreakdownTime = self:BREAKDOWN_GetNextAllowedBreakdownTime()

            if (nextAllowedBreakdownTime > 0) then
                return SysTime() >= nextAllowedBreakdownTime and true or false, string.format("You must wait %s seconds before crafting again.", math.abs(math.Round(self:BREAKDOWN_GetElapsedTime())))
            end

            return true
        end

        function CHAR:BREAKDOWN_IncreaseNextAllowedBreakdownTime(item)
            local cooldown = item:BREAKDOWN_GetDelayTime()

            self:BREAKDOWN_SetNextAllowedBreakdownTime(SysTime() + cooldown)
        end

        function CHAR:BREAKDOWN_HasRequiredAttributes(item)
            local required_attributes, attributes_count = item:BREAKDOWN_GetRequiredAttributes()
            local attributes = self:GetAttributes()

            if (attributes_count == 0) then
                return true
            end

            for k, v in next, (required_attributes) do
                local attribute = attributes[k]
                if (attribute and attribute < v) then
                    return false, string.format("You do not have the required %s attribute to break down this item.", ix.attributes.list[k].name)
                end
            end

            return true
        end

        function CHAR:BREAKDOWN_HasRequiredFaction(item)
            local required_factions, factions_count = item:BREAKDOWN_GetRequiredFactions()
            local faction = (self:GetFaction() and ix.faction.indices[self:GetFaction()]) and ix.faction.indices[self:GetFaction()].uniqueID or false

            if (factions_count == 0) then
                return true
            end

            if (required_factions[faction]) then
                return true
            end

            return false, string.format("You do not have the required faction to break down this item.")
        end

        function CHAR:BREAKDOWN_HasRequiredClass(item)
            local required_classes, classes_count = item:BREAKDOWN_GetRequiredClasses()
            
            local faction = self:GetFaction()
            local class = self:GetClass()
            faction = (faction and ix.faction.indices) and ix.faction.indices[faction].uniqueID or false
            class = (class and ix.class.list) and ix.class.list[class].uniqueID or false

            if (classes_count == 0) then
                return true
            end

            if (required_classes[faction] and required_classes[faction][class]) then
                return true
            end

            return false, string.format("You do not have the required class to break down this item.")
        end

        function CHAR:BREAKDOWN_HasRequiredBlueprints(item)
            local required_blueprints, blueprints_count = item:BREAKDOWN_GetRequiredBlueprints()

            if (blueprints_count == 0) then
                return true
            end

            for k, v in next, (required_blueprints or {}) do
                if (!self:BP_HasBlueprint(k)) then
                    return false, "You do not have the required blueprints to craft this item."
                end
            end

            return true
        end

        function CHAR:BREAKDOWN_HasSpaceForItems(items)
            local given_items, items_count = items:BREAKDOWN_GetGivenItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            local real_item_cache = {}
            local real_items_count = 0

            for k, v in next, (given_items) do
                local item = ix.item.list[k]
                if (item) then
                    for i = 1, v.amount do
                        real_items_count = real_items_count + 1
                        real_item_cache[real_items_count] = item
                    end
                end
            end

            local can, err = inventory:CanItemsFit(real_item_cache)
            return can, err
        end

        function CHAR:BREAKDOWN_HasRequiredWeight(item)
            local given_items, items_count = item:BREAKDOWN_GetGivenItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            local real_item_cache = {}
            local real_items_count = 0

            for k, v in next, (given_items) do
                local item = ix.item.list[k]
                if (item) then
                    for i = 1, v.amount do
                        real_items_count = real_items_count + 1
                        real_item_cache[real_items_count] = item
                    end
                end
            end

            local weight = self:GetWeight()
            local max_weight = self:GetMaxWeight()

            for k, v in next, (real_item_cache) do
                weight = weight + v:GetWeight()
            end

            if (weight > max_weight) then
                return false, "You do not have enough weight to craft this item."
            end

            return true
        end

        function CHAR:BREAKDOWN_HasRequiredItems(item)
            local required_items, items_count = item:BREAKDOWN_GetRequiredItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            for k, v in next, (required_items or {}) do
                local item = inventory:HasItem(k)
                if (!item) then
                    return false, string.format("You do not have the required item to break down this item.")
                end
            end

            return true
        end

        function CHAR:BREAKDOWN_IsNearbyEntities(item)
            local nearby_entities, entities_count = item:BREAKDOWN_GetRequiredEntities()
            local client = self:GetPlayer()
            local found

            if (entities_count == 0) then
                return true
            end

            local entities = ents.FindInSphere(client:GetPos(), 100)
            for k, v in next, (entities or {}) do
                if (nearby_entities[v:GetClass()]) then
                    found = true
                    break
                end
            end

            return found and true or false,  string.format("You need to be near any of the following entities: %s.", item:BREAKDOWN_GetRequiredEntitiesString())
        end

        function CHAR:BREAKDOWN_CanBreak(item_id)
            if !(item_id and ix.item.list[item_id]) then
                return false, "This item doesn't fucking exist I will kill you"
            end

            local item = ix.item.list[item_id]
            local client = self:GetPlayer()

            if !(client and IsValid(client) and client:Alive()) then return false, "Not A Valid Player" end

            local can, err = item:BREAKDOWN_HasGivenItems()
            if (!can) then return false, err end
            
            can, err = self:BREAKDOWN_IsTimeOK()
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_HasRequiredAttributes(item)
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_HasRequiredFaction(item)
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_HasRequiredClass(item)
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_HasRequiredItems(item)
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_HasRequiredBlueprints(item)
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_HasRequiredWeight(item)
            if (!can) then return false, err end
            
            can, err = self:BREAKDOWN_HasSpaceForItems(item)
            if (!can) then return false, err end

            can, err = self:BREAKDOWN_IsNearbyEntities(item)
            if (!can) then return false, err end

            return true
        end

        function CHAR:BREAKDOWN_RemoveRequiredItems(item)
            local required_items, items_count = item:BREAKDOWN_GetRequiredItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            for k, v in next, (required_items or {}) do
                local remove_amount = math.Clamp(v.remove_amount, 0, v.amount)
                if remove_amount > 0 then
                    for i = 1, remove_amount do
                        local item = inventory:HasItem(k)
                        if (item) then
                            item:Remove()
                        end
                    end
                end 
            end

            return true
        end

        function CHAR:BREAKDOWN_GiveItems(item)
            local given_items, items_count = item:BREAKDOWN_GetGivenItems()
            local inventory = self:GetInventory()

            if (items_count == 0) then
                return true
            end

            local real_item_cache = {}
            local real_items_count = 0

            local items = PLUGIN.ConvertUniqueIDsToItems(given_items)

            for k, v in next, (given_items) do
                local item = ix.item.list[k]
                if (item) then
                    for i = 1, v.amount do
                        real_items_count = real_items_count + 1
                        real_item_cache[real_items_count] = item.uniqueID
                    end
                end
            end

            for k, v in next, (real_item_cache) do
                local item = inventory:Add(v)

                if (!item) then
                    local _, _, bag = inventory:FindEmptySlot(v.width, v.height)

                    if (bag) then
                        item = bag:Add(v)
                    end
                end
            end

            return true
        end

        function CHAR:BREAKDOWN_BreakItem(item)
            local can, err = self:BREAKDOWN_CanBreak(item.uniqueID)
            if (!can) then self:GetPlayer():Notify(err) return false end

            self:BREAKDOWN_RemoveRequiredItems(item)
            self:BREAKDOWN_GiveItems(item)
            self:BREAKDOWN_IncreaseNextAllowedBreakdownTime(item)

            return true
        end

    end

    do -- mining character meta
        function CHAR:MINING_HasRequiredAttributes(item_id)
            local item = ix.item.list[item_id]
            local required_attributes, attributes_count = item:MINING_GetRequiredAttributes()

            if (attributes_count == 0) then
                return true
            end

            for k, v in next, (required_attributes or {}) do
                local attribute = self:GetAttribute(k, 0)
                if (attribute < v) then
                    return false, string.format("You do not have the required %s attribute to mine this item.", ix.attributes.list[k].name)
                end
            end

            return true
        end
    end
    
    ix.meta.character = CHAR
end

do -- item meta
    local ITEM = ix.meta.item

    do -- item crafting meta
        function ITEM:CRAFT_GetDelayTime()
            return self:GetData("craft_time", self.craft_time or 0)
        end

        function ITEM:CRAFT_GetRequiredAttributes()
            local attributes = self:GetData("craft_required_attributes", self.craft_required_attributes or {})

            return attributes, table.Count(attributes)
        end

        function ITEM:CRAFT_GetRequiredFactions()
            local factions = self:GetData("craft_required_factions", self.craft_required_factions or {})

            return factions, table.Count(factions)
        end

        function ITEM:CRAFT_GetRequiredClasses()
            local classes = self:GetData("craft_required_classes", self.craft_required_classes or {})

            return classes, table.Count(classes)
        end

        -- required items to craft, will be a table of items, if it should be removed when crafted and the amount required to craft
        function ITEM:CRAFT_GetRequiredItems()
            local items = self:GetData("craft_required_items", self.craft_required_items or {})

            return items, table.Count(items)
        end

        function ITEM:CRAFT_GetGivenItems()
            local items = self:GetData("craft_given_items", self.craft_given_items or {})

            return items, table.Count(items)
        end 

        function ITEM:CRAFT_GetRequiredBlueprints()
            local blueprints = self:GetData("craft_required_blueprints", self.craft_required_blueprints or {})

            return blueprints, table.Count(blueprints)
        end

        function ITEM:CRAFT_GetRequiredEntities()
            local entities = self:GetData("craft_required_entities", self.craft_required_entities or {})

            return entities, table.Count(entities)
        end

        function ITEM:CRAFT_SetDelayTime(time)
            self:SetData("craft_delay_time", time)
        end

        function ITEM:CRAFT_SetRequiredAttributes(attributes)
            self:SetData("craft_required_attributes", attributes)
        end

        function ITEM:CRAFT_SetRequiredFactions(factions)
            self:SetData("craft_required_factions", factions)
        end

        function ITEM:CRAFT_SetRequiredClasses(classes)
            self:SetData("craft_required_classes", classes)
        end

        function ITEM:CRAFT_SetRequiredItems(items)
            self:SetData("craft_required_items", items)
        end

        function ITEM:CRAFT_SetGivenItems(items)
            self:SetData("craft_given_items", items)
        end

        function ITEM:CRAFT_SetRequiredBlueprints(blueprints)
            self:SetData("craft_required_blueprints", blueprints)
        end

        function ITEM:CRAFT_SetRequiredEntities(entities)
            self:SetData("craft_required_entities", entities)
        end

        function ITEM:CRAFT_AddDelayTime(time)
            self:CRAFT_SetDelayTime(self:CRAFT_GetDelayTime() + time)
        end

        function ITEM:CRAFT_AddRequiredAttribute(attribute, amount)
            local attributes = self:CRAFT_GetRequiredAttributes()
            attributes[attribute] = amount

            self:CRAFT_SetRequiredAttributes(attributes)
        end

        function ITEM:CRAFT_AddRequiredFaction(faction, amount)
            local factions = self:CRAFT_GetRequiredFactions()
            factions[faction] = true

            self:CRAFT_SetRequiredFactions(factions)
        end

        function ITEM:CRAFT_AddRequiredClass(faction, class, amount)
            local classes = self:CRAFT_GetRequiredClasses()
            classes[faction] = classes[faction] or {}
            classes[faction][class] = true

            self:CRAFT_SetRequiredClasses(classes)
        end

        function ITEM:CRAFT_AddRequiredItem(item, amount, remove_amount)
            local items = self:CRAFT_GetRequiredItems()
            items[item] = {amount = amount, remove_amount = remove_amount}

            self:CRAFT_SetRequiredItems(items)
        end

        function ITEM:CRAFT_AddGivenItem(item, amount)
            local items = self:CRAFT_GetGivenItems()
            items[item] = {amount = amount}

            self:CRAFT_SetGivenItems(items)
        end

        function ITEM:CRAFT_AddRequiredBlueprint(item, amount)
            local blueprints = self:CRAFT_GetRequiredBlueprints()
            blueprints[item] = true

            self:CRAFT_SetRequiredBlueprints(blueprints)
        end

        -- entity = entities class name
        function ITEM:CRAFT_AddRequiredEntity(entity, amount)
            local entities = self:CRAFT_GetRequiredEntities()
            entities[entity] = true

            self:CRAFT_SetRequiredEntities(entities)
        end

        function ITEM:CRAFT_RemoveDelayTime(time)
            self:CRAFT_SetDelayTime(math.max(self:CRAFT_GetDelayTime() - time, 0))
        end

        function ITEM:CRAFT_RemoveRequiredAttribute(attribute)
            local attributes = self:CRAFT_GetRequiredAttributes()
            attributes[attribute] = nil

            self:CRAFT_SetRequiredAttributes(attributes)
        end

        function ITEM:CRAFT_RemoveRequiredFaction(faction)
            local factions = self:CRAFT_GetRequiredFactions()
            factions[faction] = nil

            self:CRAFT_SetRequiredFactions(factions)
        end

        function ITEM:CRAFT_RemoveRequiredClass(faction, class)
            local classes = self:CRAFT_GetRequiredClasses()
            classes[faction] = classes[faction] or {}
            classes[faction][class] = nil

            self:CRAFT_SetRequiredClasses(classes)
        end

        function ITEM:CRAFT_RemoveRequiredItem(item)
            local items = self:CRAFT_GetRequiredItems()
            items[item] = nil

            self:CRAFT_SetRequiredItems(items)
        end

        function ITEM:CRAFT_RemoveGivenItem(item)
            local items = self:CRAFT_GetGivenItems()
            items[item] = nil

            self:CRAFT_SetGivenItems(items)
        end

        function ITEM:CRAFT_RemoveRequiredBlueprint(item)
            local blueprints = self:CRAFT_GetRequiredBlueprints()
            blueprints[item] = nil

            self:CRAFT_SetRequiredBlueprints(blueprints)
        end

        function ITEM:CRAFT_RemoveRequiredEntity(entity)
            local entities = self:CRAFT_GetRequiredEntities()
            entities[entity] = nil

            self:CRAFT_SetRequiredEntities(entities)
        end

        function ITEM:CRAFT_HasGivenItems()
            local items = self:GetData("craft_given_items", self.craft_given_items or {})

            return table.Count(items) > 0 and true or false, "This item is not craftable."
        end        

        function ITEM:CRAFT_GetRequiredEntitiesString()
            local entities = self:CRAFT_GetRequiredEntities()
            local entity_names = {}

            for entity, _ in next, (entities) do
                local entity_name = PLUGIN.ConvertEntityClassToName(entity)

                if (entity_name) then
                    table.insert(entity_names, entity_name)
                end
            end

            return table.concat(entity_names, ", ")
        end

        function ITEM:CRAFT_GetRequiredBlueprintsString()
            local blueprints = self:CRAFT_GetRequiredBlueprints()
            local blueprint_names = {}

            for item, _ in next, (blueprints) do
                local item_table = ix.item.list[item]

                if (item_table) then
                    table.insert(blueprint_names, item_table.name)
                end
            end

            return table.concat(blueprint_names, ", ")
        end

        function ITEM:CRAFT_GetRequiredItemsString()
            local items = self:CRAFT_GetRequiredItems()
            local item_names = {}

            for item, data in next, (items) do
                local item_table = ix.item.list[item]

                if (item_table) then
                    table.insert(item_names, item_table.name .. " (" .. data.amount .. ")")
                end
            end

            return table.concat(item_names, ", ")
        end

        function ITEM:CRAFT_GetGivenItemsString()
            local items = self:CRAFT_GetGivenItems()
            local item_names = {}

            for item, data in next, (items) do
                local item_table = ix.item.list[item]

                if (item_table) then
                    table.insert(item_names, item_table.name .. " (" .. data.amount .. ")")
                end
            end

            return table.concat(item_names, ", ")
        end

        function ITEM:CRAFT_GetRequiredAttributesString()
            local attributes = self:CRAFT_GetRequiredAttributes()
            local attribute_names = {}

            for attribute, amount in next, (attributes) do
                local attribute_table = ix.attributes.list[attribute]

                if (attribute_table) then
                    table.insert(attribute_names, attribute_table.name .. " (" .. amount .. ")")
                end
            end

            return table.concat(attribute_names, ", ")
        end

        -- weight string
        function ITEM:CRAFT_GetWeightString()
            local weight = self:GetWeight()

            return weight > 0 and weight .. "kg" or "None"
        end

    end

    do -- item breaking down meta
        function ITEM:BREAKDOWN_GetDelayTime()
            return self:GetData("breakdown_delay_time", self.breakdown_delay_time or 0)
        end

        function ITEM:BREAKDOWN_GetRequiredAttributes()
            local attributes = self:GetData("breakdown_required_attributes", self.breakdown_required_attributes or {})

            return attributes, table.Count(attributes)
        end

        function ITEM:BREAKDOWN_GetRequiredFactions()
            local factions = self:GetData("breakdown_required_factions", self.breakdown_required_factions or {})

            return factions, table.Count(factions)
        end

        function ITEM:BREAKDOWN_GetRequiredClasses()
            local classes = self:GetData("breakdown_required_classes", self.breakdown_required_classes or {})

            return classes, table.Count(classes)
        end

        function ITEM:BREAKDOWN_GetRequiredItems()
            local items = self:GetData("breakdown_required_items", self.breakdown_required_items or {})

            return items, table.Count(items)
        end

        function ITEM:BREAKDOWN_GetGivenItems()
            local items = self:GetData("breakdown_given_items", self.breakdown_given_items or {})

            return items, table.Count(items)
        end

        function ITEM:BREAKDOWN_GetRequiredBlueprints()
            local blueprints = self:GetData("breakdown_required_blueprints", self.breakdown_required_blueprints or {})

            return blueprints, table.Count(blueprints)
        end

        function ITEM:BREAKDOWN_GetRequiredBlueprintsString()
            local blueprints = self:BREAKDOWN_GetRequiredBlueprints()
            local blueprint_names = {}

            for blueprint, _ in pairs(blueprints) do
                local blueprint_name = PLUGIN.ConvertItemClassToName(blueprint)

                if (blueprint_name) then
                    table.insert(blueprint_names, blueprint_name)
                end
            end

            return table.concat(blueprint_names, ", ")
        end

        function ITEM:BREAKDOWN_GetRequiredEntities()
            local entities = self:GetData("breakdown_required_entities", self.breakdown_required_entities or {})

            return entities, table.Count(entities)
        end

        function ITEM:BREAKDOWN_GetRequiredEntitiesString()
            local entities = self:BREAKDOWN_GetRequiredEntities()
            local entity_names = {}

            for entity, _ in pairs(entities) do
                local entity_name = PLUGIN.ConvertEntityClassToName(entity)

                if (entity_name) then
                    table.insert(entity_names, entity_name)
                end
            end

            return table.concat(entity_names, ", ")
        end

        function ITEM:BREAKDOWN_SetDelayTime(time)
            self:SetData("breakdown_delay_time", time)
        end

        function ITEM:BREAKDOWN_SetRequiredAttributes(attributes)
            self:SetData("breakdown_required_attributes", attributes)
        end

        function ITEM:BREAKDOWN_SetRequiredFactions(factions)
            self:SetData("breakdown_required_factions", factions)
        end

        function ITEM:BREAKDOWN_SetRequiredClasses(classes)
            self:SetData("breakdown_required_classes", classes)
        end

        function ITEM:BREAKDOWN_SetRequiredItems(items)
            self:SetData("breakdown_required_items", items)
        end

        function ITEM:BREAKDOWN_SetGivenItems(items)
            self:SetData("breakdown_given_items", items)
        end

        function ITEM:BREAKDOWN_SetRequiredBlueprints(blueprints)
            self:SetData("breakdown_required_blueprints", blueprints)
        end

        function ITEM:BREAKDOWN_SetRequiredEntities(entities)
            self:SetData("breakdown_required_entities", entities)
        end

        function ITEM:BREAKDOWN_AddDelayTime(time)
            self:BREAKDOWN_SetDelayTime(self:BREAKDOWN_GetDelayTime() + time)
        end

        function ITEM:BREAKDOWN_AddRequiredAttribute(attribute, amount)
            local attributes = self:BREAKDOWN_GetRequiredAttributes()
            attributes[attribute] = amount

            self:BREAKDOWN_SetRequiredAttributes(attributes)
        end

        function ITEM:BREAKDOWN_AddRequiredFaction(faction)
            local factions = self:BREAKDOWN_GetRequiredFactions()
            factions[faction] = true

            self:BREAKDOWN_SetRequiredFactions(factions)
        end 

        function ITEM:BREAKDOWN_AddRequiredClass(faction, class)
            local classes = self:BREAKDOWN_GetRequiredClasses()
            classes[faction] = classes[faction] or {}
            classes[faction][class] = true

            self:BREAKDOWN_SetRequiredClasses(classes)
        end

        function ITEM:BREAKDOWN_AddRequiredItem(item, amount, remove_amount)
            local items = self:BREAKDOWN_GetRequiredItems()
            items[item] = {amount = amount, remove_amount = remove_amount}

            self:BREAKDOWN_SetRequiredItems(items)
        end
        
        function ITEM:BREAKDOWN_AddGivenItem(item, amount)
            local items = self:BREAKDOWN_GetGivenItems()
            items[item] = {amount = amount}

            self:BREAKDOWN_SetGivenItems(items)
        end

        function ITEM:BREAKDOWN_AddRequiredBlueprint(item)
            local blueprints = self:BREAKDOWN_GetRequiredBlueprints()
            blueprints[item] = true

            self:BREAKDOWN_SetRequiredBlueprints(blueprints)
        end

        function ITEM:BREAKDOWN_AddRequiredEntity(entity)
            local entities = self:BREAKDOWN_GetRequiredEntities()
            entities[entity] = true

            self:BREAKDOWN_SetRequiredEntities(entities)
        end

        function ITEM:BREAKDOWN_TakeDelayTime(time)
            time = math.max(self:BREAKDOWN_GetDelayTime() - time, 0)
            self:BREAKDOWN_SetDelayTime(time)

            return true, time
        end

        function ITEM:BREAKDOWN_RemoveRequiredAttribute(attribute)
            local attributes = self:BREAKDOWN_GetRequiredAttributes()
            attributes[attribute] = nil

            self:BREAKDOWN_SetRequiredAttributes(attributes)
        end

        function ITEM:BREAKDOWN_RemoveRequiredFaction(faction)
            local factions = self:BREAKDOWN_GetRequiredFactions()
            factions[faction] = nil

            self:BREAKDOWN_SetRequiredFactions(factions)
        end

        function ITEM:BREAKDOWN_RemoveRequiredClass(faction, class)
            local classes = self:BREAKDOWN_GetRequiredClasses()
            classes[faction] = classes[faction] or {}
            classes[faction][class] = nil

            self:BREAKDOWN_SetRequiredClasses(classes)
        end

        function ITEM:BREAKDOWN_RemoveRequiredItem(item)
            local items = self:BREAKDOWN_GetRequiredItems()
            items[item] = nil

            self:BREAKDOWN_SetRequiredItems(items)
        end

        function ITEM:BREAKDOWN_RemoveGivenItem(item)
            local items = self:BREAKDOWN_GetGivenItems()
            items[item] = nil

            self:BREAKDOWN_SetGivenItems(items)
        end

        function ITEM:BREAKDOWN_RemoveRequiredBlueprint(item)
            local blueprints = self:BREAKDOWN_GetRequiredBlueprints()
            blueprints[item] = nil

            self:BREAKDOWN_SetRequiredBlueprints(blueprints)
        end

        function ITEM:BREAKDOWN_RemoveRequiredEntity(entity)
            local entities = self:BREAKDOWN_GetRequiredEntities()
            entities[entity] = nil

            self:BREAKDOWN_SetRequiredEntities(entities)
        end

        function ITEM:BREAKDOWN_HasGivenItems()
            local items = self:BREAKDOWN_GetGivenItems()

            return table.Count(items) > 0
        end
    end

    ix.meta.item = ITEM
end