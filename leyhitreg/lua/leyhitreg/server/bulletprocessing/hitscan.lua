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

--  bullet missed even though it should not have, try hitscan
function LeyHitreg:HitScan(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos)
    -- TODO: do hitscan here
end

local IsValid = IsValid

function LeyHitreg:HitScanBulletCallback(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos, cbdata)
    local traceres = cbdata[2]

    if (IsValid(traceres.Entity)) then
        return
    end

    self:HitScan(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos)
end

function LeyHitreg:HitScanBullet(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos)
    if (self.BulletOverwriteDisabled) then
        return
    end

    local oldCallback = bullet.Callback or function() end

    bullet.Callback = function(...)
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

        if (LeyHitreg:HitScanBulletCallback(ply, target, bullet, shot, targetBone, targetHitGroup, shootpos, cbdata)) then
            return
        end

        return oldCallback(...)
    end
end