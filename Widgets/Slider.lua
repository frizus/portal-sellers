local addonName, addon = ...
local Widget = addon.Widget

local function Slider_OnValueChanged(self, value)
    local widget = self.widget
    if not widget.sliderNotUserInput then
        widget:SetValue(value, nil, "editbox")
    else
        widget.sliderNotUserInput = nil
    end
end

local function EditBox_Refresh(self)
    local widget = self.widget
    local value = widget.value
    if not value or value == "" then
        value = widget:NumericValidator(value, widget.minusAllowed, widget.decimalPrecision)
    end
    widget:SetValue(value, "range", nil)
end

local function EditBox_OnEscapePressed(self)
    self:ClearFocus()
    EditBox_Refresh(self)
end

local function EditBox_OnEnterPressed(self)
    EditBox_Refresh(self)
    PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
end

local function EditBox_OnEnter(self)
    self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

local function EditBox_OnLeave(self)
    self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
end

local function EditBox_OnTextChanged(self, userInput)
    if userInput then
        local widget = self.widget
        widget:SetValue(widget:NumericValidator(self:GetText(), widget.minusAllowed, widget.decimalPrecision), "range", false)
    end
end

local method = {}
method.NumericValidator = function(self, text, minusAllowed, decimalPrecision)
    local valid = true
    local value = ""
    local haveMinus, haveDigit, haveDot
    local decimalDigits = 0
    local reader = string.reader(text)

    while not reader:eof() do
        local c = reader:peek()
        if c == "-" then
            if minusAllowed and not haveDigit and not haveDot and not haveMinus then
                value = value .. c
                haveMinus = true
            else
                valid = false
            end
            reader:ignore(1)
        elseif c == "." or c == "," then
            if not haveDot then
                haveDot = true
                if decimalPrecision > 0 then
                    if not haveDigit then
                        value = value .. "0"
                    end
                    value = value .. "."
                    if c == "," then
                        valid = false
                    end
                else
                    valid = false
                    break
                end
            else
                valid = false
            end
            reader:ignore(1)
        elseif
            c == "0" or c == "1" or c == "2" or c == "3" or c == "4" or
            c == "5" or c == "6" or c == "7" or c == "8" or c == "9"
        then
            if haveDot then
                if decimalDigits < decimalPrecision then
                    value = value .. c
                    decimalDigits = decimalDigits + 1
                else
                    valid = false
                    break
                end
            else
                value = value .. c
            end
            haveDigit = true
            reader:ignore(1)
        else
            valid = false
            reader:ignore(1)
        end
    end

    if value == "" or value == "-" or tonumber(value) == 0 then
        value = "0"
    end

    return value, valid
end
method.OnAcquire = function(self, options)
    self.frame:SetParent(options.parent)
    self:SetWidth(options.width)
    self:SetHeight(44)
    self.label:SetText(options.title)
    self.slider:SetMinMaxValues(options.min, options.max)
    self.slider:SetValueStep(options.step)
    self.step = options.step
    self.min = options.min
    self.max = options.max
    self.minLabel:SetText(self.min)
    self.maxLabel:SetText(self.max)
    self.minusAllowed = options.min < 0
    self.decimalPrecision = self:CalcDecimalPrecision(options.step)
    self:InitTooltip(self.slider, options.title, options.tooltip)
    self.slider:SetScript("OnValueChanged", Slider_OnValueChanged)
end
method.OnRelease = function(self)
    self.slider:SetScript("OnValueChanged", nil)
    self.value = nil
    self.minusAllowed = nil
    self.decimalPrecision = nil
    self:RemoveTooltip(self.slider)
end
method.CalcDecimalPrecision = function(self, step)
    local start, decimalEnd = tostring(step):find("\.%d+$")
    if start then
        return decimalEnd - start
    end
    return 0
end
method.GetValue = function(self)
    return self.value
end
method.SetValue = function(self, value, check, update)
    value = tonumber(value)
    if check == "precision" or check == nil then
        value = value - (value % self.step)
    end
    if check == "range" or check == nil then
        if value < self.min then
            value = self.min
        elseif value > self.max then
            value = self.max
        end
    end
    local stringValue = self.decimalPrecision > 0 and string.format("%." .. self.decimalPrecision .. "f", value) or tostring(value)

    if (update == "editbox" or update == nil) and self.editBox:GetText() ~= stringValue then
        self.editBox:SetText(stringValue)
    end
    if (update == "slider" or update == nil) and self.slider:GetValue() ~= stringValue then
        self.sliderNotUserInput = true
        self.slider:SetValue(stringValue)
    end

    self.value = value
    self:TriggerEvent("SetValue")
end

Widget:RegisterType("Slider", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    label:SetPoint("TOPLEFT")
    label:SetPoint("TOPRIGHT")
    label:SetJustifyH("CENTER")
    label:SetHeight(15)

    local slider = CreateFrame("Slider", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    slider:SetOrientation("HORIZONTAL")
    slider:SetHeight(15)
    slider:SetHitRectInsets(0, 0, -10, 0)
    slider:SetBackdrop({
        bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
        edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 }
    })
    slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])
    slider:SetPoint("TOP", label, "BOTTOM")
    slider:SetPoint("LEFT", 3, 0)
    slider:SetPoint("RIGHT", -3, 0)

    local minLabel = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    minLabel:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
    local maxLabel = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    maxLabel:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)

    local editBox = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetPoint("TOP", slider, "BOTTOM")
    editBox:SetHeight(14)
    editBox:SetWidth(70)
    editBox:SetJustifyH("CENTER")
    editBox:EnableMouse(true)
    editBox:SetBackdrop({
        bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
        edgeFile = [[Interface\ChatFrame\ChatFrameBackground]],
        tile = true, edgeSize = 1, tileSize = 5,
    })
    editBox:SetBackdropColor(0, 0, 0, 0.5)
    editBox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
    editBox:SetScript("OnEnter", EditBox_OnEnter)
    editBox:SetScript("OnLeave", EditBox_OnLeave)
    editBox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
    editBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
    editBox:SetScript("OnEditFocusLost", EditBox_Refresh)
    editBox:SetScript("OnTextChanged", EditBox_OnTextChanged)

    local widget = {
        frame = frame,
        label = label,
        slider = slider,
        minLabel = minLabel,
        maxLabel = maxLabel,
        editBox = editBox,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    slider.widget, editBox.widget = widget, widget

    return widget
end)