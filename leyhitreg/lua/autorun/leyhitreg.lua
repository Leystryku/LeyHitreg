if (SERVER) then
    AddCSLuaFile()
end

print("[/LeyHitreg/] Loading...")
LeyHitreg = LeyHitreg or {}

-- don't touch anything. no config. no, leave it. thanks.

LeyHitreg.Disabled = false -- debug: disable addon
LeyHitreg.NoSpread = false -- debug: enable nospread for everyone
LeyHitreg.BrokenDefaultSpread = false -- debug: enable broken default spread behaviour, broken because its only applied visually now
LeyHitreg.LogHitgroupMismatches = false -- debug: log hitgroup mismatches
LeyHitreg.LogFixedBullets = false -- debug: log the amount of bullets which got hitregged
LeyHitreg.BulletAimbot = false -- debug: set eyeangles to position of bullet
LeyHitreg.LogTargetBone = false -- debug: log target bone
LeyHitreg.AnnounceClientHits = false -- debug: log when the client sends a hit to server
LeyHitreg.DisableLagComp = false -- debug: disable sources original lag compensation

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
    "leyhitreg/shared/disablelagcomp/disablelagcomp.lua",
    "leyhitreg/shared/workarounds/workarounds.lua"
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

function LeyHitreg:DisableMoatHitreg()
    if (MOAT_HITREG) then
        MOAT_HITREG.MaxPing = 1
    end

    if (ConVarExists("moat_alt_hitreg")) then
        RunConsoleCommand("moat_alt_hitreg", "0")
    end

    if (SHR) then
        if (SHR.Config) then
            SHR.Config.Enabled = false
            SHR.Config.ClientDefault = 0
        end
        hook.Remove("EntityFireBullets", "SHR.FireBullets")
        hook.Remove("EntityFireBullets", "‍a")
        net.Receivers["shr"] = function() end
    end
end
print("[/LeyHitreg/] Loaded!")
