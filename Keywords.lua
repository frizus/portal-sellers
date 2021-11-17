local addonName, addon = ...
local Keywords = {}
addon.Keywords = Keywords

function Keywords:Parse(s, trim)
    local state = ""
    local keywordGroups = {}
    local currentKeywordGroup = nil
    local alreadyExists = nil
    local chars = ""
    local c

    local reader = string.reader(s)

    while not reader:eof() do
        if state == "" or state == "," then
            -- utf8gsub https://gist.github.com/Stepets/3b4dbaf5e6e6a60f3862
            chars = self:ParserNormalizeSpaces(reader:get({",", "&", "-"}), trim)
            if #chars > 0 then
                chars = chars:lower()
                currentKeywordGroup = {["&"] = {chars}}
                alreadyExists = {["&"] = {[chars] = true}}
            end
        elseif state == "&" then
            chars = self:ParserNormalizeSpaces(reader:get({",", "&", "-"}), trim)
            if #chars > 0 then
                if currentKeywordGroup == nil then
                    currentKeywordGroup = {}
                    alreadyExists = {}
                end
                if currentKeywordGroup["&"] == nil then
                    currentKeywordGroup["&"] = {}
                    alreadyExists["&"] = {}
                end

                chars = chars:lower()
                if alreadyExists["&"][chars] == nil then
                    table.insert(currentKeywordGroup["&"], chars)
                    alreadyExists["&"][chars] = true
                end
            end
        elseif state == "-" then
            chars = self:ParserNormalizeSpaces(reader:get({",", "&", "-"}), trim)
            if #chars > 0 then
                if currentKeywordGroup == nil then
                    currentKeywordGroup = {}
                    alreadyExists = {}
                end
                if currentKeywordGroup["-"] == nil then
                    currentKeywordGroup["-"] = {}
                    alreadyExists["-"] = {}
                end

                chars = chars:lower()
                if alreadyExists["-"][chars] == nil then
                    table.insert(currentKeywordGroup["-"], chars)
                    alreadyExists["-"][chars] = true
                end
            end
        end

        if reader:eof() then
            break
        end

        c = reader:peek()
        if c == "," then
            state = ","
            if currentKeywordGroup ~= nil then
                table.insert(keywordGroups, currentKeywordGroup)
                currentKeywordGroup = nil
                alreadyExists = nil
            end
        elseif c == "&" then
            state = "&"
        elseif c == "-" then
            state = "-"
        end
        reader:ignore(1)
    end

    if currentKeywordGroup ~= nil then
        table.insert(keywordGroups, currentKeywordGroup)
        alreadyExists = nil
    end

    return keywordGroups
end

function Keywords:ParserNormalizeSpaces(s, trim)
    s = string.gsub(s, "%s+", " ")

    if s == " " then
        return ""
    end
    if trim then
        s = strtrim(s)
    end
    return s
end