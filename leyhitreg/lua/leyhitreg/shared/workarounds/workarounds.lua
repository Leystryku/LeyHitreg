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

    -- Ignore shotguns
    if (wep.Shotgun or wep.IsShotgun or wep.ShotGun or wep.Primary and wep.Primary.NumShots and wep.Primary.NumShots > 1) then
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

function LeyHitreg:GetPlayerFromWeapon(wep)
    local ply = wep:GetOwner()

    if (not IsValid(ply)) then
        return
    end

    return ply
end

local IsValid = IsValid
function LeyHitreg:GetPlayerFromPlyOrBullet(plyorwep, bullet)
    if (not bullet or not IsValid(plyorwep)) then
        return
    end

    local ply = bullet.Attacker

    if (not IsValid(ply) or not ply:IsPlayer()) then
        ply = nil
    end

    if (plyorwep:IsWeapon()) then
        if (ply) then
            return ply, plyorwep
        end

        local owner = plyorwep:GetOwner()

        if (not IsValid(owner) or not owner:IsPlayer()) then
            return
        end

        return owner, plyorwep
    end

    if (not ply) then
        ply = plyorwep

        if (not ply:IsPlayer()) then
            return
        end
    end

    local wep = ply:GetActiveWeapon()

    if (not IsValid(wep)) then
        return
    end

    return ply, wep
end

local vector_origin = vector_origin
function LeyHitreg:GetWeaponSpread(ply, wep, bullet)
    local bulletSpread = bullet.Spread

    if (bulletSpread and bulletSpread != vector_origin) then
        return bulletSpread
    end

    if (wep.PrimarySpread) then
        return wep.PrimarySpread
    end

    if (wep.PrimaryCone) then
        return wep.PrimaryCone
    end

    if (wep.Primary) then
        if (wep.Primary.Spread) then
            return wep.Primary.Spread
        end

        if (wep.Primary.Cone) then
            return wep.Primary.Cone
        end

        return bulletSpread
    end

    return vector_origin
end