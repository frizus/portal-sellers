local addonName, addon = ...
local L = addon.L
addon.param = {}
local DB = addon.param

addon.frame = CreateFrame("Frame")
addon.frame:RegisterEvent("ADDON_LOADED")
addon.frame:RegisterEvent("PLAYER_LOGIN")
local function onEvent(self, event, arg1, ...)
	if event == "ADDON_LOADED" then
		if arg1 == addonName then
			addon[event](addon, arg1, ...)
		end
	elseif type(addon[event]) == "function" then
		addon[event](addon, arg1, ...)
	end
end
addon.frame:SetScript("OnEvent", onEvent)

function addon:ADDON_LOADED()
	self.DB:Init()
	self.DB:ConvertOldParameters()
	self.DB:MergeWithDefault()
	self.Minimap:Create()
	self.Options:InitBlizPanel()
end

-- AceConfigRegistry-3.0 валидация
function addon:PLAYER_LOGIN()
	self.frame:RegisterEvent("PLAYER_LOGOUT")

	print(string.format(L["welcome_message"], addonName, GetAddOnMetadata(addonName, "Version")))

	self.DB:ConvertFilterGroups()

	self.frame:RegisterEvent("CHAT_MSG_WHISPER")

	--if addon.db.global.trackerWindowVisible then
	--addon.modules.Monitoring:Create()
	--end
end

function addon:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
	tprint(self.Keywords:Parse(text))
end

function addon:PLAYER_LOGOUT()
	self.DB:SaveVariables()
	--DB.trackerWindowVisible = addon.modules.Monitoring:IsAlive()
end

SLASH_TRITON1 = "/triton"
function SlashCmdList.TRITON()
	print("переключение видимости трекера")
	--addon.modules.Monitoring.Show
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

function addon:TrackingHooks(enable)
	if enable == nil then
		enable = not addon.db.global.trackerEnabled
	end

	if enable and not addon.db.global.trackerEnabled then
		local events = {
			"CHAT_MSG_SAY",
			"CHAT_MSG_YELL",
			"CHAT_MSG_CHANNEL",
			--"CHAT_MSG_SYSTEM",
			--"WHO_LIST_UPDATE",
		}
		for _, event in pairs(events) do
			addon:RegisterEvent(event, addon.Message[event])
		end
		addon.db.global.trackerEnabled = true
	elseif not enable and addon.db.global.trackerEnabled then
		addon:UnregisterAllEvents()
		addon.db.global.trackerEnabled = false
	end
end