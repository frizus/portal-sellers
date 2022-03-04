local addonName, addon = ...
local Widget = addon.Widget

local method = {}
method.OnAcquire = function(self, options)
    self:SetParent(options.parent)
    self.scrollFrame.ScrollBar:Hide()
end
method.OnRelease = function(self)
    self.scrollShown = nil
    self.contentWidth = nil
end
method.GetContentFrame = function(self)
    return self.content
end
method.SetWidth = function(self, value, fill)
    if fill then
        self.frame:SetWidth(value)
        self.width = "fill"
    else
        if self.width ~= value then
            self.width = value
            if value and value ~= "fill" then
                self.frame:SetWidth(value)
                self:CalculateContentWidth()
            end
        end
    end
end
method.SetHeight = function(self, value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
end
method.CalculateContentWidth = function(self)
    local frameWidth = self.frame:GetWidth()
    local lastWidth = self.contentWidth

    if frameWidth then
        self.contentWidth = self.scrollShown and (frameWidth - 20) or frameWidth
        if lastWidth ~= self.contentWidth then
            self.content:SetWidth(self.contentWidth)
        end
    end
end
method.GetContentWidth = function(self)
    if not self.contentWidth then
        self:CalculateContentWidth()
    end
    return self.contentWidth
end
method.GetContentHeight = function(self)
    return self:GetHeight()
end
method.ScrollToggled = function(self, contentHeight)
    self.content:SetHeight(contentHeight)
    local viewHeight = self:GetHeight()

    if contentHeight > (viewHeight + 1) then
        if not self.scrollShown then
            self.scrollShown = true
            self.scrollFrame.ScrollBar:Show()
            self:CalculateContentWidth()
            return true
        end
    else
        if self.scrollShown then
            self.scrollShown = false
            self.scrollFrame.ScrollBar:Hide()
            self:CalculateContentWidth()
            return true
        elseif self.scrollShown == nil then
            self.scrollShown = false
            self:CalculateContentWidth()
        end
    end

    return false
end

Widget:RegisterType("ScrollFrame", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    --AceGUIContainer-ScrollFrame
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
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget, scrollFrame.widget = widget, widget

    return widget
end)