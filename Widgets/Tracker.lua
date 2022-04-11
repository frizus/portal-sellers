local addonName, addon = ...
local Widget, L, DB, TrackerList = addon.Widget, addon.L, addon.param, addon.TrackerList

local function frame_OnUpdate(self)
    local widget = self.widget
    local px, py = GetCursorPosition()
    if px ~= widget.lastMouseX or py ~= widget.lastMouseY then
        widget.lastMouseX = px
        widget.lastMouseY = py
        local widthChanged = widget:SetListWidth(widget:GetWidth())
        local heightChanged = widget:SetListHeight(widget:GetHeight())
        if widthChanged or heightChanged then
            widget:UpdateListLayout()
        end
    end
end
local function frame_OnMouseDown(self, mouseButton)
    if mouseButton == "LeftButton" then
        self:StartMoving()
        self:SetScript("OnUpdate", frame_OnUpdate)
    end
end
local function frame_OnMouseUp(self, mouseButton)
    if mouseButton == "LeftButton" then
        self:SetScript("OnUpdate", nil)
        self:StopMovingOrSizing()
        self.widget:SavePosAndSize()
    end
end
local function settings_OnClick(self, mouseButton)
    if mouseButton == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        self.widget:TriggerEvent("SettingsOnLeftClick")
    end
end
local function power_OnClick(self, mouseButton)
    if mouseButton == "LeftButton" then
        PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
        self.widget:TriggerEvent("PowerOnLeftClick")
    end
end
local function close_OnClick(self, mouseButton)
    if mouseButton == "LeftButton" then
        PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
        self.widget:TriggerEvent("CloseOnLeftClick")
    end
end
local function moverOrSizer_OnMouseUp(self, mouseButton)
    if mouseButton == "LeftButton" then
        local frame = self:GetParent()
        frame:StopMovingOrSizing()
        frame:SetScript("OnUpdate", nil)
        frame.widget:SavePosAndSize()
    end
end
local function sizerBottomRight_OnMouseDown(self, mouseButton)
    if mouseButton == "LeftButton" then
        local frame = self:GetParent()
        frame:SetScript("OnUpdate", frame_OnUpdate)
        frame:StartSizing("BOTTOMRIGHT")
    end
end
local function sizerBottom_OnMouseDown(self, mouseButton)
    if mouseButton == "LeftButton" then
        local frame = self:GetParent()
        frame:SetScript("OnUpdate", frame_OnUpdate)
        frame:StartSizing("BOTTOM")
    end
end
local function sizerRight_OnMouseDown(self, mouseButton)
    if mouseButton == "LeftButton" then
        local frame = self:GetParent()
        frame:SetScript("OnUpdate", frame_OnUpdate)
        frame:StartSizing("RIGHT")
    end
end

local method = {}
for name, closure in pairs(TrackerList) do
    method[name] = closure
end
method.OnAcquire = function(self)
    self:SetWidth(DB.trackerWindowRect.width)
    self:SetHeight(DB.trackerWindowRect.height)
    self:SetPoint("TOP", self.frame:GetParent(), "BOTTOM", 0, DB.trackerWindowRect.top)
    self:SetPoint("LEFT", self.frame:GetParent(), "LEFT", DB.trackerWindowRect.left, 0)
    self:TogglePower()
end
method.OnRelease = function(self)
    self.lastMouseX = nil
    self.lastMouseY = nil
    self:ReleaseTracker()
end
method.TogglePower = function(self)
    if DB.trackerEnabled then
        self.topArea.power:SetNormalTexture([[Interface\Addons\Triton\Media\on]])
        self.topArea.power:SetHighlightTexture([[Interface\Addons\Triton\Media\on]])
        self.topArea.power:SetPushedTexture([[Interface\Addons\Triton\Media\on]])
        self.topArea.title:SetTextColor(1, 0.82, 0, 1)
    else
        self.topArea.power:SetNormalTexture([[Interface\Addons\Triton\Media\off]])
        self.topArea.power:SetHighlightTexture([[Interface\Addons\Triton\Media\off]])
        self.topArea.power:SetPushedTexture([[Interface\Addons\Triton\Media\off]])
        self.topArea.title:SetTextColor(1, 0, 0, 1)
    end
end
method.SavePosAndSize = function(self)
    local frame = self.frame
    DB.trackerWindowRect.width = frame:GetWidth()
    DB.trackerWindowRect.height = frame:GetHeight()
    DB.trackerWindowRect.top = frame:GetTop()
    DB.trackerWindowRect.left = frame:GetLeft()
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
            end
        end
    end
    self:SetListWidth(value, fill)
