LeyHitreg.WeaponSpreads = {}

local vector_origin = vector_origin

function LeyHitreg:PlayerSwitchWeapon(ply, oldWep, newWep) 
    if (not IsValid(newWep)) then
        return
    end

    local classname = newWep:GetClass()

    if (not classname or self.WeaponSpreads[classname]) then
        return
    end

    if (self:IsIgnoreWep(newWep)) then
        self.WeaponSpreads[classname] = vector_origin
        return
    end

    ply.LeyHitreg_NeedsSpreadForce = newWep

    timer.Simple(1, function() 
        if (not IsValid(ply) or not IsValid(newWep)) then
            return
        end

        ply.LeyHitreg_NeedsSpreadForce = nil

        if (ply:GetActiveWeapon() != newWep) then
            return
        end

        LeyHitreg.WeaponSpreads[classname] = LeyHitreg.WeaponSpreads[classname] or vector_origin
    end)

    LeyHitreg:SetFittingValidClip(newWep)

    if (newWep.PrimaryAttack) then
        newWep:PrimaryAttack()
    elseif (newWep.Primary and newWep.Primary.Attack) then
        newWep.Primary.Attack()
    end
end

hook.Add("PlayerSwitchWeapon", "LeyHitreg:PlayerSwitchWeapon", function(...)
    -- process switch at next frame so FireBullets uses proper wep
    local t = {...}

    timer.Simple(0, function()
        LeyHitreg:PlayerSwitchWeapon(unpack(t))
    end)
end)

function LeyHitreg:FetchSpreadFireBullets(ply, wep, bullet)
    local spreadForceWep = ply.LeyHitreg_NeedsSpreadForce
    local validSpreadForceWep = spreadForceWep != nil and IsValid(spreadForceWep)

    -- if (validSpreadForceWep) then
    --    wep = spreadForceWep
    -- end

    local weaponSpread = LeyHitreg:GetWeaponSpread(ply, wep, bullet)
    self.WeaponSpreads[wep:GetClass()] = weaponSpread

    if (validSpreadForceWep and wep == spreadForceWep) then
        bullet.Damage = 1
        bullet.Distance = 1
        bullet.Src = Vector(-100000, -10000, -10000)
        bullet.Dir = vector_origin
 
        timer.Simple(0, function()
            if (not IsValid(ply)) then
                return
            end

            if (ply.LeyHitreg_NeedsSpreadForce == wep) then
                ply.LeyHitreg_NeedsSpreadForce = nil
            end
        end)

        return bullet
    end
end

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