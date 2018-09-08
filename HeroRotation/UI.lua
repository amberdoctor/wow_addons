--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, HR = ...;
  -- HeroLib
  local HL = HeroLib;
  local Cache = HeroCache;
  local Unit = HL.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = HL.Spell;
  local Item = HL.Item;
  -- Lua
  local pairs = pairs;
  local stringlower = string.lower;
  local tostring = tostring;
  -- File Locals



--- ============================ CONTENT ============================
--- ======= MAIN FRAME =======
  HR.MainIconFrame = CreateFrame("Frame", "HeroRotation_MainIconFrame", UIParent);
  HR.MainIconPartOverlayFrame = CreateFrame("Frame", "HeroRotation_MainIconPartOverlayFrame", UIParent);
  HR.MainIconFrame.Part = {};
  HR.MainIconFrame.CooldownFrame = CreateFrame("Cooldown", "HeroRotation_MainIconCooldownFrame", HR.MainIconFrame, "AR_CooldownFrameTemplate");
  HR.SmallIconFrame = CreateFrame("Frame", "HeroRotation_SmallIconFrame", UIParent);
  HR.LeftIconFrame = CreateFrame("Frame", "HeroRotation_LeftIconFrame", UIParent);
  HR.NameplateIconFrame = CreateFrame("Frame", "HeroRotation_NameplateIconFrame", UIParent);
  HR.SuggestedIconFrame = CreateFrame("Frame", "HeroRotation_SuggestedIconFrame", UIParent);
  HR.ToggleIconFrame = CreateFrame("Frame", "HeroRotation_ToggleIconFrame", UIParent);

--- ======= MISC =======
  -- Reset Textures
  local IdleSpellTexture = HR.GetTexture(Spell(9999000000));
  function HR.ResetIcons ()
    -- Main Icon
    HR.MainIconFrame:Hide();
    if HR.GUISettings.General.BlackBorderIcon then HR.MainIconFrame.Backdrop:Hide(); end
    HR.MainIconPartOverlayFrame:Hide();
    HR.MainIconFrame:HideParts();

    -- Small Icons
    HR.SmallIconFrame:HideIcons();
    HR.CastOffGCDOffset = 1;

    -- Left/Nameplate Icons
    HR.Nameplate.HideIcons();
    HR.CastLeftOffset = 1;

    -- Suggested Icon
    HR.SuggestedIconFrame:HideIcon();
    if HR.GUISettings.General.BlackBorderIcon then HR.SuggestedIconFrame.Backdrop:Hide(); end
    HR.CastSuggestedOffset = 1;

    -- Toggle icons
    if HR.GUISettings.General.HideToggleIcons then HR.ToggleIconFrame:Hide(); end
  end

  -- Create a Backdrop
  function HR:CreateBackdrop (Frame)
    if Frame.Backdrop or not HR.GUISettings.General.BlackBorderIcon then return; end

    local Backdrop = CreateFrame("Frame", nil, Frame);
    Frame.Backdrop = Backdrop;
    Backdrop:ClearAllPoints();
    Backdrop:SetPoint("TOPLEFT", Frame, "TOPLEFT", -1, 1);
    Backdrop:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", 1, -1);

    Backdrop:SetBackdrop({
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
      tile = false,
      tileSize = 0,
      edgeSize = 1,
      insets = { left = 0, right = 0, top = 0, bottom = 0 },
    });

    Backdrop:SetBackdropBorderColor(0, 0, 0);
    Backdrop:SetBackdropColor(0, 0, 0, 1);

    Backdrop:SetFrameStrata(HR.MainFrame:GetFrameStrata());
    if Frame:GetFrameLevel() - 2 >= 0 then
      Backdrop:SetFrameLevel(Frame:GetFrameLevel() - 2);
    else
      Backdrop:SetFrameLevel(0);
    end
  end

