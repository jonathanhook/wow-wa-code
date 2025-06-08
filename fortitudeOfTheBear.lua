local trigger = 

function()
    local spellName = "Fortitude of the Bear"
    local spellCooldown = C_Spell.GetSpellCooldown(spellName)
    if spellCooldown ~= 0 then
        return false
    end
    local healthPercent = UnitHealth("player") / UnitHealthMax("player") * 100
    if healthPercent >= 60 then
        return false
    end
    return true
end

trigger()