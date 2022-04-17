local addonName, addon = ...
local WidgetTooltip = {}
addon.WidgetTooltip = WidgetTooltip

local function trigger_OnEnter(self)
    self.widget:ShowTooltip()
end
local function trigger_OnLeave(self)
    self.widget:HideTooltip()
end
function WidgetTooltip:InitTooltip(trigger, title, tooltip)
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
function WidgetTooltip:RemoveTooltip(trigger)
    self.title = nil
    self.tooltip = nil
    trigger:SetScript("OnEnter", nil)
    trigger:SetScript("OnLeave", nil)
    self:HideTooltip()
end
function WidgetTooltip:ShowTooltip()
    GameTooltip:SetOwner(self.frame, "ANCHOR_TOPRIGHT")
    GameTooltip_AddNormalLine(GameTooltip, self.title, true)
    GameTooltip_AddColoredLine(GameTooltip, self.tooltip, TOOLTIP_DEFAULT_COLOR, true)
    GameTooltip:Show()
end
function WidgetTooltip:HideTooltip()
    if GameTooltip:GetOwner() == self.frame and GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end