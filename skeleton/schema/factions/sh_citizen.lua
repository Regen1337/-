FACTION.name = "Citizen"
FACTION.description = "An oppressed group of people"
FACTION.isDefault = true
FACTION.color = Color(100, 60, 60)
FACTION.pay = 10
FACTION.weight = 100

FACTION_CITIZEN = FACTION.index

-- You can define factions in the factions/ folder. You need to have at least one faction that is the default faction - i.e the
-- faction that will always be available without any whitelists and etc.
-- Note that the player's team will also have the same value as their current character's faction index. This means you can use
-- client:Team() == FACTION_CITIZEN to compare the faction of the player's current character.
--FACTION.weapons = {"weapon_pistol"} -- Weapons that every member of the faction should start with.
--FACTION.isGloballyRecognized = true -- Makes it so that everyone knows the name of the characters in this faction.
