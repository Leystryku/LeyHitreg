IN_LEYHITREG1 = bit.lshift(1, 27)
IN_LEYHITREG2 = bit.lshift(1, 28)

local meta = FindMetaTable("Player")
meta.OldLagCompensation = meta.OldLagCompensation or meta.LagCompensation

function meta:LagCompensation(...)
    if (not LeyHitreg.Disabled) then
        return
    end

    return self:OldLagCompensation(...)
end

local Entity = Entity

local PlyNeedsPrimReset = {}
local PlyNeedsSecReset = {}

LeyHitreg.BulletCount = {}

function LeyHitreg:StartCommand(ply, cmd)
    if (not ply:Alive() or LeyHitreg.Disabled) then
        return
    end

    local wep = ply:GetActiveWeapon()

    if (not IsValid(wep)) then
        return
    end

    local hasPrim = wep.CanPrimaryAttack and wep.PrimaryAttack
    local hasSec = wep.CanSecondaryAttack and wep.SecondaryAttack

    if (not hasPrim and not hasSec) then
        return
    end

    local shouldPrimary = cmd:KeyDown(IN_LEYHITREG1)
    local shouldSecondary = cmd:KeyDown(IN_LEYHITREG2)

    if (not shouldPrimary and not shouldSecondary) then
        return
    end

    LeyHitreg.BulletCount[ply] = (LeyHitreg.BulletCount[ply] or 0) + 1

    if (LeyHitreg.BulletCount[ply] > 30) then
        return
    end

    local targetEntIndex = cmd:GetUpMove()
    local target

    if (targetEntIndex and targetEntIndex != 0) then
        target = Entity(targetEntIndex)
    else
        targetEntIndex = 0
    end

    local targetBone = cmd:GetMouseWheel()
    cmd:SetUpMove(0)
    cmd:SetMouseWheel(0)

    if (targetBone > 0xFF) then
        return
    end

    LeyHitreg:ProcessBullet(ply, cmd, wep, shouldPrimary, target, targetBone)
end

timer.Create("LeyHitreg.BulletMax", 0.1, 0, function()
    for k, ply in ipairs(player.GetAll()) do
        LeyHitreg.BulletCount[ply] = 0
    end
end)

hook.Add("StartCommand", "LeyHitreg:StartCommand", function(ply, cmd)
    LeyHitreg:StartCommand(ply, cmd)
end)

function LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep)
    PlyNeedsPrimReset[ply] = nil
    PlyNeedsSecReset[ply] = nil
end

hook.Add("PlayerSwitchWeapon", "LeyHitreg:PlayerSwitchWeapon", function(ply, oldWep, newWep)
    LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep)
end)