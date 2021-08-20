-- just ideas to make aimbot using this harder

-- if the angle which client supposedly used to hit target is more than MaxFOVDiffDeg degrees off of the target
-- chances are it's not a information mismatch but a manipulation attempt

local mathacos = math.acos
local mathdeg = math.deg

local FOVCheckCloseDist = 350 * 350
local FOVCheckFarDist = 700 * 700

local MaxCloseFOVDiffDeg = 90
local MaxFarFOVDiffDeg = 40

local MaxCloseFOVDiffRad = math.rad(MaxCloseFOVDiffDeg)
local MaxFarFOVDiffRad = math.rad(MaxFarFOVDiffDeg)


function LeyHitreg:IsInvalidShotOutOfFOV(ply, plyang, plypos, tarpos, distsqr)
    if (distsqr < FOVCheckCloseDist) then
        if (self.LogInvalidFOV) then
            ply:ChatPrint("FOV: Close, so no checking")
        end

        return false
    end

    local maxRad = distsqr > FOVCheckFarDist and MaxFarFOVDiffRad or MaxCloseFOVDiffRad

    local targetdir = (tarpos - plypos)
    local curdir = plyang:Forward()
    local FOVDiff = mathacos(targetdir:Dot(curdir) / (targetdir:Length() * curdir:Length()))

    if (self.LogInvalidFOV) then
        ply:ChatPrint("FOV: " .. tostring(mathdeg(FOVDiff)) .. " Max: " .. tostring(mathdeg(maxRad)))
    end

    return FOVDiff > maxRad
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
function LeyHitreg:IsInvalidShot(ply, cmd, wep, shouldPrimary, target, targetBone)
    if (disableSecurityChecks) then
        return
    end

    local plyang = cmd:GetViewAngles()
    local plypos = ply:GetPos()
    local tarpos = target:GetPos()
    local distsqr = plypos:DistToSqr(tarpos)

    if (self:IsInvalidShotOutOfFOV(ply, plyang, plypos, tarpos, distsqr)) then
        return true
    end

    if (self:IsSpreadNotApplied(ply, cmd, wep, shouldPrimary)) then
        return true
    end

    return false
end