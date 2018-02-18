--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AC = ...;
  -- AethysCore
  local Cache = AethysCache;
  local Unit = AC.Unit;
  local Player = Unit.Player;
  local Pet = Unit.Pet;
  local Target = Unit.Target;
  local Spell = AC.Spell;
  local Item = AC.Item;
  -- Lua
  local pairs = pairs;
  local stringgsub = string.gsub;
  local tableinsert = table.insert;
  -- File Locals
  local KeyBindings = {};


--- ============================ CONTENT ============================
  --[[*
    * @function FindKeyBindings
    * @desc List every actions presents in action bars, sorted by their type (item, macro, spell).
    *
    * @returns {table}
    *]]
  local function FindKeyBindings ()
    --- Populate KeyBindings
    local ShortKBSubString = {
      ["-"] = ":", -- TODO: Add options to choose the separator : { ":", "", "~", ",", ".", "_", "-", " "}.
      ["ALT"] = "A",
      ["CTRL"] = "C",
      ["SHIFT"] = "S",
      ["NUMPAD"] = "N",
      ["DIVIDE"] = "/",
      ["MINUS"] = "-",
      ["MULTIPLY"] = "*",
      ["PLUS"] = "+",
      ["BUTTON"] = "M"
    };
    local function ShortenKB (KeyBinding)
      for Pattern, Replace in pairs ( ShortKBSubString ) do
        KeyBinding = stringgsub( KeyBinding, Pattern, Replace );
      end

      -- Hotfix for Numpad "-"
      KeyBinding = stringgsub( KeyBinding, "N:", "N-" );

      return KeyBinding;
    end
  
    local Commands = {};
    --- Populate Actions
    -- SlotIndex      ActionFrame                     CommandName
    -- 1..12        = ActionButton (Primary Bar)      ACTIONBUTTON..Slot
    -- 13..24       = ActionButton (Secondary Bar)    ACTIONBUTTON..Slot
    -- 25..36       = MultiBarRightButton             MULTIACTIONBAR3BUTTON..j
    -- 37..48       = MultiBarLeftButton              MULTIACTIONBAR4BUTTON..j
    -- 49..60       = MultiBarBottomRightButton       MULTIACTIONBAR2BUTTON..j
    -- 61..72       = MultiBarBottomLeftButton        MULTIACTIONBAR1BUTTON..j
    -- 72..120      = ?                               ACTIONBUTTON..Slot
    -- Where Slot is the SlotIndex in 1..120
    -- and j is the bar index in 1..12 for MULTIACTIONBARs
    local CommandNames = {
      [3] = "MULTIACTIONBAR3BUTTON",
      [4] = "MULTIACTIONBAR4BUTTON",
      [5] = "MULTIACTIONBAR2BUTTON",
      [6] = "MULTIACTIONBAR1BUTTON"
    };
    local BTCommandLeft = "CLICK BT4Button";
    local BTCommandRight = ":LeftButton";
    for i = 1, 10 do
      local CommandName = CommandNames[ i ] or "ACTIONBUTTON";
      for j = 1, 12 do
        local Slot = 12 * (i - 1) + j;
        local CommandName;
        if CommandNames[ i ] then
          CommandName = CommandNames[ i ] .. j;
        else
          CommandName = "ACTIONBUTTON" .. Slot;
        end
        if HasAction( Slot ) then
          local ActionType, ActionID, ActionSubtype, SpellID = GetActionInfo( Slot );
          if not Commands[ CommandName ] then Commands[ CommandName ] = {}; end
          tableinsert( Commands[ CommandName ], {
            ActionType = ActionType,
            ActionID = ActionID,
            ActionSubtype = ActionSubtype
          } );
        end
        local BTCommandName = BTCommandLeft .. Slot .. BTCommandRight;
        local BTKeybind = GetBindingKey(BTCommandName);
        local Binding = BTKeybind and ShortenKB(BTKeybind) or "";
        if Binding then
          local ActionType, ActionID, ActionSubtype, SpellID = GetActionInfo( Slot );
          if not Commands[ BTCommandName ] then Commands[ BTCommandName ] = {}; end
          tableinsert( Commands[ BTCommandName ], {
            ActionType = ActionType,
            ActionID = ActionID,
            ActionSubtype = ActionSubtype,
            Binding = Binding
          } );
        end
      end
    end
    
    for i = 1, GetNumBindings() do
      local CommandName, Category, Binding1, Binding2 = GetBinding( i );
      local Actions = Commands[ CommandName ];
      if Actions then
        local Binding = Binding1 and ShortenKB( Binding1 ) or "";
        for _, Action in pairs( Actions ) do
          Action.Binding = Binding;
        end
      end
    end

    --- Map Actions -> KeyBindings
    local KeyBindings = {
      Item = {},
      Macro = {},
      Spell = {}
    };
    for _, Actions in pairs( Commands ) do
      for _, Action in pairs( Actions ) do
        local ActionType = Action.ActionType;
        local ActionID = Action.ActionID;
        local Binding = Action.Binding;
        if Binding and Binding ~= "" then
          if ActionType == "item" then
            KeyBindings.Item[ ActionID ] = Binding;
          elseif ActionType == "macro" then
            local Name = GetMacroInfo( ActionID );
            if Name then KeyBindings.Macro[ Name ] = Binding; end
          elseif ActionType == "spell" then
            KeyBindings.Spell[ ActionID ] = Binding;
          end
        end
      end
    end

    return KeyBindings;
  end

  AC:RegisterForEvent(
    function ()
      KeyBindings = FindKeyBindings();
    end
    , "ZONE_CHANGED_NEW_AREA"
    , "PLAYER_SPECIALIZATION_CHANGED"
    , "PLAYER_TALENT_UPDATE"
    , "ACTIONBAR_SLOT_CHANGED"
    , "UPDATE_BINDINGS"
    , "LEARNED_SPELL_IN_TAB"
  );

  --- TODO: With the Action class (Item/Macro/Spell) rework, this is going to change.
  function AC.FindMacroKeyBinding (Name)
    return KeyBindings.Macro[ Name ] or false;
  end

  function Item:FindKeyBinding ()
    return KeyBindings.Item[ self.ItemID ] or false;
  end

  function Spell:FindKeyBinding ()
    return KeyBindings.Spell[ self.SpellID ] or false;
  end
