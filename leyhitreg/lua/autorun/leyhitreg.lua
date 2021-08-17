if (SERVER) then
    AddCSLuaFile()
end

print("[/LeyHitreg/] Loading...")
LeyHitreg = LeyHitreg or {}
LeyHitreg.Disabled = false

LeyHitreg.svfiles = {
    "leyhitreg/server/receiveshotinfo/receiveshotinfo.lua",
    "leyhitreg/server/processbullet/processbullet.lua",
    "leyhitreg/server/damageinfo/scaledamagehack.lua",
    "leyhitreg/server/damageinfo/fixscaling.lua",
}

LeyHitreg.clfiles = {
    "leyhitreg/client/sendshots/sendshots.lua",
    "leyhitreg/client/spreadsystem/bulletspread.lua"
}

LeyHitreg.sharedfiles = {
    "leyhitreg/shared/disablelagcomp/disablelagcomp.lua"
}

local function includeOnCS(filename)
    if (SERVER) then
        print("Sending to clients: " .. filename)
        AddCSLuaFile(filename)
    end

    if (CLIENT) then
        include(filename)
    end
end

local function includeOnSV(filename)
    if (SERVER) then
        print("Loading: " .. filename)
        include(filename)
    end
end

function LeyHitreg:ProcessLuaFiles()
    for k,v in pairs(LeyHitreg.clfiles) do
        includeOnCS(v)
    end

    for k,v in pairs(LeyHitreg.svfiles) do
        includeOnSV(v)
    end

    for k,v in pairs(LeyHitreg.sharedfiles) do
        includeOnCS(v)
        includeOnSV(v)
    end
end

LeyHitreg:ProcessLuaFiles()

print("[/LeyHitreg/] Loaded!")
