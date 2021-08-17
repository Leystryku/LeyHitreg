function LeyHitreg:OriginalScaleDamage(ent, hitgroup, dmg, orighitgroup)
    if (not self.LogHitgroupMismatches) then
        return
    end

    local atk = dmg:GetAttacker()

    if (orighitgroup and IsValid(atk) and atk.IsPlayer and atk:IsPlayer()) then
        local shouldHit = hitgroup
        atk:ChatPrint("HITGROUP_HEAD: " .. tostring(hitgroup == HITGROUP_HEAD))
        atk:ChatPrint(shouldHit .. "==" .. orighitgroup)
        return
    end
end

hook.Add("ScalePlayerDamage", "LeyHitreg.DamageLog", function(ent, hitgroup, dmg, orighitgroup)
    local ret = LeyHitreg:OriginalScaleDamage(ent, hitgroup, dmg, orighitgroup)
    if (ret != nil) then
        return ret
    end
end)

hook.Add("ScaleNPCDamage", "LeyHitreg.DamageLog", function(ent, hitgroup, dmg, orighitgroup)
    local ret = LeyHitreg:OriginalScaleDamage(ent, hitgroup, dmg, orighitgroup)
    if (ret != nil) then
        return ret
    end
end)

LeyHitreg.ScaleDamagePlayersHooks = {}
LeyHitreg.ScaleDamageNPCsHooks = {}

function LeyHitreg:ScaleDamageCorrectly(target, hitgroup, dmg, targetisplayer)
    local atk = dmg:GetAttacker()
    local orighitgroup = hitgroup

    if (IsValid(atk) and atk:IsPlayer()) then
        if (LeyHitreg.ScaleDamageBlockEntity[atk]) then
            LeyHitreg.ScaleDamageBlockEntity[atk] = false
        end

        hitgroup = atk.LeyHitReg_ShouldHit or hitgroup
        atk.LeyHitReg_ShouldHit = nil
    end

    local damageHooks = targetisplayer and self.ScaleDamagePlayersHooks or self.ScaleDamageNPCsHooks

    for k,v in pairs(damageHooks) do
        local ret = v(target, hitgroup, dmg, orighitgroup)

        if (ret != nil) then
            return ret
        end
    end

    if (targetisplayer) then
        local ret = GAMEMODE:OldScalePlayerDamage(target, hitgroup, dmg, orighitgroup)

        if (ret != nil) then
            return ret
        end
    else
        local ret = GAMEMODE:OldScaleNPCDamage(target, hitgroup, dmg, orighitgroup)

        if (ret != nil) then
            return ret
        end
    end
end

function LeyHitreg:ScalePlayerDamage(ply, hitgroup, dmg)
    return LeyHitreg:ScaleDamageCorrectly(ply, hitgroup, dmg, true)
end

function LeyHitreg:ScaleNPCDamage(npc, hitgroup, dmg)
    return LeyHitreg:ScaleDamageCorrectly(npc, hitgroup, dmg, false)
end

function LeyHitreg:AbsorbScaleDamageHooks()
    if (self.Disabled) then
        return
    end

    GAMEMODE.OldScalePlayerDamage = GAMEMODE.OldScalePlayerDamage or GAMEMODE.ScalePlayerDamage
    GAMEMODE.OldScaleNPCDamage = GAMEMODE.OldScaleNPCDamage or GAMEMODE.ScaleNPCDamage

    function GAMEMODE:ScalePlayerDamage(...)
        if (LeyHitreg.Disabled) then
            return self:OldScalePlayerDamage(...)
        end

        local ret = LeyHitreg:ScalePlayerDamage(...)

        if (ret) then
            return ret
        end
    end

    function GAMEMODE:ScaleNPCDamage(...)
        if (LeyHitreg.Disabled) then
            return self:OldScaleNPCDamage(...)
        end

        local ret = LeyHitreg:ScaleNPCDamage(...)

        if (ret) then
            return ret
        end
    end

    local allHooks = hook.GetTable()

    local scalePlayers = allHooks["ScalePlayerDamage"]
    local scaleNPCs = allHooks["ScaleNPCDamage"]

    for k,v in pairs(scalePlayers) do
        hook.Remove("ScalePlayerDamage", k)
        self.ScaleDamagePlayersHooks[k] = v
    end

    for k,v in pairs(scaleNPCs) do
        hook.Remove("ScaleNPCDamage", k)
        self.ScaleDamageNPCsHooks[k] = v
    end
end

timer.Simple(1, function()
    LeyHitreg:AbsorbScaleDamageHooks()
end)

timer.Create("LeyHitreg:AbsorbScaleDamageHooks", 5, 0, function()
    LeyHitreg:AbsorbScaleDamageHooks()
end)