local addonName, addon = ...
local MessageParser = {}
addon.MessageParser = MessageParser
local Chars = addon.Chars

function MessageParser:Parse()
    self.buffer = {}
    self.chars = {}
    self.index = 0

    if self.parseWithShiftLinks then
        self.withSL = {
            blocks = {},
            blocksCount = 0,
            block = false,
            allPositions = {},
            positions = false,
            charsStart = true,
            noNonSpaceChars = true,
            spaceSequence = false,
            spacesBorderStart = false,
            spacesBorderEnd = false,
        }
    end
    if self.parseNoShiftLinks then
        self.noSL = {
            blocks = {},
            blocksCount = 0,
            block = false,
            allPositions = {},
            positions = false,
            charsStart = true,
            noNonSpaceChars = true,
            spaceSequence = false,
            spacesBorderStart = false,
            spacesBorderEnd = false,
            shiftLinkLevel = 0,
        }
    end

    self.reader = string.reader(self.message)
    self:BaseParser()
    self.len = self.index
end
function MessageParser:Add(value, type)
    table.insert(self.chars, not type and value or {type, value})
    self.index = self.index + 1

    local isSpace
    if not type then
        isSpace = Chars:IsSpace(value)
        value = strlower(value)
    elseif type == self.newline then
        isSpace = true
    end
    if self.parseWithShiftLinks then
        self:AddWithSL(value, type, isSpace)
    end
    if self.parseNoShiftLinks then
        self:AddNoSL(value, type, isSpace)
    end
end
function MessageParser:AddWithSL(c, type, isSpace)
    local base = self.withSL
    if not type or type == self.newline then
        self:AddSimple(base, c, isSpace)
    else
        if type == self.raidTag or type == self.texture then
            self:AddNewBlock(base)
        end
    end
end
function MessageParser:AddNoSL(c, type, isSpace)
    local base = self.noSL
    if not type or type == self.newline then
        if base.shiftLinkLevel == 0 then
            self:AddSimple(base, c, isSpace)
        end
    else
        if type == self.raidTag or type == self.texture then
            self:AddNewBlock(base)
        elseif type == self.shiftLinkBegin then
            base.shiftLinkLevel = base.shiftLinkLevel + 1
            if base.shiftLinkLevel == 1 then
                self:AddNewBlock(base)
            end
        elseif type == self.shiftLinkEnd then
            if base.shiftLinkLevel ~= 0 then
                base.shiftLinkLevel = base.shiftLinkLevel - 1
            end
        end
    end
end
function MessageParser:AddSimple(base, c, isSpace)
    if isSpace then
        if not base.charsStart then
            if not base.spaceSequence then
                base.spaceSequence = true
                base.spacesBorderStart = self.index
            else
                base.spacesBorderEnd = self.index
            end
        end
    else
        if not base.block then
            table.insert(base.blocks, {{}, 0})
            base.blocksCount = base.blocksCount + 1
            base.block = base.blocks[base.blocksCount]
            table.insert(base.allPositions, {{}, 0})
            base.positions = base.allPositions[base.blocksCount]
        end

        if base.spaceSequence then
            base.spaceSequence = false
            if not base.spacesBorderEnd then
                table.insert(base.positions[1], base.spacesBorderStart)
            else
                table.insert(base.positions[1], {
                    base.spacesBorderStart,
                    base.spacesBorderEnd
                })
            end
            base.positions[2] = base.positions[2] + 1
            table.insert(base.block[1], " ")
            base.block[2] = base.block[2] + 1
            base.spacesBorderStart = false
            base.spacesBorderEnd = false
        end
        if base.charsStart then base.charsStart = false end
        table.insert(base.block[1], c)
        base.block[2] = base.block[2] + 1
        table.insert(base.positions[1], self.index)
        base.positions[2] = base.positions[2] + 1
        if base.noNonSpaceChars then base.noNonSpaceChars = false end
    end
end
function MessageParser:AddNewBlock(base)
    if not base.charsStart then
        base.positions = false
        base.block = false
        base.charsStart = true
    end
    if base.spaceSequence then
        base.spaceSequence = false
        base.spacesBorderStart = false
        base.spacesBorderEnd = false
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
        local reader = string.reader(chars)
        while not reader:eof() do
            table.insert(self.buffer, reader:getNext())
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
function MessageParser:GetBlocks(noShiftLinks)
    return noShiftLinks and self.noSL.blocks or self.withSL.blocks
end
function MessageParser:Empty(noShiftLinks)
    return noShiftLinks and self.noSL.noNonSpaceChars or self.withSL.noNonSpaceChars
end

function MessageParser:Construct(message, parseWithShiftLinks, parseNoShiftLinks, parseRaidTags)
    self.message = message
    self.parseWithShiftLinks = parseWithShiftLinks
    self.parseNoShiftLinks = parseNoShiftLinks
    self.parseRaidTags = parseRaidTags
end

function MessageParser:Destroy()
    self.buffer = nil
    self.message = nil
    self.parseRaidTags = nil
    self.chars = nil
    self.index = nil
    if self.parseWithShiftLinks then
        self.withSL = nil
    end
    self.parseWithShiftLinks = nil
    if self.parseNoShiftLinks then
        self.noSL = nil
    end
    self.parseNoShiftLinks = nil
    self.reader:destroy()
    self.reader = nil
    self.len = nil
end

function MessageParser:Create(message, parseWithShiftLinks, parseNoShiftLinks, parseRaidTags)
    if type(message) ~= "string" then
        error("bad argument #1 to 'MessageParser:Create' (string expected, got ".. type(message).. ")")
    end

    local parser = {}
    for name, closure in pairs(MessageParser) do
        parser[name] = closure
    end
    parser:Construct(message, parseWithShiftLinks, parseNoShiftLinks, parseRaidTags)

    return parser
end