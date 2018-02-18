--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- AethysRotation
local AR = AethysRotation;
-- Lua
local pairs = pairs;
local tableinsert = table.insert;


--- APL Local Vars
-- Commons
  local Everyone = AR.Commons.Everyone;
  local Rogue = AR.Commons.Rogue;
-- Spells
  if not Spell.Rogue then Spell.Rogue = {}; end
  Spell.Rogue.Subtlety = {
    -- Racials
    ArcaneTorrent                 = Spell(25046),
    Berserking                    = Spell(26297),
    BloodFury                     = Spell(20572),
    GiftoftheNaaru                = Spell(59547),
    Shadowmeld                    = Spell(58984),
    -- Abilities
    Backstab                      = Spell(53),
    Eviscerate                    = Spell(196819),
    Nightblade                    = Spell(195452),
    ShadowBlades                  = Spell(121471),
    ShadowDance                   = Spell(185313),
    ShadowDanceBuff               = Spell(185422),
    Shadowstrike                  = Spell(185438),
    ShurikenComboBuff             = Spell(245640),
    ShurikenStorm                 = Spell(197835),
    ShurikenToss                  = Spell(114014),
    Stealth                       = Spell(1784),
    Stealth2                      = Spell(115191), -- w/ Subterfuge Talent
    SymbolsofDeath                = Spell(212283),
    Vanish                        = Spell(1856),
    VanishBuff                    = Spell(11327),
    VanishBuff2                   = Spell(115193), -- w/ Subterfuge Talent
    -- Talents
    Alacrity                      = Spell(193539),
    AlacrityBuff                  = Spell(193538),
    Anticipation                  = Spell(114015),
    DarkShadow                    = Spell(245687),
    DeathfromAbove                = Spell(152150),
    DeeperStratagem               = Spell(193531),
    EnvelopingShadows             = Spell(238104),
    Gloomblade                    = Spell(200758),
    MarkedforDeath                = Spell(137619),
    MasterofShadows               = Spell(196976),
    MasterofShadowsBuff           = Spell(196980),
    MasterOfSubtlety              = Spell(31223),
    MasterOfSubtletyBuff          = Spell(31665),
    Nightstalker                  = Spell(14062),
    ShadowFocus                   = Spell(108209),
    Subterfuge                    = Spell(108208),
    Vigor                         = Spell(14983),
    -- Artifact
    FeedingFrenzy                 = Spell(242705),
    FinalityEviscerate            = Spell(197496),
    FinalityNightblade            = Spell(197498),
    FlickeringShadows             = Spell(197256),
    GoremawsBite                  = Spell(209782),
    LegionBlade                   = Spell(214930),
    ShadowFangs                   = Spell(221856),
    ShadowsoftheUncrowned         = Spell(241154),
    WeakPoint                     = Spell(238068),
    -- Defensive
    CrimsonVial                   = Spell(185311),
    Feint                         = Spell(1966),
    -- Utility
    Blind                         = Spell(2094),
    CheapShot                     = Spell(1833),
    Kick                          = Spell(1766),
    KidneyShot                    = Spell(408),
    Sprint                        = Spell(2983),
    -- Legendaries
    DreadlordsDeceit              = Spell(228224),
    TheFirstoftheDead             = Spell(248210),
    -- Set Bonuses
    T21_4pc_Buff                  = Spell(257945),
    -- Misc
    PoolEnergy                    = Spell(9999000010),
  };
  local S = Spell.Rogue.Subtlety;
  S.Eviscerate:RegisterDamage(
    -- Eviscerate DMG Formula (Pre-Mitigation):
    --- Player Modifier
      -- AP * CP * EviscR1_APCoef * EviscR2_M * Aura_M * F:Evisc_M * ShadowFangs_M * MoS_M * NS_M * DS_M * DSh_M * SoD_M * ShC_M * Mastery_M * Versa_M * LegionBlade_M * ShUncrowned_M
    --- Target Modifier
      -- NB_M
    function ()
      return
        --- Player Modifier
          -- Attack Power
          Player:AttackPower() *
          -- Combo Points
          Rogue.CPSpend() *
          -- Eviscerate R1 AP Coef
          0.98130 *
          -- Eviscerate R2 Multiplier
          1.5 *
          -- Aura Multiplier (SpellID: 137035)
          1.27 *
          -- Finality: Eviscerate Multiplier
          (Player:BuffP(S.FinalityEviscerate) and 1 + Player:Buff(S.FinalityEviscerate, 17) / 100 or 1) *
          -- Shadow Fangs Multiplier
          (S.ShadowFangs:ArtifactEnabled() and 1.04 or 1) *
          -- Master of Subtlety Multiplier
          (Player:BuffP(S.MasterOfSubtletyBuff) and 1.1 or 1) *
          -- Nightstalker Multiplier
          (S.Nightstalker:IsAvailable() and Player:IsStealthed(true) and 1.12 or 1) *
          -- Deeper Stratagem Multiplier
          (S.DeeperStratagem:IsAvailable() and 1.05 or 1) *
          -- Dark Shadow Multiplier
          (S.DarkShadow:IsAvailable() and Player:BuffP(S.ShadowDanceBuff) and 1.3 or 1) *
          -- Symbols of Death Multiplier
          (Player:BuffP(S.SymbolsofDeath) and 1.15+(AC.Tier20_2Pc and 0.1 or 0) or 1) *
          -- Shuriken Combo Multiplier
          (Player:BuffP(S.ShurikenComboBuff) and 1 + Player:Buff(S.ShurikenComboBuff, 17) / 100 or 1) *
          -- Mastery Finisher Multiplier
          (1 + Player:MasteryPct()/100) *
          -- Versatility Damage Multiplier
          (1 + Player:VersatilityDmgPct()/100) *
          -- Legion Blade Multiplier
          (S.LegionBlade:ArtifactEnabled() and 1.05 or 1) *
          -- Shadows of the Uncrowned Multiplier
          (S.ShadowsoftheUncrowned:ArtifactEnabled() and 1.1 or 1) *
        --- Target Modifier
          -- Nightblade Multiplier
          (Target:DebuffP(S.Nightblade) and 1.15 or 1);
    end
  );
  S.Nightblade:RegisterPMultiplier(
    {S.FinalityNightblade, function ()
      return Player:Buff(S.FinalityNightblade) and 1 + Player:Buff(S.FinalityNightblade, 17)/100 or 1;
    end},
    {function ()
      return S.Nightstalker:IsAvailable() and Player:IsStealthed(true, false) and 1.12 or 1;
    end}
  );
-- Items
  if not Item.Rogue then Item.Rogue = {}; end
  Item.Rogue.Subtlety = {
    -- Legendaries
    DenialoftheHalfGiants         = Item(137100, {9}),
    InsigniaOfRavenholdt          = Item(137049, {11, 12}),
    MantleoftheMasterAssassin     = Item(144236, {3}),
    ShadowSatyrsWalk              = Item(137032, {8}),
    TheFirstoftheDead             = Item(151818, {10}),
    -- Trinkets
    KiljaedensBurningWish         = Item(144259, {13, 14}),
    DraughtofSouls                = Item(140808, {13, 14}),
    VialofCeaselessToxins         = Item(147011, {13, 14}),
    UmbralMoonglaives             = Item(147012, {13, 14}),
    SpecterofBetrayal             = Item(151190, {13, 14}),
    VoidStalkersContract          = Item(151307, {13, 14}),
    ForgefiendsFabricator         = Item(151963, {13, 14}),
  };
  local I = Item.Rogue.Subtlety;
  local AoETrinkets = { I.UmbralMoonglaives, I.VoidStalkersContract, I.ForgefiendsFabricator };

