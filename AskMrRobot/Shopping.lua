local Amr = LibStub("AceAddon-3.0"):GetAddon("AskMrRobot")
local L = LibStub("AceLocale-3.0"):GetLocale("AskMrRobot", true)
local AceGUI = LibStub("AceGUI-3.0")

local _frameShop
local _panelContent
local _cboPlayers
local _selectedPlayer

local _specs = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
}

local _chk1
local _chk2
local _chk3
local _chk4
local _isAhOpen = false

local function incrementTableItem(tbl, key, inc)
	tbl[key] = tbl[key] and tbl[key] + inc or inc
end

local function onShopFrameClose(widget)
	AceGUI:Release(widget)
	_frameShop = nil
	_cboPlayers = nil
	_chk1 = nil
	_chk2 = nil
	_chk3 = nil
	_chk4 = nil
	_panelContent = nil
end

function Amr:HideShopWindow()
	if not _frameShop then return end
	_frameShop:Hide()
end

local function onPlayerChange(widget, eventName, value)
	_selectedPlayer = value
	Amr:RefreshShoppingUi()
end

local function onSpecClick(widget)
	local spec = widget:GetUserData("spec")	
	_specs[spec] = not _specs[spec]
	
	Amr:RefreshShoppingUi()
end

local function onItemClick(widget)
	local name = widget:GetUserData("itemName")
	if name then
		QueryAuctionItems(name)
	end
end


function Amr:ShowShopWindow()

	if not _frameShop then
		_frameShop = AceGUI:Create("AmrUiFrame")
		_frameShop:SetStatusTable(Amr.db.profile.shopWindow) -- window position is remembered in db
		_frameShop:SetCallback("OnClose", onShopFrameClose)
		_frameShop:SetLayout("None")
		_frameShop:SetWidth(500)
		_frameShop:SetHeight(500)
		_frameShop:SetBorderColor(Amr.Colors.BorderBlue)
		_frameShop:SetBackgroundColor(Amr.Colors.Bg)
		
		if Amr.db.profile.options.uiScale ~= 1 then
			local scale = tonumber(Amr.db.profile.options.uiScale)
			_frameShop:SetScale(scale)
		end
		
		local lbl = AceGUI:Create("AmrUiLabel")
		_frameShop:AddChild(lbl)
		lbl:SetWidth(400)
		lbl:SetFont(Amr.CreateFont("Bold", 28, Amr.Colors.White))
		lbl:SetText(L.ShopTitle)
		lbl:SetWordWrap(false)
		lbl:SetJustifyH("CENTER")
		lbl:SetPoint("TOP", _frameShop.content, "TOP", 0, 30)
		
		lbl:SetCallback("OnMouseDown", function(widget) _frameShop:StartMove() end)
		lbl:SetCallback("OnMouseUp", function(widget) _frameShop:EndMove() end)
		
		-- player picker
		_cboPlayers = AceGUI:Create("AmrUiDropDown")
		_cboPlayers:SetWidth(400)
		_frameShop:AddChild(_cboPlayers)
		_cboPlayers:SetPoint("TOPLEFT", _frameShop.content, "TOPLEFT", 0, -30)
		
		-- spec pickers
		_chk1 = AceGUI:Create("AmrUiCheckBox")
		_chk1:SetUserData("spec", 1)
		_chk1:SetCallback("OnClick", onSpecClick)
		_frameShop:AddChild(_chk1)
		_chk1:SetPoint("TOPLEFT", _cboPlayers.frame, "BOTTOMLEFT", 0, -20)
		
		_chk2 = AceGUI:Create("AmrUiCheckBox")
		_chk2:SetUserData("spec", 2)
		_chk2:SetCallback("OnClick", onSpecClick)
		_frameShop:AddChild(_chk2)
		_chk2:SetPoint("LEFT", _chk1.frame, "RIGHT", 30, 0)
		
		_chk3 = AceGUI:Create("AmrUiCheckBox")
		_chk3:SetUserData("spec", 3)
		_chk3:SetCallback("OnClick", onSpecClick)
		_frameShop:AddChild(_chk3)
		_chk3:SetPoint("LEFT", _chk2.frame, "RIGHT", 30, 0)
		
		_chk4 = AceGUI:Create("AmrUiCheckBox")
		_chk4:SetUserData("spec", 4)
		_chk4:SetCallback("OnClick", onSpecClick)
		_frameShop:AddChild(_chk4)
		_chk4:SetPoint("LEFT", _chk3.frame, "RIGHT", 30, 0)
		
		_panelContent = AceGUI:Create("AmrUiPanel")
		_panelContent:SetLayout("None")
		_panelContent:SetTransparent()
		_frameShop:AddChild(_panelContent)
		_panelContent:SetPoint("TOPLEFT", _chk1.frame, "BOTTOMLEFT", 0, -10)
		_panelContent:SetPoint("BOTTOMRIGHT", _frameShop.content, "BOTTOMRIGHT")
		
		-- update shopping list data
		local player = Amr:ExportCharacter()
		Amr:UpdateShoppingData(player)
		
		-- fill player list	
		local playerList = {}
		for name, data in pairs(Amr.db.global.Shopping) do
			table.insert(playerList, { text = name, value = name })
		end	
		_cboPlayers:SetItems(playerList)
		
		-- set default selected player
		if not _selectedPlayer then
			_selectedPlayer = player.Name .. "-" .. player.Realm
		end	
		_cboPlayers:SelectItem(_selectedPlayer)
		
		Amr:RefreshShoppingUi()
		
		-- set event on dropdown after UI has been initially rendered
		_cboPlayers:SetCallback("OnChange", onPlayerChange)
	else
		_frameShop:Show()
		Amr:RefreshShoppingUi()
	end
	
	_frameShop:Raise()
