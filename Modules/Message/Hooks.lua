local addonName, addon = ...
local Message = {}
addon.Message = Message
local FilterGroup, MessageParser, DB = addon.FilterGroup, addon.MessageParser, addon.param
local Table, Tracker = addon.Table, addon.Tracker

Message.trackedMessages = {}
Message.trackedMessagesLen = 0
Message.trackItBusy = 0
Message.changed = false

function Message:CHAT_MSG_SAY(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    self:Handle("SAY", text, guid, playerName)
end

function Message:CHAT_MSG_YELL(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    self:Handle("YELL", text, guid, playerName)
end

function Message:CHAT_MSG_CHANNEL(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    self:Handle(channelIndex, text, guid, playerName)
end

function Message:CHAT_MSG_WHISPER(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)
    --tprint(addon.WordGroupsParser:Parse(text))
    self:Handle("WHISPER", text, guid, playerName)
end

function Message:Handle(channel, message, playerGuid, playerName)
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.Handle, {self, channel, message, playerGuid, playerName})
        return
    end
    addon.busy = true
    if self:IsPlayerBanned(playerName, playerGuid) then
        return
    end

    local player = {
        ["localizedClass"] = true,
        ["class"] = true,
        ["localizedRace"] = true,
        ["name"] = true,
    }
    local race, gender
    player["localizedClass"], player["class"],
    player["localizedRace"], race, gender, player["name"] = GetPlayerInfoByGUID(playerGuid)

    local parser = MessageParser:Create(message, FilterGroup.haveWithShiftLinks, FilterGroup.haveRemoveShiftLinks, true)
    parser:Parse()

    local filterGroupKey, classMatch, wordGroup = self:Filter(parser, player["class"])
    if filterGroupKey then
        --parser:RemoveDupes()
        self:TrackIt(channel, parser, filterGroupKey, classMatch, wordGroup, playerGuid, playerName, player, race, gender)
    end

    parser:Destroy()
    parser = nil
    addon.busy = false
end

function Message:IsPlayerBanned(playerName, playerGuid)
    if GlobalIgnoreDB then
        for _, bannedName in pairs(GlobalIgnoreDB.ignoreList) do
            if bannedName == playerName then
                return true
            end
        end
    end

    return AcamarAPIHelper and AcamarAPIHelper:IsBlock(playerGuid)
end

function Message:Filter(messageParser, playerClass)
    local matches, filterGroupKey, classMatch, wordGroup = FilterGroup:Matches(messageParser, playerClass)
    if matches then
        return filterGroupKey, classMatch, wordGroup
    end
end

function Message:TrackIt(channel, parser, filterGroupKey, classMatch, wordGroup, playerGuid, playerName, playerInfo, race, gender)
    local groupId = playerGuid .. ":" .. filterGroupKey .. ":"
    if wordGroup then
        groupId = groupId .. wordGroup
    end

    local messageKey, messageValue
    if not DB.highlightKeywords then
        messageKey = parser:GetFormattedMessage(false)
        messageValue = messageKey
    else
        messageKey = parser:GetFormattedMessage(false)
        messageValue = parser:GetFormattedMessage(true)
    end
    if self.trackedMessages[groupId] then
        local group = self.trackedMessages[groupId]
        self:MarkChanged("update", group["message"] ~= messageValue and groupId or nil)
        self:AddVariant(group, channel, messageKey, messageValue)
    else
        playerInfo["nameRealm"] = playerName
        playerInfo["raceIcon"] = strupper(race) .. (gender == 3 and "_FEMALE" or "_MALE")
        local group = {
            updated = true,
            matchInfo = {
                ["filterGroupKey"] = filterGroupKey,
                ["class"] = classMatch and playerInfo["class"] or nil,
                ["wordGroup"] = wordGroup
            },
            playerInfo = playerInfo,
        }
        if not DB.trackerHideSimilarMessages then
            group["variants"] = {}
            group["variantsLen"] = 0
            group["variantsSorted"] = false
        end
        self:AddVariant(group, channel, messageKey, messageValue)
        self:MarkChanged("add", groupId)
        self.trackedMessages[groupId] = group
        self.trackedMessagesLen = self.trackedMessagesLen + 1
        addon.busy = false
        Tracker:ToggleTimer()
        addon.busy = true
    end
end

function Message:Outdated()
    local now = GetTime()
    local haveWho = {}
    local removedMessages = 0
    for groupId, message in pairs(self.trackedMessages) do
        local removeMessage
        if not DB.trackerHideSimilarMessages then
            local removedVariants = 0
            for id, variant in pairs(message["variants"]) do
                local removedChannels = 0
                for channelName, channel in pairs(variant["channels"]) do
                    if (now - channel["updated"]) > DB.trackedMessageLifetime then
                        variant["channels"][channelName] = nil
                        removedChannels = removedChannels + 1
                    end
                end

                if removedChannels == variant["channelsLen"] then
                    removedVariants = removedVariants + 1
                    message["variants"][id] = nil
                elseif removedChannels > 0 then
                    if variant["channelsSorted"] then
                        for i = variant["channelsLen"], variant["channelsLen"] - removedChannels + 1, -1 do
                            variant["channelsOrder"][i] = nil
                        end
                    end
                    variant["channelsLen"] = variant["channelsLen"] - removedChannels
                end
            end

            if removedVariants == message["variantsLen"] then
                removeMessage = true
            elseif removedVariants > 0 then
                if message["variantsSorted"] then
                    for i = message["variantsLen"], message["variantsLen"] - removedVariants + 1, -1 do
                        message["variantsOrder"][i] = nil
                    end
                end
                message["variantsLen"] = message["variantsLen"] - removedVariants
            end
        else
            if (now - message["updated"]) > DB.trackedMessageLifetime then
                removeMessage = true
            end
        end

        if removeMessage then
            self:DeleteChanged(groupId)
            self:MarkChanged("delete", groupId)
            self.trackedMessages[groupId] = nil
            removedMessages = removedMessages + 1
        else
--            tprint(message)
            if not haveWho[message["playerInfo"]["name"]] then
                haveWho[message["playerInfo"]["name"]] = true
            end
        end
    end

    if removedMessages == self.trackedMessagesLen then
        self.trackedMessagesLen = 0
        if self.whoLen ~= 0 then
            wipe(self.who)
            self.whoLen = 0
        end
        Tracker:ToggleTimer()
    elseif removedMessages > 0 then
        self.trackedMessagesLen = self.trackedMessagesLen - removedMessages
        for playerName in pairs(self.who) do
            if not haveWho[playerName] then
                self.who[playerName] = nil
                self.whoLen = self.whoLen - 1
                haveWho[playerName] = nil
            end
        end
    end
end

function Message:CleanMessages()
    wipe(self.trackedMessages)
    self.trackedMessagesLen = 0
    if self.changed then
        self.changed = false
    end
    wipe(self.who)
    self.whoLen = 0
    self:UnbindWhoEvents()
end

function Message:AddVariant(trackedMessage, channelName, messageKey, messageValue)
    local updated = GetTime()
    if not DB.trackerHideSimilarMessages then
        if trackedMessage["variantsSorted"] then trackedMessage["variantsSorted"] = false end
        local variants = trackedMessage["variants"]
        if variants[messageKey] then
            local variant = variants[messageKey]
            variant["updated"] = updated
            if variant["channel"] ~= channelName then
                variant["channel"] = channelName
            end

            if variant["channelsSorted"] then variant["channelsSorted"] = false end
            if variant["channels"][channelName] then
                variant["channels"][channelName]["updated"] = updated
            else
                variant["channelsLen"] = variant["channelsLen"] + 1
                variant["channels"][channelName] = {
                    channel = channelName,
                    sort = type(channelName) == "number" and string.format("Z%02d", channelName) or channelName,
                    updated = updated,
                }
            end
        else
            trackedMessage["variantsLen"] = trackedMessage["variantsLen"] + 1
            variants[messageKey] = {
                message = messageValue,
                original = messageKey,
                updated = updated,
                channel = channelName,
                channelsSorted = false,
                channelsLen = 1,
                channels = {
                    [channelName] = {
                        channel = channelName,
                        sort = type(channelName) == "number" and string.format("Z%02d", channelName) or channelName,
                        updated = updated,
                    }
                },
            }
        end
        trackedMessage["variantKey"] = messageKey
    end

    if trackedMessage["channel"] ~= channelName then
        trackedMessage["channel"] = channelName
    end
    trackedMessage["updated"] = updated
    if trackedMessage["original"] ~= messageKey then
        trackedMessage["original"] = messageKey
        trackedMessage["message"] = messageValue
    end
end

function Message:ChannelsSort(variant)
    if not variant["channelsSorted"] then
        variant["channelsOrder"] = Table:GetSortedKeys(variant["channels"], "sort")
        variant["channelsSorted"] = true
    end
end

function Message:VariantsSort(message)
    if not message["variantsSorted"] then
        message["variantsOrder"] = Table:GetSortedKeys(message["variants"], "updated", false)
        message["variantsSorted"] = true
    end
end