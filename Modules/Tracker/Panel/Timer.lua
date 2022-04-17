local addonName, addon = ...
local Tracker = addon.Tracker
local DB = addon.param

Tracker.cleanWhenClosedDuration = 10

function Tracker:ToggleTimer(skipBusy)
    if not skipBusy then
        if addon.isBusy then
            addon:LockBusy(self.ToggleTimer, {self})
            return
        end
        addon.busy = true
    end
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
    if not skipBusy then
        addon.busy = false
    end
end

function Tracker.Tick()
    if addon.isBusy then return false end
    addon.busy = true
    Tracker:Update()
    addon.busy = false
end

function Tracker.TickClosed()
    if addon.isBusy then return false end
    addon.busy = true
    addon.Message:Outdated()
    addon.busy = false
end