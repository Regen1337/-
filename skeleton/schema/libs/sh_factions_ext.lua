
ix.meta = ix.meta or {}
local META = {}

do
    META = {}
    META.__index = META
    META.__call = META

    do -- fill out default functions here for factions or edit ix.meta.faction
        function META:GetName()
            return self.name
        end

        function META:GetDescription()
            return self.description
        end

        function META:IsDefault()
            return self.isDefault
        end

        function META:GetColor()
            return self.color
        end

        function META:GetPay()
            return self.pay
        end

        function META:GetWeight()
            return self.weight
        end

        function META:GetModels()
            return self.models
        end

        function META:IsWhitelisted()
            return self.whitelist
        end

        function META:GetIndex()
            return self.index
        end

        function META:GetPlugin()
            return self.plugin
        end

        function META:GetUniqueID()
            return self.uniqueID
        end

    end

    do
        local oldFLFD = ix.faction.LoadFromDir
        function ix.faction.LoadFromDir(dir)
            oldFLFD(dir)

            for _, fac in ipairs(ix.faction.indices) do
                if !(getmetatable(fac)) then
                    fac = setmetatable(fac, META)
                end
            end
        end
    end

    ix.meta.faction = META
end

-- class meta
do 
    META = {}
    META.__index = META
    META.__call = META

    do -- fill out default functions here for classes or edit ix.meta.class
        function META:GetName()
            return self.name
        end

        function META:GetFactionIndex()
            return self.faction
        end

        function META:IsDefault()
            return self.isDefault
        end

        function META:GetWeight()
            return self.weight
        end

        function META:GetIndex()
            return self.index
        end

        function META:GetLimit()
            return self.limit
        end

    end

    do
        local oldCLFD = ix.class.LoadFromDir
        function ix.class.LoadFromDir(dir)
            oldCLFD(dir)

            for _, cls in ipairs(ix.class.list) do
                if !(getmetatable(cls)) then
                    cls = setmetatable(cls, META)
                end
            end
        end
    end

    ix.meta.class = META
end