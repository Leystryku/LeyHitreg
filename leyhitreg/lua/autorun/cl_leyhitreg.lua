if(SERVER) then
	AddCSLuaFile()
	return
end

local option_customnetmsg = "6ffce390e17b9f5849cfd8b887fac20a3cdc24cedbccb4b48326b18d079dd693"

LeyHitreg = LeyHitreg or {}

local shotsthistime = 0

function LeyHitreg.EntityFireBullets( ent, data )

	if(not IsValid(ent) or ent != LocalPlayer() or not IsFirstTimePredicted()) then return end

	if(data.Num != 1) then return end -- more than 1 bullet n shit like that, shotguns dont need this

	local primaryfire = input.IsMouseDown(MOUSE_LEFT)

	if(not input.IsMouseDown(MOUSE_LEFT) and not input.IsMouseDown(MOUSE_RIGHT)) then
		primaryfire = true
		--return
	end

	local usingwep = ent:GetActiveWeapon()
	local spread = data.Spread
	
	data.Spread = Vector(0,0,0)

	if(LeyHitreg.lasttbl) then

		local mismatch = false

		if(LeyHitreg.lastwep!=usingwep) then
			mismatch = true
			--print("wrong wep")
		end

		if(not mismatch) then
			for k,v in pairs(LeyHitreg.lasttbl) do
				if(v == data[k]) then continue end
				if(k=="Callback") then continue end
				
				mismatch = true
				break
			end
		end


		if(not mismatch) then
			if(primaryfire and usingwep.Primary and  usingwep.Primary.Delay and CurTime() > usingwep.Primary.Delay + LeyHitreg.lastsendtime) then
				mismatch = true
			end

			if(not primaryfire and usingwep.Secondary and usingwep.Secondary.Delay and CurTime() > usingwep.Secondary.Delay + LeyHitreg.lastsendtime) then
				mismatch = true
			end

		end

		if(not mismatch) then
			--print("the same")
			return false
		end
	end

	if(CurTime() == ent.lasthittime) then
		shotsthistime = shotsthistime + 1
	else
		shotsthistime = 0
	end

	LeyHitreg.lastsendtime = CurTime()
	LeyHitreg.lasttbl = table.Copy(data)
	LeyHitreg.lastwep = usingwep

	math.randomseed( CurTime() + shotsthistime )
	
	local ang = data.Dir:GetNormalized():Angle()
	
	ang:RotateAroundAxis( ang:Up( ), spread.x * (math.random() * 2 - 1) * 40 )
	ang:RotateAroundAxis( ang:Right( ), spread.y * (math.random() * 2 - 1) * 40 )
	
	data.Dir = ang:Forward()
	

	--if(CurTime() == ent.lasthittime) then return true end


	ent.lasthittime = CurTime()


	local bulletsrc = data.Src
	local bulletdir = data.Dir


	local trtbl = {}
	
	trtbl.start = bulletsrc
	trtbl.endpos = trtbl.start + (bulletdir * (56756 * 8))
	trtbl.filter = LocalPlayer()
	trtbl.mask = MASK_SHOT
	
	local blocksend = false

	local trace = util.TraceLine(trtbl)

	if(not IsValid(trace.Entity)) then
		trtbl.start = bulletsrc
		trtbl.endpos = trtbl.start + (bulletdir * (56756 * 8))
		trace = util.TraceLine(trtbl)
		
		if(not IsValid(trace.Entity)) then blocksend = true end

	end

	local hitpos = trace.HitPos
	local hitent = trace.Entity
	local hitboxhit = trace.HitGroup


	if(IsValid(usingwep)) then

		if(primaryfire) then
			--if(usingwep.lhb_nextprimaryfire and usingwep.lhb_nextprimaryfire > CurTime()) then return end

			if(usingwep.Primary and usingwep.Primary.Delay) then
				usingwep.lhb_nextprimaryfire = CurTime() + usingwep.Primary.Delay
			end
		else
			--if(usingwep.lhb_nextsecondaryfire and usingwep.lhb_nextsecondaryfire > CurTime()) then return end

			if(usingwep.Secondary and usingwep.Secondary.Delay) then
				usingwep.lhb_nextsecondaryfire = CurTime() + usingwep.Secondary.Delay
			end
		end

	end


	--print(blocksend)
	if(not blocksend) then
		net.Start(option_customnetmsg)
			net.WriteUInt(1,8)
			net.WriteBool(primaryfire)
			net.WriteEntity(usingwep)
			net.WriteEntity(hitent)

			net.WriteVector(bulletsrc)
			net.WriteVector(bulletdir)

				net.WriteVector(hitpos)
				net.WriteUInt(hitboxhit, 8)
				net.WriteUInt(CurTime(), 32)
			net.SendToServer()
			
		return true
	end
end

hook.Add("EntityFireBullets", "LeyHitreg.EntityFireBullets", LeyHitreg.EntityFireBullets)