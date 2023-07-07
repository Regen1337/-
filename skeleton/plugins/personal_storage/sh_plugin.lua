local PLUGIN = PLUGIN

PLUGIN.name = "Personal Storage"
PLUGIN.author = "regen"
PLUGIN.description = "Adds a entity that allows you to store items safely, out of reach from other players."

ix.personal_storage = ix.personal_storage or {}

do
    ix.config.Add("personalStorageMaxWeight", 100, "The maximum weight of a personal storage.", nil, {
        data = {min = 1, max = 1000},
        category = "Personal Storage"
    })

    ix.config.Add("personalStorageWidth", 4, "The width of a personal storage.", nil, {
        data = {min = 1, max = 100},
        category = "Personal Storage"
    })

    ix.config.Add("personalStorageHeight", 4, "The height of a personal storage.", nil, {
        data = {min = 1, max = 100},
        category = "Personal Storage"
    })

    ix.config.Add("personalStorageOpenTime", 5, "The time it takes to open a personal storage.", nil, {
        data = {min = 1, max = 60},
        category = "Personal Storage"
    })

    function PLUGIN:InitializedPlugins()
        ix.inventory.Register("personal_storage", ix.config.Get("personalStorageWidth", 4), ix.config.Get("personalStorageHeight", 4))
    end
end

ix.util.Include("sh_meta.lua")
ix.util.Include("sh_networking.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_derma.lua")