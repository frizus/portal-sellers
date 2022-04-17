local addonName, addon = ...
local Tracker = addon.Tracker
local DB = addon.param

function Tracker:Fill()
    if DB.trackerWindowOpened then
        if addon.isBusy then
            addon:LockBusy(self.Fill, {self})
            return
        end
        addon.busy = true
        self.widget:Fill(addon.Message.changed, addon.Message.trackedMessages)
        addon.Message.changed = false
        addon.busy = false
    end
end