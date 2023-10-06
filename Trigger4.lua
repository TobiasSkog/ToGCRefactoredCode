--CLEU:SPELL_CAST_START:SPELL_CAST_SUCCESS:SPELL_AURA_APPLIED:SPELL_AURA_APPLIED_DOSE:SPELL_AURA_REMOVED:SPELL_AURA_REMOVED_DOSE:SPELL_AURA_REFRESH:SPELL_SUMMON UNIT_HEALTH
function(event,_,subEvent,_, sourceGUID, sourceName, _, _, destGUID, destName, _, _,spellId, spellName,...)
    if not aura_env.AoL and not aura_env.pewpew then return false end
    if not type(aura_env.newAssigns) == "table" then return false end
    
    if subEvent == "SPELL_CAST_START" then
        if (aura_env.abl_tbl.SpellCastStart and aura_env.abl_tbl.SpellCastStart[spellId]) then
            aura_env.handleEvent(sourceGUID, spellId)
            return true
        end
    end ------v ADD EVENTS HERE v---------
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        if (aura_env.abl_tbl.SpellCastSuccess and aura_env.abl_tbl.SpellCastSuccess[spellId]) then
            aura_env.handleEvent(sourceGUID, spellId)
            return true
        end            
    end ------v ADD EVENTS HERE v---------
  
    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_APPLIED_DOSE" or subEvent == "SPELL_AURA_REFRESH" then
        if (aura_env.abl_tbl.SpellAuraAppliedRemoved and aura_env.abl_tbl.SpellAuraAppliedRemoved[spellId]) then            
            aura_env.handleEvent(sourceGUID, spellId)
            return true
        end
    end ------v ADD EVENTS HERE v---------

      if subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REMOVED_DOSE" then
        if (aura_env.abl_tbl.SpellAuraAppliedRemoved and aura_env.abl_tbl.SpellAuraAppliedRemoved[spellId]) then            
            aura_env.handleEvent(sourceGUID, spellId)
            return true
        end
    end ------v ADD EVENTS HERE v---------

      if subEvent == "SPELL_SUMMON" then
        if (aura_env.abl_tbl.SpellSummon and aura_env.abl_tbl.SpellSummon[spellId]) then            
            aura_env.handleEvent(sourceGUID, spellId)
            return true
        end
    end ------v ADD EVENTS HERE v---------
end
