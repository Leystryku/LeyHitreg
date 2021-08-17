local IsValid = IsValid
local CurTime = CurTime
local ipairs = ipairs
local tableremove = table.remove

LeyHitreg.ForceHit = {}

local toRemove = {}

function LeyHitreg:CleanHits(ply, wep, tbl)
    local needsRemove = false
    local highestKey = nil

    local curTime = CurTime()

    for k,v in ipairs(tbl) do
        local target = v.target

        if (not IsValid(target) or target:Health() < 0 or curTime > v.expireTime or v.weapon != wep) then
            toRemove[#toRemove + 1] = k

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

LeyHitreg.ScaleDamageBlockEntity = LeyHitreg.ScaleDamageBlockEntity or {}

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
    print(target) 
    PrintTable(shot)
    */

    local targetpos = target:GetBonePosition(shot.targetBone)
    if (not targetpos) then
        ply:ChatPrint("[/LeyHitreg/] Bone not found")
        return
    end

    bullet.Src = ply:GetShootPos()
    local newdir = (targetpos - bullet.Src)
    bullet.Dir = newdir
    self.ScaleDamageBlockEntity[ply] = true

    ply.LeyHitReg_ShouldHit = shot.targetHitGroup

    /*
    ply.Bullets = (ply.Bullets or 0) + 1
    timer.Create(ply:SteamID64() .. "_plybullets_log", 1, 1, function()
        ply:ChatPrint("bullets hitregged: " .. tostring(ply.Bullets))
        ply.Bullets = 0
    end)
    ply:SetEyeAngles(newdir:Angle())

    
    print(target:GetPos(), targetpos)

    ply:ChatPrint("Target Bone: " .. tostring(shot.targetBone))
    */

    return true
end

function LeyHitreg:InsertPlayerData(ply, cmd, wep, shouldPrimary, target, targetBone, targetHitGroup)
    if (#self.ForceHit[ply] > 500) then
        ply:Kick("[/LeyHitreg/] No Exploiting, little boy.")
        return
    end

    table.insert(self.ForceHit[ply], {
        ["shouldPrimary"] = shouldPrimary,
        ["target"] = target,
        ["targetPos"] = target:GetPos(),
        ["targetBone"] = targetBone,
        ["targetHitGroup"] = targetHitGroup,
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
        local targetHitGroup = HITGROUP_GENERIC

        local hitboxsets = target.GetHitBoxSetCount and target:GetHitBoxSetCount() or 1
        for hitboxset = 0, hitboxsets - 1 do
            local hitboxes = target:GetHitBoxCount(hitboxset)

            for hitbox = 0, hitboxes - 1 do
                local bone = target:GetHitBoxBone(hitbox, hitboxset)

                if (bone == targetBone) then
                    targetHitGroup = target:GetHitBoxHitGroup(hitbox, hitboxset)
                end
            end
        end

        self:InsertPlayerData(ply, cmd, wep, shouldPrimary, target, targetBone, targetHitGroup)
    end
end

hook.Add("EntityFireBullets", "LeyHitreg:EntityFireBullets", function(...)
    local ret = LeyHitreg:EntityFireBullets(...)

    if (ret != nil) then
        return ret
    end
end)