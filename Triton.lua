local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:OnInitialize()
	--addon.db = AceDB:New(addonName .. "DB", addon.DB.defaults, true)
	--addon.param = addon.db.global
	addon.param = {}
	addon.param["minimap"] = {}

	addon.Minimap:Create()

	AceConfigRegistry:RegisterOptionsTable(addonName, addon.BlizOptions.GetOptions)
	AceConfigDialog:AddToBlizOptions(addonName, GetAddOnMetadata(addonName, "Title"))

	--addon:RegisterChatCommand("triton", addon.modules.Monitoring.Show)
end

-- AceConfigRegistry-3.0 валидация
function addon:OnEnable()
	--addon:RegisterEvent("PLAYER_LOGOUT", addon.DB.BeforeLogout)

	print(string.format(L["welcome_message"], addonName, GetAddOnMetadata(addonName, "Version")))

	--addon.DB:ConvertOldParameters()

	self:RegisterEvent("CHAT_MSG_WHISPER", function(self, text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
		tprint(addon.Keywords:Parse(text))
	end)

	self:RegisterChatCommand("triton", function()

	end)

	--if addon.db.global.trackerWindowVisible then
	--addon.modules.Monitoring:Create()
	--end
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

function addon:OnDisable()
	--addon:TrackingHooks(false)
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