-- Rotation Var
  local ShouldReturn; -- Used to get the return string
  local Stealth, VanishBuff;
-- GUI Settings
  local Settings = {
    General = AR.GUISettings.General,
    Commons = AR.GUISettings.APL.Rogue.Commons,
    Subtlety = AR.GUISettings.APL.Rogue.Subtlety
  };

-- Melee Is In Range w/ DfA Handler
local function IsInMeleeRange ()
  return (Target:IsInRange("Melee") or S.DeathfromAbove:TimeSinceLastCast() <= 1.5) and true or false;
end
-- Shadow Satry's Walk Bug
local ExtraSSWRefundTable = {
  [101002] = 2, -- Nighthold: Krosus
  [114537] = 2, -- Trial of Valor: Helya
  [123371] = 2, -- Antorus: Garothi Worldbreaker
  [125050] = 2 -- Antorus: Kin'garoth
};
local function SSW_RefundOffset ()
  return ExtraSSWRefundTable[Target:NPCID()] or 0;
end

-- APL Action Lists (and Variables)
-- actions.precombat+=/variable,name=ssw_refund,value=equipped.shadow_satyrs_walk*(6+ssw_refund_offset)
local function SSW_Refund ()
  return I.ShadowSatyrsWalk:IsEquipped() and 6+SSW_RefundOffset() or 0;
end
-- actions.precombat+=/variable,name=stealth_threshold,value=(65+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10+variable.ssw_refund)
local function Stealth_Threshold ()
  return 65 + (S.Vigor:IsAvailable() and 35 or 0) + (S.MasterofShadows:IsAvailable() and 10 or 0) + SSW_Refund();
end
-- actions.precombat+=/variable,name=shd_fractional,value=1.725+0.725*talent.enveloping_shadows.enabled
local function ShD_Fractional ()
  return 1.725 + (S.EnvelopingShadows:IsAvailable() and 0.725 or 0);
end
-- actions=variable,name=dsh_dfa,value=talent.death_from_above.enabled&talent.dark_shadow.enabled&spell_targets.death_from_above<4
local function DSh_DfA ()
  return S.DeathfromAbove:IsAvailable() and S.DarkShadow:IsAvailable() and Cache.EnemiesCount[10] < 4;
end

-- # This let us to use Shadow Dance right before the 2nd part of DfA lands. Only with Dark Shadow.
-- actions+=/shadow_dance,if=talent.dark_shadow.enabled&(!stealthed.all|buff.subterfuge.up)&buff.death_from_above.up&buff.death_from_above.remains<=0.15
local function DfAShadowDance ()
  if S.DarkShadow:IsAvailable() and (not Player:IsStealthed(true, true) or Player:BuffP(S.Subterfuge))
    and (AR.CDsON() or (S.ShadowDance:ChargesFractional() >= Settings.Subtlety.ShDEcoCharge - (S.DarkShadow:IsAvailable() and 0.75 or 0)))
    and S.ShadowDance:IsCastable() and S.ShadowDance:Charges() >= 1 then
      return true;
  end

  return false;
end

