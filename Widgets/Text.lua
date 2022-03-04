local addonName, addon = ...
local Widget = addon.Widget

local method = {}
method.OnAcquire = function(self, options)
    self:SetParent(options.parent)
    self:SetWidth(options.width or "fill")
    self:SetFontObject(options.font or GameFontHighlightSmall)
    self.fontString:SetText(options.text)
end
method.OnRelease = function(self)
    if self.fontString:GetText() then
        self.fontString:SetText(nil)
    end
end
method.SetFontObject = function(self, font)
    local lastFont = self.fontString:GetFontObject()
    if lastFont ~= font then
        self.fontString:SetFontObject(font)
    end
    if not self.noCJK or lastFont ~= font then
        self.noCJK = true
        self.fontString:SetFont(font:GetFont())
    end
end
method.SetWidth = function(self, value, fill)
    if fill then
        self.frame:SetWidth(value)
        self.fontString:SetWidth(value)
        self.width = "fill"
    else
        if self.width ~= value then
            self.width = value
            if value and value ~= "fill" then
                self.frame:SetWidth(value)
                self.fontString:SetWidth(value)
            end
        end
    end
end
method.SetHeight = function() end
method.GetHeight = function(self)
    return self.fontString:GetStringHeight()
end

Widget:RegisterType("Text", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()
    frame:SetHeight(1)

    local fontString = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    fontString:SetNonSpaceWrap(true)
    fontString:SetPoint("TOPLEFT")

    local widget = {
        frame = frame,
        fontString = fontString,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end

    return widget
end)