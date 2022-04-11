local addonName, addon = ...
local MessageParser = addon.MessageParser

function MessageParser:GetFormattedMessage(highlighted)
    local s = ""
    local chars = highlighted and self.highlighted or self.chars
    for _, c in pairs(chars) do
        if type(c) ~= "table" then
            s = s .. c
        else
            if c[1] == self.colorBegin then
                s = s .. "|c" .. c[2]
            elseif c[1] == self.colorEnd then
                s = s .. "|r"
            elseif c[1] == self.shiftLinkBegin then
                s = s .. "|H" .. c[2] .. "|h"
            elseif c[1] == self.texture then
                s = s .. "|T" .. c[2] .. "|t"
            elseif c[1] == self.shiftLinkEnd then
                s = s .. "|h"
            elseif c[1] == self.raidTag then
                if ICON_LIST then
                    s = s .. ICON_LIST[ICON_TAG_LIST[c[2]]] .. "0:0:0:0" .. "|t"
                end
            elseif c[1] == self.newline then
                s = s .. "|n"
            elseif c[1] == self.battleNetTagRedundantEnd then
                s = s .. "|k"
            elseif c[1] == self.textureRedundantEnd then
                s = s .. "|t"
            end
        end
    end
    return s
end

function MessageParser:GetSearchMessage(noShiftLinks)
    local s = ""
    local blocks = noShiftLinks and self.noSL.blocks or self.withSL.blocks
    for _, block in pairs(blocks) do
        s = s .. "|cffFFFF00–|r"
        for _, c in pairs(block[1]) do
            if c == "|" then
                s = s .. "|"
            end
            s = s .. c
        end
    end
    return s
end