end

-- helper to render a section of the shopping list
local function renderShopSection(list, scroll, header)
	if not list or next(list) == nil then return end
	
	local w = 440
	
	local panel = AceGUI:Create("AmrUiPanel")
	panel:SetLayout("None")
	panel:SetTransparent()
	panel:SetWidth(w)
	panel:SetHeight(40)
	scroll:AddChild(panel)
	
	local lbl = AceGUI:Create("AmrUiLabel")
	panel:AddChild(lbl)
	lbl:SetWidth(w)
	lbl:SetFont(Amr.CreateFont("Regular", 18, Amr.Colors.TextHeaderActive))
	lbl:SetText(header)
	lbl:SetPoint("BOTTOMLEFT", panel.content, "BOTTOMLEFT")
	
	for itemId, count in pairs(list) do
		panel = AceGUI:Create("AmrUiPanel")
		panel:SetLayout("None")
		panel:SetTransparent()
		panel:SetWidth(w)
		panel:SetHeight(30)
		scroll:AddChild(panel)
		
		lbl = AceGUI:Create("AmrUiLabel")
		panel:AddChild(lbl)
		lbl:SetWidth(40)
		lbl:SetWordWrap(false)
		lbl:SetFont(Amr.CreateFont("Bold", 20, Amr.Colors.White))
		lbl:SetText(count .. "x")
		lbl:SetPoint("LEFT", panel.content, "LEFT")
		
		local icon = AceGUI:Create("AmrUiIcon")
		icon:SetBorderWidth(1)
		icon:SetIconBorderColor(Amr.Colors.White)
		icon:SetWidth(18)
		icon:SetHeight(18)
		panel:AddChild(icon)
		icon:SetPoint("LEFT", lbl.frame, "RIGHT", 5, 0)
		
		local btn = AceGUI:Create("AmrUiTextButton")
		btn:SetWidth(w - 30 - 18 - 15)
		btn:SetJustifyH("LEFT")
		btn:SetWordWrap(false)
		btn:SetFont(Amr.CreateFont("Bold", 14, Amr.Colors.White))
		btn:SetHoverFont(Amr.CreateFont("Bold", 14, Amr.Colors.White))
		btn:SetCallback("OnClick", onItemClick)
		panel:AddChild(btn)
		btn:SetPoint("LEFT", icon.frame, "RIGHT", 5, 0)
		
		local item = Item:CreateFromItemID(itemId)		
		if item then
			local itemLink = item:GetItemLink()
			if itemLink then
				icon:SetIcon(item:GetItemIcon())
				btn:SetText(itemLink:gsub("%[", ""):gsub("%]", ""))
				btn:SetUserData("itemName", item:GetItemName())
				Amr:SetItemTooltip(btn, itemLink)
			end
		end
	end
	
