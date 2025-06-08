local trigger =

function ()
    -- utilty functions
    local function IsSpellOffCooldown(spellName)
        local spellInfo = C_Spell.GetSpellCooldown(spellName)
        return spellInfo and spellInfo.startTime == 0 and spellInfo.duration == 0
    end

    local function UnitHasBuff(unit, buffName)
        for i = 1, 40 do
            local buffData = C_UnitAuras.GetBuffDataByIndex(unit, i)
            if not buffData or not buffData.name then break end
            if buffData.name == buffName then
                return buffData
            end
        end
        return nil
    end

    local function IsMoreThanOneEnemyEngaged()
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

    local function IsGlobalCooldownActive()
        local gcdInfo = C_Spell.GetSpellCooldown(61304)
        if not gcdInfo then return false end
        if gcdInfo.duration > 0 and gcdInfo.startTime > 0 then
            local remaining = gcdInfo.startTime + gcdInfo.duration - GetTime()
            return remaining > 0
        end
        return false
    end

    local function HasSpellCharges(spellName, minCharges)
        local charges = C_Spell.GetSpellCharges(spellName)
        return charges and charges.currentCharges >= (minCharges or 1)
    end

    -- global vars
    g_gcd = false
    g_barbedShot = false
    g_multiShot = false
    g_direBeast = false
    g_bestialWrath = false
    g_killCommand = false
    g_cobraShot = false
    
    -- focus
    local focus = UnitPower("player", SPELL_POWER_FOCUS)
    
    -- global cooldown
    g_gcd = IsGlobalCooldownActive()
    if g_gcd then
        return
    end

    -- multi-shot (if we have enough focus, more than one enemy is engaged and beast cleave is not active)
    if focus >= 40 and IsMoreThanOneEnemyEngaged() and not UnitHasBuff("pet", "Beast Cleave") then
        g_multiShot = true
        return
    end
    
    -- bestial wrath (if off cooldown)
    if IsSpellOffCooldown("Bestial Wrath") then
        g_bestialWrath = true
        return
    end
    
    -- dire beast (if off cooldown)
    if IsSpellOffCooldown("Dire Beast") then
        g_direBeast = true
        return
    end
    
    -- barbed shot (if the next kill command will not proc Howl of the Pack Leader, we have a charge ready and Frenzy isn't already stacked to 3)
    if not (UnitHasBuff("player", "Howl of the Pack Leader") and focus >= 30) and HasSpellCharges("Barbed Shot", 1) then
        local buffData = UnitHasBuff("pet", "Frenzy")
        if not buffData or buffData.applications < 3 then
            g_barbedShot = true
            return
        end
    end
           
    -- kill command (if we have enough focus and it is off cooldown)
    if focus >= 30 and IsSpellOffCooldown("Kill Command") then
        g_killCommand = true
        return
    end
    
    -- cobra shot (if no other abilities are available and we have enough focus to cast without blocking next kill command
    if focus >= 65 then
        g_cobraShot = true
        return
    end
end

trigger()