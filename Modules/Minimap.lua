local addonName, addon = ...
local Minimap = {}
addon.Minimap = Minimap
local Widget, DB, Tracker = addon.Widget, addon.param, addon.Tracker

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
    Tracker:Toggle()
end

function Minimap:OnTooltip()
    return DB.trackerWindowOpened
end