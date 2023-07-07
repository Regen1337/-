local PLUGIN = PLUGIN

do

    function PLUGIN:CharacterLoaded(character)
        character:CRAFT_SetNextAllowedCraftTime(0)
        character:BREAKDOWN_SetNextAllowedBreakdownTime(0)
    end

end