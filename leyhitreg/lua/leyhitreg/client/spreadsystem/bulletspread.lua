local Vector = Vector
local mathmodf = math.modf
local mathrandomseed = math.randomseed
local mathrandom = math.random
local mathsqrt = math.sqrt
local isnumber = isnumber
local vector_origin = vector_origin

-- yes, this spread system is only temporary

local timefn = function()
    return os.date("%S")
end

function LeyHitreg:ApplyBulletSpread(ply, dir, spread)
    if (not spread or spread == vector_origin or LeyHitreg.NoSpread) then
        return false
    end

    if (isnumber(spread)) then
        spread = Vector(spread, spread, 0)
    end

    local _, fractional = mathmodf(timefn())
    local add = (8969 * fractional)

    mathrandomseed(add + mathsqrt(dir.x ^ 2 * dir.y ^ 2 * dir.z ^ 2))

    local appliedSpread = Vector(spread.x * (mathrandom() * 2 - 1), spread.y * (mathrandom() * 2 - 1), 0)
    dir = dir + appliedSpread

    return true, dir, appliedSpread
end