local addonName, addon = ...
local Widget = addon.Widget

local menuItemsLen = 0

local function frame_OnEnter(self)
    local widget = self.widget
    local menuWidget = widget.menuWidget
    menuWidget.OnEnter(menuWidget:GetFrame())
    if not widget.isText and not widget.iconOnly then
        widget.highlight:Show()
    end
    if (not widget.isText and not widget.iconOnly and widget.tooltipTitle) or widget.haveTooltip then
        GameTooltip_AddNewbieTip(widget.frame, widget.tooltipTitle, 1.0, 1.0, 1.0, nil, 1)
    end
    widget:TriggerEvent("MenuItemOnEnter")
end
local function frame_OnLeave(self)
    local widget = self.widget
    local menuWidget = widget.menuWidget
    menuWidget.OnLeave(menuWidget:GetFrame())
    if not widget.isText and not widget.iconOnly then
        widget.highlight:Hide()
    end
    if (not widget.isText and not widget.iconOnly and widget.tooltipTitle) or widget.haveTooltip then
        if GameTooltip:IsShown() and GameTooltip:GetOwner() == widget.frame then
            GameTooltip:Hide()
        end
    end
    widget:TriggerEvent("MenuItemOnLeave")
end
local function frame_OnClick(self, mouseButton)
    if mouseButton == "LeftButton" then
        local widget = self.widget
        if widget.callback then widget.callback(widget) end
        widget:TriggerEvent("MenuItemOnLeftClick")
    end
end
local function frame_OnMouseUp(self, mouseButton)
    if mouseButton == "LeftButton" then
        self.widget:TriggerEvent("MenuItemOnLeftMouseUp")
    end
end
local function arrow_OnEnter(self)
    local widget = self.widget
    local menuWidget = widget.menuWidget
    menuWidget.OnEnter(menuWidget:GetFrame())
    widget:TriggerEvent("MenuItemOnEnter")
end
local function arrow_OnLeave(self)
    local widget = self.widget
    local menuWidget = widget.menuWidget
    menuWidget.OnLeave(menuWidget:GetFrame())
    widget:TriggerEvent("MenuItemOnLeave")
end
local function arrow_OnMouseUp(self, mouseButton)
    if mouseButton == "LeftButton" then
        self.widget:TriggerEvent("MenuItemOnLeftMouseUp")
    end
end

local method = {}
function method:OnAcquire(options)
    self:SetParent(options.parent)
    self.menuWidget = options.menuWidget
    self.dynamic = options.dynamic
    if options.submenuItemsDynamic then
        self.submenuItemsDynamic = options.submenuItemsDynamic
        self:Arrow()
    elseif options.items then
        self.items = options.items
        self:Arrow()
    end
    if options.tooltipTitle then
        self.haveTooltip = true
        self.tooltipTitle = options.tooltipTitle
    end
    self.textColor = options.textColor
    self.descColor = options.descColor or "ffcfcfcf"
    if not options.separator then
        if options.text then
            self.desc = options.desc
            self:SetText(options.text)
        end
        if options.isText then
            self.isText = options.isText
            self.frame:Disable()
        else
            self.frame:Enable()
            self.callback = options.callback
            self.frame:SetScript("OnClick", frame_OnClick)
            self:AddEventHandler("MenuItemOnLeftClick", self.menuWidget)
        end
    else
        self:SetSeparator()
    end

    if self.haveArrow then
        self:AddEventHandler("MenuItemOnLeftMouseUp", self.menuWidget)
        self.frame:SetScript("OnMouseUp", frame_OnMouseUp)
        self.arrow:SetScript("OnEnter", arrow_OnEnter)
        self.arrow:SetScript("OnLeave", arrow_OnLeave)
        self.arrow:SetScript("OnMouseUp", arrow_OnMouseUp)
    end
    self.frame:SetScript("OnEnter", frame_OnEnter)
    self.frame:SetScript("OnLeave", frame_OnLeave)
    self:AddEventHandler("MenuItemOnEnter", self.menuWidget)
    self:AddEventHandler("MenuItemOnLeave", self.menuWidget)

    self.hidden = options.hidden
    if options.params then
        for param, value in pairs(options.params) do
            self[param] = value
        end
        self.params = options.params
    end
end
function method:OnRelease()
    if self.menuWidget.openedItem and self.menuWidget.openedItem == self.id then
        self.menuWidget:CloseSubmenu()
    end
    if not self.separator and not self.isText then
        self.frame:SetScript("OnClick", nil)
    end
    if self.haveArrow then
        self.frame:SetScript("OnMouseUp", nil)
        self.arrow:SetScript("OnEnter", nil)
        self.arrow:SetScript("OnLeave", nil)
        self.arrow:SetScript("OnMouseUp", nil)
    end
    self.frame:GetScript("OnEnter", nil)
    self.frame:GetScript("OnLeave", nil)
    self:RemoveIcon()
    self.menuWidget = nil
    self.dynamic = nil
    self.submenuItemsDynamic = nil
    self.items = nil
    self.haveTooltip = nil
    self.tooltipTitle = nil
    self.textColor = nil
    self.descCololr = nil
    self.iconOnly = nil
    self.haveIcon = nil
    self.isText = nil
    self.callback = nil
    self.hidden = nil
    self:SetText(nil)
    self:RemoveArrow()
    self.haveArrow = nil
    if self.params then
        for param in pairs(self.params) do
            self[param] = nil
        end
        self.params = nil
    end
