--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, HR = ...;
  -- HeroLib
  local HL = HeroLib;
  local HR = HeroRotation;
  local Cache = HeroCache;
  local Unit = HL.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = HL.Spell;
  local Item = HL.Item;
  -- Lua
  
  -- File Locals
  


--- ============================ CONTENT ============================
--- ======= NON-COMBATLOG =======
  -- OnSpecChange
  local SpecTimer = 0;
  HL:RegisterForEvent(
    function (Event)
      -- Prevent the first event firing (when login)
      if not HL.PulseInitialized then return; end
      -- Timer to prevent bug due to the double/triple event firing.
      -- Since it takes 5s to change spec, we'll take 3seconds as timer.
      if HL.GetTime() > SpecTimer then
        -- Update the timer only on valid scan.
        if HR.PulseInit() ~= "Invalid SpecID" then
          SpecTimer = HL.GetTime() + 3;
        end
      end
    end
    , "PLAYER_SPECIALIZATION_CHANGED"
  );

--- ======= COMBATLOG =======
  --- Combat Log Arguments
    ------- Base -------
      --     1        2         3           4           5           6              7             8         9        10           11
      -- TimeStamp, Event, HideCaster, SourceGUID, SourceName, SourceFlags, SourceRaidFlags, DestGUID, DestName, DestFlags, DestRaidFlags

    ------- Prefixes -------
      --- SWING
      -- N/A

      --- SPELL & SPELL_PACIODIC
      --    12        13          14
      -- SpellID, SpellName, SpellSchool

    ------- Suffixes -------
      --- _CAST_START & _CAST_SUCCESS & _SUMMON & _RESURRECT
      -- N/A

      --- _CAST_FAILED
      --     15
      -- FailedType

      --- _AURA_APPLIED & _AURA_REMOVED & _AURA_REFRESH
      --    15
      -- AuraType

      --- _AURA_APPLIED_DOSE
      --    15       16
      -- AuraType, Charges

      --- _INTERRUPT
      --      15            16             17
      -- ExtraSpellID, ExtraSpellName, ExtraSchool

      --- _HEAL
      --   15         16         17        18
      -- Amount, Overhealing, Absorbed, Critical

      --- _DAMAGE
      --   15       16       17       18        19       20        21        22        23
      -- Amount, Overkill, School, Resisted, Blocked, Absorbed, Critical, Glancing, Crushing

      --- _MISSED
      --    15        16           17
      -- MissType, IsOffHand, AmountMissed

    ------- Special -------
      --- UNIT_DIED, UNIT_DESTROYED
      -- N/A

  --- End Combat Log Arguments

  -- Arguments Variables
  
    --------------------------
    ----- Shadow --------
    --------------------------
    HL:RegisterForSelfCombatEvent(
      function (...)
        DestGUID, _, _, _, SpellID = select(8, ...);
		
		if SpellID == 228260 then --void erruption
			-- print("reset")
			HL.VTTime = 0
			HL.VTApplied = 0
		end

      end
      , "SPELL_CAST_SUCCESS"
    );
	
	HL:RegisterForSelfCombatEvent(
      function (...)
		dateEvent,_,_,_,_,_,_,DestGUID,_,_,_, SpellID = select(1,...);
		if SpellID == 205065 and HL.VTApplied == 0 and Player:GUID() == DestGUID then --void erruption
			HL.VTApplied = dateEvent
			-- print("applied : "..HL.VTApplied)
		end

      end
      , "SPELL_AURA_APPLIED"
    );
	
	HL:RegisterForSelfCombatEvent(
      function (...)
		dateEvent,_,_,_,_,_,_,DestGUID,_,_,_, SpellID = select(1,...);
		if SpellID == 205065 and Player:GUID() == DestGUID then --void erruption
			HL.VTTime = dateEvent - HL.VTApplied
			-- print("time : "..HL.VTTime)
		end

      end
      , "SPELL_AURA_REMOVED"
    );
	
    
