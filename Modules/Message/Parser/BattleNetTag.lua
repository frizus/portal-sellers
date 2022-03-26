local addonName, addon = ...
local MessageParser = addon.MessageParser

local unknownChars = {}
local reader = string.reader(UNKNOWN)
while not reader:eof() do
    table.insert(unknownChars, reader:getNext())
end
reader:destroy()
reader = nil

-- could not find working cases
function MessageParser:ParseBattleNetTag()
    self:Buffer("K")
    if self.reader:eof() then
        return false
    end

    local c, name, presenceId = self.reader:peek(), nil, ""
    while c ~= "|" do
        self.reader:ignore1()
        self:Buffer(c)
        if not name then
            name = c
        else
            if not (c == "0" or c == "1" or c == "2" or c == "3" or c == "4" or
                    c == "5" or c == "6" or c == "7" or c == "8" or c == "9")
            then
                return false
            end
            presenceId = presenceId .. c
        end
        if self.reader:eof() then
            return false
        end
        c = self.reader:peek()
    end

    if not name then
        return false
    end

    local position = self.reader:tell()
    self.reader:ignore1()
    self:Buffer(c)

    if self.reader:eof() then
        return false
    end
    c = self.reader:peek()

    if c ~= "k" then
        self.reader:seek(position)
        return false
    end
    self.reader:ignore1()
    self:Buffer(c)

    return true, unknownChars
end