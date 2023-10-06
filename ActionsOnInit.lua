------------- SETTINGS ----------------
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")
local AceComm = LibStub:GetLibrary("AceComm-3.0")
local Prefix = "COZ_CD_ASSIGN"

aura_env.sendAssigns = function(data)  
    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    AceComm:SendCommMessage(Prefix, encoded, "RAID", nil)
end

aura_env.AoL = true
aura_env.pewpew = false
aura_env.newAssigns = ""
aura_env.encID = 0
aura_env.abl_tbl = {}
aura_env.counters = {}

---------- ENCOUNTER ID TABLE ---------
aura_env.encounterIds =
{
    [629] = true, -- Northrend Beasts
    [633] = true, -- Lord Jaraxxus
    [637] = true, -- Faction Champions
    [641] = true, -- Val'kyr Twins
    [645] = true, -- Anub'arak  
    
    
    ---------------------
    [742] = true -- Sartharion
}   
---------- BOSS ABILITY TABLE ---------
aura_env.boss_abilities = {
    
    -- Northrend Beasts
    [629] = { 
        SpellCastStart = {
            [66689] = true, -- Arctic Breath -- Icehowl
        },
        SpellCastSuccess = {
            [66901] = true, -- Paralytic Spray -- Acidmaw  
            [66902] = true, -- Burning Spray -- Dreadscale
        },
        SpellAuraAppliedRemoved = { 
            [66406] = true, -- Snobolled! -- Gormok the Impaler
            [66636] = true, -- Rising Anger -- Gormok the Impaler
            [66331] = true, -- Impale -- Gormok - instant cast -
            [66758] = true, -- Staggered Daze -- Icehowl -- DURATION 15 SEC
        },
    },
    
    -- Lord Jaraxxus
    [633] = {
        SpellCastStart = { 
            [66532] = true, -- Fel Fireball -- Interrupt rotation
            --[48785] = true, -- Flash of Light
            --[48782] = true, -- Holy Light
        },
        SpellCastSuccess = {
            [66336] = true, -- Mistress' Kiss -- Lord Jaraxxus
        },
        SpellAuraAppliedRemoved = { 
            [66237] = true, -- Incinerate Flesh  -- Lord Jaraxxus -- 15 sec dura
            [66242] = true, -- Burning Inferno -- Lord Jaraxxus (Failed to outheal Incinerate Flesh 5 sec dura)
        },
    },
    
    -- Faction Champions
    [637] = {
        SpellCastStart = nil,
        SpellCastSuccess = {
            [65947] = true, -- Blade Storm
            [65956] = true, -- Bladeflurry
            [65960] = true, -- Blind
            [65961] = true, -- Cloak of Shadows
            [65957] = true, -- Eviscerate
            [65955] = true, -- Fan of Knives
            [65954] = true, -- Hemorrhage
            [65547] = true, -- PvP Trinket
            [66178] = true, -- Shadowstep
            
        },
        SpellAuraAppliedRemoved = {
            [642] = true, -- Bubble
            [66011] = true, -- Avenging Wrath
            [63408] = true, -- Barkskin
            [66023] = true, -- Icebound Fortitude
            [67801] = true, -- Deterrence
            [65802] = true, -- Ice Block
            [65961] = true, -- Cloak of Shadows
            [65544] = true, -- Dispersion
            [69586] = true, -- Hellfire
            [67541] = true, -- Bladestorm   
            [32182] = true, -- Heroism
            [37472] = true, -- Bloodlust
            [10278] = true, -- Hand of Protection
        },
    },
    
    -- Val'kyr Twins
    [641] = {
        SpellCastStart = { 
            [65876] = true, -- Twin's Pact -- Twins heal ability (Fjola Lightbane)
            [65875] = true, -- Twin's Pact -- Twins heal ability (Eydis Darkbane)
            [66046] = true, -- Light Vortex
            [66058] = true, -- Dark Vortex 
        },
        SpellAuraAppliedRemoved = { 
            [65858] = true, -- Shield of Lights -- Twins absorb shield for heal ability (Fjola Lightbane)
            [65874] = true, -- Shield of Darkness -- Twins absorb shield for heal ability (Eydis Darkbane)
        },
    },
    
    -- Anub'arak
    [645] = {
        
        SpellCastStart = {
            [66134] = true, -- Shadow Strike Burrowers
        },
        SpellCastSuccess = {
            [67574] = true, -- Pursued by Anub'Arak -- BoP after DELAY 
        },
        SpellAuraAppliedRemoved = {       
            [66013] = true, -- Penetrating Cold -- Anub'arak -- 18 sec dura
            [67574] = true, -- Pursued by Anub'Arak -- BoP after DELAY 
            [66118] = true, -- Leeching Swarm - If you want a timer based Cooldown assignment on p3
        },      
    },    
}

