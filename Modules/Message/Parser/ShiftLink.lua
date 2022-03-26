local addonName, addon = ...
local MessageParser = addon.MessageParser

function MessageParser:ParseShiftLink()
    self:Buffer("H")
    if self.reader:eof() then
        return false
    end

    local c, shiftLink = self.reader:peek(), ""
    while c ~= "|" do
        self.reader:ignore1()
        self:Buffer(c)
        shiftLink = shiftLink .. c
        if self.reader:eof() then
            return false
        end
        c = self.reader:peek()
    end

    local position = self.reader:tell()
    self.reader:ignore1()
    self:Buffer(c)

    if self.reader:eof() then
        return false
    end
    c = self.reader:peek()

    if c ~= "h" then
        self.reader:seek(position)
        return false
    end
    self.reader:ignore1()
    self:Buffer(c)

    return true, shiftLink
end