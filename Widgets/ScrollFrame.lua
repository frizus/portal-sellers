local addonName, addon = ...
local Widget = addon.Widget

local method = {}
for name, closure in pairs(addon.ScrollFrameBasic) do
    method[name] = closure
end

Widget:RegisterType("ScrollFrame", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints(frame)
    scrollFrame.ScrollBar:ClearAllPoints()
    scrollFrame.ScrollBar:SetPoint("TOPRIGHT", 0, -13)
    scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", 0, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)

    local scrollBackground = scrollFrame.ScrollBar:CreateTexture(nil, "BACKGROUND")
    scrollBackground:SetAllPoints(scrollFrame.ScrollBar)
    scrollBackground:SetColorTexture(0, 0, 0, 0.4)

    local widget = {
        frame = frame,
        content = content,
        scrollFrame = scrollFrame,
        scrollBackground = scrollBackground,
        scrollWidth = 20,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget, scrollFrame.widget = widget, widget

    return widget
end)