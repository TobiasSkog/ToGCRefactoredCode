--ENCOUNTER_START
function(event, encounterId, encounterName, difficultyID, groupSize, instanceID) 
    if not aura_env.AoL and not aura_env.pewpew then return false end
    if not type(aura_env.newAssigns) == "table" then return false end
    if event == "ENCOUNTER_START" then
        if aura_env.encounterIds[encounterId] then 
            aura_env.pewpew = true -- lets pewpew!!
            aura_env.encID = encounterId
            -------------------- Encounter Accepted --------------------         
            ------ Find the spell IDs to track for this Encounter ------
            aura_env.abl_tbl = aura_env.boss_abilities[encounterId]        
            local spellIds = {
                SpellCastStart = aura_env.abl_tbl.SpellCastStart,
                SpellCastSuccess = aura_env.abl_tbl.SpellCastSuccess,
                SpellAuraAppliedRemoved = aura_env.abl_tbl.SpellAuraAppliedRemoved,
                SpellSummon = aura_env.abl_tbl.SpellSummon,
            }
            for spellType, spellIdTable in pairs(spellIds) do
                if spellIdTable then
                    for bossSpellId in pairs(spellIdTable) do
                        --------- Create Counters for each bossSpellId ---------
                        if not aura_env.counters[bossSpellId] then
                            aura_env.counters[bossSpellId] = 0
                        end
                    end
                end
            end
            return true
        end
    end
end



