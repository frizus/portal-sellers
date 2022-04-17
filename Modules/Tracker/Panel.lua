local addonName, addon = ...
local Tracker = {}
addon.Tracker = Tracker
local Widget, DB, TrackerMenu = addon.Widget, addon.param, addon.TrackerMenu

function Tracker:Toggle()
    if addon.isBusy then
        addon:LockBusy(self.Toggle, {self})
        return
    end
    if self.widget then
        self:Hide()
    else
        self:Show()
    end
end

function Tracker:Show()
    if addon.isBusy then
        addon:LockBusy(self.Show, {self})
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
    self.widget:AddEventHandler("LineOnClick", TrackerMenu)
    self.widget:Show()
end

function Tracker:Hide()
    if addon.isBusy then
        addon:LockBusy(self.Hide, {self})
        return
    end
    addon.busy = true
    if not DB.doTrackWhenClosed or not DB.trackerEnabled then
        addon.Message:CleanMessages()
    end
    self.widget:Release()
    self.widget = false
    DB.trackerWindowOpened = false
    TrackerMenu:ReleaseMenu()
    addon:ToggleTrackEvents("trackerWindow")
    addon.busy = false
    self:ToggleTimer()
end

function Tracker:UpdateFromOptions(updateOutput, updateFontSize)
    Tracker.widget:Update(addon.Message.trackedMessages, updateOutput, updateFontSize)
    TrackerMenu:MenuUpdate()
end

function Tracker:Update()
    addon.Message:Outdated()
    TrackerMenu:MenuUpdate()
    if addon.Message.changed then
        self.widget:Tick(addon.Message.changed, addon.Message.trackedMessages)
        addon.Message.changed = false
    else
        self.widget:Tick()
    end
end

function Tracker:SettingsOnLeftClick()
    --addon.modules.TrackerOptions:ToggleLife()
end

function Tracker:PowerOnLeftClick()
    if addon.isBusy then
        addon:LockBusy(self.PowerOnLeftClick, {self})
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