end
method.SetHeight = function(self, value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
    self:SetListHeight(value)
end

Widget:RegisterType("Tracker", function()
    local f = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    f:Hide()

    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetResizable(true)
    f:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        tile = false,
        tileSize = 1,
        edgeSize = 10,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    f:SetBackdropColor(0, 0, 0, 0.36)
    f:SetMinResize(180, 80)
    f:SetScript("OnMouseDown", frame_OnMouseDown)
    f:SetScript("OnMouseUp", frame_OnMouseUp)

    local topArea = CreateFrame("Frame", nil, f)
    topArea:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    topArea:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    topArea:SetHeight(16)

    topArea.title = topArea:CreateFontString()
    topArea.title:SetFont(DEFAULT_CHAT_FRAME:GetFont(), 11.8)
    topArea.title:SetText(L["tracker_title"])
    topArea.title:SetWidth(topArea.title:GetStringWidth())
    topArea.title:SetPoint("TOP", 0, -2)
    topArea.title:SetPoint("CENTER", 0, 0)

    topArea.settings = CreateFrame("Button", nil, topArea)
    topArea.settings:SetSize(11, 11)
    topArea.settings:SetPoint("TOPLEFT", 5, -5)
    topArea.settings:SetScript("OnClick", settings_OnClick)
    topArea.settings:SetNormalTexture([[Interface\Addons\Triton\Media\options]])
    topArea.settings:SetHighlightTexture([[Interface\Addons\Triton\Media\options]])
    topArea.settings:SetPushedTexture([[Interface\Addons\Triton\Media\options]])

    topArea.power = CreateFrame("Button", nil, topArea)
    topArea.power:SetSize(11, 11)
    topArea.power:SetPoint("TOPLEFT", topArea.settings, "TOPRIGHT", 4, 0)
    topArea.power:SetScript("OnClick", power_OnClick)

    topArea.close = CreateFrame("Button", nil, topArea)
    topArea.close:SetSize(11, 11)
    topArea.close:SetPoint("TOPRIGHT", -5, -5)
    topArea.close:SetScript("OnClick", close_OnClick)
    topArea.close:SetNormalTexture([[Interface\Buttons\UI-StopButton]])
    topArea.close:SetHighlightTexture([[Interface\Buttons\UI-StopButton]])
    topArea.close:SetPushedTexture([[Interface\Buttons\UI-StopButton]])

    f.sizerBottomRight = CreateFrame("Frame", nil, f)
    f.sizerBottomRight:SetPoint("BOTTOMRIGHT")
    f.sizerBottomRight:SetWidth(10)
    f.sizerBottomRight:SetHeight(10)
    f.sizerBottomRight:EnableMouse()
    f.sizerBottomRight:SetScript("OnMouseDown", sizerBottomRight_OnMouseDown)
    f.sizerBottomRight:SetScript("OnMouseUp", moverOrSizer_OnMouseUp)

    f.sizerBottomRight.icon = f.sizerBottomRight:CreateTexture(nil, "BACKGROUND")
    f.sizerBottomRight.icon:SetWidth(8)
    f.sizerBottomRight.icon:SetHeight(8)
    f.sizerBottomRight.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    f.sizerBottomRight.icon:SetTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])

    f.sizerBottom = CreateFrame("Frame", nil, f)
    f.sizerBottom:SetPoint("BOTTOMRIGHT", -10, 0)
    f.sizerBottom:SetPoint("BOTTOMLEFT")
    f.sizerBottom:SetHeight(10)
    f.sizerBottom:EnableMouse(true)
    f.sizerBottom:SetScript("OnMouseDown", sizerBottom_OnMouseDown)
    f.sizerBottom:SetScript("OnMouseUp", moverOrSizer_OnMouseUp)

    f.sizerRight = CreateFrame("Frame", nil, f)
    f.sizerRight:SetPoint("BOTTOMRIGHT", 0, 10)
    f.sizerRight:SetPoint("TOPRIGHT")
    f.sizerRight:SetWidth(10)
    f.sizerRight:EnableMouse(true)
    f.sizerRight:SetScript("OnMouseDown", sizerRight_OnMouseDown)
    f.sizerRight:SetScript("OnMouseUp", moverOrSizer_OnMouseUp)

    local widget = {
        frame = f,
        topArea = topArea,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    f.widget, topArea.close.widget, topArea.settings.widget, topArea.power.widget = widget, widget, widget, widget
    widget:ConstructTracker()

    return widget
end)