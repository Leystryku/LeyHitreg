local Vector = Vector
local mathmodf = math.modf
local mathrandomseed = math.randomseed
local mathrandom = math.random
local mathsqrt = math.sqrt
local isnumber = isnumber
local vector_origin = vector_origin

local timefn = function()
    return 1 -- os.date("%S")
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

	mathrandomseed(add + CurTime())

	local ang = dir:Angle()

	local appliedSpread, rgt, up = Vector(), ang:Right(), ang:Up()

	local x, y, z

	repeat
		x = mathrandom() + mathrandom() - 1
		y = mathrandom() + mathrandom() - 1

		z = x * x + y * y
	until z <= 1

	for i = 1, 3 do
		appliedSpread[i] = x * spread.x * rgt[i] + y * spread.y * up[i]
	end

	dir = dir + appliedSpread

	return true, dir, appliedSpread
end