---------- SPELL RULES ---------
local PC = 66013 -- Penetrating Cold (Anub'arak)
local LS = 66118 -- LeechingSwarm (Anub'arak)

-- Table to assign all the spells that have special rules to them
aura_env.flaggedSpells = {
    [LS] = true,    
}

-- Setting the flags of the aura_env.flaggedSpells
aura_env.spellFlags = {    
    [LS] = false,  -- Leeching swarm (Anub'arak)    
}

-- Assigning a spell that adheres to the rule of the flagged spells
aura_env.spellRules = {
    [PC] = aura_env.spellFlags[LS]
}

---------------------------------------
-------------- Functions --------------
---------------------------------------

aura_env.handleEvent = function(sourceGUID, spellId)

    -- If it's a flagged spell that meets the condition then we update the flag
    if aura_env.flaggedSpells[spellId] then 
        aura_env.flaggedSpells[spellId] = true 
    end    
    
    -- Check if spellId is in aura_env.spellRules and the corresponding value is not false
    if aura_env.spellRules[spellId] ~= false then
        
        -- Making sure we dont get a nul when checking if the spell should be reset
        if aura_env.resetCounter[spellId] then
            print("CHECKING IF WE SHOULD RESET COUNTER FOR SPELLID: ", spellId)
            
            -- Controlling if the counter of the current spellId is the same as the value assigned to reset the counter            
            if aura_env.counters[spellId] == aura_env.resetCounter[spellId] then
                print("RESETING COUNTER FOR SPELLID: ", spellId)
                -- Reseting the counter
                aura_env.counters[spellId] = 0
            end      
        end      
        
        -- Making sure we don't get a nul error when updating the counter
        if aura_env.counters[spellId] then
            -- Incrementing the counter for this spellId with + 1
            aura_env.counters[spellId] = aura_env.counters[spellId] + 1 
        end
        print("STAGE 8: ", spellId)
        -- Generating the assignmentMessages for this specific spellId at this specific counter value
        local assignmentMessages = aura_env.generateAddonMessage(spellId,aura_env.counters[spellId])
        print("STAGE 9: ", spellId)
        -- Looping thru all the assignments and sending them
        for _, msg in ipairs(assignmentMessages) do
            print("STAGE 10 SENDING MESSAGES!", spellId)
            aura_env.sendAssigns(msg) 
        end
    end    
end



--~~~~~~ SPLIT STRING TO ARRAY ~~~~~~--
local function SplitMSG(msg, d)
    local split_msg = {} 
    for part in msg:gmatch("([^"..d.."]+)") do
        table.insert(split_msg, part)
    end
    return split_msg
end

--~~~~~~ GENERATE THE ADDON MESSAGE ~~~~~~--
aura_env.generateAddonMessage = function(spellId,count)
    local addonMessages = {}      
    for bossSpellId, data in pairs(aura_env.newAssigns) do
        if bossSpellId == spellId then
            local order = data[count]
            if order then
                for _, assigns in ipairs(order) do
                    local assignedPlayer = assigns[1]
                    local spellId = assigns[2]
                    local delay = assigns[3] or 0
                    local amVariant = assigns[4] or 0         
                    local targetName = assigns[5] or ""
                    local customSound = assigns[6] or "default"
                    local msg = assignedPlayer .. ";" .. spellId .. ";" .. delay .. ";" .. amVariant .. ";".. targetName ..";"..customSound
                    table.insert(addonMessages, msg)
                end
            end
        end
    end      
    return addonMessages
end
--~~~~~~~~~~ Import Assignments From Sheet ~~~~~~~~~~~--
aura_env.getImportedAssignments = function()
    
    local rawImport = strtrim(aura_env.config.ImportOptions.assignments, " \"\t\r\n")
    local assignmentsImport = ""
    local countersImport = ""
    local inCounters = false
    
    for line in rawImport:gmatch("[^\r\n]+") do
        if line:match("^%[") then
            inCounters = true
            countersImport = countersImport .. line:sub(2)
        elseif line:match("%]$") then
            inCounters = false
            countersImport = countersImport .. line:sub(1, -2)
        elseif inCounters then
            countersImport = countersImport .. line
        else
            assignmentsImport = assignmentsImport .. line
        end
    end
    
    
    local splitAssignments = SplitMSG(assignmentsImport, ",")
    local splitCounters = SplitMSG(countersImport, ",")
    
    local newAssignments = {}
    local resetCounters = {}
    
    local dataSizeAssigns = 8
    local dataSizeCounters = 2
    
    local numRangesAssigns = math.ceil((#splitAssignments) / dataSizeAssigns)
    local numRangesCounters = math.ceil((#splitCounters) / dataSizeCounters)
    
    if aura_env.config.debug.importController then
        print("|cfffe7a00","[Cozroth's-Sender]:", "|r", "Do the","|cff55d0ff", "BLUE","|r" ,"Numbers Match?")
        print("|cfffe7a00","[Cozroth's-Sender]:", "|r", "Assignments values: ", #splitAssignments, "/", dataSizeAssigns, " = ",
        "|cff55d0ff", #splitAssignments/dataSizeAssigns, "|r", "|","|cff55d0ff", numRangesAssigns,"|r")
        print("|cfffe7a00","[Cozroth's-Sender]:", "|r", "Do the","|cffffee55", "YELLOW", "|r", "Numbers Match?")
        print("|cfffe7a00","[Cozroth's-Sender]:", "|r", "Counter Reset values: ",#splitCounters, "/", dataSizeCounters, " = ",
        "|cffffee55",#splitCounters/dataSizeCounters, "|r", "|","|cffffee55", numRangesCounters, "|r")
        
        if #splitAssignments/dataSizeAssigns == numRangesAssigns and #splitCounters/dataSizeCounters == numRangesCounters then
            print("|cfffe7a00","[Cozroth's-Sender]:", "|r", "|cff77ff55", "Successfully generated Assignments from Imported String","|r")
        else
            print("|cfffe7a00","[Cozroth's-Sender]:", "|r", "|cffff0000", "WARNING!", "|r")
            print("|cfffe7a00","[Cozroth's-Sender]:", "|r","|cffff5555", "Could NOT genereate the Assignments from imported String", "|r")
        end
    end
    
    for i = 1, numRangesAssigns do
        local bossSpellId = tonumber(strtrim(splitAssignments[i * dataSizeAssigns - 7])) or 0
        local order = tonumber(strtrim(splitAssignments[i * dataSizeAssigns - 6])) or 1  
        local player = strtrim(splitAssignments[i * dataSizeAssigns - 5]) or ""
        local spellId = tonumber(strtrim(splitAssignments[i * dataSizeAssigns - 4])) or 0
        local delay = tonumber(strtrim(splitAssignments[i * dataSizeAssigns - 3])) or 1
        local amVariant = tonumber(strtrim(splitAssignments[i * dataSizeAssigns - 2])) or 0
        local targetName = strtrim(splitAssignments[i * dataSizeAssigns - 1]) or ""
        local customSound = strtrim(splitAssignments[i * dataSizeAssigns - 0]) or "default"
        
        local assignment = { player, spellId, delay, amVariant, targetName, customSound }
        
        if not newAssignments[bossSpellId] then
            newAssignments[bossSpellId] = {}
        end
        
        if not newAssignments[bossSpellId][order] then
            newAssignments[bossSpellId][order] = {}
        end
        
        table.insert(newAssignments[bossSpellId][order], assignment)
    end
    
    for i = 1, numRangesCounters do 
        local bossSpellId = tonumber(strtrim(splitCounters[i * dataSizeCounters - 1])) or 0
        local resetCount = tonumber(strtrim(splitCounters[i * dataSizeCounters - 0])) or 0
        
        if not resetCounters[bossSpellId] then
            resetCounters[bossSpellId] = {}
        end
        
        table.insert(resetCounters[bossSpellId], resetCount)
    end
    return newAssignments, resetCounters
end


--[[
Import should look like this

    bossSpellId,order,playerName,cdToUse,delay,amVariant,targetName,customSound

        bossSpellId = the boss ability spell ID
        order = the Order to use the assignments 1 = the first time the boss uses a spell
        playerName = the name of the character being assigned
        cdToUse = spell ID of the assigned CD that the player should use
        delay = delay in seconds when to use the CD (in seconds), default to 1
        amVariant = IF the cdToUse is Aura Mastery, this should be assigned to the spell 
        ID of the AURA to use with Aura Mastery, otherwise 0
        targetNAme = if you have an assignment with a targeted player in mind you can set the name here, default value ""
        customSound = the path to the custom sound. This should be set to default if no custom sound are given!

EXAMPLE WITH NO CUSTOM SOUND:
48785,1,Kozroth,70940,1,0,"",default,
EXAMPLE WITH NO CUSTOM SOUND, WITH TARGETNAME:
48785,2,Kozroth,10278,1,0,"Cozroth",default,
-----------------------------------------

EXAMPLE WITH A CUSTOM SOUND:
48785,2,Kozroth,1766,1,0,"",Interface\Addons\FolderPathToYourSound\sound\Divine Hymn.ogg,
EXAMPLE WITH A CUSTOM SOUND, WITH TARGETNAME:
48782,1,Kozroth,31821,1,19746,"Cozroth",Interface\Addons\FolderPathToYourSound\sound\Aura Mastery.ogg,
-----------------------------------------
--]]
