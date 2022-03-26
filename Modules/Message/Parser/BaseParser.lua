local addonName, addon = ...
local Table = addon.Table
local MessageParser = addon.MessageParser

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
                    self:AddExtra("colorBegin", color)
                    self:CleanBuffer()
                else
                    self:AddFromBuffer()
                end
            elseif c == "r" then
                self:AddExtra("colorEnd")
                self:CleanBuffer()
            elseif c == "H" then
                local shiftLink
                valid, shiftLink = self:ParseShiftLink()
                if valid then
                    self:IncreaseShiftLinkLevel()
                    self:AddExtra("shiftLinkBegin", shiftLink)
                    self:CleanBuffer()
                else
                    self:AddFromBuffer()
                end
            elseif c == "T" then
                local texture
                valid, texture = self:ParseTexture()
                if valid then
                    self:AddExtra("texture", texture)
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
                self:DecreaseShiftLinkLevel()
                self:AddExtra("shiftLinkEnd")
                self:CleanBuffer()
            elseif c == "k" then
                self:AddExtra("battleNetTagRedundantEnd")
                self:CleanBuffer()
            elseif c == "t" then
                self:AddExtra("textureRedundantEnd")
                self:CleanBuffer()
            elseif c == "n" then
                self:Add("\n")
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
                self:AddExtra("raidTag", tag)
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