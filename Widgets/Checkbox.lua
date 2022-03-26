local addonName, addon = ...
local Widget, WidgetTooltip = addon.Widget, addon.WidgetTooltip

local function frame_OnMouseUp(self)
    local widget = self.widget
    widget:SetValue(not widget.value)

    if widget.value then
        PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    else
        PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    end
end

local method = {}
for name, closure in pairs(WidgetTooltip) do
    method[name] = closure
end
method.OnAcquire = function(self, options)
    self.frame:SetParent(options.parent)
    self:SetWidth(options.width)
    self:SetHeight(28)
    self.label:SetText(options.title)
    self:SetType(options.type)
    self:InitTooltip(self.frame, options.title, options.tooltip)
end
method.GetValue = function(self)
    return self.value
end
method.SetValue = function(self, value)
    self.value = value and true or false
    if self.value then
        self.check:Show()
    else
        self.check:Hide()
    end
    self:TriggerEvent("SetValue")
end
method.SetType = function(self, type)
    local size
    if type == "radio" then
        size = 16
        self.box:SetTexture(130843) -- Interface\\Buttons\\UI-RadioButton
        self.box:SetTexCoord(0, 0.25, 0, 1)
        self.check:SetTexture(130843) -- Interface\\Buttons\\UI-RadioButton
        self.check:SetTexCoord(0.25, 0.5, 0, 1)
        self.check:SetBlendMode("ADD")
        self.boxHighlight:SetTexture(130843) -- Interface\\Buttons\\UI-RadioButton
        self.boxHighlight:SetTexCoord(0.5, 0.75, 0, 1)
    else
        size = 24
        self.box:SetTexture(130755) -- Interface\\Buttons\\UI-CheckBox-Up
        self.box:SetTexCoord(0, 1, 0, 1)
        self.check:SetTexture(130751) -- Interface\\Buttons\\UI-CheckBox-Check
        self.check:SetTexCoord(0, 1, 0, 1)
        self.check:SetBlendMode("BLEND")
        self.boxHighlight:SetTexture(130753) -- Interface\\Buttons\\UI-CheckBox-Highlight
        self.boxHighlight:SetTexCoord(0, 1, 0, 1)
    end
    self.box:SetHeight(size)
    self.box:SetWidth(size)
end

Widget:RegisterType("Checkbox", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    frame:EnableMouse(true)
    frame:SetScript("OnMouseUp", frame_OnMouseUp)

    local box = frame:CreateTexture(nil, "ARTWORK")
    box:SetPoint("TOPLEFT")

    local check = frame:CreateTexture(nil, "OVERLAY")
    check:SetAllPoints(box)
    check:Hide()

    local boxHighlight = frame:CreateTexture(nil, "HIGHLIGHT")
    boxHighlight:SetBlendMode("ADD")
    boxHighlight:SetAllPoints(box)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetJustifyH("LEFT")
    label:SetHeight(18)
    label:SetPoint("LEFT", box, "RIGHT")
    label:SetPoint("RIGHT")

    local widget = {
        frame = frame,
        box = box,
        check = check,
        boxHighlight = boxHighlight,
        label = label,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget = widget

    return widget
end)