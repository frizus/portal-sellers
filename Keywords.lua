local addonName, addon = ...
local Keywords = {}
addon.Keywords = Keywords

function Keywords:Parse(s, trim)
    local state = "start"
    local keywordsLogics = {}
    local currentKeywordLogic = nil
    local alreadyExists = nil
    local chars = ""
    local c

    local reader = string.reader(s)

    while not reader:eof() do
        if state == "start" or state == "next" then
            -- utf8gsub https://gist.github.com/Stepets/3b4dbaf5e6e6a60f3862
            chars = self:ParserNormalizeSpaces(reader:get({",", "&", "-"}), trim)
            if #chars > 0 then
                chars = chars:lower()
                currentKeywordLogic = {["and"] = {chars}}
                alreadyExists = {["and"] = {[chars] = true}}
            end
        elseif state == "and" then
            chars = self:ParserNormalizeSpaces(reader:get({",", "&", "-"}), trim)
            if #chars > 0 then
                if currentKeywordLogic == nil then
                    currentKeywordLogic = {}
                    alreadyExists = {}
                end
                if currentKeywordLogic["and"] == nil then
                    currentKeywordLogic["and"] = {}
                    alreadyExists["and"] = {}
                end

                chars = chars:lower()
                if alreadyExists["and"][chars] == nil then
                    table.insert(currentKeywordLogic["and"], chars)
                    alreadyExists["and"][chars] = true
                end
            end
        elseif state == "exclude" then
            chars = self:ParserNormalizeSpaces(reader:get({",", "&", "-"}), trim)
            if #chars > 0 then
                if currentKeywordLogic == nil then
                    currentKeywordLogic = {}
                    alreadyExists = {}
                end
                if currentKeywordLogic["exclude"] == nil then
                    currentKeywordLogic["exclude"] = {}
                    alreadyExists["exclude"] = {}
                end

                chars = chars:lower()
                if alreadyExists["exclude"][chars] == nil then
                    table.insert(currentKeywordLogic["exclude"], chars)
                    alreadyExists["exclude"][chars] = true
                end
            end
        end

        if reader:eof() then
            break
        end

        c = reader:peek()
        if c == "," then
            state = "next"
            if currentKeywordLogic ~= nil then
                table.insert(keywordsLogics, currentKeywordLogic)
                currentKeywordLogic = nil
                alreadyExists = nil
            end
        elseif c == "&" then
            state = "and"
        elseif c == "-" then
            state = "exclude"
        end
        reader:ignore(1)
    end

    if currentKeywordLogic ~= nil then
        table.insert(keywordsLogics, currentKeywordLogic)
        alreadyExists = nil
    end

    return keywordsLogics
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