-- # Finishers
-- ReturnSpellOnly and StealthSpell parameters are to Predict Finisher in case of Stealth Macros
local function Finish (ReturnSpellOnly, StealthSpell)
  local ShadowDanceBuff = Player:BuffP(S.ShadowDanceBuff) or (StealthSpell and StealthSpell:ID() == S.ShadowDance:ID())

  if S.Nightblade:IsCastable() then
    local NightbladeThreshold = (6+Rogue.CPSpend()*(2+(AC.Tier19_2Pc and 2 or 0)))*0.3;
    -- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&(mantle_duration=0|remains<=mantle_duration)&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
    if IsInMeleeRange() and (not S.DarkShadow:IsAvailable() or not ShadowDanceBuff)
      and (Target:FilteredTimeToDie(">", 6, -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid())
      and Rogue.CanDoTUnit(Target, S.Eviscerate:Damage()*Settings.Subtlety.EviscerateDMGOffset)
      and (Rogue.MantleDuration() == 0 or Target:DebuffRemainsP(S.Nightblade) <= Rogue.MantleDuration())
      and ((Target:DebuffRefreshableP(S.Nightblade, NightbladeThreshold) and (not AC.Finality(Target) or Player:BuffP(S.FinalityNightblade) or DSh_DfA()))
        or Target:DebuffRemainsP(S.Nightblade) < 4)
      and (Cache.EnemiesCount[10] < 4 and not DSh_DfA() or not Player:BuffP(S.SymbolsofDeath)) then
      if ReturnSpellOnly then
        return S.Nightblade;
      else
        if AR.Cast(S.Nightblade) then return "Cast Nightblade 1"; end
      end
    end
    -- actions.finish+=/nightblade,cycle_targets=1,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>12&mantle_duration=0&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
    if AR.AoEON() and (not S.DarkShadow:IsAvailable() or not ShadowDanceBuff) and Rogue.MantleDuration() == 0 then
      local BestUnit, BestUnitTTD = nil, 12;
      for _, Unit in pairs(Cache.Enemies["Melee"]) do
        if Everyone.UnitIsCycleValid(Unit, BestUnitTTD, -Unit:DebuffRemainsP(S.Nightblade))
          and Everyone.CanDoTUnit(Unit, S.Eviscerate:Damage()*Settings.Subtlety.EviscerateDMGOffset)
          and ((Unit:DebuffRefreshableP(S.Nightblade, NightbladeThreshold) and (not AC.Finality(Unit) or Player:BuffP(S.FinalityNightblade) or DSh_DfA()))
            or Unit:DebuffRemainsP(S.Nightblade) < 4)
          and (Cache.EnemiesCount[10] < 4 and not DSh_DfA() or not Player:BuffP(S.SymbolsofDeath)) then
          BestUnit, BestUnitTTD = Unit, Unit:TimeToDie();
        end
      end
      if BestUnit then
        AR.CastLeftNameplate(BestUnit, S.Nightblade);
      end
    end
    -- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5+(combo_points=6)&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
    if IsInMeleeRange() and Target:DebuffRemainsP(S.Nightblade) < S.SymbolsofDeath:CooldownRemainsP() + 10
      and S.SymbolsofDeath:CooldownRemainsP() <= 5 + (Player:ComboPoints() == 6 and 1 or 0)
      and (Target:FilteredTimeToDie(">", 5 + S.SymbolsofDeath:CooldownRemainsP(), -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid()) then
      if ReturnSpellOnly then
        return S.Nightblade;
      else
        if AR.Cast(S.Nightblade) then return "Cast Nightblade 2"; end
      end
    end
  end
  -- actions.finish+=/death_from_above,if=!talent.dark_shadow.enabled|(!buff.shadow_dance.up|spell_targets>=4)&(buff.symbols_of_death.up|cooldown.symbols_of_death.remains>=10+set_bonus.tier20_4pc*5)&buff.the_first_of_the_dead.remains<1&(buff.finality_eviscerate.up|spell_targets.shuriken_storm<4)
  if S.DeathfromAbove:IsCastable(15)
    and (not S.DarkShadow:IsAvailable()
      or (not ShadowDanceBuff or Cache.EnemiesCount[10] >= 4)
      and (Player:BuffP(S.SymbolsofDeath) or S.SymbolsofDeath:CooldownRemainsP() >= 10 + (AC.Tier20_4Pc and 5 or 0))
      and Player:BuffRemainsP(S.TheFirstoftheDead) < 1
      and (Player:BuffP(S.FinalityEviscerate) or Cache.EnemiesCount[10] < 4)) then
    if ReturnSpellOnly then
      return S.DeathfromAbove;
    else
      -- Display DfA/ShadowDance Macro if we know in advance that we meet the conditions for using ShadowDance mid-air
      if DfAShadowDance() and Settings.Subtlety.StealthMacro.ShadowDance then
        if AR.CastQueue(S.DeathfromAbove, S.ShadowDance) then return "Cast Death from Above / Shadow Dance"; end
      else
        if AR.Cast(S.DeathfromAbove) then return "Cast Death from Above"; end
      end
    end
  end
  -- actions.finish+=/eviscerate
  if S.Eviscerate:IsCastable() and IsInMeleeRange() then
    if ReturnSpellOnly then
      return S.Eviscerate;
    else
      -- Since Eviscerate costs more than Nightblade, show pooling icon in case conditions change while gaining Energy
      if Player:EnergyPredicted() < S.Eviscerate:Cost() then
        if AR.Cast(S.PoolEnergy) then return "Pool for Finisher"; end
      else
        if AR.Cast(S.Eviscerate) then return "Cast Eviscerate " .. (Player:BuffP(S.SymbolsofDeath) and 1 or 0) .. " " .. Player:BuffRemainsP(S.TheFirstoftheDead) .. " " .. (Player:BuffP(S.FinalityEviscerate) and 1 or 0); end
      end
    end
  end
  return false;
end
-- # Stealthed Rotation
-- ReturnSpellOnly and StealthSpell parameters are to Predict Finisher in case of Stealth Macros
local function Stealthed (ReturnSpellOnly, StealthSpell)
  local StealthBuff = Player:Buff(Stealth) or (StealthSpell and StealthSpell:ID() == Stealth:ID())
  -- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
  -- actions.stealthed=shadowstrike,if=buff.stealth.up
  if StealthBuff and S.Shadowstrike:IsCastable() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
    if ReturnSpellOnly then
      return S.Shadowstrike
    else
      if AR.Cast(S.Shadowstrike) then return "Cast Shadowstrike 1"; end
    end
  end
  -- actions.stealthed+=/call_action_list,name=finish,if=combo_points>=5&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration>=0.3))
  if Player:ComboPoints() >= 5 and (Cache.EnemiesCount[10] >= 3 + (I.ShadowSatyrsWalk:IsEquipped() and 1 or 0)
      or (Rogue.MantleDuration() <= 1.3 and Rogue.MantleDuration() >= 0.3)) then
    return Finish(ReturnSpellOnly, StealthSpell);
  end
  -- actions.stealthed+=/shuriken_storm,if=buff.shadowmeld.down&((combo_points.deficit>=2+equipped.insignia_of_ravenholdt&spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk)|(combo_points.deficit>=1&buff.the_dreadlords_deceit.stack>=29))
  if S.ShurikenStorm:IsCastable() and not Player:Buff(S.Shadowmeld)
      and ((Player:ComboPointsDeficit() >= 2 + (I.InsigniaOfRavenholdt:IsEquipped() and 1 or 0) and Cache.EnemiesCount[10] >= 3 + (I.ShadowSatyrsWalk:IsEquipped() and 1 or 0))
        or (AR.AoEON() and IsInMeleeRange() and Player:ComboPointsDeficit() >= 1 and Player:BuffStack(S.DreadlordsDeceit) >= 29)) then
    if ReturnSpellOnly then
      return S.ShurikenStorm
    else
      if AR.Cast(S.ShurikenStorm) then return "Cast Shuriken Storm"; end
    end
  end
  -- actions.stealthed+=/call_action_list,name=finish,if=combo_points>=5&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
  if Player:ComboPoints() >= 5
    and Player:ComboPointsDeficit() < 3 + (Player:BuffP(S.ShadowBlades) and 1 or 0) - (I.MantleoftheMasterAssassin:IsEquipped() and 1 or 0) then
    return Finish(ReturnSpellOnly, StealthSpell);
  end
  -- actions.stealthed+=/shadowstrike
  if S.Shadowstrike:IsCastable() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
    if ReturnSpellOnly then
      return S.Shadowstrike
    else
      if AR.Cast(S.Shadowstrike) then return "Cast Shadowstrike 2"; end
    end
  end
  return false;
end
-- # Stealth Macros
-- This returns a table with the original Stealth spell and the result of the Stealthed action list as if the applicable buff was present
local function StealthMacro (StealthSpell)
  local MacroTable = {StealthSpell};

  -- Handle StealthMacro GUI options
  -- If false, just suggest them as off-GCD and bail out of the macro functionality
  if StealthSpell == S.Vanish and not Settings.Subtlety.StealthMacro.Vanish then
    if AR.Cast(S.Vanish, Settings.Commons.OffGCDasOffGCD.Vanish) then return "Cast Vanish"; end
    return false;
  elseif StealthSpell == S.Shadowmeld and not Settings.Subtlety.StealthMacro.Shadowmeld then
    if AR.Cast(S.Shadowmeld, Settings.Commons.OffGCDasOffGCD.Racials) then return "Cast Shadowmeld"; end
    return false;
  elseif StealthSpell == S.ShadowDance and not Settings.Subtlety.StealthMacro.ShadowDance then
    if AR.Cast(S.ShadowDance, Settings.Subtlety.OffGCDasOffGCD.ShadowDance) then return "Cast Shadow Dance"; end
    return false;
  end

  tableinsert(MacroTable, Stealthed(true, StealthSpell))

   -- Note: In case DfA is adviced (which can only be a combo for ShD), we swap them to let understand it's DfA then ShD during DfA (DfA - ShD bug)
  if MacroTable[1] == S.ShadowDance and MacroTable[2] == S.DeathfromAbove then
    return AR.CastQueue(MacroTable[2], MacroTable[1]);
  else
    return AR.CastQueue(unpack(MacroTable));
  end
end
-- # Builders
local function Build ()
  -- actions.build=shuriken_storm,if=spell_targets.shuriken_storm>=2+(buff.the_first_of_the_dead.up|buff.symbols_of_death.up|buff.master_of_subtlety.up)
  if S.ShurikenStorm:IsCastableP() and Cache.EnemiesCount[10] >= 2 + ((Player:BuffP(S.TheFirstoftheDead) or Player:BuffP(S.SymbolsofDeath) or Player:BuffP(S.MasterOfSubtletyBuff)) and 1 or 0) then
    if AR.Cast(S.ShurikenStorm) then return "Cast Shuriken Storm"; end
  end
  if IsInMeleeRange() then
    -- actions.build+=/gloomblade
    if S.Gloomblade:IsCastable() then
      if AR.Cast(S.Gloomblade) then return "Cast Gloomblade"; end
    -- actions.build+=/backstab
    elseif S.Backstab:IsCastable() then
      if AR.Cast(S.Backstab) then return "Cast Backstab"; end
    end
  end
  return false;
