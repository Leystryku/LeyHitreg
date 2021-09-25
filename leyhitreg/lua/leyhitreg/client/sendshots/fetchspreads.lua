LeyHitreg.WeaponSpreads = {}

function LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep) 
    if (not IsValid(newWep)) then
        return
    end

    local classname = newWep:GetClass()

    if (not classname or self.WeaponSpreads[classname]) then
        return
    end

    local classname = newWep:GetClass()

    if (self:IsIgnoreWep(newWep)) then
        self.WeaponSpreads[classname] = vector_origin
        return
    end

    ply.LeyHitreg_NeedsSpreadForce = newWep

    timer.Simple(0.1, function()
        if (not IsValid(ply)) then
            return
        end

        ply.LeyHitreg_NeedsSpreadForce = nil

        if (ply:GetActiveWeapon() != newWep) then
            return
        end

        LeyHitreg.WeaponSpreads[classname] = LeyHitreg.WeaponSpreads[classname] or vector_origin
    end)

    newWep:SetClip1(9999)

    if (newWep.PrimaryAttack) then
        newWep:PrimaryAttack()
    elseif (newWep.Primary and newWep.Primary.Attack) then
        newWep.Primary.Attack()
    end
end

hook.Add("PlayerSwitchWeapon", "LeyHitreg:PlayerSwitchWeapon", function(...)
    LeyHitreg:PlayerSwitchWeapon(...)
end)


function LeyHitreg:EntityEmitSoundSpreadPrefire(data)
    if (not data) then
        return
    end

    local ent = data.Entity

    if (not IsValid(ent)) then
        return
    end


    if (ent:IsPlayer()) then
        if (ent.LeyHitreg_NeedsSpreadForce) then
            return false
        end
        local wep = ent:GetActiveWeapon()
        
        if (not IsValid(wep)) then
            return
        end

        if (wep.LeyHitreg_NeedsSpreadForce) then
            return false
        end

        return
    end

    if (not ent:IsWeapon()) then
        return
    end

    local ply = ent:GetOwner()

    if (IsValid(ply) and ply:IsPlayer() and ply.LeyHitreg_NeedsSpreadForce) then
        return false
    end
    
    if (ent.LeyHitreg_NeedsSpreadForce) then
        return false
    end
end

hook.Add("EntityEmitSound", "LeyHitreg:EntityEmitSoundSpreadPrefire", function(data)
    local ret = LeyHitreg:EntityEmitSoundSpreadPrefire(data)

    if (ret != nil) then
        return ret
    end
end)
