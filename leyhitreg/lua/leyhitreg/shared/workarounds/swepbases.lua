
function LeyHitreg:ConVarSet(name, val)
    if (GetConVar(name)) then
        RunConsoleCommand(name, val)
    end
end

function LeyHitreg:SWEPConvars()
    self:ConVarSet("arccw_enable_penetration", "0")
    self:ConVarSet("sv_tfa_bullet_penetration", "0")
    self:ConVarSet("sv_tfa_bullet_randomseed", "0")
end

timer.Simple(1, function()
    LeyHitreg:SWEPConvars()
end)