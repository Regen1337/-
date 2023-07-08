local PLUGIN = PLUGIN

PLUGIN.name = "Item Rarities"
PLUGIN.author = "regen"
PLUGIN.description = "Adds rarities to items, which can be used for crafting and other things"

ix.item.rarities = ix.item.rarities or {}
ix.item.rarities.list = ix.item.rarities.list or {}

local rarities = ix.item.rarities

function rarities:register(name, color, chance, scales)
    self.list[name] = {
        name = name,
        color = color,
        chance = chance,
        scales = scales
    }

    return self.list[name]
end

function rarities:get(name)
    return self.list[name]
end

function rarities:getAll()
    return self.list
end

-- get a iteration table of list
function rarities:getIter()
    local cache = {}

    for _, rarity in next, (self:getAll()) do
        cache[#cache + 1] = rarity
    end

    return cache
end

-- function that will generate a random rarity based on the chance factor
-- optionally, you can pass a float value that will boost the chance factor, the float will be a value 1 - 100
-- this is useful for things like crafting, where you can boost the chance of getting a higher rarity based on the characters crafting skill
-- you can also optionally specify a minimum rarity, which will be the lowest rarity that can be generated
function rarities:generate(chanceBoost, minRarity)
    local rarity_iteration = self:getIter()
    local chance, max_chance = math.random(1, 1e8), 1e8
    local selected_rarity = false

    if chanceBoost then
        chance = math.min(chance / chanceBoost, max_chance)
    end

    table.sort(rarity_iteration, function(a, b) return a.chance < b.chance end)

    for _, rarity in ipairs(rarity_iteration) do
        if chance <= rarity.chance then
            selected_rarity = rarity
            break
        end
    end

    if (minRarity and selected_rarity.chance > minRarity.chance) then
        selected_rarity = minRarity
    end

    return selected_rarity
end

function rarities:test_generation(generations, chanceBoost, minRarity)
    local rarityCounts = {}

    for i = 1, generations do
        local rarity = self:generate(chanceBoost, minRarity)

        if rarityCounts[rarity.name] then
            rarityCounts[rarity.name] = rarityCounts[rarity.name] + 1
        else
            rarityCounts[rarity.name] = 1
        end
    end

    print("Rarity Generation Test Results:")
    print("--------------------------------")

    local totalGenerated = generations

    for rarityName, count in pairs(rarityCounts) do
        local percentage = (count / totalGenerated) * 100
        print(rarityName .. ": " .. count .. " (" .. string.format("%.2f", percentage) .. "%)")
    end
end

do
    rarities:register("Common", Color(128, 128, 128), 1e8, {
        price = 1,
        damage = 1,
        resistance = 1,
        healing = 1,
        ammo = 1
    })

    rarities:register("Standard", Color(0, 255, 0), 1e7, {
        price = 1.5,
        damage = 1.5,
        resistance = 1.5,
        healing = 1.5,
        ammo = 1.5
    })

    rarities:register("Special", Color(0, 0, 255), 1e6, {
        price = 2,
        damage = 2,
        resistance = 2,
        healing = 2,
        ammo = 2
    })

    rarities:register("Superior", Color(128, 0, 128), 1e5, {
        price = 2.5,
        damage = 2.5,
        resistance = 2.5,
        healing = 2.5,
        ammo = 2.5
    })

    rarities:register("Epic", Color(255, 165, 0), 1e4, {
        price = 3,
        damage = 3,
        resistance = 3,
        healing = 3,
        ammo = 3
    })

    rarities:register("Legendary", Color(255, 215, 0), 1e3, {
        price = 3.5,
        damage = 3.5,
        resistance = 3.5,
        healing = 3.5,
        ammo = 3.5
    })

    rarities:register("Ascended", Color(255, 0, 255), 1e2, {
        price = 4,
        damage = 4,
        resistance = 4,
        healing = 4,
        ammo = 4
    })

    rarities:register("Eternal", Color(255, 0, 0), 1e1, {
        price = 5,
        damage = 5,
        resistance = 5,
        healing = 5,
        ammo = 5
    })
end

if !(SERVER) then
    function PLUGIN:PopulateItemTooltip(tooltip, item)
        local rarity = item:GetRarityTable()
        if rarity then
            local row = tooltip:AddRowAfter("name", "rarity")
                row:SetFont("ixItemDescFont")
                row:SetText(item:GetRarityName())
                row:SetColor(item:GetRarityColor())
                row:SetBackgroundColor(Color(0, 0, 0, 200))
        end
    end
end

ix.item.rarities = rarities
ix.util.Include("sh_meta.lua")