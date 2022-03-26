local addonName, addon = ...
local WidgetTooltip = {}
addon.WidgetTooltip = WidgetTooltip

local function trigger_OnEnter(self)
    self.widget:ShowTooltip()
end
local function trigger_OnLeave(self)
    self.widget:HideTooltip()
end
WidgetTooltip.InitTooltip = function(self, trigger, title, tooltip)
    if type(title) == "function" then
        trigger:SetScript("OnEnter", title)
        trigger:SetScript("OnLeave", trigger_OnLeave)
    else
        if tooltip and tooltip ~= "" then
            self.title = title
            self.tooltip = tooltip
            trigger:SetScript("OnEnter", trigger_OnEnter)
            trigger:SetScript("OnLeave", trigger_OnLeave)
        end
    end

end
WidgetTooltip.RemoveTooltip = function(self, trigger)
    self.title = nil
    self.tooltip = nil
    trigger:SetScript("OnEnter", nil)
    trigger:SetScript("OnLeave", nil)
    self:HideTooltip()
end
WidgetTooltip.ShowTooltip = function(self)
    GameTooltip:SetOwner(self.frame, "ANCHOR_TOPRIGHT")
    GameTooltip_AddNormalLine(GameTooltip, self.title, true)
    GameTooltip_AddColoredLine(GameTooltip, self.tooltip, TOOLTIP_DEFAULT_COLOR, true)
    GameTooltip:Show()
end
WidgetTooltip.HideTooltip = function(self)
    if GameTooltip:GetOwner() == self.frame and GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end