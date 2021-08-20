-- just ideas to make aimbot using this harder

-- if the angle which client supposedly used to hit target is more than 70 degrees off of the target
-- chances are it's not a information mismatch but a manipulation attempt

local MaxFOVDiffDeg = 90
local MaxFOVDiffRad = math.rad(MaxFOVDiffDeg)
local mathacos = math.acos
local mathdeg = math.deg

function LeyHitreg:IsInvalidShotOutOfFOV(plyang, plypos, tarpos)
    local targetdir = (tarpos - plypos)
    local curdir = plyang:Forward()
    local FOVDiff = mathacos(targetdir:Dot(curdir) / (targetdir:Length() * curdir:Length()))

    return FOVDiff > MaxFOVDiffRad
end

-- if the weapon has spread, and the client did not apply any spread, then reject the bullet
-- this requires the unmodified va to be sent together in the usercmd somehow
-- then can compare the two and if equal, yeet
function LeyHitreg:IsSpreadNotApplied(ply, cmd, wep, shouldPrimary)
    if (self.NoSpread) then
        return false
    end

    return false
end

local disableSecurityChecks = false -- this is here instead of in the main startup file to avoid stupid people from doing stupid things
local FOVCheckDist = 700 * 700
function LeyHitreg:IsInvalidShot(ply, cmd, wep, shouldPrimary, target, targetBone)
    if (not target or disableSecurityChecks) then
        return
    end

    local plyang = cmd:GetViewAngles()
    local plypos = ply:GetPos()
    local tarpos = target:GetPos()

    if (plypos:DistToSqr(tarpos) > FOVCheckDist) then
        if (self:IsInvalidShotOutOfFOV(plyang, plypos, tarpos)) then
            return false
        end
    end

    if (self:IsSpreadNotApplied(ply, cmd, wep, shouldPrimary)) then
        return false
    end

    return true
end