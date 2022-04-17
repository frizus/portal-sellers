local addonName, addon = ...
local Widget = addon.Widget

local method = {}
function method:OnAcquire(options)
    self.frame:SetParent(options.parent)
    self:SetWidth(options.width or "fill")
    self:SetHeight(18)
end

Widget:RegisterType("Separator", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    local line = frame:CreateTexture(nil, "BACKGROUND")
    line:SetHeight(8)
    line:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    line:SetTexCoord(0.81, 0.94, 0.5, 1) -- AceGUIWidget-Heading
    line:SetPoint("LEFT", 3, 0)
    line:SetPoint("RIGHT", -3, 0)

    local widget = {
        frame = frame,
        line = line,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end

    return widget
end)