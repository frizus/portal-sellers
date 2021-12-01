local addonName, addon = ...
local DB = {}
addon.DB = DB

DB.defaults = {
    global = {
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
    },
}

function DB:ConvertOldParameters()
    -- conversion from version 1.57 to 1.58
    local conversion = {
        ["ui_switch_on"] = "trackerWindowVisible",
        ["globalswitch"] = "trackerEnabled",
        ["max_topic_live_secs"] = "trackedMessageLifetime",
        ["refresh_interval"] = "trackerRefreshRate",
        ["fontsize"] = "trackerFontSize",
        ["ui"] = "trackerWindowRect",
    }
    local remove = { "cleaner_run_interval", "safe_cleaner_run_interval" }

    for oldKey, newKey in pairs(conversion) do
        if addon.param[oldKey] ~= nil then
            addon.param[newKey] = addon.param[oldKey]
            addon.param[oldKey] = nil
        end
    end
    for _, key in pairs(remove) do
        if addon.param[key] ~= nil then
            addon.param[key] = nil
        end
    end

    if addon.param.keywords ~= nil then
        addon.param.conditions = {active = {}, inactive = {}}
        for key, search in pairs(addon.param.keywords) do
            local condition = {
                original = key,
                keywords = search["words"],
                alias = search["alias"],
            }
            local id = addon.Tool.GenerateConditionId(condition)
            if search["active"] then
                addon.param.conditions.active[id] = condition
            else
                addon.param.conditions.inactive[id] = condition
            end
            addon.param.keywords[key] = nil
        end
        addon.param.keywords = nil
    end
end

function DB:BeforeLogout()
    addon.param.trackerWindowVisible = addon.modules.Monitoring:IsAlive()
end