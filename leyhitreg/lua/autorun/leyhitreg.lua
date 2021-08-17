if (SERVER) then
    AddCSLuaFile()
end

print("[/LeyHitreg/] Loading...")
LeyHitreg = LeyHitreg or {}

LeyHitreg.svfiles = {
    "leyhitreg/server/receiveshotinfo/receiveshotinfo.lua",
    "leyhitreg/server/processbullet/processbullet.lua",
}

LeyHitreg.clfiles = {
    "leyhitreg/client/sendshots/sendshots.lua"
}

local function includeOnCS(filename)
    if (SERVER) then
        print("Uploading: " .. filename)
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
end

LeyHitreg:ProcessLuaFiles()

print("[/LeyHitreg/] Loaded!")
