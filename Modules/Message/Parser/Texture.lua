local addonName, addon = ...
local MessageParser = addon.MessageParser

function MessageParser:ParseTexture()
    self:Buffer("T")
    if self.reader:eof() then
        return false
    end

    local c, texture = self.reader:peek(), ""
    while c ~= "|" do
        self.reader:ignore1()
        self:Buffer(c)
        texture = texture .. c
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

    if c ~= "t" then
        self.reader:seek(position)
        return false
    end
    self.reader:ignore1()
    self:Buffer(c)

    return true, texture
end