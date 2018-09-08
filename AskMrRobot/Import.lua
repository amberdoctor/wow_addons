local Amr = LibStub("AceAddon-3.0"):GetAddon("AskMrRobot")
local L = LibStub("AceLocale-3.0"):GetLocale("AskMrRobot", true)
local AceGUI = LibStub("AceGUI-3.0")

local _txtImport
local _lblError
local _panelCover

local function onImportOkClick(widget)
	local txt = _txtImport:GetText()
	local msg = Amr:ImportCharacter(txt)
	if msg then
		_lblError:SetText(msg)
		_txtImport:SetFocus(true)
	else
		Amr:HideCover()
		Amr:RefreshGearTab()
	end
end

local function onImportCancelClick(widget)
	Amr:HideCover()
end

local function onTextEnterPressed(widget)
	-- hide the overwolf cover when import data is received
	if _panelCover then
		_panelCover:SetVisible(false)
	end
	
	-- do an import if the data starts and ends with a dollar sign
	local txt = _txtImport:GetText()
	local txtLen = string.len(txt)
	if txtLen > 2 and string.sub(txt, 1, 1) == '$' then	
		onImportOkClick()
	end
	
end

local function renderImportWindow(container, fromOverwolf)

	local panelImport = Amr:RenderCoverChrome(container, 700, 450)
	
	local lbl = AceGUI:Create("AmrUiLabel")
	panelImport:AddChild(lbl)
	lbl:SetWidth(600)
	lbl:SetText(L.ImportHeader)
	lbl:SetPoint("TOP", panelImport.content, "TOP", 0, -10)

	_txtImport = AceGUI:Create("AmrUiTextarea")
	_txtImport:SetWidth(600)
	_txtImport:SetHeight(300)
	_txtImport:SetFont(Amr.CreateFont("Regular", 12, Amr.Colors.Text))
	_txtImport:SetCallback("OnEnterPressed", onTextEnterPressed)
	panelImport:AddChild(_txtImport)
	_txtImport:SetPoint("TOP", lbl.frame, "BOTTOM", 0, -10)
	
	local btnImportOk = AceGUI:Create("AmrUiButton")
	btnImportOk:SetText(L.ImportButtonOk)
	btnImportOk:SetBackgroundColor(Amr.Colors.Green)
	btnImportOk:SetFont(Amr.CreateFont("Bold", 16, Amr.Colors.White))
	btnImportOk:SetWidth(120)
	btnImportOk:SetHeight(28)
	btnImportOk:SetCallback("OnClick", onImportOkClick)
	panelImport:AddChild(btnImportOk)
	btnImportOk:SetPoint("TOPLEFT", _txtImport.frame, "BOTTOMLEFT", 0, -10)
	
	local btnImportCancel = AceGUI:Create("AmrUiButton")
	btnImportCancel:SetText(L.ImportButtonCancel)
	btnImportCancel:SetBackgroundColor(Amr.Colors.Green)
	btnImportCancel:SetFont(Amr.CreateFont("Bold", 16, Amr.Colors.White))
	btnImportCancel:SetWidth(120)
	btnImportCancel:SetHeight(28)
	btnImportCancel:SetCallback("OnClick", onImportCancelClick)
	panelImport:AddChild(btnImportCancel)
	btnImportCancel:SetPoint("LEFT", btnImportOk.frame, "RIGHT", 20, 0)
	
	_lblError = AceGUI:Create("AmrUiLabel")
	panelImport:AddChild(_lblError)
	_lblError:SetWidth(600)
	_lblError:SetFont(Amr.CreateFont("Bold", 14, Amr.Colors.Red))
	_lblError:SetText("")
	_lblError:SetPoint("TOPLEFT", btnImportOk.frame, "BOTTOMLEFT", 0, -20)
	
	if fromOverwolf then
		-- show a cover preventing interaction until we receive data from overwolf
		_panelCover = AceGUI:Create("AmrUiPanel")
		_panelCover:SetLayout("None")
		_panelCover:EnableMouse(true)
		_panelCover:SetBackgroundColor(Amr.Colors.Black, 0.75)
		panelImport:AddChild(_panelCover)
		_panelCover:SetPoint("TOPLEFT", panelImport.frame, "TOPLEFT")
		_panelCover:SetPoint("BOTTOMRIGHT", panelImport.frame, "BOTTOMRIGHT")

		local coverMsg = AceGUI:Create("AmrUiLabel")
		_panelCover:AddChild(coverMsg)
		coverMsg:SetWidth(500)
		coverMsg:SetFont(Amr.CreateFont("Regular", 16, Amr.Colors.TextTan))
		coverMsg:SetJustifyH("MIDDLE")
		coverMsg:SetJustifyV("MIDDLE")
		coverMsg:SetText(L.ImportOverwolfWait)
		coverMsg:SetPoint("CENTER", _panelCover.frame, "CENTER", 0, 20)
		
		-- after adding, set cover to sit on top of everything
		_panelCover:SetStrata("FULLSCREEN_DIALOG")
		_panelCover:SetLevel(Amr.FrameLevels.Highest)		
	end
