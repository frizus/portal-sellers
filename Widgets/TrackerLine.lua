local addonName, addon = ...
local Widget, DB = addon.Widget, addon.param

local function frame_OnUpdate(self)
    local widget = self.widget
    local px, py = GetCursorPosition()
    if px ~= widget.lastMouseX or py ~= widget.lastMouseY then
        widget.dragging = true
        widget.baseWidget:TriggerEvent("StartDragging")
        self:SetScript("OnUpdate", nil)
    end
end
local function frame_OnMouseDown(self, mouseButton)
    local widget = self.widget
    if mouseButton == "LeftButton" then
        if not self:GetScript("OnUpdate") then
            widget.holdingLeftButton = true
            widget.lastMouseX, widget.lastMouseY = GetCursorPosition()
            self:SetScript("OnUpdate", frame_OnUpdate)
        end
    else
        widget.baseWidget:TriggerEvent("LineOnClick", widget, mouseButton)
    end
end
local function frame_OnMouseUp(self, mouseButton)
    local widget = self.widget
    if widget.holdingLeftButton then
        self:SetScript("OnUpdate", nil)
        widget.lastMouseX, widget.lastMouseY = nil, nil
        widget.holdingLeftButton = false
        if widget.dragging then
            widget.baseWidget:TriggerEvent("StopDragging")
        else
            widget.baseWidget:TriggerEvent("LineOnClick", widget, mouseButton)
        end
        widget.dragging = false
    end
end

local function frame_OnHyperlinkClick(self, linkData, link, button)
    SetItemRef(linkData, link, button)
end

local function frame_OnHyperlinkEnter(self, linkData, link)
    if IsModifierKeyDown() then
        ShowUIPanel(ItemRefTooltip)
        if ( not ItemRefTooltip:IsShown() ) then
            ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
        end
        ItemRefTooltip:SetHyperlink(linkData)
    end
end

local method = {}
for name, closure in pairs(addon.TrackerLineTick) do
    method[name] = closure
end
for name, closure in pairs(addon.TrackerMenuSimilars) do
    method[name] = closure
end
function method:OnAcquire(options)
    self:SetParent(options.parent)
    self:UpdateFontSize()
    if options.fill then
        self.blinked = true
    end
    self.baseWidget = options.base
end
function method:OnRelease()
    if self.fontString:GetText() then
        self.fontString:SetText(nil)
    end
    self.holdingLeftButton = nil
    self.lastMouseX, self.lastMouseY = nil, nil
    self.dragging = nil
    self.blinked = nil
    self.fontSize = nil
    self.baseWidget = nil
    self:ReleaseTick()
    self:TriggerEvent("OnRelease")
end
function method:UpdateFontSize()
    local fontSize = DB.trackerFontSize
    if self.fontSize ~= fontSize then
        local font, _, flags = DEFAULT_CHAT_FRAME:GetFont()
        self.fontString:SetFont(font, fontSize, flags)
        self.fontSize = fontSize
    end
end
function method:Blink()
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
function method:SetWidth(value, fill)
    if fill then
        self.frame:SetWidth(value)
        self.fontString:SetWidth(value)
        self:SetHeightNotTruncated()
        self.width = "fill"
    else
        if self.width ~= value then
            self.width = value
            if value and value ~= "fill" then
                self.frame:SetWidth(value)
                self.fontString:SetWidth(value)
                self:SetHeightNotTruncated()
            end
        end
    end
end
function method:SetHeight(value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
    if value then
        self.fontString:SetHeight(value)
    end
end
function method:GetHeight()
    return self.fontString:GetStringHeight()
end
function method:SetHeightNotTruncated()
    self.fontString:SetHeight(self.fontString:GetStringHeight() + 2000)
    self:SetHeight(self.fontString:GetStringHeight())
end
function method:SetText(text, onlyTime)
    self.fontString:SetText(text)
end

Widget:RegisterType("TrackerLine", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()
    frame:SetHeight(1)

    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", frame_OnMouseDown)
    frame:SetScript("OnMouseUp", frame_OnMouseUp)
    frame:SetHyperlinksEnabled(true)
    frame:SetScript("OnHyperlinkEnter", frame_OnHyperlinkEnter)
    frame:SetScript("OnHyperlinkClick", frame_OnHyperlinkClick)

    local fontString = frame:CreateFontString()
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    fontString:SetNonSpaceWrap(true)
    fontString:SetWordWrap(true)
    fontString:SetPoint("TOPLEFT")

    local widget = {
        frame = frame,
        fontString = fontString,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget = widget

    return widget
end)