local meta = FindMetaTable("CTakeDamageInfo")

LeyHitreg.ScaleDamageBlockEntity = LeyHitreg.ScaleDamageBlockEntity or {}
meta.OldScaleDamage = meta.OldScaleDamage or meta.ScaleDamage

function meta:ScaleDamage(scale)
    if (self:IsBulletDamage() and LeyHitreg and LeyHitreg.ScaleDamageBlockEntity[self:GetAttacker()]) then
        return
    end

    return self:OldScaleDamage(scale)
end