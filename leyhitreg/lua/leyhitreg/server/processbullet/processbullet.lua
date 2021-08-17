LeyHitreg.ForceHit = {}

local toRemove = {}

local CurTime = CurTime
local tableremove = table.remove

function LeyHitreg:CleanHits(ply, wep, tbl)
    local needsRemove = false
    local highestKey = nil

    local curTime = CurTime()

    for k,v in ipairs(tbl) do
        local target = v.target

        if (not IsValid(target) or target:Health() < 0 or curTime > v.expireTime or v.weapon != wep) then
            toRemove[#toRemove + 1] = v

            if (not highestKey or k > highestKey) then
                highestKey = k
            end

            needsRemove = true
        end
    end

    if (not needsRemove) then
        return tbl
    end

    for i = #toRemove, 1, -1 do
        local key = toRemove[i]
        tableremove(tbl, key)
        toRemove[i] = nil
    end

    return tbl
end

local trace = {}
local traceres = {}
trace.filter = MASK_SHOT
trace.output = traceres

LeyHitreg.VisibilityCheckDisabled = false

function LeyHitreg:CanSeeEnt(ply, pos, target, targetpos)
    if (self.VisibilityCheckDisabled) then
        return true
    end
    /*
    trace.filter = ply
    trace.start = ply:EyePos()
    trace.endpos = target:EyePos()

    util.TraceLine(trace)
    */
    return ply:VisibleVec(target:GetPos())
end

local meta = FindMetaTable("Player")
meta.OldLagCompensation = meta.OldLagCompensation or meta.LagCompensation

function meta:LagCompensation(...)
    if (not LeyHitreg.Disabled) then
        return
    end

    return self:OldLagCompensation(...)
end

function LeyHitreg:EntityFireBullets(ply, bullet)
    local wep = ply:GetActiveWeapon()

    if (not IsValid(wep)) then
        return
    end

    local hitTable = LeyHitreg.ForceHit[ply]

    if (not hitTable) then
        return
    end

    local shot = self:CleanHits(ply, wep, hitTable)[1]

    if (not shot) then
        return
    end

    tableremove(hitTable, 1)
    local target = shot.target

    local canSee, _ = self:CanSeeEnt(ply, shot.shootPos, target, targetPos)
    if (not canSee) then
        -- ply:ChatPrint("NOT VISIBLE: " .. tostring(canSeeEnt))
        return
    end

    /*
    print(canSee)
    PrintTable(shot)
    */

    local targetpos = target:GetBonePosition(shot.targetBone)
    if (not targetpos) then
        ply:ChatPrint("[/LeyHitreg/] Bone not found")
        return
    end

    local newdir = (targetpos - bullet.Src)
    bullet.Dir = newdir
    /*
    ply.Bullets = (ply.Bullets or 0) + 1
    timer.Create(ply:SteamID64() .. "_plybullets_log", 1, 1, function()
        ply:ChatPrint("bullets hitregged: " .. tostring(ply.Bullets))
        ply.Bullets = 0
    end)

    ply.shouldHit = shot.targetBone
    bullet.Spread = Vector(0,0,0)
    
    print(target:GetPos(), targetpos)

    ply:SetEyeAngles(newdir:Angle())
    ply:ChatPrint("Target Bone: " .. tostring(shot.targetBone))
    */

    return true
end


function LeyHitreg:InsertPlayerData(ply, cmd, wep, shouldPrimary, target, targetBone)
    if (#self.ForceHit[ply] > 500) then
        ply:Kick("[/LeyHitreg/] No Exploiting, little boy.")
        return
    end

    table.insert(self.ForceHit[ply], {
        ["shouldPrimary"] = shouldPrimary,
        ["target"] = target,
        ["targetPos"] = target:GetPos(),
        ["targetBone"] = targetBone,
        ["shootPos"] = ply:GetShootPos(),
        ["eyeAngles"] = cmd:GetViewAngles(),
        ["aimVec"] = ply:GetAimVector(),
        ["shootPos"] = ply:GetPos(),
        ["weapon"] = wep,
        ["expireTime"] = CurTime() + 0.8
    })
end

function LeyHitreg:ProcessBullet(ply, cmd, wep, shouldPrimary, target, targetBone)
    self.ForceHit[ply] = self.ForceHit[ply] or {}

    if (not IsValid(target) or target:Health() < 0) then
        return
    end

    if (wep.LeyHitregIgnore or (shouldPrimary and wep:Clip1() == 0) or (not shouldPrimary and wep:Clip2() == 0)) then
        return
    end

    if (shouldPrimary and wep.CanPrimaryAttack and wep:CanPrimaryAttack()) then
        self:InsertPlayerData(ply, cmd, wep, shouldPrimary, target, targetBone)
    end
end

hook.Add("EntityFireBullets", "LeyHitreg:EntityFireBullets", function(...)
    local ret = LeyHitreg:EntityFireBullets(...)

    if (ret != nil) then
        return ret
    end
end)