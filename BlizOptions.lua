local addonName, addon = ...
local BlizOptions = {}
addon.BlizOptions = BlizOptions
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function BlizOptions.GetOptions(uiType, uiName, appName)
    if appName == addonName then
        local options = {
            type = "group",
            name = GetAddOnMetadata(addonName, "Title") .. " (" .. GetAddOnMetadata(addonName, "Version") .. ")",
            get = function(info)
                return addon.db.global[info[#info]] or ""
            end,
            set = function(info, value)
                addon.db.global[info[#info]] = value
            end,
            args = {
                addoninfo = {
                    type = "description",
                    name = L["ADDON_INFO"],
                    descStyle = L["ADDON_INFO"],
                    order = 0.1,
                },

                header01 = {
                    type = "header",
                    name = "",
                    order = 1.01,
                },

                trackedMessageLifetime = {
                    type = "range",
                    width = "double",
                    min = 10,
                    max = 600,
                    step = 1,
                    softMin = 10,
                    softMax = 600,
                    name = L["Message alive time"],
                    desc = L["How long will message be removed from event (default to 120 seconds)?"],
                    width = "normal",
                    order = 1.1,
                },

                header02 = {
                    type = "header",
                    name = "",
                    order = 2.01,
                },

                interfaceFontSize = {
                    type = "range",
                    width = "double",
                    min = 3,
                    max = 60,
                    step = 0.1,
                    softMin = 3,
                    softMax = 60,
                    name = L["Font size"],
                    desc = L["Font size of event window (default to 12.8)."],
                    width = "normal",
                    order = 2.1,
                },

                header03 = {
                    type = "header",
                    name = "",
                    order = 3.01,
                },

                trackingRefreshInterval = {
                    type = "range",
                    width = "double",
                    min = 1,
                    max = 60,
                    step = 1,
                    softMin = 1,
                    softMax = 60,
                    name = L["Refresh interval"],
                    desc = L["How frequent to refresh event window (default to 2 seconds)?"],
                    width = "normal",
                    order = 3.1,
                },

                header06 = {
                    type = "header",
                    name = "",
                    order = 6.01,
                },

                authorinfo = {
                    type = "description",
                    name = L["AUTHOR_INFO"],
                    descStyle = L["AUTHOR_INFO"],
                    order = 6.1,
                },
            },
        }
        return options
    end
end