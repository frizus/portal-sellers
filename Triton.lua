local addonName, addon = ...
local L = addon.L
addon.param = {}
local DB = addon.param
addon.eventHandlersObject, addon.eventHandlersObjectMethod = {}, {}

function addon:RegisterEvent(event, object, method)
	self.frame:RegisterEvent(event)
	self.eventHandlersObject[event] = object or self
	self.eventHandlersObjectMethod[event] = method or event
end
function addon:UnregisterEvent(event)
	self.frame:UnregisterEvent(event)
	self.eventHandlersObject[event] = nil
	self.eventHandlersObjectMethod[event] = nil
end

addon.frame = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
local function onEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == addonName and addon.eventHandlersObject[event] then
			addon.eventHandlersObject[event][addon.eventHandlersObjectMethod[event]](addon.eventHandlersObject[event], ...)
		end
	elseif addon.eventHandlersObject[event] then
		addon.eventHandlersObject[event][addon.eventHandlersObjectMethod[event]](addon.eventHandlersObject[event], ...)
	end
end
addon.frame:SetScript("OnEvent", onEvent)

function addon:ADDON_LOADED()
	self.DB:Init()
	self.DB:ConvertOldParameters()
	self.DB:MergeWithDefault()
	if DB.minimap.show then
		self.Minimap:Show()
	end
	self.Options:InitBlizPanel()
end

-- AceConfigRegistry-3.0 валидация
function addon:PLAYER_LOGIN()
	if DB.showStartMessage then
		print(string.format(L["welcome_message"], addonName, GetAddOnMetadata(addonName, "Version")))
	end
	self.DB:ConvertFilterGroups()
	self:RegisterEvent("PLAYER_LOGOUT", self.DB)

	if DB.trackerWindowOpened then
		self.Tracker:Show()
	end
	self:ToggleTrackEvents("init")

	local message = "{x}|cff0000ff before |cff00ffff |Hitem|h[item1] |Hitem |h[item2]|h |h|rafter |rafter2"
	local parser = addon.MessageParser:Create(message, true, true)
	parser:Parse()
	print("|cffFFFF00Message|r",message)
	print("|cffFFFF00Formatted|r",parser:GetFormattedMessage())
	print("|cffFFFF00Search Message|r",parser:GetSearchMessage())
	print("|cffFFFF00Search Message w/o shift links|r",parser:GetSearchMessage(true))
end

SLASH_TRITON1 = "/triton"
function SlashCmdList.TRITON()
	addon.Tracker:Toggle()
	addon:ToggleTrackEvents("trackerWindow")
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		elseif type(v) == 'boolean' then
			print(formatting .. tostring(v))
		else
			print(formatting .. v)
		end
	end
end

function addon:ToggleTrackEvents(status)
	local enable
	if status == "toggle" then
		if DB.trackerWindowOpened or DB.doTrackWhenClosed then
			enable = not DB.trackerEnabled
		end
		DB.trackerEnabled = not DB.trackerEnabled
	elseif DB.trackerEnabled then
		if status == "trackerWindow" then
			if not DB.doTrackWhenClosed then
				enable = DB.trackerWindowOpened
			end
		elseif status == "option" then
			if not DB.trackerWindowOpened then
				enable = DB.doTrackWhenClosed
			end
		elseif status == "init" then
			if DB.trackerWindowOpened or DB.doTrackWhenClosed then
				enable = true
			end
		end
	end
	if enable == true then
		--self:RegisterEvent("CHAT_MSG_SAY", self.Message)
		--self:RegisterEvent("CHAT_MSG_YELL", self.Message)
		--self:RegisterEvent("CHAT_MSG_CHANNEL", self.Message)
		--self:RegisterEvent("CHAT_MSG_SYSTEM", self.Message)
		--self:RegisterEvent("WHO_LIST_UPDATE", self.Message)
		self:RegisterEvent("CHAT_MSG_WHISPER", self.Message)
	elseif enable == false then
		self:UnregisterEvent("CHAT_MSG_SAY")
		self:UnregisterEvent("CHAT_MSG_YELL")
		self:UnregisterEvent("CHAT_MSG_CHANNEL")
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:UnregisterEvent("WHO_LIST_UPDATE")
		self:UnregisterEvent("CHAT_MSG_WHISPER")
	end
end