end

function Amr:ShowImportWindow(fromOverwolf)
	-- this is shown as a modal dialog
	Amr:ShowCover(function(container)
		renderImportWindow(container, fromOverwolf)
	end)
	
	_txtImport:SetText("")
	_txtImport:SetFocus(true)
end

----------------------------------------------------------------------------
-- Import Parsing
----------------------------------------------------------------------------

--
-- Import a character, returning nil on success, otherwise an error message, import result stored in the db.
--
function Amr:ImportCharacter(data, isTest)

    -- make sure all data is up to date before importing and get a local copy of player's current state
    local currentPlayerData = self:ExportCharacter()
    
    if data == nil or string.len(data) == 0 then
        return L.ImportErrorEmpty
    end
	
	-- if multiple specs are included in the data, parse each individually, then quit
	local specParts = { strsplit("\n", data) }
	if #specParts > 1 then
		for i = 1, #specParts do
			local err = self:ImportCharacter(specParts[i], isTest)
			if err ~= nil then
				return err
			end
		end
		return	
	end
    
    local data1 = { strsplit("$", data) }
    if #data1 ~= 3 then
        return L.ImportErrorFormat
    end
    
    local parts = { strsplit(";", data1[2]) }
    
    -- require a minimum version
    local ver = tonumber(parts[1])
    if ver < Amr.MIN_IMPORT_VERSION then
        return L.ImportErrorVersion
    end
    
    -- require name match (don't match realm due to language issues for now)
    if not isTest then
		local region = parts[2]
        local realm = parts[3]
        local name = parts[4]
        if name ~= currentPlayerData.Name then
            local importPlayerName = name .. " (" .. realm .. ")"
            local you = currentPlayerData.Name .. " (" .. currentPlayerData.Realm .. ")"
            return L.ImportErrorChar(importPlayerName, you)
        end
        
        -- require race match
        local race = tonumber(parts[6])
        if race ~= Amr.RaceIds[currentPlayerData.Race] then
            return L.ImportErrorRace
        end
        
        -- require faction match
        local faction = tonumber(parts[7])
        if faction ~= Amr.FactionIds[currentPlayerData.Faction] then
            return L.ImportErrorFaction
        end
        
        -- require level match
        local level = tonumber(parts[8])
        if level ~= currentPlayerData.Level then
            return L.ImportErrorLevel
        end
    end
    
    -- if we make it this far, the data is valid, so read item information
	local specSlot = tonumber(parts[11])
	
    local importData = {}
    local enchantInfo = {}
    
    local prevItemId = 0
    local prevGemId = 0
    local prevEnchantId = 0
    local prevUpgradeId = 0
    local prevBonusId = 0
    local prevLevel = 0
    local prevAzeriteId = 0
    local digits = {
        ["-"] = true,
        ["0"] = true,
        ["1"] = true,
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true,
        ["6"] = true,
        ["7"] = true,
        ["8"] = true,
        ["9"] = true,
    }
    for i = 16, #parts do
        local itemString = parts[i]
        if itemString ~= "" and itemString ~= "_" then
            local tokens = {}
            local bonusIds = {}
            local azerite = {}
            local hasBonuses = false
            local hasAzerites = false
            local token = ""
            local prop = "i"
            local tokenComplete = false
            for j = 1, string.len(itemString) do
                local c = string.sub(itemString, j, j)
                if digits[c] == nil then
                    tokenComplete = true
                else
                    token = token .. c
                end
                
                if tokenComplete or j == string.len(itemString) then
                    local val = tonumber(token)
                    if prop == "i" then
                        val = val + prevItemId
                        prevItemId = val
                    elseif prop == "u" then
                        val = val + prevUpgradeId
                        prevUpgradeId = val
					elseif prop == "v" then
						val = val + prevLevel
						prevLevel = val
                    elseif prop == "b" then
                        val = val + prevBonusId
                        prevBonusId = val
                    elseif prop == "x" or prop == "y" or prop == "z" then
                        val = val + prevGemId
                        prevGemId = val
                    elseif prop == "e" then
                        val = val + prevEnchantId
                        prevEnchantId = val
                    elseif prop == "a" then
                        val = val + prevAzeriteId
                        prevAzeriteId = val
                    end
                    
                    if prop == "b" then
                        table.insert(bonusIds, val)
                        hasBonuses = true
                    elseif prop == "a" then
                        table.insert(azerite, val)
                        hasAzerites = true
                    else
                        tokens[prop] = val
                    end
                    
                    token = ""
                    tokenComplete = false
                    
                    -- we have moved on to the next token
                    prop = c
                end
            end
            
            local obj = {}
            importData[tonumber(tokens["s"])] = obj
            
            obj.id = tokens["i"]
            obj.suffixId = tokens["f"] or 0
            obj.upgradeId = tokens["u"] or 0
			obj.level = tokens["v"] or 0
            obj.enchantId = tokens["e"] or 0
			obj.inventoryId = tokens["t"] or 0
            
            obj.gemIds = {}
            table.insert(obj.gemIds, tokens["x"] or 0)
            table.insert(obj.gemIds, tokens["y"] or 0)
            table.insert(obj.gemIds, tokens["z"] or 0)
            table.insert(obj.gemIds, 0)
            
            if hasBonuses then
                obj.bonusIds = bonusIds
            end
            
            if hasAzerites then
                obj.azerite = azerite
            end
        end
    end
    
    -- now read any extra display information
    parts = { strsplit("@", data1[3]) }
    for i = 1, #parts do
        local infoParts = { strsplit("\\", parts[i]) }
        
        if infoParts[1] == "e" then
        
            local enchObj = {}
            enchObj.id = tonumber(infoParts[2])
            enchObj.itemId = tonumber(infoParts[3])
            enchObj.spellId = tonumber(infoParts[4])
            enchObj.text = string.gsub(infoParts[5], "_(%a+)_", function(s) return L.StatsShort[s] end)
            
            local mats = infoParts[6]
            if string.len(mats) > 0 then
                enchObj.materials = {}
                mats = { strsplit(",", mats) }
                for j = 1, #mats do
                    local kv = { strsplit("=", mats[j]) }
                    enchObj.materials[tonumber(kv[1])] = tonumber(kv[2])
                end
            end
            
            enchantInfo[enchObj.id] = enchObj            
        end
    end
    
    if isTest then
		print("spec " .. specSlot)
        -- print result for debugging
        for k,v in pairs(importData) do
			local blah = Amr.CreateItemLink(v)
			--print(blah)
            local name, link = GetItemInfo(blah)
            print(link)
            if link == nil then
                print(blah)
                print("bad item: " .. v.id)
            end
        end              
    else
        -- we have succeeded, record the result
		Amr.db.char.GearSets[specSlot] = importData

        for k,v in pairs(enchantInfo) do
            Amr.db.char.ExtraEnchantData[k] = v    
        end
		
		-- also update shopping list after import
		Amr:UpdateShoppingData(currentPlayerData)
    end
end
