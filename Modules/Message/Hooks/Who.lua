local addonName, addon = ...
local Message = addon.Message
local LibDeformat, L = LibStub("LibDeformat-3.0"), addon.L
local Tracker = addon.Tracker

Message.who = {}
Message.whoLen = 0
Message.whoTimeout = 30

function Message:CHAT_MSG_SYSTEM(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    local _, name, level, race, class, _, location = LibDeformat(text, WHO_LIST_GUILD_FORMAT)
    if not name then
        _, name, level, race, class, location = LibDeformat(text, WHO_LIST_FORMAT)
    end
    if not name or not level or not location then return end

    if self.requestedWho == name or self.requestedWhoRealm == name then
        self:AddWho(name, level, location)
    end
end

function Message:WHO_LIST_UPDATE()
    local who, name
    for i = 1, C_FriendList.GetNumWhoResults() do
        who = C_FriendList.GetWhoInfo(i)

        name = who["fullName"]
        local dash = string.find(name, "-", 1, true)
        if dash then name = string.sub(name, 1, dash - 1) end

        if self.requestedWho == name or self.requestedWhoRealm == name then
            self:AddWho(name, who["level"], who["area"])
            break
        end
    end
end

function Message:AddWho(name, level, area)
    if addon.isBusy then
        addon:LockBusy(self.AddWho, {self, name, level, area})
        return
    end
    addon.busy = true

    local dash = string.find(name, "-", 1, true)
    if dash then name = string.sub(name, 1, dash - 1) end
    local oldLevel, oldArea
    if self.who[name] then
        oldLevel = self.who[name]["level"]
        oldArea = self.who[name]["area"]
        self.who[name]["level"] = level
        self.who[name]["area"] = area
        self.who[name]["updated"] = GetTime()
    else
        self.who[name] = {
            level = level,
            area = area,
            updated = GetTime(),
        }
        self.whoLen = self.whoLen + 1
    end

    self:MarkChanged("who", (oldLevel ~= level or oldArea ~= area) and name or nil)
    self:UnbindWhoEvents()
    self.requestedWho = false
    self.requestedWhoRealm = false
    Tracker:Update()
    addon.busy = false
end

function Message:BindWhoEvents()
    if self.whoEventsTimeoutTimer then
        addon:CancelTimer(self.whoEventsTimeoutTimer)
    else
        addon:RegisterEvent("CHAT_MSG_SYSTEM", self)
        addon:RegisterEvent("WHO_LIST_UPDATE", self)
    end
    self.whoEventsTimeoutTimer = addon:NewTimer(self.whoTimeout, self.WhoEventsTimeout)
end

function Message:UnbindWhoEvents()
    if self.whoEventsTimeoutTimer then
        addon:UnregisterEvent("CHAT_MSG_SYSTEM")
        addon:UnregisterEvent("WHO_LIST_UPDATE")
        addon:CancelTimer(self.whoEventsTimeoutTimer)
        self.whoEventsTimeoutTimer = false
    end
end

function Message.WhoEventsTimeout()
    addon:UnregisterEvent("CHAT_MSG_SYSTEM")
    addon:UnregisterEvent("WHO_LIST_UPDATE")
    Message.whoEventsTimeoutTimer = false
    Message.requestedWho = false
    Message.requestedWhoRealm = false
end