local trigger =

function ()
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
    aura_env.gcd = aura_env.IsGlobalCooldownActive()
    if g_gcd then
        return
    end
   
    -- bestial wrath (if off cooldown)
    if aura_env.IsSpellOffCooldown("Bestial Wrath") then
        g_bestialWrath = true
        return
    end
    
    -- dire beast (if off cooldown)
    if aura_env.IsSpellOffCooldown("Dire Beast") then
        g_direBeast = true
        return
    end

    -- barbed shot (if the next kill command will not proc Howl of the Pack Leader, we have a charge ready and Frenzy isn't already stacked to 3)
    if not (aura_env.UnitHasBuff("player", "Howl of the Pack Leader") and focus >= 30) and aura_env.HasSpellCharges("Barbed Shot", 1) then
        local buffData = aura_env.UnitHasBuff("pet", "Frenzy")
        if not buffData or buffData.applications < 3 then
            g_barbedShot = true
            return
        end
    end

    -- multi-shot (if we have enough focus, more than one enemy is engaged and beast cleave is not active)
    if focus >= 40 and aura_env.IsMoreThanOneEnemyEngaged() and not aura_env.UnitHasBuff("pet", "Beast Cleave") then
        g_multiShot = true
        return
    end
           
    -- kill command (if we have enough focus and it is off cooldown)
    if focus >= 30 and aura_env.IsSpellOffCooldown("Kill Command") then
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