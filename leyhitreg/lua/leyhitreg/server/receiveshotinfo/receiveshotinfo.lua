IN_LEYHITREG1 = bit.lshift(1, 27)

local Entity = Entity
local IsValid = IsValid

local PlyNeedsPrimReset = {}

LeyHitreg.BulletCount = {}
LeyHitreg.InvalidShots = {}

function LeyHitreg:StartCommand(ply, cmd)
    if (not ply:Alive() or LeyHitreg.Disabled) then
        return
    end

    local shouldPrimary = cmd:KeyDown(IN_LEYHITREG1)

    if (not shouldPrimary) then
        return
    end

    local targetEntIndex = cmd:GetUpMove()
    local targetBone = cmd:GetMouseWheel()

    cmd:SetUpMove(0)
    cmd:SetMouseWheel(0)

    if (targetBone > 0xFF) then
        return
    end

    local wep = ply:GetActiveWeapon()

    if (not IsValid(wep)) then
        return
    end

    if (self:IsIgnoreWep(wep)) then
        return
    end

    if (LeyHitreg.BulletCount[ply] > 50) then
        return
    end

    LeyHitreg.BulletCount[ply] = (LeyHitreg.BulletCount[ply] or 0) + 1

    local target

    if (targetEntIndex and targetEntIndex > 0) then
        target = Entity(targetEntIndex)

        if (not IsValid(target) or not (target:IsNPC() or target:IsPlayer())) then
            target = nil
        end
    else
        targetEntIndex = 0
    end

    if (target) then
        if (self:IsInvalidShot(ply, cmd, wep, shouldPrimary, target, targetBone)) then
            if (self.LogInvalidShots) then
                ply:ChatPrint("Invalid shot!")
            end

            LeyHitreg.InvalidShots[ply] = (LeyHitreg.InvalidShots[ply] or 0) + 1
            return
        end

    end

    LeyHitreg:ProcessBullet(ply, cmd, wep, shouldPrimary, target, targetBone)
end

timer.Create("LeyHitreg.BulletMax", 0.1, 0, function()
    for k, ply in ipairs(player.GetAll()) do
        LeyHitreg.BulletCount[ply] = 0
    end
end)

timer.Create("LeyHitreg.KickInvalidShooters", 30, 0, function()
    for k, ply in ipairs(player.GetAll()) do
        if ((LeyHitreg.InvalidShots[ply] or 0) >= 10) then
            ply:Kick("[/LeyHitreg/] Too many invalid shots!")
        end

        LeyHitreg.InvalidShots[ply] = 0
    end
end)

hook.Add("StartCommand", "LeyHitreg:StartCommand", function(ply, cmd)
    LeyHitreg:StartCommand(ply, cmd)
end)

function LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep)
    PlyNeedsPrimReset[ply] = nil
end

hook.Add("PlayerSwitchWeapon", "LeyHitreg:PlayerSwitchWeapon", function(ply, oldWep, newWep)
    LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep)
end)