end
-- # Cooldowns
local function CDs ()
  if IsInMeleeRange() then
    if AR.CDsON() then
      -- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
      -- TODO: Add Potion Suggestion

      -- Trinkets
      local TrinketSuggested = false;
      if not TrinketSuggested and I.SpecterofBetrayal:IsEquipped() and I.SpecterofBetrayal:IsReady() then
        if S.DarkShadow:IsAvailable() then
          -- if=talent.dark_shadow.enabled&buff.shadow_dance.up&(!set_bonus.tier20_4pc|buff.symbols_of_death.up|(!talent.death_from_above.enabled&((mantle_duration>=3|!equipped.mantle_of_the_master_assassin)|cooldown.vanish.remains>=43)))
          if Player:Buff(S.ShadowDanceBuff) and (not AC.Tier20_4Pc or Player:Buff(S.SymbolsofDeath) or
            (not S.DeathfromAbove:IsAvailable() and ((Rogue.MantleDuration() >= 3 or not I.MantleoftheMasterAssassin:IsEquipped()) or S.Vanish:CooldownRemains() >= 43))) then
              if AR.CastSuggested(I.SpecterofBetrayal) then TrinketSuggested = true; end
          end
        else
          -- if=!talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&(mantle_duration>=3|!equipped.mantle_of_the_master_assassin)
          if not Player:IsStealthed(true, true) and not Player:Buff(Stealth) and not Player:Buff(S.Vanish)
            and (Rogue.MantleDuration() >= 3 or not I.MantleoftheMasterAssassin:IsEquipped()) then
              if AR.CastSuggested(I.SpecterofBetrayal) then TrinketSuggested = true; end
          end
        end
      end
      if not TrinketSuggested then
        for i = 1, #AoETrinkets do
          local Trinket = AoETrinkets[i];
          if Trinket:IsEquipped() and Trinket:IsReady() then
            if S.DarkShadow:IsAvailable() then
              -- if=talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&buff.shadow_dance.up&(buff.symbols_of_death.up|(!talent.death_from_above.enabled&(mantle_duration>=3|!equipped.mantle_of_the_master_assassin)))
              if Player:Buff(S.ShadowDanceBuff) and (Player:Buff(S.SymbolsofDeath) or
                (not S.DeathfromAbove:IsAvailable() and (Rogue.MantleDuration() >= 3 or not I.MantleoftheMasterAssassin:IsEquipped()))) then
                  if AR.CastSuggested(Trinket) then TrinketSuggested = true; break; end
              end
            else
              -- if=!talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&(mantle_duration>=3|!equipped.mantle_of_the_master_assassin)
              if not Player:IsStealthed(true, true) and not Player:Buff(Stealth) and not Player:Buff(S.Vanish)
                and (Rogue.MantleDuration() >= 3 or not I.MantleoftheMasterAssassin:IsEquipped()) then
                  if AR.CastSuggested(Trinket) then TrinketSuggested = true; break; end
              end
            end
          end
        end
      end
      if not TrinketSuggested and I.VialofCeaselessToxins:IsEquipped() and I.VialofCeaselessToxins:IsReady() then
        -- if=(!talent.dark_shadow.enabled|buff.shadow_dance.up)&(buff.symbols_of_death.up|(!talent.death_from_above.enabled&((mantle_duration>=3|!equipped.mantle_of_the_master_assassin)|cooldown.vanish.remains>=60)))
        if (not S.DarkShadow:IsAvailable() or Player:Buff(S.ShadowDanceBuff)) and (Player:Buff(S.SymbolsofDeath)
          or (not S.DeathfromAbove:IsAvailable() and (Rogue.MantleDuration() >= 3 or not I.MantleoftheMasterAssassin:IsEquipped() or S.Vanish:CooldownRemains() >= 60))) then
            if AR.CastSuggested(I.VialofCeaselessToxins) then TrinketSuggested = true; end
        end
      end

      -- Racials
      if Player:IsStealthed(true, false) then
        -- actions.cds+=/blood_fury,if=stealthed.rogue
        if S.BloodFury:IsCastable() then
          if AR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "Cast Blood Fury"; end
        end
        -- actions.cds+=/berserking,if=stealthed.rogue
        if S.Berserking:IsCastable() then
          if AR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "Cast Berserking"; end
        end
        -- actions.cds+=/arcane_torrent,if=stealthed.rogue&energy.deficit>70
        if S.ArcaneTorrent:IsCastable() and Player:EnergyDeficitPredicted() > 70 then
          if AR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "Cast Arcane Torrent"; end
        end
      end
    end
    if S.SymbolsofDeath:IsCastable() then
      if not S.DeathfromAbove:IsAvailable() then
        -- actions.cds+=/symbols_of_death,if=!talent.death_from_above.enabled
        if AR.Cast(S.SymbolsofDeath, Settings.Subtlety.OffGCDasOffGCD.SymbolsofDeath) then return "Cast Symbols of Death"; end
      else
        -- actions.cds+=/symbols_of_death,if=(talent.death_from_above.enabled&cooldown.death_from_above.remains<=1&(dot.nightblade.remains>=cooldown.death_from_above.remains+3|target.time_to_die-dot.nightblade.remains<=6)&(time>=3|set_bonus.tier20_4pc|equipped.the_first_of_the_dead))|target.time_to_die-remains<=10
        if (S.DeathfromAbove:CooldownRemainsP() <= 1
            and (Target:DebuffRemainsP(S.Nightblade) >= S.DeathfromAbove:CooldownRemainsP() + 3
              or Target:FilteredTimeToDie("<=", 6))
            and (AC.CombatTime() >= 3 or AC.Tier20_4Pc or I.TheFirstoftheDead:IsEquipped()))
          or Target:FilteredTimeToDie("<=", 10) then
          if AR.Cast(S.SymbolsofDeath, Settings.Subtlety.OffGCDasOffGCD.SymbolsofDeath) then return "Cast Symbols of Death"; end
        end
      end
    end
    if AR.CDsON() then
      -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
      -- Note: Done at the start of the Rotation (Rogue Commmon)
      -- actions.cds+=/marked_for_death,if=raid_event.adds.in>40&!stealthed.all&combo_points.deficit>=cp_max_spend
      if S.MarkedforDeath:IsCastable() then
        if Target:FilteredTimeToDie("<", Player:ComboPointsDeficit()) or (Settings.Subtlety.STMfDAsDPSCD and not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= Rogue.CPMaxSpend()) then
          if AR.Cast(S.MarkedforDeath, Settings.Commons.OffGCDasOffGCD.MarkedforDeath) then return "Cast Marked for Death"; end
        elseif Player:ComboPointsDeficit() >= Rogue.CPMaxSpend() then
          AR.CastSuggested(S.MarkedforDeath);
        end
      end
      -- actions.cds+=/shadow_blades,if=(time>10&combo_points.deficit>=2+stealthed.all-equipped.mantle_of_the_master_assassin)|(time<10&(!talent.marked_for_death.enabled|combo_points.deficit>=3|dot.nightblade.ticking))
      if S.ShadowBlades:IsCastable() and not Player:Buff(S.ShadowBlades)
        and ((AC.CombatTime() > 10 and Player:ComboPointsDeficit() >= 2 + (Player:IsStealthed(true, true) and 1 or 0) - (I.MantleoftheMasterAssassin:IsEquipped() and 1 or 0))
          or (AC.CombatTime() < 10 and (not S.MarkedforDeath:IsAvailable() or Player:ComboPointsDeficit() >= 3 or Target:Debuff(S.Nightblade)))) then
        if AR.Cast(S.ShadowBlades, Settings.Subtlety.OffGCDasOffGCD.ShadowBlades) then return "Cast Shadow Blades"; end
      end
      -- actions.cds+=/goremaws_bite,if=!stealthed.all&cooldown.shadow_dance.charges_fractional<=variable.ShD_Fractional&((combo_points.deficit>=4-(time<10)*2&energy.deficit>50+talent.vigor.enabled*25-(time>=10)*15)|(combo_points.deficit>=1&target.time_to_die<8))
      if S.GoremawsBite:IsCastable() and not Player:IsStealthed(true, true) and S.ShadowDance:ChargesFractional() <= ShD_Fractional()
          and ((Player:ComboPointsDeficit() >= 4-(AC.CombatTime() < 10 and 2 or 0)
              and Player:EnergyDeficitPredictedWithRS() > 50+(S.Vigor:IsAvailable() and 25 or 0)-(AC.CombatTime() >= 10 and 15 or 0))
            or (Player:ComboPointsDeficit() >= 1 and Target:TimeToDie(10) < 8)) then
        if AR.Cast(S.GoremawsBite) then return "Cast Goremaw's Bite"; end
      end
      -- actions.cds+=/vanish,if=energy>=55-talent.shadow_focus.enabled*10&variable.dsh_dfa&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&!buff.shadow_dance.up&!buff.stealth.up&mantle_duration=0&(dot.nightblade.remains>=cooldown.death_from_above.remains+6&!(buff.the_first_of_the_dead.remains>1&combo_points>=5)|target.time_to_die-dot.nightblade.remains<=6)&cooldown.death_from_above.remains<=1|target.time_to_die<=7
      -- Disable vanish while mantle buff is up, we put mantle_duration=0 as a mandatory condition. This isn't seen in SimC since combat length < 5s are rare, might be worth to port it tho. It won't hurt.
      -- Removed the TTD part for now.
      if AR.CDsON() and S.Vanish:IsCastable() and S.ShadowDance:TimeSinceLastDisplay() > 0.3 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and not Player:IsTanking(Target)
        and Rogue.MantleDuration() == 0 and DSh_DfA() and (not I.MantleoftheMasterAssassin:IsEquipped() or Player:BuffP(S.SymbolsofDeath))
          and S.ShadowDance:ChargesFractional() <= ShD_Fractional() and not Player:BuffP(S.ShadowDanceBuff) and not Player:Buff(Stealth)
          and (Target:DebuffRemainsP(S.Nightblade) >= S.DeathfromAbove:CooldownRemainsP() + 6
            -- &!(buff.the_first_of_the_dead.remains>1&combo_points>=5)
            and not (Player:BuffRemainsP(S.TheFirstoftheDead) > 1 and Player:ComboPoints() >= 5)
            or Target:FilteredTimeToDie("<=", 6, -Target:DebuffRemainsP(S.Nightblade)) or not Target:TimeToDieIsNotValid())
          and S.DeathfromAbove:CooldownRemainsP() <= 1 then
        -- actions.cds+=/pool_resource,for_next=1,extra_amount=55-talent.shadow_focus.enabled*10
        if Player:Energy() < 55 - (S.ShadowFocus:IsAvailable() and 10 or 0) then
          if AR.Cast(S.PoolEnergy) then return "Pool for Vanish"; end
        end
        if StealthMacro(S.Vanish) then return "Vanish Macro"; end
      end
      -- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=4+talent.subterfuge.enabled
      if S.ShadowDance:IsCastable() and not Player:BuffP(S.ShadowDanceBuff) and Target:FilteredTimeToDie("<=", 4 + (S.Subterfuge:IsAvailable() and 1 or 0)) then
        if StealthMacro(S.ShadowDance) then return "ShadowDance Macro"; end
   end
  end
