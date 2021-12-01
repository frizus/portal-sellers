local addonName, addon = ...
local BlizOptions = {}
addon.BlizOptions = BlizOptions
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function BlizOptions.GetOptions(uiType, uiName, appName)
    if appName == addonName then
        return {
            type = "group",
            name = string.format(L["bliz_options_title"], GetAddOnMetadata(addonName, "Title"), GetAddOnMetadata(addonName, "Version")),
            get = function(info)
                return addon.param[info[#info]] or ""
            end,
            set = function(info, value)
                addon.param[info[#info]] = value
            end,
            args = {
                top = {
                    type = "description",
                    name = L["bliz_options_addon_info"],
                    order = 0.1,
                },

                header = {
                    type = "header",
                    name = "",
                    order = 1.01,
                },

                trackedMessageLifetime = {
                    type = "range",
                    min = 10,
                    max = 600,
                    step = 1,
                    softMin = 10,
                    softMax = 600,
                    name = L["bliz_options_tracked_message_lifetime"],
                    desc = string.format(L["bliz_options_tracked_message_lifetime_tooltip"], addon.DB.defaults.global.trackedMessageLifetime),
                    width = "normal",
                    order = 1.1,
                },

                trackerRefreshRate = {
                    type = "range",
                    min = 1,
                    max = 60,
                    step = 1,
                    softMin = 1,
                    softMax = 60,
                    name = L["bliz_options_tracking_refresh_rate"],
                    desc = string.format(L["bliz_options_tracking_refresh_rate_tooltip"], addon.DB.defaults.global.trackerRefreshRate),
                    width = "normal",
                    order = 1.2,
                },

                trackerFontSize = {
                    type = "range",
                    width = "double",
                    min = 3,
                    max = 60,
                    step = 0.1,
                    softMin = 3,
                    softMax = 60,
                    name = L["bliz_options_tracker_messages_font_size"],
                    desc = string.format(L["bliz_options_tracker_messages_font_size_tooltip"], addon.DB.defaults.global.trackerFontSize),
                    width = "normal",
                    order = 1.3,
                },

                trackerHideChannel = {
                    type = "toggle",
                    name = L["bliz_options_tracker_hide_channel"],
                    desc = string.format(L["bliz_options_tracker_hide_channel_tooltip"], addon.DB.defaults.global.trackerHideChannel and L["bliz_options_toggle_enabled"] or L["bliz_options_toggle_disabled"]),
                    width = "normal",
                    order = 1.4,
                },

                trackerHideSimilarMessages = {
                    type = "toggle",
                    name = L["bliz_options_tracker_hide_similar_messages"],
                    desc = string.format(L["bliz_options_tracker_hide_similar_messages_tooltip"], addon.DB.defaults.global.trackerHideSimilarMessages and L["bliz_options_toggle_enabled"] or L["bliz_options_toggle_disabled"]),
                    width = "normal",
                    order = 1.5,
                },

                header2 = {
                    type = "header",
                    name = "",
                    order = 2.01,
                },

                bottom = {
                    type = "description",
                    name = L["bliz_options_bottom"],
                    order = 2.1,
                },
            },
        }
    end
end