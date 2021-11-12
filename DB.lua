local addonName, addon = ...
local DB = {}
addon.DB = DB

DB.defaults = {
    global = {
        trackingEnabled = true,
        trackedMessageLifetime = 120,
        trackingRefreshInterval = 2,
        interfaceFontSize = 12.8,
        interfaceTrackingPanel = {
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
        ["ui_switch_on"] = "interfaceTrackingPanelVisible",
        ["globalswitch"] = "trackingEnabled",
        ["max_topic_live_secs"] = "trackedMessageLifetime",
        ["refresh_interval"] = "trackingRefreshRate",
        ["fontsize"] = "interfaceFontsize",
        ["ui"] = "interfaceTrackingPanel",
    }

    for oldKey, newKey in pairs(conversion) do
        if addon.param[oldKey] ~= nil then
            addon.param[newKey] = addon.param[oldKey]
            addon.param[oldKey] = nil
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
    addon.param.interfaceTrackingPanelVisible = addon.modules.Monitoring:IsAlive()
end