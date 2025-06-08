local trigger =

function ()
    -- utilty functions
    local function IsOffCooldown(spellname)
        local spellInfo = C_Spell.GetSpellCooldown(spellname)
        return spellInfo.startTime == 0 and spellInfo.duration == 0
    end

    local function PetHasBuff(buffName)
        for i = 1, 40 do
            local buffData = C_UnitAuras.GetBuffDataByIndex("pet", i)
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

    -- global vars
    g_gcd = false
    g_barbedShot = false
    g_multiShot = false
    g_direBeast = false
    g_bestialWrath = false
    --g_callOfTheWild = false
    --g_explosiveShot = false
    g_killCommand = false
    --g_killShot = false
    g_cobraShot = false
    
    -- local vars
    local focus = UnitPower("player", SPELL_POWER_FOCUS)
    
    -- global cooldown
    local gcdInfo = C_Spell.GetSpellCooldown(61304)
    if gcdInfo.duration > 0 and gcdInfo.startTime > 0 then
        local remaining = gcdInfo.startTime + gcdInfo.duration - GetTime()
        if remaining > 0 then
            g_gcd = true
            return
        end
    end
    
    -- bestial wrath
    if IsOffCooldown("Bestial Wrath") then
        g_bestialWrath = true
        return
    end
    
    -- dire beast
    if IsOffCooldown("Dire Beast") then
        g_direBeast = true
        return
    end
    
    -- barbed shot
    local bsCharges = C_Spell.GetSpellCharges("Barbed Shot")
    if bsCharges.currentCharges > 0 then
        local buffData = PetHasBuff("Frenzy")
        if not buffData or buffData.applications < 3 then
            g_barbedShot = true
            return
        end
    end
        
    -- multi-shot
    if focus >= 40 and IsMoreThanOneEnemyEngaged() and not PetHasBuff("Beast Cleave") then
        g_multiShot = true
        return
    end
    
    -- kill command
    if focus >= 30 and IsOffCooldown("Kill Command") then
        g_killCommand = true
        return
    end
    
    -- cobra shot
    if focus >= 65 then
        g_cobraShot = true
        return
    end
end

trigger()

    -- call of the wild
    --if isOffCooldown("Call of the Wild") == 0 then
    --    g_callOfTheWild = true
    --    return
    --end

    -- explosive shot
    --if isOffCooldown("Explosive Shot") then
    --    g_explosiveShot = true
    --    return
    --end

        -- kill shot
    --if focus >= 70 then
    --    local targetHealth = UnitHealth("target")
    --    local targetMaxHealth = UnitHealthMax("target")
    --    
    --    if (targetHealth / targetMaxHealth) < 0.2 then
    --        g_killShot = true
    --        return
    --    end
    --end