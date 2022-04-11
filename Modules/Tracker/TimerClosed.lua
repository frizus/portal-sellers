local addonName, addon = ...
local Tracker = addon.Tracker

function Tracker.TickClosed()
    if not addon.IsNotBusy() then return false end
    addon.busy = true
    addon.Message:Outdated()
    addon.busy = false
end