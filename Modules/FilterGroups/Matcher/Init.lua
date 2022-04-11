local addonName, addon = ...
local FilterGroup, DB, WordGroupsParser = addon.FilterGroup, addon.param, addon.WordGroupsParser
local Table = addon.Table

function FilterGroup:Init()
    if self.inited then return end
    self.inited = true

    self:CreateMatchVariants()
end

function FilterGroup:CreateMatchVariants()
    self.wordGroups = {}
    self.matchVariants = {}
    self.haveMatchVariants = nil
    self.haveClassMatch = nil
    self.haveRemoveShiftLinks = nil
    self.haveWithShiftLinks = nil
    if not DB.filterGroups then return end

    local added, removeShiftLinks, haveClassMatch, wordGroups

    for tag, filterGroup in pairs(DB.filterGroups) do
        if not filterGroup["disabled"] then
            added, removeShiftLinks = nil, nil
            if filterGroup["wordGroupsString"] then
                wordGroups = WordGroupsParser:Parse(filterGroup["wordGroupsString"])
                if wordGroups and Table:NotEmpty(wordGroups) then
                    removeShiftLinks = filterGroup["removeShiftLinks"] == true
                    for _, wordGroup in pairs(wordGroups) do
                        if wordGroup["&"] and not self.wordGroups[wordGroup["string"]] then
                            self.wordGroups[wordGroup["string"]] = wordGroup
                        end
                        table.insert(self.matchVariants, {
                            key = tag,
                            classes = filterGroup["classes"],
                            wordGroup = wordGroup,
                            global = (not wordGroup["&"] and wordGroup["-"]) and true or nil
                        })
                        haveClassMatch = filterGroup["classes"] ~= nil
                        added = true
                    end
                end
            end
            if not added and filterGroup["classes"] then
                table.insert(self.matchVariants, {
                    key = tag,
                    classes = filterGroup["classes"],
                    global = true,
                })
                haveClassMatch = true
                added = true
            end

            if added then
                if not self.haveMatchVariants then
                    self.haveMatchVariants = true
                end

                if haveClassMatch and not self.haveClassMatch then
                    self.haveClassMatch = true
                end
                if removeShiftLinks == true then
                    if not self.haveRemoveShiftLinks then
                        self.haveRemoveShiftLinks = true
                    end
                elseif removeShiftLinks == false then
                    if not self.haveWithShiftLinks then
                        self.haveWithShiftLinks = true
                    end
                end
            end
        end
    end

    if self.haveMatchVariants then
        self:Sort()
    end
end

function FilterGroup:Sort()
    table.sort(self.matchVariants, self.SortFunction)
end

function FilterGroup.SortFunction(a, b)
    local aHaveClasses = a["classes"] ~= nil
    local aHaveWordGroup = a["wordGroup"] ~= nil
    local bHaveClasses = b["classes"] ~= nil
    local bHaveWordGroup = b["wordGroup"] ~= nil
    local aOnlyWordGroup = not aHaveClasses and aHaveWordGroup
    local aBoth = aHaveClasses and aHaveWordGroup
    local bOnlyWordGroup = not bHaveClasses and bHaveWordGroup
    local bBoth = bHaveClasses and bHaveWordGroup

    if a["global"] and b["global"]then
        local aOnlyClass = aHaveClasses and not aHaveWordGroup
        local bOnlyClass = bHaveClasses and not bHaveWordGroup

        if aOnlyClass and bOnlyClass then
            return a["classes"] < b["classes"]
        elseif aOnlyClass and not bOnlyClass then
            return true
        elseif not aOnlyClass and bOnlyClass then
            return false
        else

            if aOnlyWordGroup and bOnlyWordGroup then
                return a["wordGroup"]["string"] < b["wordGroup"]["string"]
            elseif aOnlyWordGroup and not bOnlyWordGroup then
                return true
            elseif not aOnlyWordGroup and bOnlyWordGroup then
                return false
            else

                if aBoth and bBoth then
                    if a["classes"] == b["classes"] then
                        return a["wordGroup"]["string"] < b["wordGroup"]["string"]
                    end
                    return a["classes"] < b["classes"]
                elseif aBoth and not bBoth then
                    return true
                else
                    return false
                end

            end

        end
    elseif a["global"] and not b["global"] then
        return true
    elseif not a["global"] and b["global"] then
        return false
    else

        if aOnlyWordGroup and bOnlyWordGroup then
            return a["wordGroup"]["string"] < b["wordGroup"]["string"]
        elseif aOnlyWordGroup and not bOnlyWordGroup then
            return true
        elseif not aOnlyWordGroup and bOnlyWordGroup then
            return false
        else

            if aBoth and bBoth then
                if a["classes"] == b["classes"] then
                    return a["wordGroup"]["string"] < b["wordGroup"]["string"]
                end
                return a["classes"] < b["classes"]
            elseif aBoth and not bBoth then
                return true
            else
                return false
            end

        end

    end
end