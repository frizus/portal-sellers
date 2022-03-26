local addonName, addon = ...
local Minimap = {}
addon.Minimap = Minimap
local Widget, DB = addon.Widget, addon.param

function Minimap:Toggle(show)
    if show then
        self:Show()
    else
        self:Hide()
    end
end

function Minimap:Show()
    self.widget = Widget:Create("MinimapPin")
    self.widget:AddEventHandler("OnLeftClick", self)
    self.widget:AddEventHandler("OnTooltip", self)
    self.widget:Show()
end

function Minimap:Hide()
    self.widget:Release()
    self.widget = nil
end

function Minimap:OnLeftClick()
    addon.Tracker:Toggle()
    addon:ToggleTrackEvents("trackerWindow")
end

function Minimap:OnTooltip()
    return DB.trackerWindowOpened
end