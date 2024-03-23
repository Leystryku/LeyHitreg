local HL2Ignore = {}
HL2Ignore["weapon_physcannon"] = true
HL2Ignore["weapon_physgun"] = true
HL2Ignore["weapon_frag"] = true
HL2Ignore["weapon_rpg"] = true
HL2Ignore["gmod_camera"] = true
HL2Ignore["gmod_tool"] = true
HL2Ignore["weapon_physcannon"] = true
HL2Ignore["weapon_shotgun"] = true

local MeleeHoldType = {}
MeleeHoldType["knife"] = true
MeleeHoldType["melee"] = true
MeleeHoldType["melee2"] = true

local ExtraIgnores = {}

function LeyHitreg:IsIgnoreWep(wep)
    if (HL2Ignore[wep:GetClass()]) then
        return true
    end

    if (ExtraIgnores[wep:GetClass()]) then
        return true
    end

    -- Ignore all melees
    if (wep.IsMelee or wep.Melee or wep:Clip1() < 0) then
        return true
    end


    if (wep.GetHoldType) then
        local holdType = wep:GetHoldType()

        if (MeleeHoldType[holdType]) then
            return true
        end
    end

    -- Ignore shotguns
    if (wep.Shotgun or wep.IsShotgun or wep.ShotgunReload or wep.ShotGun or wep.Primary and wep.Primary.NumShots and wep.Primary.NumShots > 1) then
        return true
    end
    -- Ignore modern day SWEP creators who are too busy reinventing the wheel to add a single wep.IsShotgun variable
    if (wep.ShotgunEmptyAnim or wep.ShotgunStartAnimShell) then
        return true
    end

    if (wep.Category and string.find(string.lower(wep.Category), "shotgun", 1, true)) then
        return true
    end

    if (wep.Purpose and string.find(string.lower(wep.Purpose), "shotgun", 1, true)) then
        return true
    end

    if (wep.PrintName and string.find(string.lower(wep.PrintName), "shotgun", 1, true)) then
        return true
    end

    if (ACT3_CAT_SHOTGUN and wep.ACT3Cat and wep.ACT3Cat == ACT3_CAT_SHOTGUN) then
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
    -- MW Swep pack workaround
    if (wep.CalculateCone) then
        return wep:CalculateCone() * 0.1 * 0.7
    end

    -- TFA workaround
    if (wep.CalculateConeRecoil) then
        return wep:CalculateConeRecoil()
    end

    -- ARCCW workaround
    if (wep.GetBuff and wep.ApplyRandomSpread and wep.TryBustDoor and ArcCW) then
        return ArcCW.MOAToAcc * wep:GetBuff("AccuracyMOA") * 4.5
    end


    -- CW2 workaround

    if (wep.AimSpread and wep.recalculateAimSpread and wep.getBaseCone) then
        return wep:getBaseCone()
    end

    if (bullet) then
        local bulletSpread = bullet.Spread

        if (bulletSpread and bulletSpread != vector_origin) then
            return bulletSpread
        end
    end

    if (self.WeaponSpreads and self.WeaponSpreads[wep:GetClass()]) then
        return self.WeaponSpreads[wep:GetClass()]
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

function LeyHitreg:SetFittingValidClip(wep)
    local clip1 = wep:Clip1()

    if (clip1 == -1 or clip1 > 0) then
        return
    end

    local max = wep:GetMaxClip1()

    if (max > 0) then
        wep:SetClip1(max)
        return
    end

    wep:SetClip1(30)
end
