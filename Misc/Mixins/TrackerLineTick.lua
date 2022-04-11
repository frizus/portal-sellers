local addonName, addon = ...
local TrackerLineTick = {}
addon.TrackerLineTick = TrackerLineTick
local DB, L = addon.param, addon.L

local say = "SAY"
local yell = "YELL"
local sayColor = "ffffffff"
local yellColor = "ffff3f40"
local channelColor = "fffec1c0"
local channelTextColor = "ff00cccc"

local function ChannelNameColor(channel)
    if channel == say then return L["say"], sayColor end
    if channel == yell then return L["yell"], yellColor end
    return channel, channelColor
end

local function TextColor(channel)
    if channel == say then return sayColor end
    if channel == yell then return yellColor end
    return channelTextColor
end

local function Channels(message)
    if not DB.trackerHideSimilarMessages then
        local variant = message["variants"][message["variantKey"]]
        if variant["channelsLen"] == 1 and
            (variant["channel"] == say or variant["channel"] == yell)
        then
            return nil
        end
        local s, name, color = "", nil, nil
        addon.Message:ChannelsSort(variant)
        for i, id in ipairs(variant["channelsOrder"]) do
            if i > 1 then s = s .. " " end
            local channel = variant["channels"][id]["channel"]
            name, color = ChannelNameColor(channel)
            s = s .. "|c" .. color .. "[" .. name .. "]" .. "|r"
        end
        return s
    end

    if message["channel"] == say or message["channel"] == yell then
        return nil
    end

    local channel = message["channel"]
    local name, color = ChannelNameColor(channel)
    return "|c" .. color .. "[" .. name .. "]" .. "|r"
end

TrackerLineTick.ReleaseTick = function(self)
    self.text1 = nil
    self.text2 = nil
    self.text3 = nil
    self.text4 = nil
    self.text5 = nil
    self.message = nil
    self.whoText = nil
    self.haveWho = nil
    self.lastUpdated = nil
end
TrackerLineTick.Tick = function(self, changed, now, id)
    local message, who
    if changed then
        if id then self.id = id end
        message = addon.Message.trackedMessages[self.id]
        if not who then
            who = addon.Message.who[message["playerInfo"]["name"]]
        end

        local alias = addon.param.filterGroups[message["matchInfo"]["filterGroupKey"]]["alias"]
        self.text1 = "|cff00cc00"
        if alias then
            self.text1 = self.text1 .. alias
        else
            self.text1 = self.text1 .. message["matchInfo"]["wordGroup"]
        end
        self.text1 = self.text1 .. "|r "
        self.text1 = self.text1 ..
            "|cffca99ff[|r" ..
            "|c" .. RAID_CLASS_COLORS[message["playerInfo"]["class"]]["colorStr"] ..
            message["playerInfo"]["name"]
        local hadWho = self.haveWho
        self.haveWho = who ~= nil
        if self.haveWho then
            self.text2 = who["text"] .. " |cff008800"
            self.text3 = "|r"
        elseif hadWho then
            self.text2 = false
            self.text3 = false
        end
        self.text4 = "|r|cffca99ff]|r"
        local channels = Channels(message)
        if channels then self.text4 = self.text4 .. " " .. channels end
        self.text4 = self.text4 .. " "
        local color = TextColor(message["channel"])
        if not DB.trackerHideSimilarMessages and message["variantsLen"] > 1 then
            self.text4 = self.text4 .. "|cffffffaa+" .. (message["variantsLen"] - 1) .. "|r "
        end
        self.text4 = self.text4 .. "|c" .. color .. message["message"] .. "|r |cff008800"
        self.text5 = "|r"
    else
        message = addon.Message.trackedMessages[self.id]
        if self.haveWho then
            who = addon.Message.who[message["playerInfo"]["name"]]
        end
    end

    if now then
        self.lastUpdated = now
    else
        now = self.lastUpdated
    end

    if not self.haveWho then
        self:SetText(
            self.text1 .. self.text4 ..
            string.format(L["tracker_line_seconds"], math.floor(now - message["updated"])) ..
            self.text5
        )
    else
        self:SetText(
            self.text1 .. self.text2 ..
            string.format(L["tracker_line_seconds"], math.floor(now - who["updated"])) ..
            self.text4 ..
            string.format(L["tracker_line_seconds"], math.floor(now - message["updated"])) ..
            self.text5
        )
    end
end