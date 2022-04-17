local addonName, addon = ...
local MessageParser = addon.MessageParser

local raidTagsGroupedByLen = {}
local raidTagsMaxLen = 0
if ICON_TAG_LIST then
    for tag in pairs(ICON_TAG_LIST) do
        local len = string.utf8len(tag)
        if not raidTagsGroupedByLen[len] then
            raidTagsGroupedByLen[len] = {}
        end
        table.insert(raidTagsGroupedByLen[len], tag)
        if raidTagsMaxLen < len then
            raidTagsMaxLen = len
        end
    end
end

function MessageParser:ParseRaidTag()
    self:Buffer("{")
    if self.reader:eof() then
        return false
    end

    local opening, c = 1, self.reader:peek()
    while c == "{" do
        opening = opening + 1
        self.reader:ignore1()
        self:Buffer(c)
        if self.reader:eof() then
            return false
        end
        c = self.reader:peek()
    end

    if c == "|" or c == "}" then
        return false
    end

    local raidTag, len = c, 1
    self.reader:ignore1()
    self:Buffer(c)

    if self.reader:eof() then
        return false
    end
    c = self.reader:peek()

    while c ~= "|" and c ~= "{" and c ~= "}" do
        raidTag = raidTag .. c
        len = len + 1
        self.reader:ignore1()
        self:Buffer(c)
        if len > raidTagsMaxLen or self.reader:eof() then
            return false
        end
        c = self.reader:peek()
    end

    if c ~= "}" or not raidTagsGroupedByLen[len] then
        return false
    end

    local match = false
    raidTag = string.utf8lower(raidTag)
    for _, matchingTag in pairs(raidTagsGroupedByLen[len]) do
        if raidTag == matchingTag then
            match = true
            break
        end
    end
    if not match then
        return false
    end

    local closing = 0
    while c == "}" do
        closing = closing + 1
        self.reader:ignore1()
        self:Buffer(c)
        if closing == opening or self.reader:eof() then
            break
        end
        c = self.reader:peek()
    end

    if closing == 0 then
        return false
    end

    return true, raidTag, opening - closing
end