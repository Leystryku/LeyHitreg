
local IsValid = IsValid
local inputIsMouseDown = input.IsMouseDown
local vector_origin = vector_origin

IN_LEYHITREG1 = bit.lshift(1, 27)

function LeyHitreg:ShouldPrimaryAttack()
    return inputIsMouseDown(MOUSE_LEFT) or inputIsMouseDown(MOUSE_RIGHT)
end

local lastPrim = nil
function LeyHitreg:CanShoot(cmd, wep, primary)
    local canShoot = true

    local nextPrim = wep:GetNextPrimaryFire()

    if (primary) then
        if (nextPrim == lastPrim or wep:Clip1() == 0) then
            canShoot = false
        else
            lastPrim = nextPrim
        end
    end

    return canShoot
end

local bitbor = bit.bor
local trace = {}
local traceres = {}
trace.filter = LocalPlayer()
trace.mask = MASK_SHOT
trace.output = traceres

local lply = nil

timer.Create("LeyHitreg.LocalPlayerGet", 0.1, 0, function()
    if (not lply and IsValid(LocalPlayer())) then
        lply = LocalPlayer()
        trace.filter = lply
        timer.Remove("LeyHitreg.LocalPlayerGet")
    end
end)

local WeaponSpread = nil

function LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep)
    if (ply != lply) then
        return
    end

    WeaponSpread = nil

    if (newWep.Primary and newWep.Primary.Cone) then
        WeaponSpread = newWep.Primary.Cone
    elseif (newWep.PrimaryCone) then
        WeaponSpread = newWep.PrimaryCone
    end

    if (WeaponSpread == vector_origin) then
        WeaponSpread = nil
    end
end

hook.Add("PlayerSwitchWeapon", "LeyHitreg:PlayerSwitchWeapon", function(...)
    LeyHitreg:PlayerSwitchWeapon(...)
end)

function LeyHitreg:IsAutoWep(wep)
    if (wep.Primary) then
        return wep.Primary.Automatic
    end

    return true
end

local NeedsPrimReset = false

function LeyHitreg:CreateMove(cmd)
    if (cmd:CommandNumber() == 0 or LeyHitreg.Disabled or not lply) then
        return
    end

    local cmdAttack1 = cmd:KeyDown(IN_ATTACK)

    if (not cmdAttack1) then
        NeedsPrimReset = false
        return
    elseif (NeedsPrimReset and not cmdAttack1) then
        NeedsPrimReset = false
    end

    local shouldPrimary = self:ShouldPrimaryAttack()

    if (not shouldPrimary) then
        return
    end

    local wep = lply:GetActiveWeapon()

    if (not IsValid(wep)) then
        return
    end

    if (self:IsIgnoreWep(wep)) then
        return
    end

    if (not self:CanShoot(cmd, wep, shouldPrimary)) then
        return
    end

    local primAuto = self:IsAutoWep(wep)

    if (NeedsPrimReset and shouldPrimary) then
        return
    end

    if (not primAuto and shouldPrimary) then
        NeedsPrimReset = true
    end

    if (shouldPrimary) then
        cmd:SetButtons(bitbor(cmd:GetButtons(), IN_LEYHITREG1))
    end

    trace.start = lply:GetShootPos()
    local dir = cmd:GetViewAngles():Forward()

    if (WeaponSpread) then
        local applied, newDir = self:ApplyBulletSpread(lply, cmd:GetViewAngles():Forward(), WeaponSpread)

        if (applied) then
            dir = newDir
        end
    end

    trace.endpos = trace.start + (dir * (56756 * 8))
    traceres.Entity = nil
    traceres.HitGroup = nil
    traceres.HitBox = nil

    util.TraceLine(trace)

    local target = traceres.Entity

    if (not IsValid(target) or not (target:IsNPC() or target:IsPlayer())) then
        cmd:SetUpMove(-1)
        if (LeyHitreg.AnnounceClientHits) then
            LocalPlayer():ChatPrint("It's a miss!")
            -- PrintTable(trace)
        end
        return
    end

    local hitgroup = traceres.HitGroup
    local hitbox = traceres.HitBox
    local hitbone = target:GetHitBoxBone(hitbox, 0)

    if (not hitbone or not hitgroup) then
        print("[/LeyHitreg/] Bone not found")
        return
    end

    cmd:SetUpMove(target:EntIndex())
    cmd:SetMouseWheel(hitbone)

    if (LeyHitreg.AnnounceClientHits) then
        LocalPlayer():ChatPrint("It's a hit!")
    end
end

hook.Add("CreateMove", "LeyHitreg:CreateMove", function(...)
    LeyHitreg:CreateMove(...)
end)


function LeyHitreg:EntityFireBullets(ply, bullet)
    if (LeyHitreg.Disabled) then
        return
    end

    local appliedAny, newDir = self:ApplyBulletSpread(ply, bullet.Dir, WeaponSpread)
    WeaponSpread = bullet.Spread
    if (WeaponSpread == vector_origin) then
        WeaponSpread = nil
    end

    if (not appliedAny) then
        return
    end

    bullet.Spread = vector_origin
    bullet.Dir = newDir
    return true
end

hook.Add("EntityFireBullets", "LeyHitreg:EntityFireBullets", function(...)
    local ret = LeyHitreg:EntityFireBullets(...)

    if (ret != nil) then
        return ret
    end
end)