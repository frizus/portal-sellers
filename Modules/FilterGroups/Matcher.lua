local addonName, addon = ...
local FilterGroup = {}
addon.FilterGroup = FilterGroup
local Chars, DB = addon.Chars, addon.param

function FilterGroup:Matches(messageParser, playerClass)
    if not self.haveClassMatch then
        if messageParser:Empty() or
            (self.haveRemoveShiftLinks and
                not self.haveWithShiftLinks and
                messageParser:Empty(true)
            )
        then
            return false
        end
    else
        playerClass = " " .. playerClass .. " "
    end

    local classMatch, wordGroupMatch, wordGroup

    for _, matchVariant in pairs(self.matchVariants) do
        classMatch = self:ClassMatch(playerClass, matchVariant["classes"])
        if classMatch ~= false then
            wordGroupMatch, wordGroup = self:WordGroupMatch(
                messageParser, matchVariant["wordGroup"], DB.filterGroups[matchVariant["key"]]
            )
            if wordGroupMatch ~= false then
                if wordGroupMatch or (wordGroupMatch == nil and classMatch) then
                    return true, matchVariant["key"], classMatch, wordGroup
                end
            elseif matchVariant["global"] then
                return false
            end
        elseif matchVariant["global"] then
            return false
        end
    end

    return false
end

function FilterGroup:ClassMatch(playerClass, classes)
    if not classes then return nil end
    return string.find(classes, playerClass, 1, true) ~= nil
end

function FilterGroup:WordGroupMatch(messageParser, wordGroup, filterGroup)
    if not wordGroup then return nil end
    if messageParser:Empty(filterGroup["removeShiftLinks"]) then
        return false
    end

    local blocks = messageParser:GetBlocks(filterGroup["removeShiftLinks"])
    if wordGroup["-"] then
        for _, negate in pairs(wordGroup["-"]) do
            for _, block in pairs(blocks) do
                if Chars:Position(block[1], block[2], negate[1], negate[2], 1, filterGroup["wordSearch"]) then
                    return false
                end
            end
        end
    end
    if wordGroup["&"] then
        if not DB.highlightKeywords then
            local found
            for _, contain in pairs(wordGroup["&"]) do
                found = false
                for _, block in pairs(blocks) do
                    if Chars:Position(block[1], block[2], contain[1], contain[2], 1, filterGroup["wordSearch"]) then
                        found = true
                        break
                    end
                end
                if not found then return false end
            end
        else
            local pos, firstPositions = nil, {}
            local found
            for i, contain in pairs(wordGroup["&"]) do
                found = false
                for j, block in pairs(blocks) do
                    pos = Chars:Position(block[1], block[2], contain[1], contain[2], 1, filterGroup["wordSearch"])
                    if pos then
                        found = true
                        firstPositions[i] = {j, pos}
                        break
                    end
                end
                if not found then return false end
            end
            messageParser:Highlight(filterGroup["removeShiftLinks"], wordGroup["&"], firstPositions, filterGroup["wordSearch"])
        end
    end
    return true, wordGroup["string"]
end