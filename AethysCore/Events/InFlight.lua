--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AC = ...;
  -- AethysCore
  local Cache = AethysCache;
  local Unit = AC.Unit;
  local Player = Unit.Player;
  local Spell = AC.Spell;
  -- Lua
  local pairs = pairs;
  -- File Locals
  local TrackedSpells = {};

--- ============================ CONTENT ============================
function Spell:RegisterInFlight (...)
  Arg = {...};
  TrackedSpells[self.SpellID] = {
    Inflight = false, 
    DestGUID = nil, 
    Count = 0,
    Auras = {}
  };
  for _, v in pairs(Arg) do
    if v.SpellID then
      TrackedSpells[self.SpellID].Auras[v] = false;
    end
  end
end

AC:RegisterForSelfCombatEvent(
  function (...)
    local spellID = select(12, ...)
    local TrackedSpell = TrackedSpells[spellID]
    if TrackedSpell then
      TrackedSpell.DestGUID = select(8, ...);
      TrackedSpell.Count = TrackedSpell.Count + 1;
      TrackedSpell.Inflight = true;
      for k, _ in pairs(TrackedSpell.Auras) do
        TrackedSpell.Auras[k] = Player:Buff(k) or k:TimeSinceLastRemovedOnPlayer() < 0.1;
      end
      -- Backup clear
      C_Timer.After(2, function ()
          if TrackedSpell.Count == 1 then
            TrackedSpell.Inflight = false;
          end
          TrackedSpell.Count = TrackedSpell.Count - 1;
        end
      );
    end
  end
  , "SPELL_CAST_SUCCESS"
);
AC:RegisterForSelfCombatEvent(
  function (...)
    local DestGUID, _, _, _, spellID = select(8, ...)
    local TrackedSpell = TrackedSpells[spellID]
    if TrackedSpell and DestGUID == TrackedSpell.DestGUID then
      TrackedSpell.Inflight = false;
    end
  end
  , "SPELL_DAMAGE"
  , "SPELL_MISSED"
);
-- Prevent InFlight getting stuck when target dies mid-flight
AC:RegisterForCombatEvent(
  function (...)
    local DestGUID = select(8, ...);
    for spellID, _ in pairs(TrackedSpells) do
      if TrackedSpells[spellID].DestGUID == DestGUID then
        TrackedSpells[spellID].Inflight = false;
      end
    end
  end
  , "UNIT_DIED"
  , "UNIT_DESTROYED"
);

function Spell:InFlight (Aura)
  local TrackedSpell = TrackedSpells[self.SpellID]
  if TrackedSpell and Aura then
    return TrackedSpell.Inflight and TrackedSpell.Auras[Aura];
  elseif TrackedSpell then
    return TrackedSpell.Inflight;
  else
    error("You forgot to register " .. self:Name() .. " for InFlight tracking.")
  end
end
