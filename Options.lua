local addonName, addon = ...
local Options = {}
addon.Options = Options
local Widget, L = addon.Widget, addon.L

function Options:InitBlizPanel()
    local widthMultiplier = 170
    self:Panel({
        leftPanelName = string.format(
            L["bliz_options_panel_name"],
            GetAddOnMetadata(addonName, "Title")
        ),
        title = string.format(
            L["bliz_options_title"],
            GetAddOnMetadata(addonName, "Title"),
            GetAddOnMetadata(addonName, "Version")
        ),
        children = {
            {
                type = "Text",
                text = L["bliz_options_addon_info"],
            },
            {
                type = "Separator",
            },
            {
                type = "Slider",
                param = "trackedMessageLifetime",
                title = L["bliz_options_tracked_message_lifetime"],
                tooltip = string.format(
                    L["bliz_options_tracked_message_lifetime_tooltip"],
                    addon.DB.default.trackedMessageLifetime
                ),
                min = 10,
                max = 600,
                step = 1,
                width = widthMultiplier,
            },
            {
                type = "Slider",
                param = "trackerRefreshRate",
                title = L["bliz_options_tracking_refresh_rate"],
                tooltip = string.format(
                    L["bliz_options_tracking_refresh_rate_tooltip"],
                    addon.DB.default.trackerRefreshRate
                ),
                min = 1,
                max = 60,
                step = 1,
                width = widthMultiplier,
            },
            {
                type = "Slider",
                param = "trackerFontSize",
                title = L["bliz_options_tracker_messages_font_size"],
                tooltip = string.format(
                    L["bliz_options_tracker_messages_font_size_tooltip"],
                    addon.DB.default.trackerFontSize
                ),
                min = 3,
                max = 60,
                step = 0.1,
                width = widthMultiplier,
            },
            {
                type = "Container",
                layout = "Flow",
                width = widthMultiplier,
                marginTop = 10,
                children = {
                    {
                        type = "Checkbox",
                        param = "trackerHideChannel",
                        title = L["bliz_options_tracker_hide_channel"],
                        tooltip = string.format(
                            L["bliz_options_tracker_hide_channel_tooltip"],
                            addon.DB.default.trackerHideChannel and
                                L["bliz_options_toggle_enabled"] or
                                L["bliz_options_toggle_disabled"]
                        ),
                        width = "fill",
                    },
                    {
                        type = "Checkbox",
                        param = "trackerHideSimilarMessages",
                        title = L["bliz_options_tracker_hide_similar_messages"],
                        tooltip = string.format(
                            L["bliz_options_tracker_hide_similar_messages_tooltip"],
                            addon.DB.default.trackerHideSimilarMessages and
                                L["bliz_options_toggle_enabled"] or
                                L["bliz_options_toggle_disabled"]
                        ),
                        width = "fill",
                    }
                }
            },
            {
                type = "Separator",
            },
            {
                type = "Text",
                text = L["bliz_options_bottom"],
            },
        },
    })
end

function Options:Panel(arg)
    local options = {
        leftPanelName = arg.leftPanelName,
        title = arg.title,
        children = arg.children,
    }
    local panelWidget
    if not arg.parent then
        if self.primaryPanelName == nil then
            panelWidget = Widget:Create("BlizOptionsPanel", options)
            self.primaryPanelName = panelWidget:GetName()
        else
            options.parent = self.primaryPanelName
            panelWidget = Widget:Create("BlizOptionsPanel", options)
        end
    else
        options.parent = arg.parent
        panelWidget = Widget:Create("BlizOptionsPanel", options)
    end

    InterfaceOptions_AddCategory(panelWidget:GetFrame())

    return panelWidget
end