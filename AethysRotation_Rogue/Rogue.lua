--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, addonTable = ...;
  -- AethysCore
  local AC = AethysCore;
  local Cache = AethysCache;
  local Unit = AC.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local MouseOver = Unit.MouseOver;
  local Spell = AC.Spell;
  local Item = AC.Item;
  -- AethysRotation
  local AR = AethysRotation;
  -- Lua
  local mathmin = math.min;
  local pairs = pairs;
  -- File Locals
  local Commons = {};
  AR.Commons.Rogue = Commons;
  local Settings = AR.GUISettings.APL.Rogue.Commons;
  local Everyone = AR.Commons.Everyone;

--- ============================ CONTENT ============================
  -- Stealth
  function Commons.Stealth (Stealth, Setting)
    if Settings.StealthOOC and Stealth:IsCastable() and not Player:IsStealthed() then
      if AR.Cast(Stealth, Settings.OffGCDasOffGCD.Stealth) then return "Cast Stealth (OOC)"; end
    end
    return false;
  end

  -- Crimson Vial
  function Commons.CrimsonVial (CrimsonVial)
    if CrimsonVial:IsCastable() and Player:HealthPercentage() <= Settings.CrimsonVialHP then
      if AR.Cast(CrimsonVial, Settings.GCDasOffGCD.CrimsonVial) then return "Cast Crimson Vial (Defensives)"; end
    end
    return false;
  end

  -- Feint
  function Commons.Feint (Feint)
    if Feint:IsCastable() and not Player:Buff(Feint) and Player:HealthPercentage() <= Settings.FeintHP then
      if AR.Cast(Feint, Settings.GCDasOffGCD.Feint) then return "Cast Feint (Defensives)"; end
    end
  end

  -- Marked for Death Sniping
  local BestUnit, BestUnitTTD;
  function Commons.MfDSniping (MarkedforDeath)
    if MarkedforDeath:IsCastable() then
      -- Get Units up to 30y for MfD.
      AC.GetEnemies(30);

      BestUnit, BestUnitTTD = nil, 60;
      local MOTTD = MouseOver:IsInRange(30) and MouseOver:TimeToDie() or 11111;
      local TTD;
      for _, Unit in pairs(Cache.Enemies[30]) do
        TTD = Unit:TimeToDie();
        -- Note: Increased the SimC condition by 50% since we are slower.
        if not Unit:IsMfdBlacklisted() and TTD < Player:ComboPointsDeficit()*1.5 and TTD < BestUnitTTD then
          if MOTTD - TTD > 1 then
            BestUnit, BestUnitTTD = Unit, TTD;
          else
            BestUnit, BestUnitTTD = MouseOver, MOTTD;
          end
        end
      end
      if BestUnit then
        AR.CastLeftNameplate(BestUnit, MarkedforDeath);
      end
    end
  end

  -- Everyone CanDotUnit override to account for Mantle
  -- Is it worth to DoT the unit ?
  function Commons.CanDoTUnit (Unit, HealthThreshold)
    return Everyone.CanDoTUnit(Unit, HealthThreshold*(Commons.MantleDuration() > 0 and Settings.EDMGMantleOffset or 1));
  end