end
  return false;
end
-- # Stealth Cooldowns
local function Stealth_CDs ()
  if IsInMeleeRange() then
    -- actions.stealth_cds=vanish,if=!variable.dsh_dfa&mantle_duration=0&cooldown.shadow_dance.charges_fractional<variable.shd_fractional+(equipped.mantle_of_the_master_assassin&time<30)*0.3&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)
    if AR.CDsON() and S.Vanish:IsCastable() and S.ShadowDance:TimeSinceLastDisplay() > 0.3 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and not Player:IsTanking(Target)
      and not DSh_DfA() and Rogue.MantleDuration() == 0
      and S.ShadowDance:ChargesFractional() < ShD_Fractional()+(I.MantleoftheMasterAssassin:IsEquipped() and AC.CombatTime() < 30 and 0.3 or 0)
      and (not I.MantleoftheMasterAssassin:IsEquipped() or Player:BuffP(S.SymbolsofDeath)) then
      if StealthMacro(S.Vanish) then return "Vanish Macro"; end
    end
    -- actions.stealth_cds+=/shadow_dance,if=charges_fractional>=variable.shd_fractional
    -- actions.stealth_cds+=/shadow_dance,if=dot.nightblade.remains>=5&charges_fractional>=variable.shd_fractional|target.time_to_die<cooldown.symbols_of_death.remains
    if (AR.CDsON() or (S.ShadowDance:ChargesFractional() >= Settings.Subtlety.ShDEcoCharge - (S.DarkShadow:IsAvailable() and 0.75 or 0)))
      and S.ShadowDance:IsCastable() and S.Vanish:TimeSinceLastDisplay() > 0.3
      and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and (S.ShadowDance:ChargesFractional() >= ShD_Fractional()
	  and Target:DebuffRemainsP(S.Nightblade) > 4
        or (Target:IsInBossList() and Target:FilteredTimeToDie("<", Player:BuffRemainsP(S.SymbolsofDeath)))) then
      if StealthMacro(S.ShadowDance) then return "ShadowDance Macro 1"; end
    end
    -- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
    if AR.CDsON() and S.Shadowmeld:IsCastable() and S.ShadowDance:TimeSinceLastDisplay() > 0.3 and S.Vanish:TimeSinceLastDisplay() > 0.3 and not Player:IsTanking(Target)
      and GetUnitSpeed("player") == 0 and Player:EnergyDeficitPredicted() > 10+SSW_Refund() then
      -- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40
      if Player:Energy() < 40 then
        if AR.Cast(S.PoolEnergy) then return "Pool for Shadowmeld"; end
      end
      if StealthMacro(S.Shadowmeld) then return "Shadowmeld Macro"; end
    end
    -- actions.stealth_cds+=/shadow_dance,if=!variable.dsh_dfa&combo_points.deficit>=2+talent.subterfuge.enabled*2&(buff.symbols_of_death.remains>=1.2|cooldown.symbols_of_death.remains>=12+(talent.dark_shadow.enabled&set_bonus.tier20_4pc)*3-(!talent.dark_shadow.enabled&set_bonus.tier20_4pc)*4|mantle_duration>0)&(spell_targets.shuriken_storm>=4|!buff.the_first_of_the_dead.up)
    if (AR.CDsON() or (S.ShadowDance:ChargesFractional() >= Settings.Subtlety.ShDEcoCharge - (S.DarkShadow:IsAvailable() and 0.75 or 0))) and S.ShadowDance:IsCastable() and S.Vanish:TimeSinceLastDisplay() > 0.3
      and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1 and not DSh_DfA()
      and Player:ComboPointsDeficit() >= 2 + (S.Subterfuge:IsAvailable() and 2 or 0)
      and (Player:BuffRemainsP(S.SymbolsofDeath) >= 1.2 or S.SymbolsofDeath:CooldownRemainsP() >= 12 + (S.DarkShadow:IsAvailable() and AC.Tier20_4Pc and 3 or 0) - (not S.DarkShadow:IsAvailable() and AC.Tier20_4Pc and 4 or 0))
      and (Cache.EnemiesCount[10] >= 4 or not Player:BuffP(S.TheFirstoftheDead)) then
      if StealthMacro(S.ShadowDance) then return "ShadowDance Macro 2"; end
    end
  end
  return false;
