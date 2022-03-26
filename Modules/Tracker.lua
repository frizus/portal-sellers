local addonName, addon = ...
local Tracker = {}
addon.Tracker = Tracker
local Widget, DB = addon.Widget, addon.param

function Tracker:Toggle()
    if self.widget then
        self:Hide()
    else
        self:Show()
    end
end

function Tracker:Show()
    self.widget = Widget:Create("Tracker")
    self.widget:AddEventHandler("SettingsOnLeftClick", self)
    self.widget:AddEventHandler("PowerOnLeftClick", self)
    self.widget:AddEventHandler("CloseOnLeftClick", self)
    self.widget:Show()
    DB.trackerWindowOpened = true
end

function Tracker:Hide()
    self.widget:Release()
    self.widget = nil
    DB.trackerWindowOpened = false
end

function Tracker:SettingsOnLeftClick()
    --addon.modules.TrackerOptions:ToggleLife()
end

function Tracker:PowerOnLeftClick()
    addon:ToggleTrackEvents("toggle")
    self.widget:TogglePower()
    --addon.modules.TrackerOptions:RefreshPowerState()
end

function Tracker:CloseOnLeftClick()
    self:Hide()
    addon:ToggleTrackEvents("trackerWindow")
end