--- ======= SIMC CUSTOM FUNCTION / EXPRESSION =======
  -- cp_max_spend
  function Commons.CPMaxSpend ()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return Spell.Rogue.Subtlety.DeeperStratagem:IsAvailable() and 6 or 5;
  end

  -- "cp_spend"
  function Commons.CPSpend ()
    return mathmin(Player:ComboPoints(), Commons.CPMaxSpend());
  end

  -- poisoned
  --[[ Original SimC Code
    return dots.deadly_poison -> is_ticking() ||
            debuffs.wound_poison -> check();
  ]]
  function Commons.Poisoned (Unit)
    return (Unit:Debuff(Spell.Rogue.Assassination.DeadlyPoisonDebuff) or Unit:Debuff(Spell.Rogue.Assassination.WoundPoisonDebuff)) and true or false;
  end

  -- poison_remains
  --[[ Original SimC Code
    if ( dots.deadly_poison -> is_ticking() ) {
      return dots.deadly_poison -> remains();
    } else if ( debuffs.wound_poison -> check() ) {
      return debuffs.wound_poison -> remains();
    } else {
      return timespan_t::from_seconds( 0.0 );
    }
  ]]
  function Commons.PoisonRemains (Unit)
    return (Unit:Debuff(Spell.Rogue.Assassination.DeadlyPoisonDebuff) and Unit:DebuffRemainsP(Spell.Rogue.Assassination.DeadlyPoisonDebuff))
      or (Unit:Debuff(Spell.Rogue.Assassination.WoundPoisonDebuff) and Unit:DebuffRemainsP(Spell.Rogue.Assassination.WoundPoisonDebuff))
      or 0;
  end

  -- bleeds
  --[[ Original SimC Code
    rogue_td_t* tdata = get_target_data( target );
    return tdata -> dots.garrote -> is_ticking() +
           tdata -> dots.internal_bleeding -> is_ticking() +
           tdata -> dots.rupture -> is_ticking();
  ]]
  function Commons.Bleeds ()
    return (Target:Debuff(Spell.Rogue.Assassination.Garrote) and 1 or 0) + (Target:Debuff(Spell.Rogue.Assassination.Rupture) and 1 or 0) + (Target:Debuff(Spell.Rogue.Assassination.InternalBleeding) and 1 or 0);
  end

  -- poisoned_bleeds
  --[[ Original SimC Code
    int poisoned_bleeds = 0;
    for ( size_t i = 0, actors = sim -> target_non_sleeping_list.size(); i < actors; i++ )
    {
      player_t* t = sim -> target_non_sleeping_list[i];
      rogue_td_t* tdata = get_target_data( t );
      if ( tdata -> lethal_poisoned() ) {
        poisoned_bleeds += tdata -> dots.garrote -> is_ticking() +
                            tdata -> dots.internal_bleeding -> is_ticking() +
                            tdata -> dots.rupture -> is_ticking();
      }
    }
    return poisoned_bleeds;
  ]]
  local PoisonedBleedsCount = 0;
  function Commons.PoisonedBleeds ()
    PoisonedBleedsCount = 0;
    -- Get Units up to 50y (not really worth the potential performance loss to go higher).
    AC.GetEnemies(50);
    for _, Unit in pairs(Cache.Enemies[50]) do
      if Commons.Poisoned(Unit) then
        -- TODO: For loop for this ? Not sure it's worth considering we would have to make 2 times spell object (Assa is init after Commons)
        if Unit:Debuff(Spell.Rogue.Assassination.Garrote) then
          PoisonedBleedsCount = PoisonedBleedsCount + 1;
        end
        if Unit:Debuff(Spell.Rogue.Assassination.InternalBleeding) then
          PoisonedBleedsCount = PoisonedBleedsCount + 1;
        end
        if Unit:Debuff(Spell.Rogue.Assassination.Rupture) then
          PoisonedBleedsCount = PoisonedBleedsCount + 1;
        end
      end
    end
    return PoisonedBleedsCount;
  end

  -- Assassination Tier 19 4PC Envenom Multiplier
  --[[ Original SimC Code
    if ( p() -> sets.has_set_bonus( ROGUE_ASSASSINATION, T19, B4 ) )
    {
      size_t bleeds = 0;
      rogue_td_t* tdata = td( target );
      bleeds += tdata -> dots.garrote -> is_ticking();
      bleeds += tdata -> dots.internal_bleeding -> is_ticking();
      bleeds += tdata -> dots.rupture -> is_ticking();
      // As of 04/08/2017, Mutilated Flesh works on T19 4PC.
      bleeds += tdata -> dots.mutilated_flesh -> is_ticking();

      m *= 1.0 + p() -> sets.set( ROGUE_ASSASSINATION, T19, B4 ) -> effectN( 1 ).percent() * bleeds;
    }
  ]]
  local T19_4C_BaseMultiplier = 0.1;
  function Commons.Assa_T19_4PC_EnvMultiplier ()
    return 1 + T19_4C_BaseMultiplier * (Commons.Bleeds() + (Target:Debuff(Spell.Rogue.Assassination.MutilatedFlesh) and 1 or 0));
  end

  -- mantle_duration
  --[[ Original SimC Code
    if ( buffs.mantle_of_the_master_assassin_aura -> check() )
    {
      timespan_t nominal_master_assassin_duration = timespan_t::from_seconds( spell.master_assassins_initiative -> effectN( 1 ).base_value() );
      timespan_t gcd_remains = timespan_t::from_seconds( std::max( ( gcd_ready - sim -> current_time() ).total_seconds(), 0.0 ) );
      return gcd_remains + nominal_master_assassin_duration;
    }
    else if ( buffs.mantle_of_the_master_assassin -> check() )
      return buffs.mantle_of_the_master_assassin -> remains();
    else
      return timespan_t::from_seconds( 0.0 );
  ]]
  local MasterAssassinsInitiative, NominalDuration = Spell(235027), 6;
  function Commons.MantleDuration ()
    if Player:BuffRemains(MasterAssassinsInitiative) < 0 then
      return Player:GCDRemains() + NominalDuration;
    else
      return Player:BuffRemainsP(MasterAssassinsInitiative);
    end
  end
