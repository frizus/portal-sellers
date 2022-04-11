local addonName, addon = ...
local Message = addon.Message
local LibDeformat, L = LibStub("LibDeformat-3.0"), addon.L
local Tracker = addon.Tracker

Message.who = {}
Message.whoLen = 0
Message.addWhoBusy = 0

function Message:CHAT_MSG_SYSTEM(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    --if not self.requestedWho then return end

    local _, name, level, race, class, _, location = LibDeformat(text, WHO_LIST_GUILD_FORMAT)
    if not name then
        _, name, level, race, class, location = LibDeformat(text, WHO_LIST_FORMAT)
    end
    if not name or not level or not location then return end

    local dash = string.find(name, "-", 1, true)
    if dash then name = string.sub(name, 1, dash - 1) end
    if true or self.requestedWho == name then
        self:AddWho(name, level, location)
    end
end

function Message:WHO_LIST_UPDATE()
    --if not self.requestedWho then return end

    local who, name
    for i = 1, C_FriendList.GetNumWhoResults() do
        who = C_FriendList.GetWhoInfo(i)

        name = who["fullName"]
        local dash = string.find(name, "-", 1, true)
        if dash then name = string.sub(name, 1, dash - 1) end

        if true or self.requestedWho == name then
            self:AddWho(name, who["level"], who["area"])
            break
        end
    end
end

function Message:AddWho(name, level, area)
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.AddWho, {self, name, level, area})
        return
    end
    addon.busy = true

    local text = " - " .. level .. " " .. L["level_abbr"] .. " - " .. area
    local oldWhoText
    if self.who[name] then
        oldWhoText = self.who[name]["text"]
        self.who[name]["text"] = text
        self.who[name]["updated"] = GetTime()
    else
        self.who[name] = {
            text = text,
            updated = GetTime(),
        }
        self.whoLen = self.whoLen + 1
    end

    self:MarkChanged("who", oldWhoText ~= text and name or nil)
    self.requestedWho = false
    self:UnbindWhoEvents()
    addon.busy = false
end

function Message:UnbindWhoEvents()
    if self.whoEventsTimeoutTimer then
        addon:UnregisterEvent("CHAT_MSG_SYSTEM")
        addon:UnregisterEvent("WHO_LIST_UPDATE")
        self.whoEventsTimeoutTimer:Cancel()
        self.whoEventsTimeoutTimer = false
    end
end