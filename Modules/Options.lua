local addonName, addon = ...
local Options = {}
addon.Options = Options
local Widget, L, Minimap = addon.Widget, addon.L, addon.Minimap

function Options:InitBlizPanel()
    local widthMultiplier = 170
    self:Panel({
        leftPanelName = L["bliz_options_panel_name"],
        title = L["bliz_options_title"],
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
                type = "Container",
                layout = "Flow",
                width = widthMultiplier,
                marginTop = 10,
                children = {
                    {
                        type = "Checkbox",
                        param = "doTrackWhenClosed",
                        title = L["bliz_options_do_track_when_closed"],
                        tooltip = string.format(
                                L["bliz_options_do_track_when_closed_tooltip"],
                                addon.DB.default.doTrackWhenClosed and
                                        L["bliz_options_toggle_enabled"] or
                                        L["bliz_options_toggle_disabled"]
                        ),
                        width = "fill",
                        onSet = function(value)
                            addon:ToggleTrackEvents("option")
                        end
                    },
                }
            },
            {
                type = "Container",
                layout = "Flow",
                width = widthMultiplier,
                marginTop = 10,
                children = {
                    {
                        type = "Checkbox",
                        param = {"minimap", "show"},
                        title = L["bliz_options_minimap_show"],
                        tooltip = string.format(
                                L["bliz_options_minimap_show_tooltip"],
                                addon.DB.default.minimap.show and
                                        L["bliz_options_toggle_enabled"] or
                                        L["bliz_options_toggle_disabled"]
                        ),
                        width = "fill",
                        onSet = function(value)
                            Minimap:Toggle(value)
                        end
                    },
                    {
                        type = "Checkbox",
                        param = "showStartMessage",
                        title = L["bliz_options_show_start_message"],
                        tooltip = string.format(
                                L["bliz_options_show_start_message_tooltip"],
                                addon.DB.default.showStartMessage and
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
        if not self.primaryPanelName then
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