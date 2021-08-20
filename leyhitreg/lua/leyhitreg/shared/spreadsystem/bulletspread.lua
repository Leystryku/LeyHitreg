local Vector = Vector
local mathmodf = math.modf
local mathrandomseed = math.randomseed
local mathrandom = math.random
local mathsqrt = math.sqrt
local isnumber = isnumber
local vector_origin = vector_origin

local timefn = function()
    return os.date("%S")
end

function LeyHitreg:ApplyBulletSpread(ply, dir, spread)
    if (LeyHitreg.NoSpread) then
        return true, dir, vector_origin
    end

    if (not spread or spread == vector_origin or LeyHitreg.BrokenSpread) then
        return false
    end

    if (isnumber(spread)) then
        spread = Vector(spread, spread, spread)
    end

    local add = (8969 * timefn())
    
    mathrandomseed(add)

    local rnda, rndb, rndc = mathrandom(), mathrandom(), mathrandom()


    local appliedSpread = Vector(spread.x * (rnda * 2 - 1), spread.y * (rndb * 2 - 1), spread.z * (rndc * 2 - 1))
    dir = dir + appliedSpread

    return true, dir, appliedSpread
end