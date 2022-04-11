local addonName, addon = ...
local Tracker = {}
addon.Tracker = Tracker
local Widget, DB = addon.Widget, addon.param

function Tracker:Toggle()
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.Toggle, {self})
        return
    end
    if self.widget then
        self:Hide()
    else
        self:Show()
    end
end

function Tracker:Show()
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.Show, {self})
        return
    end
    addon.busy = true
    self:CreateWidget()
    DB.trackerWindowOpened = true
    addon:ToggleTrackEvents("trackerWindow")
    addon.busy = false
    Tracker:ToggleTimer()
    Tracker:Fill()
end

function Tracker:CreateWidget()
    self.widget = Widget:Create("Tracker")
    self.widget:AddEventHandler("SettingsOnLeftClick", self)
    self.widget:AddEventHandler("PowerOnLeftClick", self)
    self.widget:AddEventHandler("CloseOnLeftClick", self)
    self.widget:Show()
end

function Tracker:Update(updateOutput, updateFontSize)
    Tracker.widget:Update(addon.Message.trackedMessages, updateOutput, updateFontSize)
end

function Tracker:Hide()
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.Hide, {self})
        return
    end
    addon.busy = true
    if not DB.doTrackWhenClosed or not DB.trackerEnabled then
        addon.Message:CleanMessages()
        self.widget:Release()
        self.widget = false
        DB.trackerWindowOpened = false
        addon:ToggleTrackEvents("trackerWindow")
    else
        self.widget:Release()
        self.widget = false
        DB.trackerWindowOpened = false
        addon:ToggleTrackEvents("trackerWindow")
    end
    addon.busy = false
    self:ToggleTimer()
end

function Tracker:SettingsOnLeftClick()
    --addon.modules.TrackerOptions:ToggleLife()
end

function Tracker:PowerOnLeftClick()
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.PowerOnLeftClick, {self})
        return
    end
    addon.busy = true
    if not DB.trackerEnabled then
        addon.Message:CleanMessages()
        self.widget:CleanLines()
    end
    addon:ToggleTrackEvents("toggle")
    addon.busy = false
    addon.Tracker:ToggleTimer()
    self.widget:TogglePower()
    --addon.modules.TrackerOptions:RefreshPowerState()
end

function Tracker:CloseOnLeftClick()
    self:Hide()
end