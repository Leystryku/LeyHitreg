-- THESE ARE THE SETTINGS 

-- Security stuff
LeyHitreg.SecurityNetMessageName = "6ffce390e17b9f5849cfd8b887fac20a3cdc24cedbccb4b48326b18d079dd693" -- if you change this, do so in cl_leyhitreg.lua as well
LeyHitreg.SecurityCheckBulletPos = false -- confirm the bullet position
LeyHitreg.SecurityCheckVisibility = false -- confirm whether the player can see his target
LeyHitreg.SecurityCheckBulletMaxDist = 600 -- NOT visibility its for bullet confirmation

-- Optimization stuff
LeyHitreg.DisableWhenPlayers = 40 -- more than these many players = disable hitreg, useful for big servers



LeyHitreg.IgnoreSweps = {}
LeyHitreg.IgnoreSweps["weapon_someweaponwithveryfastfirerate"] = true


-- DO NOT CHANGE THESE (Stuff you do not and should not change)
-- ONLY CHANGE THESE IF I TELL YOU SO IN A TICKET

LeyHitreg.DisableSourceHitHandling = false -- DONT CHANGE; This is mainly for testing. If this is enabled sources hit handling will always be ignored.
LeyHitreg.SecuritySacrifice = false -- DONT CHANGE; Sacrifice security for better perf
LeyHitreg.EnableLagComp = true -- LeyHitreg lag compensation enabled?

-- DO NOT REMOVE OR CHANGE BELOW
-- DO NOT REMOVE OR CHANGE BELOW
-- DO NOT REMOVE OR CHANGE BELOW
-- DO NOT REMOVE OR CHANGE BELOW
-- DO NOT REMOVE OR CHANGE BELOW
-- DO NOT REMOVE OR CHANGE BELOW
-- DO NOT REMOVE OR CHANGE BELOW

return true