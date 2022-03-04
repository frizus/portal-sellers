local addonName, addon = ...
local DB = {}
addon.DB = DB
local DBparam = addon.param
local savedVariableName = addonName .. "DB"

DB.default = {
    trackerEnabled = true,
    trackedMessageLifetime = 120,
    trackerRefreshRate = 2,
    trackerHideChannel = false,
    trackerHideSimilarMessages = false,
    trackerFontSize = 12.8,
    trackerWindowRect = {
        height = 160,
        top = 260,
        left = 950,
        width = 320,
    },
    minimap = {},
}

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
            if self:ParamsLength(value) == 0 then
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
    if DBparam.global == nil then
        return
    end
    DBparam.profileKeys = nil
    local conversion = {
        ["globalswitch"] = "trackerEnabled",
        ["max_topic_live_secs"] = "trackedMessageLifetime",
        ["refresh_interval"] = "trackerRefreshRate",
        ["fontsize"] = "trackerFontSize",
        ["ui"] = "trackerWindowRect",
        ["ui_switch_on"] = "trackerWindowVisible",
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

end

function DB:SaveVariables()
    self:RemoveDefault(DBparam, self.default)
    _G[savedVariableName] = DBparam
end

function DB:RemoveDefault(params, default)
    for key, value in pairs(default) do
        if params[key] ~= nil and type(value) == type(params[key]) then
            if type(value) == "table" then
                self:RemoveDefault(params[key], value)
                if self:ParamsLength(params[key]) == 0 then
                    params[key] = nil
                end
            elseif params[key] == value then
                params[key] = nil
            end
        end
    end
end

function DB:ParamsLength(table)
    local length = 0
    for _ in pairs(table) do
        length = length + 1
    end
    return length
end