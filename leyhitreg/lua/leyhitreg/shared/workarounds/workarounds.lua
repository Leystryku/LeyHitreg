local HL2Ignore = {}
HL2Ignore["weapon_physcannon"] = true
HL2Ignore["weapon_physgun"] = true
HL2Ignore["weapon_frag"] = true
HL2Ignore["weapon_rpg"] = true
HL2Ignore["gmod_camera"] = true
HL2Ignore["gmod_tool"] = true
HL2Ignore["weapon_physcannon"] = true

local ExtraIgnores = {}

function LeyHitreg:IsIgnoreWep(wep)
    if (HL2Ignore[wep:GetClass()]) then
        return true
    end

    if (ExtraIgnores[wep:GetClass()]) then
        return true
    end

    -- This gets rid of all melees, but might  also get rid of some non-melees with inf ammo
    -- maybe even some limited action melees
    -- but, gonna fix conflicts as they arise
    if (wep.IsMelee or wep.Melee or wep:Clip1() < 0) then
        return true
    end

    return false
end

function LeyHitreg:AddIgnoreWeapon(weporclass)
    if (isstring(weporclass)) then
        ExtraIgnores[weporclass] = true
    else
        ExtraIgnores[weporclass:GetClass()] = true
    end
end