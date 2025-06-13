function IsSpellOffCooldown(spellName)
    local spellInfo = C_Spell.GetSpellCooldown(spellName)
    return spellInfo and spellInfo.startTime == 0 and spellInfo.duration == 0
end

function UnitHasBuff(unit, buffName)
    for i = 1, 40 do
        local buffData = C_UnitAuras.GetBuffDataByIndex(unit, i)
        if not buffData or not buffData.name then break end
        if buffData.name == buffName then
            return buffData
        end
    end
    return nil
end

function IsMoreThanOneEnemyEngaged()
    local count = 0
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitCanAttack("player", unit) and UnitAffectingCombat(unit) then
            count = count + 1
            if count > 1 then
                return true
            end
        end
    end
    return false
end

function IsGlobalCooldownActive()
    local gcdInfo = C_Spell.GetSpellCooldown(61304)
    if not gcdInfo then return false end
    if gcdInfo.duration > 0 and gcdInfo.startTime > 0 then
        local remaining = gcdInfo.startTime + gcdInfo.duration - GetTime()
        return remaining > 0
    end
    return false
end

function HasSpellCharges(spellName, minCharges)
    local charges = C_Spell.GetSpellCharges(spellName)
    return charges and charges.currentCharges >= (minCharges or 1)
end