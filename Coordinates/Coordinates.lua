-- Coordinates
-- By Szandos

--Variables
local Coordinates_UpdateInterval = 0.2
local timeSinceLastUpdate = 0
local color = "|cff00ffff"

-------------------------------------------------------------------------------

-- Need a frame for events
local Coordinates_eventFrame = CreateFrame("Frame")
Coordinates_eventFrame:RegisterEvent("VARIABLES_LOADED")
Coordinates_eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Coordinates_eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
Coordinates_eventFrame:RegisterEvent("ZONE_CHANGED")
Coordinates_eventFrame:SetScript("OnEvent",function(self,event,...) self[event](self,event,...);end)

-- Create slash command
SLASH_COORDINATES1 = "/coordinates"
SLASH_COORDINATES2 = "/coord"

-- Handle slash commands
function SlashCmdList.COORDINATES(msg)
	msg = string.lower(msg)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if (command == "worldmap" or command =="w") then
		if CoordinatesDB["worldmap"] == true then 
			CoordinatesDB["worldmap"] = false
			DEFAULT_CHAT_FRAME:AddMessage(color.."Coordinates: World map coordinates disabled")
		else
			CoordinatesDB["worldmap"] = true
			DEFAULT_CHAT_FRAME:AddMessage(color.."Coordinates: World map coordinates enabled")
		end
	elseif (command == "minimap" or command =="m") then
		if CoordinatesDB["minimap"] == true then 
			CoordinatesDB["minimap"] = false
			MinimapZoneText:SetText( GetMinimapZoneText() )
			DEFAULT_CHAT_FRAME:AddMessage(color.."Coordinates: Mini map coordinates disabled")
		else
			CoordinatesDB["minimap"] = true
			DEFAULT_CHAT_FRAME:AddMessage(color.."Coordinates: Mini map coordinates enabled")
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage(color.."Coordinates by Szandos")
		DEFAULT_CHAT_FRAME:AddMessage(color.."Version: "..GetAddOnMetadata("Coordinates", "Version"))
		DEFAULT_CHAT_FRAME:AddMessage(color.."Usage:")
		DEFAULT_CHAT_FRAME:AddMessage(color.."/coordinates worldmap - Enable/disable coordinates on the world map")
		DEFAULT_CHAT_FRAME:AddMessage(color.."/coordinates minimap - Enable/disable coordinates on the mini map")
	end
end

--Event handler
function Coordinates_eventFrame:VARIABLES_LOADED()
	if (not CoordinatesDB) then
		CoordinatesDB = {}
		CoordinatesDB["worldmap"] = true
		CoordinatesDB["minimap"] = true
	end
	Coordinates_eventFrame:SetScript("OnUpdate", function(self, elapsed) Coordinates_OnUpdate(self, elapsed) end)
end

function Coordinates_eventFrame:ZONE_CHANGED_NEW_AREA()
	Coordinates_UpdateCoordinates()
end

function Coordinates_eventFrame:ZONE_CHANGED_INDOORS()
	Coordinates_UpdateCoordinates()
end

function Coordinates_eventFrame:ZONE_CHANGED()
	Coordinates_UpdateCoordinates()
end

--OnUpdate
function Coordinates_OnUpdate(self, elapsed)
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if (timeSinceLastUpdate > Coordinates_UpdateInterval) then
		-- Update the update time
		timeSinceLastUpdate = 0
		Coordinates_UpdateCoordinates()
	end
end

function Coordinates_UpdateCoordinates()
	--MinimapCoordinates
	if (CoordinatesDB["minimap"] and Minimap:IsVisible()) then
		local px, py = GetPlayerMapPosition("player")
		if (px and px ~= 0 and py ~= 0 ) then
			MinimapZoneText:SetText( format("(%d:%d) ",px*100.0,py*100.0) .. GetMinimapZoneText() );
		end
	end

	--WorldMapCoordinates
 	if (CoordinatesDB["worldmap"] and WorldMapFrame:IsVisible()) then
 		-- Get the cursor's coordinates
 		local cursorX, cursorY = GetCursorPosition()
		
		-- Calculate cursor position
 		local scale = WorldMapDetailFrame:GetEffectiveScale()
 		cursorX = cursorX / scale
 		cursorY = cursorY / scale
 		local width = WorldMapDetailFrame:GetWidth()
 		local height = WorldMapDetailFrame:GetHeight()
		local left = WorldMapDetailFrame:GetLeft()
		local top = WorldMapDetailFrame:GetTop()
		cursorX = (cursorX - left) / width * 100
		cursorY = (top - cursorY) / height * 100
 		local worldmapCoordsText = "Cursor(X,Y): "..format("%.1f , %.1f |", cursorX, cursorY)
		
		-- Player position
		local px, py = GetPlayerMapPosition("player")
 		if (px == nil or px == 0 and py == 0 ) then
 			worldmapCoordsText = worldmapCoordsText.." Player(X,Y): n/a"
 		else
 			worldmapCoordsText = worldmapCoordsText.." Player(X,Y): "..format("%.1f , %.1f", px * 100, py * 100)
 		end
		
		-- Add text to world map
		WorldMapFrame.BorderFrame.TitleText:SetText(worldmapCoordsText)
	end
	if ((not CoordinatesDB["worldmap"]) and WorldMapFrame:IsVisible()) then
		WorldMapFrame.BorderFrame.TitleText:SetText(MAP_AND_QUEST_LOG)
	end
end