end
-- # Stealth Action List Starter
local function Stealth_ALS ()
  -- actions.stealth_als=call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
  if (Player:EnergyDeficitPredicted() <= Stealth_Threshold() - ((not S.GoremawsBite:CooldownUp() and not Player:BuffP(S.FeedingFrenzy)) and 25 or 0)
    and (not I.ShadowSatyrsWalk:IsEquipped() or S.ShadowDance:ChargesFractional() >= ShD_Fractional() or Player:EnergyDeficitPredicted() >= 10))
  -- actions.stealth_als+=/call_action_list,name=stealth_cds,if=mantle_duration>2.3
    or Rogue.MantleDuration() > 2.3
  -- actions.stealth_als+=/call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=4
    or Cache.EnemiesCount[10] >= 4
  -- actions.stealth_als+=/call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
    or (S.Shadowmeld:CooldownUp() and not S.Vanish:CooldownUp() and S.ShadowDance:Charges() <= 1)
  -- actions.stealth_als+=/call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
    or (Target:IsInBossList() and Target:TimeToDie() < 12*S.ShadowDance:ChargesFractional()*(I.ShadowSatyrsWalk:IsEquipped() and 1.5 or 1)) then
   return Stealth_CDs();
  end
  return false;
end

local MythicDungeon;
do
  local SappedSoulSpells = {
    {S.Kick, "Cast Kick (Sapped Soul)", function () return IsInMeleeRange(); end},
    {S.Feint, "Cast Feint (Sapped Soul)", function () return true; end},
    {S.CrimsonVial, "Cast Crimson Vial (Sapped Soul)", function () return true; end}
  };
  MythicDungeon = function ()
    -- Sapped Soul
    if AC.MythicDungeon() == "Sapped Soul" then
      for i = 1, #SappedSoulSpells do
        local Spell = SappedSoulSpells[i];
        if Spell[1]:IsCastable() and Spell[3]() then
          AR.ChangePulseTimer(1);
          AR.Cast(Spell[1]);
          return Spell[2];
        end
      end
    end
    return false;
  end
end
local function TrainingScenario ()
  if Target:CastName() == "Unstable Explosion" and Target:CastPercentage() > 60-10*Player:ComboPoints() then
    -- Kidney Shot
    if IsInMeleeRange() and S.KidneyShot:IsCastable() and Player:ComboPoints() > 0 then
      if AR.Cast(S.KidneyShot) then return "Cast Kidney Shot (Unstable Explosion)"; end
    end
  end
  return false;
end
local Interrupts = {
  {S.Blind, "Cast Blind (Interrupt)", function () return true; end},
  {S.KidneyShot, "Cast Kidney Shot (Interrupt)", function () return Player:ComboPoints() > 0; end},
  {S.CheapShot, "Cast Cheap Shot (Interrupt)", function () return Player:IsStealthed(true, true); end}
};

