local addonName, addon = ...
local Table = addon.Table
local MessageParser = addon.MessageParser

MessageParser.colorBegin = 1
MessageParser.colorEnd = 2
MessageParser.shiftLinkBegin = 3
MessageParser.shiftLinkEnd = 4
MessageParser.texture = 5
MessageParser.battleNetTagRedundantEnd = 6
MessageParser.textureRedundantEnd = 7
MessageParser.raidTag = 8
MessageParser.newline = 9

function MessageParser:BaseParser()
    local c, valid
    local simple
    while not self.reader:eof() do
        c = self.reader:getNext()
        simple = false
        if c == "|" then
            if self.reader:eof() then
                self:Add(c)
                break
            end
            self:Buffer(c)

            c = self.reader:getNext()
            if c == "|" then
                self:AddFromBuffer()
                self:Add(c)
            elseif c == "c" then
                local color
                valid, color = self:ParseColor()
                if valid then
                    self:Add(color, self.colorBegin)
                    self:CleanBuffer()
                else
                    self:AddFromBuffer()
                end
            elseif c == "r" then
                self:Add(nil, self.colorEnd)
                self:CleanBuffer()
            elseif c == "H" then
                local shiftLink
                valid, shiftLink = self:ParseShiftLink()
                if valid then
                    self:Add(shiftLink, self.shiftLinkBegin)
                    self:CleanBuffer()
                else
                    self:AddFromBuffer()
                end
            elseif c == "T" then
                local texture
                valid, texture = self:ParseTexture()
                if valid then
                    self:Add(texture, self.texture)
                    self:CleanBuffer()
                else
                    self:AddFromBuffer()
                end
            elseif c == "K" then
                local name
                valid, name = self:ParseBattleNetTag()
                if valid then
                    self:CleanBuffer()
                    self:BufferChars(name)
                    self:AddFromBuffer()
                else
                    self:AddFromBuffer()
                end
            elseif c == "h" then
                self:Add(nil, self.shiftLinkEnd)
                self:CleanBuffer()
            elseif c == "k" then
                self:Add(nil, self.battleNetTagRedundantEnd)
                self:CleanBuffer()
            elseif c == "t" then
                self:Add(nil, self.textureRedundantEnd)
                self:CleanBuffer()
            elseif c == "n" then
                self:Add(nil, self.newline)
                self:CleanBuffer()
            else
                self:AddFromBuffer()
                simple = true
            end
        elseif c == "{" and self.parseRaidTags then
            local tag, openingExtra
            valid, tag, openingExtra = self:ParseRaidTag()
            if valid then
                if openingExtra ~= 0 then
                    for i = 1, openingExtra do
                        self:Add("{")
                    end
                end
                self:Add(tag, self.raidTag)
                self:CleanBuffer()
            else
                self:AddFromBuffer()
            end
        else
            simple = true
        end

        if simple then
            self:Add(c)
        end
    end
end