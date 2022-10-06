
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

LeyHitreg.WeaponSpreads = {}

function LeyHitreg:IsAutoWep(wep)
    if (wep.Primary) then
        return wep.Primary.Automatic
    end

    return true
end

local NeedsPrimReset = false

function LeyHitreg:CreateMove(cmd)
    if (not lply or LeyHitreg.Disabled or LeyHitreg.DisabledOnlyOnClient) then
        return
    end

    local spreadWep = lply.LeyHitreg_NeedsSpreadForce

    if (spreadWep and IsValid(spreadWep)) then
        LeyHitreg:SetFittingValidClip(spreadWep)
    end

    if (cmd:CommandNumber() == 0) then
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
    local viewang = cmd:GetViewAngles()
    local dir = viewang:Forward()

    local weaponSpread = self:GetWeaponSpread(lply, wep)

    if (weaponSpread) then
        local applied, newDir = self:ApplyBulletSpread(lply, dir, weaponSpread)
 
        if (applied) then
            dir = newDir
        end
    else
        -- LocalPlayer():ChatPrint("NO WEAPONSPREAD")
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

function LeyHitreg:EntityFireBullets(plyorwep, bullet)
    if (LeyHitreg.Disabled or LeyHitreg.DisabledOnlyOnClient) then
        return
    end

    local ply, wep = self:GetPlayerFromPlyOrBullet(plyorwep, bullet)

    if (not ply) then
        return
    end

    if (not LeyHitreg.ShotDirForceDisabled) then
        bullet.Dir = ply:GetAimVector()
    end

    local forcedShot = LeyHitreg:FetchSpreadFireBullets(ply, wep, bullet)

    if (forcedShot != nil) then
        return forcedShot
    end

    if (not wep or self:IsIgnoreWep(wep)) then
        return
    end

    local ret = LeyHitreg:SpreadedEntityFireBullets(ply, wep, bullet, bulletSpread)

    if (ret != nil) then
        return ret
    end
end

hook.Add("EntityFireBullets", "LeyHitreg:EntityFireBullets", function(plyorwep, bullet)
    local ret = LeyHitreg:EntityFireBullets(plyorwep, bullet)

    if (ret != nil) then
        return ret
    end
end)