local addonName, addon = ...
local Widget = addon.Widget

local method = {}
for name, closure in pairs(addon.ScrollFrameBasic) do
    method[name] = closure
end

local i = 1

Widget:RegisterType("TrackerScrollFrame", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    local scrollFrameName = "TritonTrackerScrollFrame" .. i
    i = i + 1
    local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints(frame)
    scrollFrame.ScrollBar:ClearAllPoints()
    scrollFrame.ScrollBar:SetWidth(9)
    scrollFrame.ScrollBar:SetPoint("TOPRIGHT", -1, -2)
    scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", -1, 2)
    scrollFrame.ScrollBar.ScrollUpButton:ClearAllPoints()
    scrollFrame.ScrollBar.ScrollDownButton:ClearAllPoints()
    scrollFrame.ScrollBar.ScrollUpButton:Hide()
    scrollFrame.ScrollBar.ScrollDownButton:Hide()
    scrollFrame.ScrollBar.ThumbTexture = scrollFrame.ScrollBar:CreateTexture(scrollFrameName .. "ScrollBarThumbTexture")
    scrollFrame.ScrollBar.ThumbTexture:SetSize(6, 14)
    scrollFrame.ScrollBar.ThumbTexture:SetColorTexture(0, 0.8, 0.8, 0.7)
    scrollFrame.ScrollBar:SetThumbTexture(scrollFrame.ScrollBar.ThumbTexture)

    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)

    local widget = {
        frame = frame,
        content = content,
        scrollFrame = scrollFrame,
        scrollWidth = 12,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget, scrollFrame.widget = widget, widget

    return widget
end)