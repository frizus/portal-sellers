local addonName, addon = ...
local Widget = {}
addon.Widget = Widget
local AceGUI = LibStub("AceGUI-3.0")

function Widget:Create(type, ...)
    local widget = AceGUI:Create(type)
    if widget then
        if select("#", ...) > 0 and widget.OnAcquireExtra then
            widget:OnAcquireExtra(...)
        end
    end
    return widget
end