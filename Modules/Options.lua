local addonName, addon = ...
local Options = {}
addon.Options = Options
local Widget, L, Minimap = addon.Widget, addon.L, addon.Minimap
local Message, FilterGroup, DB = addon.Message, addon.FilterGroup, addon.param
local MessageParser, Tracker = addon.MessageParser, addon.Tracker

function Options:InitBlizPanel()
    local widthMultiplier = 170
    self:Panel({
        leftPanelName = L["bliz_options_panel_name"],
        title = L["bliz_options_title"],
        setHandler = self.OnSetOptions,
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
                        param = "trackerHideSimilarMessages",
                        title = L["bliz_options_tracker_hide_similar_messages"],
                        tooltip = string.format(
                            L["bliz_options_tracker_hide_similar_messages_tooltip"],
                            addon.DB.default.trackerHideSimilarMessages and
                                L["bliz_options_toggle_enabled"] or
                                L["bliz_options_toggle_disabled"]
                        ),
                        width = "fill",
                    },
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
                            addon.Tracker:ToggleTimer()
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
                type = "Container",
                layout = "Flow",
                width = widthMultiplier,
                marginTop = 10,
                children = {
                    {
                        type = "Checkbox",
                        param = "highlightKeywords",
                        title = L["bliz_options_highlight_keywords"],
                        tooltip = string.format(
                                L["bliz_options_highlight_keywords_tooltip"],
                                addon.DB.default.highlightKeywords and
                                        L["bliz_options_toggle_enabled"] or
                                        L["bliz_options_toggle_disabled"]
                        ),
                        width = "fill",
                    },
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
        setHandler = arg.setHandler,
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

function Options.OnSetOptions(panel)
    if addon.isBusy then
        addon:LockBusy(Options.OnSetOptions, {panel})
        return
    end
    addon.busy = true
    local changedValues = {}
    for param in pairs(panel.panelChangedInputs) do
        local newValue, oldValue = panel.panelChangedInputs[param], nil
        oldValue = addon.Table:Get(DB, param)
        addon.Table:Set(DB, param, newValue)
        if oldValue ~= newValue and not (oldValue == nil and newValue == false) then
            addon.Table:Set(changedValues, param, true)
            if panel.panelInputOnSetHandlers[param] then
                panel.panelInputOnSetHandlers[param](newValue)
            end
        end
        panel.panelChangedInputs[param] = nil
    end

    if Message.trackedMessagesLen ~= 0 then
        local updateLayout, updateOutput, updateFontSize
        if changedValues.trackerHideSimilarMessages then
            updateLayout = true
            updateOutput = true
            for _, message in pairs(Message.trackedMessages) do
                if DB.trackerHideSimilarMessages then
                    message["variants"] = nil
                    message["variantsLen"] = nil
                    message["variantKey"] = nil
                    message["variantsOrder"] = nil
                    message["variantsSorted"] = nil
                else
                    message["variantKey"] = message["original"]
                    message["variants"] = {
                        [message["variantKey"]] = {
                            message = message["message"],
                            original = message["original"],
                            updated = message["updated"],
                            channel = message["channel"],
                            channelsSorted = false,
                            channelsLen = 1,
                            channels = {
                                [message["channel"]] = {
                                    channel = message["channel"],
                                    sort = type(message["channel"]) == "number" and string.format("Z%02d", message["channel"]) or message["channel"],
                                    updated = message["updated"],
                                }
                            }
                        }
                    }
                    message["variantsLen"] = 1
                    message["variantsSorted"] = false
                end
            end
        end

        if changedValues.highlightKeywords then
            if not updateLayout then updateLayout = true end
            if not updateOutput then updateOutput = true end
            local wordGroupString, wordGroup, filterGroup
            for _, message in pairs(Message.trackedMessages) do
                if not DB.trackerHideSimilarMessages then
                    local messageParser
                    for variantId, variant in pairs(message["variants"]) do
                        messageParser = MessageParser:Create(variant["original"], FilterGroup.haveWithShiftLinks, FilterGroup.haveRemoveShiftLinks, true)
                        messageParser:Parse()
                        if DB.highlightKeywords then
                            filterGroup = DB.filterGroups[message["matchInfo"]["filterGroupKey"]]
                            wordGroupString = message["matchInfo"]["wordGroup"]
                            if wordGroupString then
                                wordGroup = FilterGroup.wordGroups[wordGroupString]
                                if wordGroup["&"] then
                                    messageParser:Highlight(filterGroup["removeShiftLinks"], wordGroup["&"], nil, filterGroup["wordSearch"])
                                    variant["message"] = messageParser:GetFormattedMessage(true)
                                    variant["unescaped"] = messageParser:GetUnescapedMessage(true)
                                    if variantId == message["variantKey"] then
                                        message["message"] = variant["message"]
                                    end
                                end
                            end
                        else
                            variant["message"] = messageParser:GetFormattedMessage(false)
                            variant["unescaped"] = messageParser:GetUnescapedMessage(false)
                            if variantId == message["variantKey"] then
                                message["message"] = variant["message"]
                            end
                        end
                        messageParser:Destroy()
                        messageParser = nil
                    end
                else
                    if DB.highlightKeywords then
                        local messageParser = MessageParser:Create(message["original"], FilterGroup.haveWithShiftLinks, FilterGroup.haveRemoveShiftLinks, true)
                        messageParser:Parse()
                        filterGroup = DB.filterGroups[message["matchInfo"]["filterGroupKey"]]
                        wordGroupString = message["matchInfo"]["wordGroup"]
                        if wordGroupString then
                            wordGroup = FilterGroup.wordGroups[wordGroupString]
                            if wordGroup["&"] then
                                message["message"] = messageParser:GetFormattedMessage(true)
                            end
                        end
                        messageParser:Destroy()
                        messageParser = nil
                    else
                        message["message"] = message["original"]
                    end
                end
            end
        end

        if changedValues.trackerFontSize then
            if not updateLayout then updateLayout = true end
            updateFontSize = true
        end

        if changedValues.trackerRefreshRate and DB.trackerWindowOpened and Tracker.timer then
            addon:CancelTimer(Tracker.timer)
            if Tracker.timerType ~= "opened" then
                Tracker.timerType = "opened"
            end
            Tracker.timer = addon:NewTimer(DB.trackerRefreshRate, Tracker.Tick, GetTime() % DB.trackerRefreshRate)
        end

        if updateLayout and DB.trackerWindowOpened then
            Tracker:UpdateFromOptions(updateOutput, updateFontSize)
        end
    end
    addon.busy = false
end