end
function method:ResetParam(param)
    self[param] = self.params[param]
end
function method:SetHidden(hidden)
    if hidden then self:SetText(nil) end
    self.hidden = hidden
end
function method:IsHidden()
    return self.hidden
end
function method:IsShown()
    return self.frame:IsShown()
end
function method:SetSeparator()
    self.iconOnly = true
    self.haveIcon = true
    self.frame:Disable()
    self.frame:SetText("")
    self.icon:SetTexture([[Interface\Common\UI-TooltipDivider-Transparent]])
    self.icon:SetTexCoord(0, 1, 0, 1)
    self.icon:SetWidth(0)
    self.icon:SetHeight(8)
    self.iconStretch = true
    self:SetWidth(0, "fill")
    self:SetHeight(13 + self.yOffset)
    self.icon:ClearAllPoints()
    self.icon:SetPoint("TOPLEFT", 0, -4)
    self.icon:Show()
end
function method:RemoveIcon()
    if self.haveIcon then
        self.icon:SetTexture(nil)
        self.icon:ClearAllPoints()
        self.icon:Hide()
    end
end
function method:Arrow()
    self.haveArrow = true
    if not self.arrow then
        self.arrow = CreateFrame("Button", nil, self.frame)
        self.arrow:SetNormalTexture([[Interface\ChatFrame\ChatFrameExpandArrow]])
        self.arrow:EnableMouse(true)
        self.arrow.widget = self
    end
    self.arrow:SetSize(16, 16)
    self.arrow:SetPoint("RIGHT", 5.5, 0)
    self.arrow:Show()
end
function method:RemoveArrow()
    if self.haveArrow then
        self.arrow:SetSize(0, 0)
        self.arrow:ClearAllPoints()
        self.arrow:Hide()
    end
end
function method:SetText(text)
    if not self.haveTooltip then
        self.tooltipTitle = text
        if self.tooltipTitle and self.desc then
            self.tooltipTitle = self.tooltipTitle .. " " .. self.desc
        end
    end
    if text then
        local text1 = ""
        if self.textColor then text1 = text1 .. "|c" .. self.textColor end
        text1 = text1 .. text
        if self.textColor then text1 = text1 .. "|r" end
        if text1 and self.desc then
            text1 = text1 .. " |c" .. self.descColor .. self.desc .. "|r"
        end
        self.frame:SetText(text1)
    else
        self.frame:SetText(nil)
    end
end
function method:SetTooltip(title)
    if not self.haveTooltip then self.haveTooltip = true end
    self.tooltipTitle = title
end
function method:GetWidth()
    return self.fontString:GetUnboundedStringWidth()
end
function method:SetWidth(value, fill)
    if fill then
        self.frame:SetWidth(value)
        if not self.iconOnly then
            self.fontString:SetWidth(value)
            self:SetHeightNotTruncated()
        end
        if self.haveIcon and self.iconStretch then
            self.icon:SetWidth(value)
        end
        self.width = "fill"
    else
        if self.width ~= value then
            self.width = value
            if value and value ~= "fill" then
                self.frame:SetWidth(value)
                if not self.iconOnly then
                    self.fontString:SetWidth(value)
                    self:SetHeightNotTruncated()
                end
                if self.haveIcon and self.iconStretch then
                    self.icon:SetWidth(value)
                end
            end
        end
    end
end
function method:GetHeight()
    if self.haveIcon then
        return self.frame:GetHeight()
    end
    return self.fontString:GetStringHeight() + self.yOffset
end
function method:SetHeight(value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
    if value and not self.iconOnly then
        self.fontString:SetHeight(value - self.yOffset)
    end
end
function method:SetHeightNotTruncated()
    self.fontString:SetHeight(self.fontString:GetStringHeight() + 2000)
    self:SetHeight(self.fontString:GetStringHeight() + self.yOffset)
end

Widget:RegisterType("MenuItem", function()
    menuItemsLen = menuItemsLen + 1
    local name = "TritonMenuItem" .. menuItemsLen
    local frame = CreateFrame("Button", name)
    frame:Hide()
    frame:SetHeight(1)
    frame:EnableMouse(true)
    frame:SetMotionScriptsWhileDisabled(true)
    local fontString = frame:CreateFontString()
    frame:SetFontString(fontString)
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("MIDDLE")
    fontString:SetNonSpaceWrap(true)
    fontString:SetWordWrap(true)
    fontString:SetPoint("LEFT", 0, 0)
    frame:SetNormalFontObject(GameFontHighlightSmallLeft)
    frame:SetHighlightFontObject(GameFontHighlightSmallLeft)
    frame:SetDisabledFontObject(GameFontHighlightSmallLeft)
    local icon = frame:CreateTexture(nil, "ARTWORK")
    local highlight = frame:CreateTexture(nil, "BACKGROUND")
    highlight:Hide()
    highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
    highlight:SetBlendMode("ADD")
    highlight:SetPoint("TOPLEFT")
    highlight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 6, 0)

    local widget = {
        id = name,
        frame = frame,
        fontString = fontString,
        icon = icon,
        highlight = highlight,
        yOffset = 6,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget, icon.widget = widget, widget
    return widget
end)