end

-- get the number of a specified gem/enchant/material that the player currently owns
local function getOwnedCount(itemId)
	local ret = 0
	
	local list = Amr.db.char.BagItemsAndCounts
	if list and list[itemId] then
		ret = ret + list[itemId]
	end
	
	local bankBags = Amr.db.char.BankItemsAndCounts
	if bankBags then
		for bagId,bagList in pairs(bankBags) do
			if bagList[itemId] then
				ret = ret + bagList[itemId]
			end
		end
	end
	
	return ret
end

local function removeOwned(list, owned)
	
	for itemId, count in pairs(list) do
		-- load up how many of an item we have
		if not owned.loaded[itemId] then
			owned.counts[itemId] = getOwnedCount(itemId)
			owned.loaded[itemId] = true
		end
		
		-- see how many we can remove from the required count
		local used = math.min(owned.counts[itemId], count)
		
		-- update owned count so we can't double-use something
		owned.counts[itemId] = owned.counts[itemId] - used;
		
		-- reduce the requirement, removing entirely if we have it completely covered
		list[itemId] = list[itemId] - used;
		if list[itemId] == 0 then
			list[itemId] = nil
		end
	end
end

function Amr:RefreshShoppingUi()

	local posToCheck = { _chk1, _chk2, _chk3, _chk4 }
	local chk
	
	-- reset spec checkboxes
	for specPos = 1,4 do
		chk = posToCheck[specPos]
		chk:SetVisible(false)
		chk:SetChecked(false)
	end
		
	-- clear out any previous data
	_panelContent:ReleaseChildren()
	
	local data = Amr.db.global.Shopping[_selectedPlayer]
	if not data then		
		_panelContent:SetLayout("None")
		
		local lbl = AceGUI:Create("AmrUiLabel")
		_panelContent:AddChild(lbl)
		lbl:SetFont(Amr.CreateFont("Italic", 18, Amr.Colors.TextTan))
		lbl:SetText(L.ShopEmpty)
		lbl:SetJustifyH("CENTER")
		lbl:SetPoint("TOP", _panelContent.content, "TOP", 0, -30)
	else
		local allStuff = { gems = {}, enchants = {}, materials = {} }
		local hasStuff = false
		local visited = {}
		
		for specPos = 1,4 do
			-- set labels on checkboxes
			if data.specs[specPos] and data.specs[specPos] ~= 0 then
				chk = posToCheck[specPos]
				chk:SetText(L.SpecsShort[data.specs[specPos]])
				chk:SetVisible(true)
				chk:SetChecked(_specs[specPos])
				
				-- gather up all stuff for checked specs
				if _specs[specPos] then
					hasStuff = true
					
					for inventoryId, stuff in pairs(data.stuff[specPos]) do
						if not visited[inventoryId] then
							if stuff.gems then
								for itemId, count in pairs(stuff.gems) do
									incrementTableItem(allStuff.gems, itemId, count)
								end
							end
							
							if stuff.enchants then
								for itemId, count in pairs(stuff.enchants) do
									incrementTableItem(allStuff.enchants, itemId, count)
								end
							end
							
							if stuff.materials then
								for itemId, count in pairs(stuff.materials) do
									incrementTableItem(allStuff.materials, itemId, count)
								end
							end
						
							-- make sure not to count the same physical item twice
							if inventoryId ~= -1 then
								visited[inventoryId] = true
							end
						end
					end
				end
				
			end
			
		end
		
		if hasStuff then		
			-- remove what we already own
			local owned = { counts = {}, loaded = {} }
			removeOwned(allStuff.gems, owned)
			removeOwned(allStuff.enchants, owned)
			removeOwned(allStuff.materials, owned)
			
			_panelContent:SetLayout("Fill")
			
			local scroll = AceGUI:Create("AmrUiScrollFrame")
			scroll:SetLayout("List")
			_panelContent:AddChild(scroll)
			
			renderShopSection(allStuff.gems, scroll, L.ShopHeaderGems)
			renderShopSection(allStuff.enchants, scroll, L.ShopHeaderEnchants)		
			renderShopSection(allStuff.materials, scroll, L.ShopHeaderMaterials)
		end
	end
				
