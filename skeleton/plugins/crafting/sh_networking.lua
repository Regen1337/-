if SERVER then
    util.AddNetworkString("char_craft")

    net.Receive("char_craft", function(len, ply)
        local item_id = net.ReadString()
        local item = ix.item.list[item_id]
        if !(item) then ply:Notify("That item doesn't exist!") return end

        local character = ply:GetCharacter()
        if !(character) then ply:Notify("You don't have a character!") return end

        local inventory = character:GetInventory()
        if !(inventory) then ply:Notify("You don't have an inventory!") return end

        local can, err = character:CRAFT_CraftItem(item)

        if !(can) then ply:Notify(err) return end
    end)
else
    net.Start("char_craft")
        net.WriteString("test")
    net.SendToServer()
end