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
		print(L["welcome_message"])
	end
	self.DB:ConvertFilterGroups()
	self:RegisterEvent("PLAYER_LOGOUT", self.DB)

	if DB.trackerWindowOpened then
		self.Tracker:CreateWidget()
	end
	self:ToggleTrackEvents("init")
	self.Tracker:ToggleTimer()

	local message = "{x}|cff0000ff before |cff00ffff |Hitem|h[item1]|h |Hitem|h[item2]|h |rafter |rafter2"
	local parser = addon.MessageParser:Create(message, true, true, true)
	parser:Parse()
	print("|cffFFFF00Message|r",message)
	print("|cffFFFF00Formatted|r",parser:GetFormattedMessage())
	print("|cffFFFF00Search Message|r",parser:GetSearchMessage())
	print("|cffFFFF00Search Message w/o shift links|r",parser:GetSearchMessage(true))

	--[[ to see these testing tracked messages add this
	TritonDB = {
		["filterGroups"] = {
			["--а,е,и,й,о,у,ы,э,ю,я"] = {
				["wordGroupsString"] = "а,е,и,й,о,у,ы,э,ю,я",
			},
		},
	}
	to "World of Warcraft/_classic_/WTF/Account/<account id>/SavedVariables/Triton.lua
	]]
	self.FilterGroup:Init()
	for _, message in pairs({
		"а а аа а  а аа а а а а а а",
		" {череп} бвд {череп} еее е е еее е е е ее",
		"о оо о о о оо о о о о",
		"уу у у у уу у уу уу",
		"э э э э ээ  э э э э",
		"ы ы ыы ы ы ы  ы",
		"ауогшауышуыоашгуыоагшыуаоуышгщаоыугшщаыоуагшщыуоыугшщаоуыагшыуаощ",
		"ауогшауышуыоашгуыоагшыуаоуышгщаоыугшщаыоуагшщыуоыугшщаоуыагшыуаощ",
		"ауогшауышуыоашгуыоагшыуаоуышгщаоыугшщаыоуагшщыуоыугшщаоуыагшыуаощ",
		"ауогшауышуыоашгуыоагшыуаоуышгщаоыугшщаыоуагшщыуоыугшщаоуыагшыуаощ",
		"ауогшауышуыоашгуыоагшыуаоуышгщаоыугшщаыоуагшщыуоыугшщаоуыагшыуаощ",
		"ауогшауышуыоашгуыоагшыуаоуышгщаоыугшщаыоуагшщыуоыугшщаоуыагшыуаощ",
	}) do
		local parser = addon.MessageParser:Create(message, addon.FilterGroup.haveWithShiftLinks, addon.FilterGroup.haveRemoveShiftLinks, true)
		parser:Parse()

		local player = {
			["localizedClass"] = true,
			["class"] = true,
			["localizedRace"] = true,
			["name"] = true,
		}
		local race, gender
		player["localizedClass"], player["class"],
		player["localizedRace"], race, gender, player["name"] = "Друид", "ROGUE", "Человек", "HUMAN", "MALE", "test"

		local filterGroupKey, classMatch, wordGroup = addon.Message:Filter(parser, "ROGUE")
		if filterGroupKey then
			--parser:RemoveDupes()
			local channel = math.random(1,2) == 2 and "SAY" or (math.random(1,2) == 2 and "YELL" or math.random(1,4))
			addon.Message:TrackIt(channel, parser, filterGroupKey, classMatch, wordGroup, "SHIT", "test", player, race, gender)
		end

		parser:Destroy()
		parser = nil
	end
end

SLASH_TRITON1 = "/triton"
function SlashCmdList.TRITON()
	addon.Tracker:Toggle()
end

addon.isBusy = false
addon.waitTable = {}

function addon:LockBusy(runFunc, args)
	print("|cffff0000LOCKED|r")
	table.insert(self.waitTable, {runFunc, args})
	if not self.waiting then
		self.frame:SetScript("OnUpdate", self.WaitRoom)
		self.waiting = true
	end
