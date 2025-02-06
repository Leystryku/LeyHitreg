-- By just locking onto a specific bone, we don't always get a match. We might lock onto a bone pos
-- and that bone pos just happens to be the center. Then, if we're looking through a edge
-- it's possible that the bullet would miss
-- so how do we fix this? well, hit scanning
-- if a bullet which should hit locked onto a bone pos misses,
-- then attempt to use a more expensive calculation to scan for the precise
-- location which would hit
-- if one is found -> fire bullet again but with that information
-- alternatively, dont fire
-- the calculation is done in bullet cb to make it less expensive
-- because most of the time, just picking the bone pos should work

-- Bullet missed even though it should not have, try hitscan.
-- Luckily we can do this via the HullSize, as  we're in bullet cb here
-- which utilizes TraceHull for bullets if set
LeyHitreg.RefireHullSize = 100
function LeyHitreg:HitScan(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos)
    bullet.HullSize = self.RefireHullSize
    ply:FireBullets(bullet)

    return true
end

local IsValid = IsValid

function LeyHitreg:HitScanBulletCallback(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos, atk, traceres, dmginfo)
    if (bullet.HullSize >= self.RefireHullSize) then
        return
    end

    if (IsValid(traceres.Entity)) then
        return
    end

    return self:HitScan(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos)
end

function LeyHitreg:BulletCallback(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos, oldCallback, ...)
    local cbdata = {...}

    if (cbdata[1] != ply) then
        return oldCallback(...)
    end

    local ignoreBullet = hook.Call("LeyHitreg.OnBulletCallback", cbdata[1], cbdata[2], cbdata[3])

    if (ignoreBullet) then
        return
    end

    if (LeyHitreg.HitScanDisabled) then
        return oldCallback(...)
    end

    if (LeyHitreg:HitScanBulletCallback(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos, cbdata[1], cbdata[2], cbdata[3])) then
        return
    end

    return oldCallback(...)
end

function LeyHitreg:HitScanBullet(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos)
    if (self.BulletOverwriteDisabled) then
        return
    end

    local oldCallback = bullet.Callback or function() end

    bullet.Callback = function(...)
        return self:BulletCallback(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos, oldCallback, ...)
    end
end