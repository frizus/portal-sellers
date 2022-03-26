local addonName, addon = ...
local MessageParser = addon.MessageParser

function MessageParser:ParseColor()
    self:Buffer("c")
    local color, c, c2 = "", nil, nil
    for i = 1, 8 do
        if self.reader:eof() then
            return false
        end
        c = self.reader:peek()

        if c == "|" or c == "{" then
            return false
        end
        self.reader:ignore1()

        self:Buffer(c)
        c2 = strlower(c)
        if c2 == "0" or c2 == "1" or c2 == "2" or c2 == "3" or c2 == "4" or
                c2 == "5" or c2 == "6" or c2 == "7" or c2 == "8" or c2 == "9" or
                c2 == "a" or c2 == "b" or c2 == "c" or c2 == "d" or c2 == "e" or
                c2 == "f"
        then
            color = color .. c
        else
            return false
        end
    end

    return true, color
end