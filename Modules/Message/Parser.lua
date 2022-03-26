local addonName, addon = ...
local MessageParser = {}
addon.MessageParser = MessageParser
local Chars = addon.Chars

function MessageParser:Parse()
    self.buffer = {}
    self.base = {
        charsStart = true,
        chars = {},
        len = 0,
        spaceSequence = nil,
        extraLayerType = {},
        extraLayerValue = {},
    }
    if self.parseNoShiftLinks then
        self.noSL = {
            charsStart = true,
            chars = {},
            len = 0,
            spaceSequence = nil,
        }
    else
        self.noSL = nil
    end

    self.reader = string.reader(self.message)
    self:BaseParser()

    if self.shiftLinksLevel ~= 0 then
        self.shiftLinksLevel = 0
    end
end
function MessageParser:Add(c)
    self:AddBase(c)
    if self.parseNoShiftLinks then
        self:AddNoShiftLinks(c)
    end
end
function MessageParser:AddBase(c)
    if Chars:IsSpace(c) then
        if not self.base.spaceSequence then
            self.base.spaceSequence = true
        end
        self:AddExtra("space", c)
    else
        if self.base.spaceSequence then
            self.base.spaceSequence = nil
            if not self.base.charsStart then
                table.insert(self.base.chars, " ")
                self.base.len = self.base.len + 1
            end
        end
        if self.base.charsStart then self.base.charsStart = nil end

        table.insert(self.base.chars, c)
        self.base.len = self.base.len + 1
    end
end
function MessageParser:AddNoShiftLinks(c)
    if self.shiftLinksLevel ~= 0 then
        return
    end

    if Chars:IsSpace(c) then
        if not self.noSL.spaceSequence then
            self.noSL.spaceSequence = true
        end
    else
        if self.noSL.spaceSequence then
            self.noSL.spaceSequence = nil
            if not self.noSL.charsStart then
                table.insert(self.noSL.chars, " ")
                self.noSL.len = self.noSL.len + 1
            end
        end
        if self.noSL.charsStart then self.noSL.charsStart = nil end

        table.insert(self.noSL.chars, c)
        self.noSL.len = self.noSL.len + 1
    end
end
function MessageParser:Buffer(c)
    table.insert(self.buffer, c)
end
function MessageParser:BufferChars(chars, base, noShiftLinks)
    if type(chars) == "table" then
        for _, c in pairs(chars) do
            table.insert(self.buffer, c)
        end
    else
        local reader, c = string.reader(chars), nil
        while not reader:eof() do
            c = reader:getNext()
            table.insert(self.buffer, c)
        end
    end
end
function MessageParser:CleanBuffer()
    for i in pairs(self.buffer) do
        self.buffer[i] = nil
    end
end
function MessageParser:AddFromBuffer()
    for i, c in pairs(self.buffer) do
        self:Add(c)
        self.buffer[i] = nil
    end
end
function MessageParser:AddExtra(type, value)
    if self.base.charsStart then self.base.charsStart = nil end
    if not self.base.extraLayerType[self.base.len] then
        self.base.extraLayerType[self.base.len] = {}
        self.base.extraLayerValue[self.base.len] = {}
    end
    table.insert(self.base.extraLayerType[self.base.len], type)
    table.insert(self.base.extraLayerValue[self.base.len], value == nil and true or value)
end
function MessageParser:IncreaseShiftLinkLevel()
    if self.parseNoShiftLinks then
        self.shiftLinksLevel = self.shiftLinksLevel + 1
    end
end
function MessageParser:DecreaseShiftLinkLevel()
    if self.parseNoShiftLinks and self.shiftLinksLevel ~= 0 then
        self.shiftLinksLevel = self.shiftLinksLevel - 1
    end
end
function MessageParser:GetChars(noShiftLinks)
    if noShiftLinks and self.parseNoShiftLinks then
        return self.noSL.chars, self.noSL.len
    end
    return self.base.chars, self.base.len
end
function MessageParser:Empty(noShiftLinks)
    if noShiftLinks and self.parseNoShiftLinks then
        return self.noSL.len == 0
    end
    return self.base.len == 0
end

function MessageParser:Construct(message, parseRaidTags, parseNoShiftLinks)
    if parseNoShiftLinks then
        self.shiftLinksLevel = 0
    end
    self.message = message
    self.parseRaidTags = parseRaidTags
    self.parseNoShiftLinks = parseNoShiftLinks
end

function MessageParser:Destroy()
    self.message = nil
    self.parseRaidTags = nil
    self.base = nil
    if self.parseNoShiftLinks then
        self.noSL = nil
        self.shiftLinksLevel = nil
    end
    self.parseNoShiftLinks = nil
end

function MessageParser:Create(message, parseRaidTags, parseNoShiftLinks)
    if type(message) ~= "string" then
        error("bad argument #1 to 'MessageParser:Create' (string expected, got ".. type(message).. ")")
    end

    local parser = {}
    for name, closure in pairs(MessageParser) do
        parser[name] = closure
    end
    parser:Construct(message, parseRaidTags, parseNoShiftLinks)

    return parser
end