local addonName, addon = ...
local WordGroupsParser = {}
addon.WordGroupsParser = WordGroupsParser
local Chars = addon.Chars

function WordGroupsParser:Parse(raw)
    local state = ""
    local wordGroups = {}
    local parsedWordGroup, word, c
    local normalized, normalizedWords = "", ""
    local assoc = {["&"] = {}, ["-"] = {}}
    local addedContain, addedNegate
    self.reader = string.reader(raw)

    while not self.reader:eof() do
        if state == "" or state == "," then
            word, normalized = self:GetWord()
            if word[2] ~= 0 then
                parsedWordGroup = {["&"] = {word}}
                assoc["&"][normalized] = true
                normalizedWords = normalized
                addedContain = true
            end
        elseif state == "&" then
            word, normalized = self:GetWord()
            if word[2] ~= 0 then
                if not parsedWordGroup then
                    parsedWordGroup = {}
                end
                if not parsedWordGroup["&"] then
                    parsedWordGroup["&"] = {}
                end

                if not assoc["&"][normalized] then
                    table.insert(parsedWordGroup["&"], word)
                    assoc["&"][normalized] = true
                    if addedContain or addedNegate then
                        normalizedWords = normalizedWords .. "&"
                    end
                    addedContain = true
                    normalizedWords = normalizedWords .. normalized
                end
            end
        elseif state == "-" then
            word, normalized = self:GetWord()
            if word[2] ~= 0 then
                if not parsedWordGroup then
                    parsedWordGroup = {}
                end
                if not parsedWordGroup["-"] then
                    parsedWordGroup["-"] = {}
                end

                if not assoc["-"][normalized] then
                    table.insert(parsedWordGroup["-"], word)
                    assoc["-"][normalized] = true
                    normalizedWords = normalizedWords .. "-" .. normalized
                    addedNegate = true
                end
            end
        end

        if self.reader:eof() then
            break
        end

        c = self.reader:getNext()
        if c == "," then
            state = ","
            if parsedWordGroup then
                parsedWordGroup["string"] = normalizedWords
                table.insert(wordGroups, parsedWordGroup)
                parsedWordGroup = nil
                for key in pairs(assoc["&"]) do assoc["&"][key] = nil end
                for key in pairs(assoc["-"]) do assoc["-"][key] = nil end
                normalizedWords = ""
                addedContain = nil
                addedNegate = nil
            end
        elseif c == "&" then
            state = "&"
        elseif c == "-" then
            state = "-"
        end
    end

    if parsedWordGroup then
        parsedWordGroup["string"] = normalizedWords
        table.insert(wordGroups, parsedWordGroup)
    end
    self.reader = nil

    return wordGroups
end

function WordGroupsParser:GetWord()
    local c, c2 = self.reader:peek(), nil
    local word = {{}, 0}
    local normalized = ""
    local start, spaceSequence, isSpace = true, nil, nil

    while c ~= "," and c ~= "&" and c ~= "-" do
        self.reader:ignore1()
        if c == "\\" then
            isSpace = false
            if not self.reader:eof() then
                c2 = self.reader:peek()
                if c2 == "," or c2 == "&" or c2 == "-" then
                    c = c2
                    c2 = nil
                    self.reader:ignore1()
                elseif c2 == "\\" then
                    c2 = nil
                    self.reader:ignore1()
                end
            end
        else
            isSpace = nil
        end

        if isSpace ~= false and Chars:IsSpace(c) then
            if not spaceSequence then spaceSequence = true end
        else
            if spaceSequence then
                spaceSequence = nil
                if not start then
                    table.insert(word[1], " ")
                    word[2] = word[2] + 1
                    normalized = normalized .. " "
                end
            end
            if start then start = nil end
            c = strlower(c)
            table.insert(word[1], c)
            word[2] = word[2] + 1
            normalized = normalized .. c
        end
        if not c2 then
            if self.reader:eof() then break end
            c = self.reader:peek()
        else
            c = c2
            c2 = nil
        end
    end

    return word, normalized
end