end

-- https://wowwiki-archive.fandom.com/wiki/USERAPI_wait
function addon.WaitRoom()
	local removed = 0
	local waitLen = #addon.waitTable
	local wait
	local i = 1
	while i <= waitLen do
		if addon.isBusy then break end
		wait = table.remove(addon.waitTable, 1)
		if wait[2] then
			wait[1](unpack(wait[2]))
		else
			wait[1]()
		end
		removed = removed + 1
		i = i + 1
	end
	if removed == waitLen then
		addon.frame:SetScript("OnUpdate", nil)
		addon.waiting = false
	end
end

function addon:NewTimer(delay, callback, loop, firstDelay)
	if delay < 0.01 then delay = 0.01 end
	local timer = {
		loop = loop,
		closure = true,
		callback = callback,
		delay = delay,
		cancelled = false,
	}

	timer.closure = function()
		if timer.cancelled then return end
		local success = timer.callback()
		if success == false then
			C_Timer.After(0.01, timer.closure)
		elseif timer.loop and not timer.cancelled then
			C_Timer.After(timer.delay, timer.closure)
		else
			timer = nil
		end
	end

	firstDelay = firstDelay and (firstDelay < 0.01 and 0.01 or firstDelay) or delay
	C_Timer.After(firstDelay, timer.closure)
	return timer
end

function addon:CancelTimer(timer)
	timer.cancelled = true
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
		local trackerToggled = not DB.trackerEnabled
		if DB.trackerWindowOpened or DB.doTrackWhenClosed then
			if trackerToggled then
				if not self.trackEvents then
					self.FilterGroup:Init()
					if self.FilterGroup.haveMatchVariants then enable = true end
				end
			else
				if self.trackEvents then enable = false end
			end
		end
		DB.trackerEnabled = trackerToggled
	elseif DB.trackerEnabled then
		if status == "trackerWindow" then
			if DB.trackerWindowOpened then
				if DB.doTrackWhenClosed then
					if not self.trackEvents then
						self.FilterGroup:Init()
						if self.FilterGroup.haveMatchVariants then enable = true end
					end
				else
					self.FilterGroup:Init()
					if self.FilterGroup.haveMatchVariants then enable = true end
				end
			else
				if not DB.doTrackWhenClosed and self.trackEvents then enable = false end
			end
		elseif status == "filterGroupEdit" then
			if self.trackEvents then
				self.FilterGroup:Init()
				if not self.filterGroup.haveMatchVariants then enable = false end
			else
				if DB.trackerWindowOpened or DB.doTrackWhenClosed then
					self.FilterGroup:Init()
					if self.FilterGroup.haveMatchVariants then enable = true end
				end
			end
		elseif status == "option" then
			if not DB.trackerWindowOpened then
				if DB.doTrackWhenClosed then
					self.FilterGroup:Init()
					if self.FilterGroup.haveMatchVariants then enable = true end
				else
					if self.trackEvents then enable = false end
				end
			end
		elseif status == "init" then
			if DB.trackerWindowOpened or DB.doTrackWhenClosed then
				self.FilterGroup:Init()
				if self.FilterGroup.haveMatchVariants then enable = true end
			end
		end
	end
	if enable == true then
		self:RegisterEvent("CHAT_MSG_SAY", self.Message)
		self:RegisterEvent("CHAT_MSG_YELL", self.Message)
		self:RegisterEvent("CHAT_MSG_CHANNEL", self.Message)
		self:RegisterEvent("CHAT_MSG_WHISPER", self.Message)
		self.trackEvents = true
	elseif enable == false then
		self.trackEvents = false
		self:UnregisterEvent("CHAT_MSG_SAY")
		self:UnregisterEvent("CHAT_MSG_YELL")
		self:UnregisterEvent("CHAT_MSG_CHANNEL")
		self:UnregisterEvent("CHAT_MSG_WHISPER")
	end
end