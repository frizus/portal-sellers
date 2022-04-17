local addonName, addon = ...
local MessageParser, Chars = addon.MessageParser, addon.Chars

MessageParser.highlightColors = {
    "ffffff00",
    "ffccff00",
    "ffffcc00",
    "ffcccc00",
    "ffffff77",
    "ffccff77",
    "ffffcc77",
    "ffcccc77",
}
MessageParser.highlightColorsLen = #MessageParser.highlightColors

function MessageParser:Highlight(noShiftLinks, contains, first, wordSearch)
    local colorNum, pos = 1, nil
    local start, finish
    local base = noShiftLinks and self.noSL or self.withSL
    local allPositions = base.allPositions

    local hlAllPositions = {}
    local hlLengths = {}
    for i, contain in pairs(contains) do
        local foundBlockJ
        local foundBlockPos
        if first and first[i] then
            foundBlockJ = first[i][1]
            foundBlockPos = first[i][2]
            if not hlAllPositions[foundBlockJ] then
                hlAllPositions[foundBlockJ] = {}
                hlLengths[foundBlockJ] = 0
            end
            start = allPositions[foundBlockJ][1][foundBlockPos]
            finish = allPositions[foundBlockJ][1][foundBlockPos + contain[2] - 1]
            table.insert(hlAllPositions[foundBlockJ], {
                type(start) == "table" and start[1] or start,
                type(finish) == "table" and finish[2] or finish,
                colorNum
            })
            hlLengths[foundBlockJ] = hlLengths[foundBlockJ] + 1
            foundBlockPos = foundBlockPos + contain[2]
        end
        for j, block in pairs(base.blocks) do
            pos = j == foundBlockJ and foundBlockPos or 1
            while pos <= block[2] do
                pos = Chars:Position(block[1], block[2], contain[1], contain[2], pos, wordSearch)
                if pos then
                    if not hlAllPositions[j] then
                        hlAllPositions[j] = {}
                        hlLengths[j] = 0
                    end
                    start = allPositions[j][1][pos]
                    finish = allPositions[j][1][pos + contain[2] - 1]
                    table.insert(hlAllPositions[j], {
                        type(start) == "table" and start[1] or start,
                        type(finish) == "table" and finish[2] or finish,
                        colorNum
                    })
                    hlLengths[j] = hlLengths[j] + 1
                    pos = pos + contain[2]
                else
                    break
                end
            end
        end
        colorNum = colorNum ~= self.highlightColorsLen and (colorNum + 1) or 1
    end

    self.highlightCursor = 1
    self.highlighted = {}
    local hlPositionA, hlPositionB, leftIn, rightIn, removed
    for i = 1, base.blocksCount do
        if hlLengths[i] then
            removed = nil
            for j = 1, hlLengths[i] - 1 do
                hlPositionA = hlAllPositions[i][j]
                if hlPositionA then
                    for l = j + 1, hlLengths[i] do
                        hlPositionB = hlAllPositions[i][l]
                        if hlPositionB then
                            leftIn = hlPositionB[1] >= hlPositionA[1] and hlPositionB[1] <= hlPositionA[2]
                            rightIn = hlPositionB[2] >= hlPositionA[1] and hlPositionB[2] <= hlPositionA[2]
                            if leftIn and not rightIn then
                                hlPositionB[1] = hlPositionA[2] + 1
                            elseif not leftIn and rightIn then
                                hlPositionB[2] = hlPositionA[1] - 1
                            elseif leftIn and rightIn then
                                hlAllPositions[i][l] = nil
                                if not removed then removed = true end
                            end
                        end
                    end
                end
            end
            if removed then
                local counter = 1
                for j, hlPosition in pairs(hlAllPositions[i]) do
                    if j ~= counter then
                        hlAllPositions[i][counter] = hlPosition
                        hlAllPositions[i][j] = nil
                    end
                    counter = counter + 1
                end
            end
            table.sort(hlAllPositions[i], self.HighlightSortFunction)
            for _, hlPosition in pairs(hlAllPositions[i]) do
                self:HighlightString(hlPosition[1], hlPosition[2], hlPosition[3])
            end
        end
    end
    self:HighlightEnd()
end

function MessageParser.HighlightSortFunction(a, b)
    return a[1] < b[1]
end

function MessageParser:HighlightString(start, finish, colorNum)
    local c, color = nil, self.highlightColors[colorNum]
    for i = self.highlightCursor, start - 1 do
        table.insert(self.highlighted, self.chars[i])
    end
    table.insert(self.highlighted, {self.highlightBegin, color})
    for i = start, finish do
        c = self.chars[i]
        if type(c) == "table" then
            if c[1] == self.colorBegin then
                table.insert(self.highlighted, {self.highlightEnd})
                table.insert(self.highlighted, c)
                table.insert(self.highlighted, {self.highlightBegin, color})
            elseif c[1] == self.colorEnd then
                table.insert(self.highlighted, c)
                table.insert(self.highlighted, {self.highlightBegin, color})
            else
                table.insert(self.highlighted, c)
            end
        else
            table.insert(self.highlighted, c)
        end
    end
    table.insert(self.highlighted, {self.highlightEnd})
    self.highlightCursor = finish + 1
end

function MessageParser:HighlightEnd()
    if self.highlightCursor <= self.len then
        for i = self.highlightCursor, self.len do
            table.insert(self.highlighted, self.chars[i])
        end
        self.highlightCursor = self.len + 1
    end
end