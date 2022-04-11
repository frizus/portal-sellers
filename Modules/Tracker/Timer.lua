local addonName, addon = ...
local Tracker = addon.Tracker
local DB = addon.param

Tracker.cleanWhenClosedDuration = 10

function Tracker:ToggleTimer()
    if not addon.IsNotBusy() then
        addon:Locked(addon.IsNotBusy, self.ToggleTimer, {self})
        return
    end
    addon.busy = true
    if addon.Message.trackedMessagesLen ~= 0 and addon.trackEvents == true then
        if DB.trackerWindowOpened then
            if self.timerType ~= "opened" then
                if self.timer then addon:CancelTimer(self.timer) end
                self.timerType = "opened"
                self.timer = addon:NewTimer(DB.trackerRefreshRate, self.Tick, true, GetTime() % DB.trackerRefreshRate)
            end
        else
            if DB.doTrackWhenClosed and self.timerType ~= "closed" then
                if self.timer then addon:CancelTimer(self.timer) end
                self.timerType = "closed"
                self.timer = addon:NewTimer(self.cleanWhenClosedDuration, self.TickClosed, true)
            end
        end
    elseif addon.Message.trackedMessagesLen == 0 or addon.trackEvents == false then
        if self.timer then
            addon:CancelTimer(self.timer)
            self.timer = false
            self.timerType = false
        end
    end
    addon.busy = false
end

function Tracker.Tick()
    if not addon.IsNotBusy() then return false end
    addon.busy = true
    addon.Message:Outdated()
    if addon.Message.changed then
        Tracker.widget:Tick(addon.Message.changed, addon.Message.trackedMessages)
        addon.Message.changed = false
    else
        Tracker.widget:Tick()
    end
    addon.busy = false
end