local addonName, addon = ...
local Widget, L, DB = addon.Widget, addon.L, addon.param

local function frame_OnMouseDown(self, mouseButton)

end

local function frame_OnHyperlinkClick(self, linkData, link, button)
    SetItemRef(linkData, link, button)
end

local method = {}
for name, closure in pairs(addon.TrackerLineTick) do
    method[name] = closure
end
method.OnAcquire = function(self, options)
    self:SetParent(options.parent)
    self:UpdateFontSize()
    if options.fill then
        self.blinked = true
    end
end
method.OnRelease = function(self)
    if self.fontString:GetText() then
        self.fontString:SetText(nil)
    end
    self.blinked = nil
    self.fontSize = nil
end
method.UpdateFontSize = function(self)
    local fontSize = DB.trackerFontSize
    if self.fontSize ~= fontSize then
        local font, _, flags = self.fontString:GetFont()
        self.fontString:SetFont(font, fontSize, flags)
        self.fontSize = fontSize
    end
end
method.Blink = function(self)
    if self.blinked then return end
    self.blinked = true

    if not self.blinkAnimation then
        self.blinkAnimation = self.frame:CreateAnimationGroup()
        local animation1 = self.blinkAnimation:CreateAnimation("Alpha")
        animation1:SetDuration(0.21)
        animation1:SetFromAlpha(1)
        animation1:SetToAlpha(0.5)
        animation1:SetOrder(1)
        local animation2 = self.blinkAnimation:CreateAnimation("Alpha")
        animation2:SetDuration(0.39)
        animation2:SetFromAlpha(0.5)
        animation2:SetToAlpha(1)
        animation2:SetOrder(2)
    end

    if not self.blinkAnimation:IsPlaying() then
        self.blinkAnimation:Play()
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
method.SetText = function(self, text, onlyTime)
    self.fontString:SetText(text)
end

Widget:RegisterType("TrackerLine", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()
    frame:SetHeight(1)

    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", frame_OnMouseDown)
    frame:SetHyperlinksEnabled(true)
    frame:SetScript("OnHyperlinkClick", frame_OnHyperlinkClick)

    local fontSize = DB.trackerFontSize
    local fontString = frame:CreateFontString()
    fontString:SetFont(DEFAULT_CHAT_FRAME:GetFont(), fontSize)
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    fontString:SetNonSpaceWrap(true)
    fontString:SetWordWrap(true)
    fontString:SetPoint("TOPLEFT")

    local widget = {
        frame = frame,
        fontString = fontString,
        fontSize = fontSize,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget = widget

    return widget
end)