-- APL Main
local function APL ()
  -- Spell ID Changes check
  if S.Subterfuge:IsAvailable() then
    Stealth = S.Stealth2;
    VanishBuff = S.VanishBuff2;
  else
    Stealth = S.Stealth;
    VanishBuff = S.VanishBuff;
  end
  -- Unit Update
  AC.GetEnemies(10, true); -- Shuriken Storm & Death from Above
  AC.GetEnemies("Melee"); -- Melee
  Everyone.AoEToggleEnemiesUpdate();
  --- Defensives
    -- Crimson Vial
    ShouldReturn = Rogue.CrimsonVial (S.CrimsonVial);
    if ShouldReturn then return ShouldReturn; end
    -- Feint
    ShouldReturn = Rogue.Feint (S.Feint);
    if ShouldReturn then return ShouldReturn; end
  --- Out of Combat
    if not Player:AffectingCombat() then
      -- Stealth
    -- Note: Since 7.2.5, Blizzard disallowed Stealth cast under ShD (workaround to prevent the Extended Stealth bug)
      if not Player:Buff(S.ShadowDanceBuff) and not Player:Buff(VanishBuff) then
        ShouldReturn = Rogue.Stealth(Stealth);
        if ShouldReturn then return ShouldReturn; end
      end
      -- Flask
      -- Food
      -- Rune
      -- PrePot w/ Bossmod Countdown
      -- Opener
      if Everyone.TargetIsValid() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
        if Player:IsStealthed(true, true) then
          ShouldReturn = Stealthed();
          if ShouldReturn then return ShouldReturn .. " (OOC)"; end
          if Player:EnergyPredicted() < 30 then -- To avoid pooling icon spam
            if AR.Cast(S.PoolEnergy) then return "Stealthed Pooling (OOC)"; end
          else
            return "Stealthed Pooling (OOC)";
          end
        elseif Player:ComboPoints() >= 5 then
          ShouldReturn = Finish();
          if ShouldReturn then return ShouldReturn .. " (OOC)"; end
        elseif S.Backstab:IsCastable() then
          if AR.Cast(S.Backstab) then return "Cast Backstab (OOC)"; end
        end
      end
      return;
    end

    -- In Combat
    -- MfD Sniping
    Rogue.MfDSniping(S.MarkedforDeath);
    if Everyone.TargetIsValid() then
      -- Mythic Dungeon
      ShouldReturn = MythicDungeon();
      if ShouldReturn then return ShouldReturn; end
      -- Training Scenario
      ShouldReturn = TrainingScenario();
      if ShouldReturn then return ShouldReturn; end
      -- Interrupts
      Everyone.Interrupt(5, S.Kick, Settings.Commons.OffGCDasOffGCD.Kick, Interrupts);

      -- Note: DfA execute time is 1.475s, the buff is modeled to lasts 1.475s on SimC, while it's 1s in-game. So we retrieve it from TimeSinceLastCast.
      if DfAShadowDance() and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.DeathfromAbove:TimeSinceLastCast() <= 1.325 then
          if AR.Cast(S.ShadowDance) then
            -- Set the cooldown on the main frame to be equal to the delay we actually want, not the full GCD duration
            AR.MainIconFrame:SetCooldown(S.DeathfromAbove.LastCastTime, 1.325);
            return "Cast Shadow Dance (DfA)";
          end
      end

      -- # This is triggered only with DfA talent since we check shadow_dance even while the gcd is ongoing, it's purely for simulation performance.
      -- actions+=/wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
      -- actions+=/call_action_list,name=cds
      ShouldReturn = CDs();
      if ShouldReturn then return "CDs: " .. ShouldReturn; end
      -- actions+=/run_action_list,name=stealthed,if=stealthed.all
      if Player:IsStealthed(true, true) then
        ShouldReturn = Stealthed();
        if ShouldReturn then return "Stealthed: " .. ShouldReturn; end
        -- run_action_list forces the return
        if Player:EnergyPredicted() < 30 then -- To avoid pooling icon spam
          if AR.Cast(S.PoolEnergy) then return "Stealthed Pooling"; end
        else
          return "Stealthed Pooling";
        end
      end
      -- actions+=/nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
      if S.Nightblade:IsCastable() and IsInMeleeRange()
        and (Target:FilteredTimeToDie(">", 6) or Target:TimeToDieIsNotValid())
        and Rogue.CanDoTUnit(Target, S.Eviscerate:Damage()*Settings.Subtlety.EviscerateDMGOffset)
        and Target:DebuffRemainsP(S.Nightblade) < Player:GCD() and Player:ComboPoints() >= 4 - (AC.CombatTime() < 10 and 2 or 0) then
        if AR.Cast(S.Nightblade) then return "Cast Nightblade (Low Duration)"; end
      end
      if S.DarkShadow:IsAvailable() then
        -- actions+=/call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=2+buff.shadow_blades.up&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
        if Player:ComboPointsDeficit() >= 2 + (Player:BuffP(S.ShadowBlades) and 1 or 0) and (Target:DebuffRemainsP(S.Nightblade) > 4 + (S.Subterfuge:IsAvailable() and 1 or 0) or (S.ShadowDance:ChargesFractional() >= 1.9 and (not I.DenialoftheHalfGiants:IsEquipped() or AC.CombatTime() > 10))) then
          ShouldReturn = Stealth_ALS();
          if ShouldReturn then return "Stealth ALS 1: " .. ShouldReturn; end
        end
      else
        -- actions+=/call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=2+buff.shadow_blades.up|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
        if Player:ComboPointsDeficit() >= 2 + (Player:BuffP(S.ShadowBlades) and 1 or 0) or S.ShadowDance:ChargesFractional() >= 1.9 + (S.EnvelopingShadows:IsAvailable() and 1 or 0) then
          ShouldReturn = Stealth_ALS();
          if ShouldReturn then return "Stealth ALS 2: " .. ShouldReturn; end
        end
      end
      -- actions+=/call_action_list,name=finish,if=combo_points>=5+3*(buff.the_first_of_the_dead.up&talent.anticipation.enabled)+(talent.deeper_stratagem.enabled&!buff.shadow_blades.up&(mantle_duration=0|set_bonus.tier20_4pc)&(!buff.the_first_of_the_dead.up|variable.dsh_dfa))|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
      if Player:ComboPoints() >= 5 + (Player:BuffP(S.TheFirstoftheDead) and S.Anticipation:IsAvailable() and 3 or 0) + (S.DeeperStratagem:IsAvailable() and not Player:BuffP(S.ShadowBlades) and (Rogue.MantleDuration() == 0 or AC.Tier20_4Pc)
          and (not Player:BuffP(S.TheFirstoftheDead) or DSh_DfA()) and 1 or 0)
        or (Player:ComboPoints() >= 4 and Cache.EnemiesCount[10] >= 3 and Cache.EnemiesCount[10] <= 4)
        or (Target:FilteredTimeToDie("<=", 1) and Player:ComboPoints() >= 3) then
        ShouldReturn = Finish();
        if ShouldReturn then return "Finish 1: " .. ShouldReturn; end
      end
      -- actions+=/call_action_list,name=finish,if=buff.the_first_of_the_dead.remains>1&combo_points>=3&spell_targets.shuriken_storm<2&!buff.shadow_gestures.up
      if Player:BuffRemainsP(S.TheFirstoftheDead) > 1 and Player:ComboPoints() >= 3 and Cache.EnemiesCount[10] < 2 and not Player:BuffP(S.T21_4pc_Buff) then
        ShouldReturn = Finish();
        if ShouldReturn then return "Finish 2: " .. ShouldReturn; end
      end
      -- actions+=/call_action_list,name=finish,if=variable.dsh_dfa&equipped.the_first_of_the_dead&dot.nightblade.remains<=(cooldown.symbols_of_death.remains+10)&cooldown.symbols_of_death.remains<=2&combo_points>=2
      if DSh_DfA() and I.TheFirstoftheDead:IsEquipped() and Target:DebuffRemainsP(S.Nightblade) <= (S.SymbolsofDeath:CooldownRemainsP() + 10)
        and S.SymbolsofDeath:CooldownRemainsP() <= 2 and Player:ComboPoints() >= 2 then
        ShouldReturn = Finish();
        if ShouldReturn then return "Finish 3: " .. ShouldReturn; end
      end
      -- actions+=/wait,sec=time_to_sht.5,if=combo_points=5&time_to_sht.5<=1&energy.deficit>=30&!buff.shadow_blades.up
      if Player:ComboPoints() == 5 and Player:EnergyDeficitPredicted() >= 30 and not Player:Buff(S.ShadowBlades) and Player:TimeToSht(5) <= 1 then
        if AR.Cast(S.PoolEnergy) then return "Wait for Shadow Techniques"; end
      end
      -- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
      if Player:EnergyDeficitPredicted() <= Stealth_Threshold() then
        ShouldReturn = Build();
        if ShouldReturn then return "Build: " .. ShouldReturn; end
      end
      -- Shuriken Toss Out of Range
      if S.ShurikenToss:IsCastable(30) and not Target:IsInRange(10) and not Player:IsStealthed(true, true) and not Player:BuffP(S.Sprint)
        and Player:EnergyDeficitPredicted() < 20 and (Player:ComboPointsDeficit() >= 1 or Player:EnergyTimeToMax() <= 1.2) then
        if AR.Cast(S.ShurikenToss) then return "Cast Shuriken Toss"; end
      end
      -- Trick to take in consideration the Recovery Setting
      if S.Shadowstrike:IsCastable() and IsInMeleeRange() then
        if AR.Cast(S.PoolEnergy) then return "Normal Pooling"; end
      end
    end
end

AR.SetAPL(261, APL);

-- Last Update: 02/03/2018

-- # Executed before combat begins. Accepts non-harmful actions only.
-- actions.precombat=flask
-- actions.precombat+=/augmentation
-- actions.precombat+=/food
-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
-- actions.precombat+=/snapshot_stats
-- # Defined variables that doesn't change during the fight.
-- actions.precombat+=/variable,name=ssw_refund,value=equipped.shadow_satyrs_walk*(6+ssw_refund_offset)
-- actions.precombat+=/variable,name=stealth_threshold,value=(65+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10+variable.ssw_refund)
-- actions.precombat+=/variable,name=shd_fractional,value=1.725+0.725*talent.enveloping_shadows.enabled
-- actions.precombat+=/stealth
-- actions.precombat+=/marked_for_death,precombat=1
-- actions.precombat+=/potion

