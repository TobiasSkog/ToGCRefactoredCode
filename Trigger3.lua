--ENCOUNTER_END
function(event, encounterId, encounterName, difficultyID, groupSize, success)
    if not aura_env.AoL and not aura_env.pewpew then return false end
    if not type(aura_env.newAssigns) == "table" then return false end    
    if event == "ENCOUNTER_END" then        
        aura_env.pewpew = false
        wipe(aura_env.counters)        
        return true
    end
end
