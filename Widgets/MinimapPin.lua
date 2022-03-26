local addonName, addon = ...
local Widget, WidgetTooltip, L, DB = addon.Widget, addon.WidgetTooltip, addon.L, addon.param

local function button_OnUpdate(self)
    local widget = self.widget
    local px, py = GetCursorPosition()
    if px ~= widget.lastMouseX or py ~= widget.lastMouseY then
        local parent = self:GetParent()
        local mx, my = parent:GetCenter()
        local scale = parent:GetEffectiveScale()
        px, py = px / scale, py / scale
        widget.lastMouseX = px
        widget.lastMouseY = py
        self.widget:UpdatePosition(math.deg(math.atan2(py - my, px - mx)) % 360)
    end
end

local function button_OnDragStart(self)
    local widget = self.widget
    self:LockHighlight()
    widget:TogglePinFocus(true)
    self:SetScript("OnUpdate", button_OnUpdate)
    widget.isDragging = true
    widget:HideTooltip()
end

local function button_OnDragStop(self)
    local widget = self.widget
    widget.isDragging = false
    self:SetScript("OnUpdate", nil)
    widget:TogglePinFocus(false)
    self:UnlockHighlight()
end

local function button_OnMouseDown(self)
    self.widget:TogglePinFocus(true)
end

local function button_OnMouseUp(self)
    self.widget:TogglePinFocus(false)
end

local function button_ShowTooltip(self)
    local widget = self.widget
    if not widget.isDragging then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
        local trackerVisible = widget:TriggerEvent("OnTooltip")
        GameTooltip:AddLine(
        trackerVisible and
                L["minimap_pin_tooltip_tracker_window_shown"] or
                L["minimap_pin_tooltip_tracker_window_hidden"]
        )
        GameTooltip:Show()
    end
end

local function button_OnClick(self, mouseButton)
    if mouseButton == "LeftButton" then
        self.widget:TriggerEvent("OnLeftClick")
        button_ShowTooltip(self)
    end
end

local minimapShapes = {
    -- quadrant booleans (same order as SetTexCoord)
    -- {upper-left, lower-left, upper-right, lower-right}
    -- true = rounded, false = squared
    ["ROUND"] = { true, true, true, true },
    ["SQUARE"] = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { true, false, false, false },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { false, false, false, true },
    ["SIDE-LEFT"] = { true, true, false, false },
    ["SIDE-RIGHT"] = { false, false, true, true },
    ["SIDE-TOP"] = { true, false, true, false },
    ["SIDE-BOTTOM"] = { false, true, false, true },
    ["TRICORNER-TOPLEFT"] = { true, true, true, false },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { false, true, true, true },
}

local method = {}
for name, closure in pairs(WidgetTooltip) do
    method[name] = closure
end
method.OnAcquire = function(self, options)
    self:SetParent(_G["Minimap"])
    self:TogglePinFocus(false)
    self:UpdatePosition()
    self:InitTooltip(self.frame, button_ShowTooltip)
end
method.OnRelease = function(self)
    self.isDragging = nil
    self.lastMouseX = nil
    self.lastMouseY = nil
    self:RemoveTooltip(self.frame)
end
method.SetParent = function(self, parent)
    if parent then
        local frame = self.frame
        if frame:GetParent() ~= parent then
            frame:SetParent(nil)
            frame:SetParent(parent)
            frame:SetFrameStrata("MEDIUM")
            frame:SetFrameLevel(8)
        end
    end
end
method.TogglePinFocus = function(self, focus)
    if focus then
        self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    else
        self.icon:SetTexCoord(0, 1, 0, 1)
    end
end
method.UpdatePosition = function(self, newPosition)
    if newPosition then
        DB.minimap.minimapPos = newPosition
    end
    local button = self.frame
    local parent = button:GetParent()
    local w = (parent:GetWidth() / 2) + 5
    local h = (parent:GetHeight() / 2) + 5
    local angle = math.rad(DB.minimap.minimapPos)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    if x < 0 then
        q = q + 1
    end
    if y > 0 then
        q = q + 2
    end
    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadTable = minimapShapes[minimapShape]

    if quadTable[q] then
        x = x * w
        y = y * h
    else
        local diagRadius = math.sqrt(2 * (w) ^ 2) - 10
        x = math.max(-w, math.min(x * diagRadius, w))
        diagRadius = math.sqrt(2 * (h) ^ 2) - 10
        y = math.max(-h, math.min(y * diagRadius, h))
    end
    button:SetPoint("CENTER", parent, "CENTER", x, y)
end

Widget:RegisterType("MinimapPin", function()
    local button = CreateFrame("Button", nil, UIParent)
    button:Hide()

    button:SetSize(31, 31)
    button:RegisterForClicks("anyUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    button:SetScript("OnDragStart", button_OnDragStart)
    button:SetScript("OnDragStop", button_OnDragStop)
    button:SetScript("OnMouseDown", button_OnMouseDown)
    button:SetScript("OnMouseUp", button_OnMouseUp)
    button:SetScript("OnClick", button_OnClick)

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
    overlay:SetPoint("TOPLEFT")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture([[Interface\Addons\Triton\Media\logo]])
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", 7, -6)

    local widget = {
        frame = button,
        overlay = overlay,
        background = background,
        icon = icon,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    button.widget = widget

    return widget
end)