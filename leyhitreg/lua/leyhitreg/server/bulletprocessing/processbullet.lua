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

LeyHitreg.ScaleDamageBlockEntity = LeyHitreg.ScaleDamageBlockEntity or {}

local spread = vector_origin

function LeyHitreg:FallbackEntityFireBullets(ply, wep, bullet)
    local ret = LeyHitreg:SpreadedEntityFireBullets(ply, wep, bullet)
    if (LeyHitreg.ShowActualShotSpreadedHit) then
        LeyHitreg:DebugShowActualShotHit(bullet)
    end
    if (ret != nil) then
        return ret
    end
end

function LeyHitreg:DebugShowActualShotHit(bullet)

    local ocb = bullet.Callback or function() end

    bullet.Callback = function(atk, tr, dmginfo, ...)
        util.Decal("Eye", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        return ocb(atk, tr, dmginfo, ...)
    end

end

function LeyHitreg:EntityTakeDamage(ent, dmg)
    if (not IsValid(ent)) then
        return
    end

    if (not ent.IsNPC or not ent.IsPlayer) then
        return
    end

    if (not ent:IsNPC() and not ent:IsPlayer()) then
        return
    end

    local atk = dmg:GetAttacker()
    
    if (not IsValid(atk)) then
        return
    end

    if (atk.LeyHitreg_CurrentBullet) then
        atk.LeyHitreg_CurrentBullet = nil
        atk.LeyHitreg_LastShotMissed = nil
    end
end

hook.Add("EntityTakeDamage","LeyHitreg:EntityTakeDamage", function(ent, dmg)
    local ret = LeyHitreg:EntityTakeDamage(ent, dmg)

    if (ret != nil) then
        return ret
    end
end)

local tickCount = engine.TickCount
function LeyHitreg:PlayerTick(ply)
    if (ply.LeyHitreg_CurrentBullet) then
        local curTick = tickCount()
        ply.LeyHitreg_CurrentBullet = nil
        ply.LeyHitreg_LastShotMissed = curTick

        local hitTable = LeyHitreg.ForceHit[ply]

        if (not hitTable) then
            return
        end

        local shot = nil
        local bestDelta = nil

        for k,v in ipairs(hitTable) do
            local delta = curTick - v.tickCount
            if (delta >= 0) then
                if (not bestDelta or bestDelta > delta) then
                    bestDelta = delta
                    shot = v
                end
            end
        end

        if (not shot) then
            return
        end

        if (bestDelta > 6) then -- Ideally I'd probably assume it's the same tick
            return
        end

        ply.LeyHitreg_LastBulletEnt:FireBullets(ply.LeyHitreg_LastBullet)
    end
end

hook.Add("PlayerTick", "LeyHitreg:PlayerTick", function(ply)
    LeyHitreg:PlayerTick(ply)
end)

function LeyHitreg:EntityFireBullets(plyorwep, bullet)
    local ocb = bullet.Callback or function() end

    bullet.Callback = function(atk, tr, dmginfo, ...)
        atk.LeyHitreg_CurrentBullet = true
        atk.LeyHitreg_LastBullet = table.Copy(bullet)
        atk.LeyHitreg_LastBulletEnt = plyorwep
        return ocb(atk, tr, dmginfo, ...)
    end

    if (LeyHitreg.ShowActualShotHit) then
        LeyHitreg:DebugShowActualShotHit(bullet)
    end

    local ply, wep = self:GetPlayerFromPlyOrBullet(plyorwep, bullet)

    if (not ply or not wep) then
        return
    end
    
    if (self:IsIgnoreWep(wep)) then
        return
    end

    if (not LeyHitreg.ShotDirForceDisabled) then
        bullet.Dir = ply:GetAimVector()
    end

    local hitTable = LeyHitreg.ForceHit[ply]

    if (not hitTable) then
        return self:FallbackEntityFireBullets(ply, wep, bullet)
    end

    local shot = self:CleanHits(ply, wep, hitTable)[1]

    if (not shot) then
        return self:FallbackEntityFireBullets(ply, wep, bullet)
    end

    tableremove(hitTable, 1)
    local target = shot.target


    -- print(canSee)
    -- print(target) 
    -- PrintTable(shot)

    local targetpos = target:GetBonePosition(shot.targetBone)

    if (not targetpos) then
        ply:ChatPrint("[/LeyHitreg/] Bone not found")
        return self:FallbackEntityFireBullets(ply, wep, bullet)
    end

    local newshootpos = ply:GetShootPos()
    local newdir = (targetpos - bullet.Src)

    LeyHitreg:HitScanBullet(ply, target, bullet, shot, shot.targetBone, shot.targetHitGroup, newshootpos)

    bullet.Src = newshootpos
    bullet.Dir = newdir
    bullet.Spread = vector_origin

    self.ScaleDamageBlockEntity[ply] = true

    ply.LeyHitReg_ShouldHit = shot.targetHitGroup

    if (LeyHitreg.LogFixedBullets) then
        ply.LeyHitreg_Bullets = (ply.LeyHitreg_Bullets or 0) + 1

        timer.Create("LeyHitreg." .. ply:SteamID64() .. ".LogFixedBullets", 1, 1, function()
            ply:ChatPrint("bullets hitregged: " .. tostring(ply.LeyHitreg_Bullets))
            ply.LeyHitreg_Bullets = 0
        end)
    end

    if (LeyHitreg.BulletAimbot) then
        timer.Simple(0, function()
            ply:SetEyeAngles(newdir:Angle())
        end)
    end

    if (LeyHitreg.LogTargetBone) then
        ply:ChatPrint("Target Bone: " .. tostring(shot.targetBone))
    end

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
        ["expireTime"] = CurTime() + 0.8,
        ["tickCount"] = engine.TickCount()
    })
end

function LeyHitreg:CanPrimaryAttack(wep)
    local ply = wep:GetOwner()
    if (wep:Clip1() == 0) then
        return false
    end

    if (not self.IgnoreCanNextPrimaryAttack and wep.CanPrimaryAttack) then
        if (not wep:CanPrimaryAttack()) then
            return false
        end

        return true
    end

    local nextPrim = wep:GetNextPrimaryFire()

    if (wep.LastNextPrim and wep.LastNextPrim == nextPrim) then
        return false
    end

    wep.LastNextPrim = nextPrim

    return true
end

function LeyHitreg:ProcessBullet(ply, cmd, wep, shouldPrimary, target, targetBone)
    self.ForceHit[ply] = self.ForceHit[ply] or {}

    if (not target or target:Health() < 0) then
        return
    end

    if (wep.LeyHitregIgnore) then
        return
    end

    if (shouldPrimary and self:CanPrimaryAttack(wep)) then
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

        local hookRet = hook.Call("LeyHitreg:ProcessBullet", nil, ply, cmd, wep, shouldPrimary, target, targetBone, targetHitGroup)
        if (hookRet == false) then
            return
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
