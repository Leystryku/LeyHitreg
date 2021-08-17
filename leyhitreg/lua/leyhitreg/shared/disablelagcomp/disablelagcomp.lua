local meta = FindMetaTable("Player")
meta.OldLagCompensation = meta.OldLagCompensation or meta.LagCompensation

function meta:LagCompensation(...)
    if (LeyHitreg.DisableLagComp and not LeyHitreg.Disabled) then
        return
    end

    return self:OldLagCompensation(...)
end