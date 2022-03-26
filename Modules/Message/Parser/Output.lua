local addonName, addon = ...
local MessageParser = addon.MessageParser

function MessageParser:GetFormattedMessage()
    local s = ""
    if self.base.extraLayerType[0] then
        s = s .. self:OutputExtra(0)
    end
    for i, char in pairs(self.base.chars) do
        if char ~= " " then
            s = s .. char
        end
        if self.base.extraLayerType[i] then
            s = s .. self:OutputExtra(i)
        end
    end
    return s
end

function MessageParser:GetSearchMessage(noShiftLinks)
    local s = ""
    local chars = (noShiftLinks and self.parseNoShiftLinks) and self.noSL.chars or self.base.chars
    for i, char in pairs(chars) do
        if char == "|" then
            s = s .. "|"
        end
        s = s .. char
    end
    return s
end

function MessageParser:OutputExtra(index)
    local s, value = "", nil
    if self.base.extraLayerType[index] then
        for i, type in pairs(self.base.extraLayerType[index]) do
            value = self.base.extraLayerValue[index][i]
            if type == "space" then
                if not value then
                    print(index,i)
                end
                s = s .. value
            elseif type == "colorBegin" then
                s = s .. "|c" .. value
            elseif type == "colorEnd" then
                s = s .. "|r"
            elseif type == "shiftLinkBegin" then
                s = s .. "|H" .. value .. "|h"
            elseif type == "texture" then
                s = s .. "|T" .. value .. "|t"
            elseif type == "shiftLinkEnd" then
                s = s .. "|h"
            elseif type == "raidTag" then
                if ICON_LIST then
                    s = s .. ICON_LIST[ICON_TAG_LIST[value]] .. "0:0:0:0" .. "|t"
                end
            elseif type == "battleNetTagRedundantEnd" then
                s = s .. "|k"
            elseif type == "textureRedundantEnd" then
                s = s .. "|t"
            end
        end
    end
    return s
end