-- # Executed every time the actor is available.
-- actions=variable,name=dsh_dfa,value=talent.death_from_above.enabled&talent.dark_shadow.enabled&spell_targets.death_from_above<4
-- # This let us to use Shadow Dance right before the 2nd part of DfA lands. Only with Dark Shadow.
-- actions+=/shadow_dance,if=talent.dark_shadow.enabled&(!stealthed.all|buff.subterfuge.up)&buff.death_from_above.up&buff.death_from_above.remains<=0.15
-- # This is triggered only with DfA talent since we check shadow_dance even while the gcd is ongoing, it's purely for simulation performance.
-- actions+=/wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
-- actions+=/call_action_list,name=cds
-- # Fully switch to the Stealthed Rotation (by doing so, it forces pooling if nothing is available).
-- actions+=/run_action_list,name=stealthed,if=stealthed.all
-- actions+=/nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
-- actions+=/call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=2+buff.shadow_blades.up&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
-- actions+=/call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=2+buff.shadow_blades.up|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
-- actions+=/call_action_list,name=finish,if=combo_points>=5+3*(buff.the_first_of_the_dead.up&talent.anticipation.enabled)+(talent.deeper_stratagem.enabled&!buff.shadow_blades.up&(mantle_duration=0|set_bonus.tier20_4pc)&(!buff.the_first_of_the_dead.up|variable.dsh_dfa))|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
-- actions+=/call_action_list,name=finish,if=buff.the_first_of_the_dead.remains>1&combo_points>=3&spell_targets.shuriken_storm<2&!buff.shadow_gestures.up
-- actions+=/call_action_list,name=finish,if=variable.dsh_dfa&equipped.the_first_of_the_dead&dot.nightblade.remains<=(cooldown.symbols_of_death.remains+10)&cooldown.symbols_of_death.remains<=2&combo_points>=2
-- actions+=/wait,sec=time_to_sht.5,if=combo_points=5&time_to_sht.5<=1&energy.deficit>=30&!buff.shadow_blades.up
-- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold

-- # Builders
-- actions.build=shuriken_storm,if=spell_targets.shuriken_storm>=2+(buff.the_first_of_the_dead.up|buff.symbols_of_death.up|buff.master_of_subtlety.up)
-- actions.build+=/gloomblade
-- actions.build+=/backstab

-- # Cooldowns
-- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
-- actions.cds+=/use_item,name=specter_of_betrayal,if=talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&buff.shadow_dance.up&(buff.symbols_of_death.up|(!talent.death_from_above.enabled&((mantle_duration>=3|!equipped.mantle_of_the_master_assassin)|cooldown.vanish.remains>=43)))
-- actions.cds+=/use_item,name=specter_of_betrayal,if=!talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&(mantle_duration>=3|!equipped.mantle_of_the_master_assassin)
-- actions.cds+=/blood_fury,if=stealthed.rogue
-- actions.cds+=/berserking,if=stealthed.rogue
-- actions.cds+=/arcane_torrent,if=stealthed.rogue&energy.deficit>70
-- actions.cds+=/symbols_of_death,if=!talent.death_from_above.enabled
-- actions.cds+=/symbols_of_death,if=(talent.death_from_above.enabled&cooldown.death_from_above.remains<=1&(dot.nightblade.remains>=cooldown.death_from_above.remains+3|target.time_to_die-dot.nightblade.remains<=6)&(time>=3|set_bonus.tier20_4pc|equipped.the_first_of_the_dead))|target.time_to_die-remains<=10
-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
-- actions.cds+=/marked_for_death,if=raid_event.adds.in>40&!stealthed.all&combo_points.deficit>=cp_max_spend
-- actions.cds+=/shadow_blades,if=(time>10&combo_points.deficit>=2+stealthed.all-equipped.mantle_of_the_master_assassin)|(time<10&(!talent.marked_for_death.enabled|combo_points.deficit>=3|dot.nightblade.ticking))
-- actions.cds+=/goremaws_bite,if=!stealthed.all&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&((combo_points.deficit>=4-(time<10)*2&energy.deficit>50+talent.vigor.enabled*25-(time>=10)*15)|(combo_points.deficit>=1&target.time_to_die<8))
-- actions.cds+=/pool_resource,for_next=1,extra_amount=55-talent.shadow_focus.enabled*10
-- actions.cds+=/vanish,if=energy>=55-talent.shadow_focus.enabled*10&variable.dsh_dfa&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&!buff.shadow_dance.up&!buff.stealth.up&mantle_duration=0&(dot.nightblade.remains>=cooldown.death_from_above.remains+6&!(buff.the_first_of_the_dead.remains>1&combo_points>=5)|target.time_to_die-dot.nightblade.remains<=6)&cooldown.death_from_above.remains<=1|target.time_to_die<=7
-- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=4+talent.subterfuge.enabled

-- # Finishers
-- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&(mantle_duration=0|remains<=mantle_duration)&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
-- actions.finish+=/nightblade,cycle_targets=1,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>12&mantle_duration=0&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
-- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5+(combo_points=6)&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
-- actions.finish+=/death_from_above,if=!talent.dark_shadow.enabled|(!buff.shadow_dance.up|spell_targets>=4)&(buff.symbols_of_death.up|cooldown.symbols_of_death.remains>=10+set_bonus.tier20_4pc*5)&buff.the_first_of_the_dead.remains<1&(buff.finality_eviscerate.up|spell_targets.shuriken_storm<4)
-- actions.finish+=/eviscerate

-- # Stealth Action List Starter
-- actions.stealth_als=call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
-- actions.stealth_als+=/call_action_list,name=stealth_cds,if=mantle_duration>2.3
-- actions.stealth_als+=/call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=4
-- actions.stealth_als+=/call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
-- actions.stealth_als+=/call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)

-- # Stealth Cooldowns
-- actions.stealth_cds=vanish,if=!variable.dsh_dfa&mantle_duration=0&cooldown.shadow_dance.charges_fractional<variable.shd_fractional+(equipped.mantle_of_the_master_assassin&time<30)*0.3&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)
-- actions.stealth_cds+=/shadow_dance,if=dot.nightblade.remains>=5&charges_fractional>=variable.shd_fractional|target.time_to_die<cooldown.symbols_of_death.remains
-- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40
-- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
-- actions.stealth_cds+=/shadow_dance,if=!variable.dsh_dfa&combo_points.deficit>=2+talent.subterfuge.enabled*2&(buff.symbols_of_death.remains>=1.2|cooldown.symbols_of_death.remains>=12+(talent.dark_shadow.enabled&set_bonus.tier20_4pc)*3-(!talent.dark_shadow.enabled&set_bonus.tier20_4pc)*4|mantle_duration>0)&(spell_targets.shuriken_storm>=4|!buff.the_first_of_the_dead.up)

-- # Stealthed Rotation
-- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
-- actions.stealthed=shadowstrike,if=buff.stealth.up
-- actions.stealthed+=/call_action_list,name=finish,if=combo_points>=5&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration>=0.3))
-- actions.stealthed+=/shuriken_storm,if=buff.shadowmeld.down&((combo_points.deficit>=2+equipped.insignia_of_ravenholdt&spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk)|(combo_points.deficit>=1&buff.the_dreadlords_deceit.stack>=29))
-- actions.stealthed+=/call_action_list,name=finish,if=combo_points>=5&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
-- actions.stealthed+=/shadowstrike