end

-- compare gear to everything the player owns, and return the minimum gems/enchants/materials needed to optimize, 
-- grouped by inventory ID so that we can combine multiple specs without double-counting
local function getShoppingData(player, gear)

	local ret = {}
	
	-- used to prevent considering the same item twice
	local usedItems = {}
	
	for slotId, optimalItem in pairs(gear) do
		local matchItem = Amr:FindMatchingItem(optimalItem, player, usedItems)
		local inventoryId = optimalItem.inventoryId or -1
		
		-- find gem/enchant differences on the best-matching item
		
		-- gems
		if not optimalItem.relicBonusIds and (not matchItem or not matchItem.relicBonusIds) then
			for i = 1, 3 do
				local g = optimalItem.gemIds[i]
				local isGemEquipped = g == 0 or (matchItem and matchItem.gemIds and matchItem.gemIds[i] == g)
				if not isGemEquipped then
					if not ret[inventoryId] then
						ret[inventoryId] = { gems = {}, enchants = {}, materials = {} }
					end
					incrementTableItem(ret[inventoryId].gems, g, 1)
				end
			end
		end
		
		-- enchant
		if optimalItem.enchantId and optimalItem.enchantId ~= 0 then
			local e = optimalItem.enchantId
			local isEnchantEquipped = matchItem and matchItem.enchantId and matchItem.enchantId == e
			
			if not isEnchantEquipped then
				-- enchant info
				local enchInfo = Amr.db.char.ExtraEnchantData[e]
				if enchInfo then
					if not ret[inventoryId] then
						ret[inventoryId] = { gems = {}, enchants = {}, materials = {} }
					end
					incrementTableItem(ret[inventoryId].enchants, enchInfo.itemId, 1)
					
					if enchInfo.materials then
						for k, v in pairs(enchInfo.materials) do
							incrementTableItem(ret[inventoryId].materials, k, v)
						end
					end
				end
			end
		end
	end
	
	return ret
end

-- look at both gear sets and find stuff that a player needs to acquire to gem/enchant their gear
function Amr:UpdateShoppingData(player)

	local required = {
		stuff = {},
		specs = player.Specs
	}
	
	for i, spec in ipairs(required.specs) do
		local gear = Amr.db.char.GearSets[i]
		if gear then
			required.stuff[i] = getShoppingData(player, gear)
		else
			required.stuff[i] = {}
		end
	end
	
	Amr.db.global.Shopping[player.Name .. "-" .. player.Realm] = required
end

Amr:AddEventHandler("AUCTION_HOUSE_SHOW", function() 
	_isAhOpen = true
	if Amr.db.profile.options.shopAh then
		Amr:ShowShopWindow()
	end
end)

Amr:AddEventHandler("AUCTION_HOUSE_CLOSED", function() 
	_isAhOpen = false
	if Amr.db.profile.options.shopAh then
		Amr:HideShopWindow()
	end
end)
