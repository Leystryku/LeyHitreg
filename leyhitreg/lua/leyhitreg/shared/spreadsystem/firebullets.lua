function LeyHitreg:SpreadedEntityFireBullets(ply, wep, bullet, spread)
    if (LeyHitreg.Disabled) then
        return
    end

    if (LeyHitreg.BrokenDefaultSpread) then
        return
    end

    local bulletSpread = spread or LeyHitreg:GetWeaponSpread(ply, wep, bullet)
    local appliedAny, newDir = self:ApplyBulletSpread(ply, bullet.Dir, bulletSpread)

    if (not appliedAny) then
        return
    end

    bullet.Spread = vector_origin
    bullet.Dir = newDir
    return true
end
