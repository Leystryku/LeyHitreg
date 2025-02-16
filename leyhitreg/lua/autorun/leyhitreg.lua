if (SERVER) then
    AddCSLuaFile()
end

print("[/LeyHitreg/] Loading...")
LeyHitreg = LeyHitreg or {}


-- ShotDirForceDisabled allows is for testing with bullet dirs to test how problematic some swep bases are
-- if this alleviates issues, then you need to disable bullet penetration etc in your swep base
LeyHitreg.ShotDirForceDisabled = false
LeyHitreg.DisableSecurityChecks = false
LeyHitreg.IgnoreCanNextPrimaryAttack = true





-- don't touch anything below this. no config. no, leave it. thanks.

LeyHitreg.Disabled = false -- debug: disable addon
LeyHitreg.DisabledOnlyOnClient = false -- debug: disable only on cl
LeyHitreg.NoSpread = false -- debug: enable nospread for everyone
LeyHitreg.ShowActualShotHit = false -- debug: show where the shot actually landed on the sv without spread
LeyHitreg.ShowActualShotSpreadedHit = false -- debug: show where the shot actually landed on the sv with spread
LeyHitreg.BrokenDefaultSpread = false -- debug: enable broken default spread behaviour, broken because its only applied visually now
LeyHitreg.LogHitgroupMismatches = false -- debug: log hitgroup mismatches
LeyHitreg.LogFixedBullets = false -- debug: log the amount of bullets which got hitregged
LeyHitreg.LogInvalidFOV = false -- debug: log invalid FOV
LeyHitreg.LogInvalidShots = false -- debug: log the invalid shots
LeyHitreg.BulletAimbot = false -- debug: set eyeangles to position of bullet
LeyHitreg.LogTargetBone = false -- debug: log target bone
LeyHitreg.HitScanDisabled = false -- debug: disable hitscan within bullet cb
LeyHitreg.BulletOverwriteDisabled = false -- debug: disable hitscan and bullet overwrite
LeyHitreg.AnnounceClientHits = false -- debug: log when the client sends a hit to server
LeyHitreg.DisableLagComp = false -- debug: disable sources original lag compensation

if (LeyHitreg.Disabled) then
    print("[/LeyHitreg/] Disabled")
    return
end

LeyHitreg.svfiles = {
    "leyhitreg/server/bulletprocessing/hitscan.lua",
    "leyhitreg/server/bulletprocessing/processbullet.lua",
    "leyhitreg/server/damageinfo/scaledamagehack.lua",
    "leyhitreg/server/damageinfo/fixscaling.lua",
    "leyhitreg/server/receiveshotinfo/receiveshotinfo.lua",
    "leyhitreg/server/receiveshotinfo/shotvalidator.lua",
}

LeyHitreg.clfiles = {
    "leyhitreg/client/sendshots/sendshots.lua",
    "leyhitreg/client/sendshots/fetchspreads.lua"
}

LeyHitreg.sharedfiles = {
    "leyhitreg/shared/spreadsystem/bulletspread.lua",
    "leyhitreg/shared/spreadsystem/firebullets.lua",
    "leyhitreg/shared/disablelagcomp/disablelagcomp.lua",
    "leyhitreg/shared/workarounds/workarounds.lua",
    "leyhitreg/shared/workarounds/swepbases.lua"
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
