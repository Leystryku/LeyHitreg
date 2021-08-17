IN_LEYHITREG1 = bit.lshift(1, 27)

local inputIsMouseDown = input.IsMouseDown

function LeyHitreg:ShouldPrimaryAttack()
    return inputIsMouseDown(MOUSE_LEFT) or inputIsMouseDown(MOUSE_RIGHT)
end

local IsValid = IsValid

local lastPrim = nil

function LeyHitreg:CanShoot(cmd, primary, secondary)
    local wep = LocalPlayer():GetActiveWeapon()

    if (not IsValid(wep)) then
        return
    end

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

local NeedsPrimReset = false

function LeyHitreg:CreateMove(cmd)
    if (cmd:CommandNumber() == 0 or LeyHitreg.Disabled) then
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

    if (not shouldPrimary and not shouldSecondary) then
        return
    end

    if (not self:CanShoot(cmd, shouldPrimary, shouldSecondary)) then
        return
    end
    local primAuto = wep.Primary and wep.Primary.Automatic

    if (NeedsPrimReset and shouldPrimary) then
        return
    end

    if (not primAuto and shouldPrimary) then
        NeedsPrimReset = true
    end

    if (shouldPrimary) then
        cmd:SetButtons(bitbor(cmd:GetButtons(), IN_LEYHITREG1))
    end

    trace.start = LocalPlayer():GetShootPos()
    trace.endpos = trace.start + (cmd:GetViewAngles():Forward() * (4096 * 8))
    util.TraceLine(trace)

    local target = traceres.Entity

    if (not IsValid(target)) then
        cmd:SetUpMove(-1)
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
end

hook.Add("CreateMove", "LeyHitreg:CreateMove", function(...)
    LeyHitreg:CreateMove(...)
end)