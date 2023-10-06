-- GROUP_ROSTER_UPDATE
function()
    if (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then
        aura_env.AoL = true
    else
        aura_env.AoL = false
    end
    aura_env.AoL = true
    if aura_env.AoL and not aura_env.pewpew then  
        aura_env.newAssigns, aura_env.resetCounter = aura_env.getImportedAssignments()
        return true    
    end
end
