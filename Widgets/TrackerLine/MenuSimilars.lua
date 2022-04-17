local addonName, addon = ...
local TrackerMenuSimilars = {}
addon.TrackerMenuSimilars = TrackerMenuSimilars
local L = addon.L

local say = "SAY"
local yell = "YELL"

local function ChannelName(channel)
    if channel == say then return L["say"] end
    if channel == yell then return L["yell"] end
    return channel
end

local function Channels(variant)
    local s = ""
    addon.Message:ChannelsSort(variant)
    for i, id in ipairs(variant["channelsOrder"]) do
        if i > 1 then s = s .. " " end
        s = s .. "[" .. ChannelName(variant["channels"][id]["channel"]) .. "]"
    end
    return s
end

function TrackerMenuSimilars:Similar(message, variantId, i)
    local variant = message["variants"][variantId]
    return {
        isText = true,
        params = {
            variantId = variantId,
            text2 = Channels(variant) .. "|r ",
            text4 = variant["unescaped"] .. "|r ",
            text6 = "|r",
        }
    }
end

function TrackerMenuSimilars:SimilarGlue(texts, i, now, updated)
    return (i == 1 and "|cfffff000" or "|cffb1c9c9") ..
        texts["text2"] ..
        (i == 1 and "|cffffd100" or "|cff889d9d") ..
        texts["text4"] ..
        (i == 1 and "|cfffff000" or "|cffb1c9c9") ..
        string.format(L["tracker_line_seconds"], math.floor(now - updated)) ..
        texts["text6"]
end