local addonName, addon = ...
local Message = {}
addon.Message = Message
local MessageParser, DB = addon.MessageParser, addon.DB

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
    tprint(addon.WordGroupsParser:Parse(text))
    self:Handle("WHISPER", text, guid, playerName)
end

function Message:Handle(channel, message, playerGuid, playerName)
    if self:IsPlayerBanned(playerName, playerGuid) then
        return
    end

    local player = {
        ["locallizedClass"] = true,
        ["class"] = true,
        ["localizedRace"] = true,
    }
    local race, gender
    player["localizedClass"], player["class"],
    player["localizedRace"], race, gender = GetPlayerInfoByGUID(playerGuid)

    local parser = MessageParser:Create(message)
    parser:Parse()

    if self:Filter(parser, player["class"]) then
        --parser:RemoveDupes()
        self:TrackIt(channel, parser, playerGuid, playerName, player, race, gender)
    end
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

end

function Message:TrackIt(channel, parser, playerGuid, playerName, playerInfo, race, gender)

end