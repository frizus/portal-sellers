local addonName, addon = ...
local DB = {}
addon.DB = DB
local DBparam, Table = addon.param, addon.Table
local savedVariableName = addonName .. "DB"

DB.default = {
    trackerEnabled = true,
    trackedMessageLifetime = 120,
    trackerRefreshRate = 2,
    trackerHideSimilarMessages = false,
    trackerFontSize = 12.8,
    trackerWindowRect = {
        height = 160,
        top = 260,
        left = 950,
        width = 320,
    },
    trackerWindowOpened = false,
    showStartMessage = true,
    doTrackWhenClosed = false,
    minimap = {
        show = true,
        minimapPos = 225,
    },
    highlightKeywords = false,
}

function DB:PLAYER_LOGOUT()
    self:SaveVariables()
end

function DB:Init()
    if type(_G[savedVariableName]) ~= "table" then
        _G[savedVariableName] = {}
    else
        self:CopyParams(_G[savedVariableName], DBparam)
    end
end

function DB:CopyParams(from, to)
    for key, value in pairs(from) do
        if type(value) == "table" then
            to[key] = {}
            self:CopyParams(value, to[key])
            if Table:Empty(value) then
                from[key] = nil
            end
        else
            to[key] = value
            from[key] = nil
        end
    end
end

-- conversion from version 1.57 to 1.58
function DB:ConvertOldParameters()
    if DBparam.profileKeys then
        DBparam.profileKeys = nil
    end
    if DBparam.global then
        local conversion = {
            ["globalswitch"] = "trackerEnabled",
            ["max_topic_live_secs"] = "trackedMessageLifetime",
            ["refresh_interval"] = "trackerRefreshRate",
            ["fontsize"] = "trackerFontSize",
            ["ui"] = "trackerWindowRect",
            ["ui_switch_on"] = "trackerWindowOpened",
        }
        local remove = {
            ["cleaner_run_interval"] = true,
            ["safe_cleaner_run_interval"] = true
        }

        for oldName, value in pairs(DBparam.global) do
            if conversion[oldName] then
                DBparam[conversion[oldName]] = value
            elseif not remove[oldName] then
                DBparam[oldName] = value
            end
            DBparam.global[oldName] = nil
        end
        DBparam.global = nil
    end
end

function DB:MergeWithDefault()
    self:CopyDefault(self.default, DBparam)
end

function DB:CopyDefault(default, params)
    for key, value in pairs(default) do
        if params[key] == nil then
            if type(value) == "table" then
                params[key] = {}
                self:CopyDefault(value, params[key])
            else
                params[key] = value
            end
        elseif type(value) == "table" and type(params[key]) == "table" then
            self:CopyDefault(value, params[key])
        end
    end
end

function DB:ConvertFilterGroups()
    if DBparam.keywords then
        DBparam.filterGroups = {}
        local filterGroup
        local aliasSeparatorPos
        local alias, wordGroupsString
        for tag, keyword in pairs(DBparam.keywords) do
            aliasSeparatorPos = string.find(tag, ":", 1, true)
            if aliasSeparatorPos and keyword["alias"] ~= nil then
                alias = string.sub(tag, 1, aliasSeparatorPos - 1)
                wordGroupsString = string.sub(tag, aliasSeparatorPos + 1)
            else
                alias = nil
                wordGroupsString = tostring(tag)
            end
            if alias ~= "" and wordGroupsString ~= "" then
                filterGroup = {
                    alias = alias,
                    disabled = keyword["active"] ~= true and true or nil,
                    wordGroupsString = wordGroupsString,
                    wordSearch = nil,
                    removeShiftLinks = nil,
                    classes = nil,
                    blinkInTaskbarWhenFound = nil,
                }
                DBparam.filterGroups[addon.FilterGroupForm:CreateTag(filterGroup)] = filterGroup
            end
            DBparam.keywords[tag] = nil
        end
        DBparam.keywords = nil
    end
end

function DB:SaveVariables()
    self:RemoveDefault(DBparam, self.default)
    _G[savedVariableName] = DBparam
    DBparam = nil
end

function DB:RemoveDefault(params, default)
    for key, value in pairs(default) do
        if params[key] ~= nil and type(value) == type(params[key]) then
            if type(value) == "table" then
                self:RemoveDefault(params[key], value)
                if Table:Empty(value) then
                    params[key] = nil
                end
            elseif params[key] == value then
                params[key] = nil
            end
        end
    end
end