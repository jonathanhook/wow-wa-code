local trigger =

function ()
    -- global vars
    g_gcd = false
    g_barbedShot = false
    g_multiShot = false
    g_bloodshed = false
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
   
    -- bestial wrath (if off cooldown)
    if IsSpellOffCooldown("Bestial Wrath") then
        g_bestialWrath = true
        return
    end
    
    -- barbed shot (prioritize using Barbed Shot Icon Barbed Shot over Kill Command Icon Kill Command under either of the following conditions)
    if IsSpellOffCooldown("Barbed Shot") and HasSpellCharges("Barbed Shot", 1) then
        -- If Barbed Shot Icon Barbed Shot is at, or close to, 2 charges
        local timeUntilTwoBarbedShotCharges = GetTimeUntilDesiredCharges("Barbed Shot", 2)
        if timeUntilTwoBarbedShotCharges == 0 then
            g_barbedShot = true
            return
        end

        -- If Barbed Shot Icon Barbed Shot is closer to reaching 2 charges than Kill Command Icon Kill Command is
        local timeUntilTwoKillCommandCharges = GetTimeUntilDesiredCharges("Kill Command", 2)
        if timeUntilTwoBarbedShotCharges < timeUntilTwoKillCommandCharges then
            g_barbedShot = true
            return
        end

        -- To refresh the Frenzy Icon Frenzy buff if it is about to fall off
        local buffData = UnitHasBuff("pet", "Frenzy")
        if not buffData or buffData.applications < 3 then
            g_barbedShot = true
            return
        end
    end

    -- multi-shot (if we have enough focus, more than one enemy is engaged and beast cleave is not active)
    if focus >= 40 and IsMoreThanOneEnemyEngaged() and not UnitHasBuff("pet", "Beast Cleave") then
        g_multiShot = true
        return
    end
           
    -- bloodshed (if off cooldown)
    if IsSpellOffCooldown("Bloodshed") then
        g_bloodshed = true
        return
    end

    -- kill command (if we have enough focus and it is off cooldown)
    if focus >= 30 and IsSpellOffCooldown("Kill Command") and HasSpellCharges("Kill Command", 1) then
        g_killCommand = true
        return
    end

    -- second barbed shot
    if IsSpellOffCooldown("Barbed Shot") and HasSpellCharges("Barbed Shot", 1) then
        g_barbedShot = true
        return
    end
    
    -- cobra shot (if no other abilities are available and we have enough focus to cast without blocking next kill command
    if focus >= 65 then
        g_cobraShot = true
        return
    end
end

trigger()