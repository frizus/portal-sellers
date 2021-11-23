local localeName = ...
local Type, Version = "TritonMinimapPin", 1
local L = LibStub("AceLocale-3.0"):GetLocale(localeName)
local AceGUI = LibStub("AceGUI-3.0")

local function buttonOnUpdate(self)
    local parent = self:GetParent()
    local mx, my = parent:GetCenter()
    local px, py = GetCursorPosition()
    local w = ((parent:GetWidth() / 2) + 5)
    local scale = parent:GetEffectiveScale()
    px, py = px / scale, py / scale
    local dx, dy = px - mx, py - my
    local dist = math.sqrt(dx * dx + dy * dy) / w
    if dist < 1 then
        dist = 1
    elseif dist > 2 then
        dist = 2
    end

    local minimapPos = math.deg(math.atan2(dy, dx)) % 360
    self.obj:UpdatePosition(minimapPos, dist)
end

local function iconFocus(icon, focus)
    if focus then
        icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    else
        icon:SetTexCoord(0, 1, 0, 1)
    end
end

local function buttonOnDragStart(self)
    self.obj:SetUserData("isDragging", true)
    self:LockHighlight()
    iconFocus(self.obj.icon, true)
    self:SetScript("OnUpdate", buttonOnUpdate)
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end

local function buttonOnDragStop(self)
    self.obj:SetUserData("isDragging", false)
    self:UnlockHighlight()
    iconFocus(self.obj.icon, false)
    self:SetScript("OnUpdate", nil)
end

local function buttonOnMouseDown(self)
    iconFocus(self.obj.icon, true)
end

local function buttonOnMouseUp(self)
    iconFocus(self.obj.icon, false)
end

local function buttonOnEnter(self)
    local widget = self.obj
    if not widget:GetUserData("isDragging") then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
        if widget:GetUserData("trackerWindowIsShown")() then
            GameTooltip:AddLine(L["minimap_pin_tooltip_tracker_window_shown"])
        else
            GameTooltip:AddLine(L["minimap_pin_tooltip_tracker_window_hidden"])
        end
        GameTooltip:Show()
    end
end

local function buttonOnLeave(self)
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
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

local methods = {
    ["OnAcquire"] = function(self)
        self:SetUserData("isDragging", false)
        iconFocus(self.icon, false)
    end,

    ["OnAcquireExtra"] = function(self, options)
        self.frame:SetParent(options.minimapFrame)
        if options.params.minimapPos == nil then
            options.params.minimapPos = 225
        end
        if options.params.distance == nil then
            options.params.distance = 1
        end
        self:SetUserData("params", options.params)
        self:SetUserData("trackerWindowIsShown", options.trackerWindowIsShown)
        self.frame:SetScript("OnClick", options.onPinClick)
        self:UpdatePosition()
        self.frame:Show()
    end,

    ["UpdatePosition"] = function(self, minimapPos, distance)
        local params = self:GetUserData("params")
        if minimapPos ~= nil then
            params.minimapPos = minimapPos
        end
        if distance ~= nil then
            params.distance = distance
        end
        local button = self.frame
        local parent = button:GetParent()
        local w = ((parent:GetWidth() / 2) + 10) * params.distance
        local h = ((parent:GetHeight() / 2) + 10) * params.distance
        local rounding = 10
        local angle = math.rad(params.minimapPos)
        local y = math.sin(angle)
        local x = math.cos(angle)
        local q = 1
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
            local diagRadius = math.sqrt(2 * (w) ^ 2) - rounding
            x = math.max(-w, math.min(x * diagRadius, w))
            diagRadius = math.sqrt(2 * (h) ^ 2) - rounding
            y = math.max(-h, math.min(y * diagRadius, h))
        end
        button:SetPoint("CENTER", parent, "CENTER", x, y)
    end
}

local function Constructor()
    local button = CreateFrame("Button")
    button:Hide()

    button:SetFrameStrata("MEDIUM")
    button:SetSize(31, 31)
    button:SetFrameLevel(8)
    button:RegisterForClicks("anyUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]])
    button:SetScript("OnDragStart", buttonOnDragStart)
    button:SetScript("OnDragStop", buttonOnDragStop)
    button:SetScript("OnMouseDown", buttonOnMouseDown)
    button:SetScript("OnMouseUp", buttonOnMouseUp)
    button:SetScript("OnEnter", buttonOnEnter)
    button:SetScript("OnLeave", buttonOnLeave)

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])
    overlay:SetPoint("TOPLEFT")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture([[Interface\Minimap\UI-Minimap-Background]])
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture([[Interface\Addons\Triton\Media\logo]])
    icon:SetPoint("TOPLEFT", 7, -6)

    local widget = {
        frame = button,
        overlay = overlay,
        background = background,
        icon = icon,
        type = Type,
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)