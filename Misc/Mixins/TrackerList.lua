local addonName, addon = ...
local TrackerList = {}
addon.TrackerList = TrackerList
local Widget = addon.Widget

TrackerList.ConstructTracker = function(self)
    self.itemsWidget = Widget:Create("Container", {
        parent = self.frame,
        type = "Container",
        layout = "Flow",
        scroll = true,
    })
    self.itemsWidget:SetPoint("TOPLEFT", 5, -17)
    self.itemsWidget:SetPoint("BOTTOMRIGHT", -5, 11)
end
TrackerList.AddMessage = function(self)

end
TrackerList.RemoveMessage = function(self, key)

end
TrackerList.ReleaseTracker = function(self)
    self.itemsWidget:ReleaseChildren()
end