--- ======= MAIN ICON =======
  -- Init
  function HR.MainIconFrame:Init ()
    -- Frame Init
    self:SetFrameStrata(HR.MainFrame:GetFrameStrata());
    self:SetFrameLevel(HR.MainFrame:GetFrameLevel() - 1);
    self:SetWidth(64);
    self:SetHeight(64);
    self:SetPoint("BOTTOMRIGHT", HR.MainFrame, "BOTTOMRIGHT", 0, 0);
    -- Texture
    self.Texture = self:CreateTexture(nil, "ARTWORK");
    self.Texture:SetAllPoints(self);
    -- Cooldown
    self.CooldownFrame:SetAllPoints(self);

    HR.MainIconPartOverlayFrame:SetFrameStrata(self:GetFrameStrata());
    HR.MainIconPartOverlayFrame:SetFrameLevel(self:GetFrameLevel() + 1);
    HR.MainIconPartOverlayFrame:SetWidth(64);
    HR.MainIconPartOverlayFrame:SetHeight(64);
    HR.MainIconPartOverlayFrame:SetPoint("Left", self, "Left", 0, 0);
    HR.MainIconPartOverlayFrame.Texture = HR.MainIconPartOverlayFrame:CreateTexture(nil, "ARTWORK");
    HR.MainIconPartOverlayFrame.Texture:SetAllPoints(HR.MainIconPartOverlayFrame);
    -- Keybind
    local KeybindFrame = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    self.Keybind = KeybindFrame;
    KeybindFrame:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
    KeybindFrame:SetAllPoints(true);
    KeybindFrame:SetJustifyH("RIGHT");
    KeybindFrame:SetJustifyV("TOP");
    KeybindFrame:SetPoint("TOPRIGHT");
    KeybindFrame:SetTextColor(0.8,0.8,0.8,1);
    KeybindFrame:SetText("");
    -- Overlay Text
    local TextFrame = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    self.Text = TextFrame;
    TextFrame:SetAllPoints(true);
    TextFrame:SetJustifyH("CENTER");
    TextFrame:SetJustifyV("CENTER");
    TextFrame:SetPoint("CENTER");
    TextFrame:SetTextColor(1,1,1,1);
    TextFrame:SetText("");
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon then
      self.Texture:SetTexCoord(.08, .92, .08, .92);
      HR:CreateBackdrop(self);
    end
    -- Parts
    self:InitParts();
    -- Display
    self:Show();
  end
  -- Change Icon
  function HR.MainIconFrame:ChangeIcon (Texture, Keybind, Usable)
    -- Texture
    self.Texture:SetTexture(Texture);
    if HR.GUISettings.General.NotEnoughManaEnabled and not Usable then
      self.Texture:SetGradient("HORIZONTAL", 0.5, 0.5, 1.0, 0.5, 0.5, 1.0);
    else
      self.Texture:SetGradient("HORIZONTAL", 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
    end
    self.Texture:SetAllPoints(self);
    -- Keybind
    if Keybind then
      self.Keybind:SetText(Keybind);
    else
      self.Keybind:SetText("");
    end
    -- Overlay Text
    self.Text:SetText("");
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon and not self.Backdrop:IsVisible() then
      self.Backdrop:Show();
    end
    -- Display
    if not self:IsVisible() then
      self:Show();
    end
  end
  -- Set text on frame
  function HR.MainIconFrame:OverlayText(Text)
    self.Text:SetText(Text);
  end
  -- Set a Cooldown Frame
  function HR.MainIconFrame:SetCooldown (Start, Duration)
    self.CooldownFrame:SetCooldown(Start, Duration);
  end
  function HR.MainIconFrame:InitParts ()
    HR.MainIconPartOverlayFrame:Show();
    for i = 1, HR.MaxQueuedCasts do
      -- Frame Init
      local PartFrame = CreateFrame("Frame", "HeroRotation_MainIconPartFrame"..tostring(i), UIParent);
      self.Part[i] = PartFrame;
      PartFrame:SetFrameStrata(self:GetFrameStrata());
      PartFrame:SetFrameLevel(self:GetFrameLevel() + 1);
      PartFrame:SetWidth(64);
      PartFrame:SetHeight(64);
      PartFrame:SetPoint("Left", self, "Left", 0, 0);
      -- Texture
      PartFrame.Texture = PartFrame:CreateTexture(nil, "BACKGROUND");
      -- Keybind
      PartFrame.Keybind = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
      PartFrame.Keybind:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE");
      PartFrame.Keybind:SetAllPoints(true);
      PartFrame.Keybind:SetJustifyH("RIGHT");
      PartFrame.Keybind:SetJustifyV("TOP");
      PartFrame.Keybind:SetPoint("TOPRIGHT");
      PartFrame.Keybind:SetTextColor(0.8,0.8,0.8,1);
      PartFrame.Keybind:SetText("");
      -- Black Border Icon
      if HR.GUISettings.General.BlackBorderIcon then
        PartFrame.Texture:SetTexCoord(.08, .92, .08, .92);
        HR:CreateBackdrop(PartFrame);
      end
      -- Display
      PartFrame:Show();
    end
  end
  local QueuedCasts, FrameWidth;
  function HR.MainIconFrame:SetupParts (Textures, Keybinds)
    QueuedCasts = #Textures;
    FrameWidth = (HR.MainIconPartOverlayFrame.Texture:GetWidth() / QueuedCasts) * (HeroRotationDB.GUISettings["General.ScaleUI"] or 1)
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = HR.MainIconPartOverlayFrame.Texture:GetTexCoord();
    for i = 1, QueuedCasts do
      local PartFrame = self.Part[i];
      -- Size & Position
      PartFrame:SetWidth(FrameWidth);
      PartFrame:SetHeight(FrameWidth*QueuedCasts);
      PartFrame:ClearAllPoints();
      local _, AnchorPoint = HR.MainIconPartOverlayFrame.Texture:GetPoint();
      if i == HR.MaxQueuedCasts or i == QueuedCasts then
        PartFrame:SetPoint("Center", AnchorPoint, "Center", FrameWidth/(4-QueuedCasts), 0);
      else
        PartFrame:SetPoint("Center", AnchorPoint, "Center", (FrameWidth/(4-QueuedCasts))*(i-2), 0);
      end
      PartFrame.Texture:SetTexture(Textures[i]);
      PartFrame.Texture:SetAllPoints(PartFrame);
      if PartFrame.Backdrop then
        if HR.MainIconPartOverlayFrame.__MSQ_NormalColor then
          PartFrame.Backdrop:Hide();
        else
          PartFrame.Backdrop:Show();
        end
      end
      local Blackborder = HR.GUISettings.General.BlackBorderIcon and not HR.MainIconPartOverlayFrame.__MSQ_NormalColor;
      local leftxslice = ((i-1)/QueuedCasts);
      local rightxslice = (i/QueuedCasts);
      PartFrame.Texture:SetTexCoord(
        i == 1 and (Blackborder and ULx + 0.08 or ULx) or (URx * leftxslice),
        i == 1 and (Blackborder and ULy + 0.08 or ULy) or (Blackborder and URy + 0.08 or URy),
        i == 1 and (Blackborder and LLx + 0.08 or LLx) or (LRx * leftxslice),
        i == 1 and (Blackborder and LLy - 0.08 or LLy) or (Blackborder and LRy - 0.08 or LRy),
        (i == QueuedCasts and Blackborder) and (URx * rightxslice) - 0.08 or URx * rightxslice,
        Blackborder and URy + 0.08 or URy,
        (i == QueuedCasts and Blackborder) and (LRx * rightxslice) - 0.08 or LRx * rightxslice,
        Blackborder and LRy - 0.08 or LRy
      );

      PartFrame.Keybind:SetText(Keybinds[i]);
      -- Keybind
      if Keybind then
        PartFrame.Keybind:SetText(Keybinds[i]);
      else
        PartFrame.Keybind:SetText("");
      end
      -- Display
      if not PartFrame:IsVisible() then
        HR.MainIconPartOverlayFrame:Show();
        PartFrame:Show();
      end
    end
  end
  function HR.MainIconFrame:HideParts ()
    HR.MainIconPartOverlayFrame:Hide();
    for i = 1, #self.Part do
      self.Part[i]:Hide();
    end
  end

--- ======= SMALL ICONS =======
  -- Init
  function HR.SmallIconFrame:Init ()
    -- Frame Container
    self:SetFrameStrata(HR.MainFrame:GetFrameStrata());
    self:SetFrameLevel(HR.MainFrame:GetFrameLevel() - 1);
    self:SetWidth(64);
    self:SetHeight(32);
    self:SetPoint("BOTTOMLEFT", HR.MainIconFrame, "TOPLEFT", 0, HR.GUISettings.General.BlackBorderIcon and 1 or 0);

    -- Frames
    self.Icon = {};
    self:CreateIcons(1, "LEFT");
    self:CreateIcons(2, "RIGHT");

    -- Display
    self:Show();
  end
  -- Create Small Icons Frames
  function HR.SmallIconFrame:CreateIcons (Index, Align)
    -- Frame Init
    local IconFrame = CreateFrame("Frame", "HeroRotation_SmallIconFrame"..tostring(Index), UIParent);
    self.Icon[Index] = IconFrame;
    IconFrame:SetFrameStrata(self:GetFrameStrata());
    IconFrame:SetFrameLevel(self:GetFrameLevel() - 1);
    IconFrame:SetWidth(HR.GUISettings.General.BlackBorderIcon and 30 or 32);
    IconFrame:SetHeight(HR.GUISettings.General.BlackBorderIcon and 30 or 32);
    IconFrame:SetPoint(Align, self, Align, 0, 0);
    -- Texture
    IconFrame.Texture = IconFrame:CreateTexture(nil, "ARTWORK");
    -- Keybind
    local Keybind = IconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    IconFrame.Keybind = Keybind;
    Keybind:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    Keybind:SetAllPoints(true);
    Keybind:SetJustifyH("RIGHT");
    Keybind:SetJustifyV("TOP");
    Keybind:SetPoint("TOPRIGHT");
    Keybind:SetTextColor(0.8,0.8,0.8,1);
    Keybind:SetText("");
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon then
      IconFrame.Texture:SetTexCoord(.08, .92, .08, .92);
      HR:CreateBackdrop(IconFrame);
    end
    -- Display
    IconFrame:Show();
  end
  -- Change Icon
  function HR.SmallIconFrame:ChangeIcon (FrameID, Texture, Keybind)
    local IconFrame = self.Icon[FrameID];
    -- Texture
    IconFrame.Texture:SetTexture(Texture);
    IconFrame.Texture:SetAllPoints(IconFrame);
    -- Keybind
    if Keybind then
      IconFrame.Keybind:SetText(Keybind);
    else
      IconFrame.Keybind:SetText("");
    end
    -- Display
    if not IconFrame:IsVisible() then
      IconFrame:Show();
    end
  end
  -- Hide Small Icons
  function HR.SmallIconFrame:HideIcons ()
    for i = 1, #self.Icon do
      self.Icon[i]:Hide();
    end
  end

--- ======= LEFT ICON =======
  -- Init LeftIcon
  function HR.LeftIconFrame:Init ()
    -- Frame Init
    self:SetFrameStrata(HR.MainFrame:GetFrameStrata());
    self:SetFrameLevel(HR.MainFrame:GetFrameLevel() - 1);
    self:SetWidth(48);
    self:SetHeight(48);
    self:SetPoint("RIGHT", HR.MainIconFrame, "LEFT", HR.GUISettings.General.BlackBorderIcon and -1 or 0, 0);
    -- Texture
    self.Texture = self:CreateTexture(nil, "BACKGROUND");
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon then
      self.Texture:SetTexCoord(.08, .92, .08, .92);
      HR:CreateBackdrop(self);
    end
    -- Display
    self:Show();
  end
  -- Change Icon
  function HR.LeftIconFrame:ChangeIcon (Texture)
    -- Texture
    self.Texture:SetTexture(Texture);
    self.Texture:SetAllPoints(self);
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon and not self.Backdrop:IsVisible() then
      self.Backdrop:Show();
    end
    -- Display
    if not self:IsVisible() then
      self:Show();
    end
  end

--- ======= NAMEPLATES =======
  HR.Nameplate = {
    Initialized = false
  };
  -- Add the Icon on Nameplates
  function HR.Nameplate.AddIcon (ThisUnit, Object)
    if HR.GUISettings.General.NamePlateIconAnchor == "Disable" then return true end
    local Token = stringlower(ThisUnit.UnitID);
    local Nameplate = C_NamePlate.GetNamePlateForUnit(Token);
    if Nameplate then
      -- Locals
      local ScreenHeight = GetScreenHeight();
      local NameplateScaler = (ScreenHeight > 768) and (768 / ScreenHeight) or 1;
      local NameplateIconSize = Nameplate:GetHeight() / NameplateScaler;
      local HealthBar;
      if HR.GUISettings.General.NamePlateIconAnchor == "Life Bar" then
        if _G.ElvUI and _G.ElvUI[1].NamePlates then
          HealthBar = Nameplate.unitFrame.HealthBar;
          NameplateIconSize = HealthBar:GetWidth() / 3.5;
        elseif _G.ShestakUI and _G.ShestakUI[2].nameplate.enable then
          HealthBar = Nameplate.unitFrame.Health;
          NameplateIconSize = (HealthBar:GetWidth() / NameplateScaler) / 3.5;
        else
          HealthBar = Nameplate.UnitFrame.healthBar;
          NameplateIconSize = (HealthBar:GetWidth() / NameplateScaler) / 3.5;
        end
      end
      local IconFrame = HR.NameplateIconFrame;

      -- Init Frame if not already
      if not HR.Nameplate.Initialized then
        -- Frame
        IconFrame:SetFrameStrata(Nameplate:GetFrameStrata());
        IconFrame:SetFrameLevel(Nameplate:GetFrameLevel() + 50);
        IconFrame:SetWidth(NameplateIconSize);
        IconFrame:SetHeight(NameplateIconSize);
        -- Texture
        IconFrame.Texture = IconFrame:CreateTexture(nil, "BACKGROUND");

        if HR.GUISettings.General.BlackBorderIcon then
          IconFrame.Texture:SetTexCoord(.08, .92, .08, .92);
          HR:CreateBackdrop(IconFrame);
        end

        HR.Nameplate.Initialized = true;
      end

      -- Set the Texture
      IconFrame.Texture:SetTexture(HR.GetTexture(Object));
      IconFrame.Texture:SetAllPoints(IconFrame);
      IconFrame.Texture:SetAlpha(ThisUnit:IsInRange(Object) and 1 or 0.4);
      IconFrame:ClearAllPoints();
      if not IconFrame:IsVisible() then
        if HR.GUISettings.General.NamePlateIconAnchor == "Life Bar" then
          IconFrame:SetPoint("CENTER", HealthBar);
        else
          IconFrame:SetPoint("CENTER", Nameplate);
        end
        IconFrame:Show();
      end

      -- Register the Unit for Error Checks (see Not Facing Unit Blacklist in Events.lua)
      HR.LastUnitCycled = ThisUnit;
      HR.LastUnitCycledTime = HL.GetTime();

      return true;
    end
    return false;
  end
  -- Remove Icons
  function HR.Nameplate.HideIcons ()
    -- Nameplate Icon
    HR.NameplateIconFrame:Hide();
    -- Left Icon
    HR.LeftIconFrame:Hide();
  end

--- ======= SUGGESTED ICON =======
  -- Init
  function HR.SuggestedIconFrame:Init ()
    -- Frame Init
    self:SetFrameStrata(HR.MainFrame:GetFrameStrata());
    self:SetFrameLevel(HR.MainFrame:GetFrameLevel() - 1);
    self:SetWidth(32);
    self:SetHeight(32);
    self:SetPoint("BOTTOM", HR.MainIconFrame, "LEFT", -HR.LeftIconFrame:GetWidth()/2, HR.LeftIconFrame:GetHeight()/2+(HR.GUISettings.General.BlackBorderIcon and 3 or 4));
    -- Texture
    self.Texture = self:CreateTexture(nil, "BACKGROUND");
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon then
      self.Texture:SetTexCoord(.08, .92, .08, .92);
      HR:CreateBackdrop(self);
    end
    -- Display
    self:Show();
  end
  -- Change Icon
  function HR.SuggestedIconFrame:ChangeIcon (Texture)
    -- Texture
    self.Texture:SetTexture(Texture);
    self.Texture:SetAllPoints(self);
    -- Black Border Icon
    if HR.GUISettings.General.BlackBorderIcon and not self.Backdrop:IsVisible() then
      self.Backdrop:Show();
    end
    -- Display
    if not self:IsVisible() then
      self:Show();
    end
  end
  -- Hide Icon
  function HR.SuggestedIconFrame:HideIcon ()
    HR.SuggestedIconFrame:Hide();
  end

--- ======= TOGGLES =======
  -- Init
  function HR.ToggleIconFrame:Init ()
    -- Frame Init
    self:SetFrameStrata(HR.MainFrame:GetFrameStrata());
    self:SetFrameLevel(HR.MainFrame:GetFrameLevel() - 1);
    self:SetWidth(64);
    self:SetHeight(20);

    -- Reset the Anchor if saved data are not valid (i.e. data saved before 7.1.5843)
    -- TODO: Remove this part later.
    if HeroRotationDB and HeroRotationDB.ButtonsFramePos and type(HeroRotationDB.ButtonsFramePos[2]) ~= "string" then
      self:ResetAnchor();
    end

    -- Anchor based on Settings
    if HeroRotationDB and HeroRotationDB.ButtonsFramePos then
      self:SetPoint(HeroRotationDB.ButtonsFramePos[1], _G[HeroRotationDB.ButtonsFramePos[2]], HeroRotationDB.ButtonsFramePos[3], HeroRotationDB.ButtonsFramePos[4], HeroRotationDB.ButtonsFramePos[5]);
    else
      self:SetPoint("TOPLEFT", HR.MainIconFrame, "BOTTOMLEFT", 0, HR.GUISettings.General.BlackBorderIcon and -3 or 0);
    end

    -- Start Move
    local function StartMove (self)
      self:StartMoving();
    end
    self:SetScript("OnMouseDown", StartMove);
    -- Stop Move
    local function StopMove (self)
      self:StopMovingOrSizing();
      if not HeroRotationDB then HeroRotationDB = {}; end
      local point, relativeTo, relativePoint, xOffset, yOffset, relativeToName;
      point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint();
      if not relativeTo then
        relativeToName = "UIParent";
      else
        relativeToName = relativeTo:GetName();
      end
      HeroRotationDB.ButtonsFramePos = {
        point,
        relativeToName,
        relativePoint,
        xOffset,
        yOffset
      };
    end
    self:SetScript("OnMouseUp", StopMove);
    self:SetScript("OnHide", StopMove);
    self:Show();

    -- Button Creation
    self.Button = {};
    self:AddButton("C", 1, "CDs", "cds");
    self:AddButton("A", 2, "AoE", "aoe");
    self:AddButton("O", 3, "On/Off", "toggle");
  end
  -- Reset Anchor
  function HR.ToggleIconFrame:ResetAnchor ()
    self:SetPoint("TOPLEFT", HR.MainIconFrame, "BOTTOMLEFT", 0, HR.GUISettings.General.BlackBorderIcon and -3 or 0);
    HeroRotationDB.ButtonsFramePos = false;
  end
  -- Add a button
  function HR.ToggleIconFrame:AddButton (Text, i, Tooltip, CmdArg)
    local ButtonFrame = CreateFrame("Button", "$parentButton"..tostring(i), self);
    ButtonFrame:SetFrameStrata(self:GetFrameStrata());
    ButtonFrame:SetFrameLevel(self:GetFrameLevel() - 1);
    ButtonFrame:SetWidth(20);
    ButtonFrame:SetHeight(20);
    ButtonFrame:SetPoint("LEFT", self, "LEFT", 20*(i-1)+i, 0);

    -- Button Tooltip (Optional)
    if Tooltip then
      ButtonFrame:SetScript("OnEnter",
        function ()
          GameTooltip:SetOwner(HR.ToggleIconFrame, "ANCHOR_BOTTOM", 0, 0);
          GameTooltip:ClearLines();
          GameTooltip:SetBackdropColor(0, 0, 0, 1);
          GameTooltip:SetText(Tooltip, nil, nil, nil, 1, true);
          GameTooltip:Show();
        end
      );
      ButtonFrame:SetScript("OnLeave",
        function ()
          GameTooltip:Hide();
        end
      );
    end

    -- Button Text
    ButtonFrame:SetNormalFontObject("GameFontNormalSmall");
    ButtonFrame.text = Text;

    -- Button Texture
    local NormalTexture = ButtonFrame:CreateTexture();
    NormalTexture:SetTexture("Interface/Buttons/UI-Silver-Button-Up");
    NormalTexture:SetTexCoord(0, 0.625, 0, 0.7875);
    NormalTexture:SetAllPoints();
    ButtonFrame:SetNormalTexture(NormalTexture);
    local HighlightTexture = ButtonFrame:CreateTexture();
    HighlightTexture:SetTexture("Interface/Buttons/UI-Silver-Button-Highlight");
    HighlightTexture:SetTexCoord(0, 0.625, 0, 0.7875);
    HighlightTexture:SetAllPoints();
    ButtonFrame:SetHighlightTexture(HighlightTexture);
    local PushedTexture = ButtonFrame:CreateTexture();
    PushedTexture:SetTexture("Interface/Buttons/UI-Silver-Button-Down");
    PushedTexture:SetTexCoord(0, 0.625, 0, 0.7875);
    PushedTexture:SetAllPoints();
    ButtonFrame:SetPushedTexture(PushedTexture);

    -- Button Setting
    if type(HeroRotationCharDB) ~= "table" then
      HeroRotationCharDB = {};
    end
    if type(HeroRotationCharDB.Toggles) ~= "table" then
      HeroRotationCharDB.Toggles = {};
    end
    if type(HeroRotationCharDB.Toggles[i]) ~= "boolean" then
      HeroRotationCharDB.Toggles[i] = true;
    end

    -- OnClick Callback
    ButtonFrame:SetScript("OnMouseDown",
      function (self, Button)
        if Button == "LeftButton" then
          HR.CmdHandler(CmdArg);
        end
      end
    );

    self.Button[i] = ButtonFrame;

    HR.ToggleIconFrame:UpdateButtonText(i);

    ButtonFrame:Show();
  end
  -- Update a button text
  function HR.ToggleIconFrame:UpdateButtonText (i)
    if HeroRotationCharDB.Toggles[i] then
      self.Button[i]:SetFormattedText("|cff00ff00%s|r", self.Button[i].text);
    else
      self.Button[i]:SetFormattedText("|cffff0000%s|r", self.Button[i].text);
    end
  end


