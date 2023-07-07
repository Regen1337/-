local PLUGIN = PLUGIN

do
    ix.log.AddType("xpAdd", function(client, amount)
        return string.format("%s has gained %d XP.", client:Name(), amount)
    end)

    ix.log.AddType("xpSet", function(client, amount)
        return string.format("%s has set their XP to %d.", client:Name(), amount)
    end)

    ix.log.AddType("xpRemove", function(client, amount)
        return string.format("%s has lost %d XP.", client:Name(), amount)
    end)

    ix.log.AddType("xpReset", function(client)
        return string.format("%s has reset their XP.", client:Name())
    end)

    ix.log.AddType("levelAdd", function(client, amount)
        local level = amount > 1 and "levels" or "level"
        return string.format("%s has gained %d %s", client:Name(), amount, level)
    end)

    ix.log.AddType("levelSet", function(client, amount)
        return string.format("%s has set their level to %d.", client:Name(), amount)
    end)

    ix.log.AddType("levelRemove", function(client, amount)
        local level = amount > 1 and "levels" or "level"
        return string.format("%s has lost %d %s", client:Name(), amount, level)
    end)

    ix.log.AddType("levelReset", function(client)
        return string.format("%s has reset their level.", client:Name())
    end)
end

do
    local META = ix.meta.character
end

    