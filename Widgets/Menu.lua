local addonName, addon = ...
local Widget = addon.Widget

local menusLen = 0
local innerClose
local function CloseTritonMenus(skip)
    for i = 1, menusLen do
        local name = "TritonMenu" .. i
        if not skip or (skip and skip ~= name) then
            local menu = _G[name]
            if menu and menu.widget and menu.widget:IsShown() then
                menu.widget:Hide()
                local frame = menu.widget:GetFrame()
                if frame:GetScript("OnUpdate") then
                    frame:SetScript("OnUpdate", nil)
                    menu.widget.timeLeft = false
                end
            end
        end
    end
end
hooksecurefunc("CloseMenus", function()
    if not innerClose then CloseTritonMenus() end
end)
local DropDownList = _G["DropDownList1"]
if DropDownList then
    DropDownList:HookScript("OnShow", function() CloseTritonMenus() end)
end
local LibUIDropDownMenu = _G["L_DropDownList1"]
if LibUIDropDownMenu then
    LibUIDropDownMenu:HookScript("OnShow", function() CloseTritonMenus() end)
end

local delegateFrame = CreateFrame("Frame")
local timeLeft

local function frame_OnClick(self, mouseButton)
    if mouseButton == "LeftButton" then CloseTritonMenus() end
end
local function delegateFrame_OnUpdate(self, elapsed)
    timeLeft = timeLeft - elapsed
    if timeLeft <= 0 then
        CloseTritonMenus()
        delegateFrame:SetScript("OnUpdate", nil)
    end
end
local function container_SetHeight(self, value)
    self.parentWidget:SetHeight(value)
end
local function container_SetWidth(self, value, fill)
    self.parentWidget:SetWidth(value, fill)
end

local method = {}
function method.OnEnter(self)
    delegateFrame:SetScript("OnUpdate", nil)
    timeLeft = false
end
function method.OnLeave(self)
    timeLeft = self.widget.autoClose
    delegateFrame:SetScript("OnUpdate", delegateFrame_OnUpdate)
end
function method:OnAcquire(options)
    self:SetParent(options.parent)
    self.container.maxWidth = options.maxWidth or 250
    self.level = options.level or 1
    self.frame:SetScript("OnEnter", method.OnEnter)
    self.frame:SetScript("OnLeave", method.OnLeave)
    self.autoClose = options.autoClose or 2
end
function method:OnRelease()
    self.frame:SetScript("OnEnter", nil)
    self.frame:SetScript("OnLeave", nil)
    if self.frame:GetScript("OnUpdate") then
        self.frame:SetScript("OnUpdate", nil)
    end
    self.level = nil
    self.autoClose = nil
    self.timeLeft = nil
    self.refreshLayout = nil
    if self.submenu then
        self.submenu:Release()
        self.submenu = nil
    end
    self.container:ReleaseChildren()
    self.dynamicItems = nil
    self.submenuItemsDynamic = nil
end
function method:IsShown()
    return self.frame:IsShown()
end
function method:Show()
    if self.level == 1 then
        innerClose = true
        CloseMenus()
        innerClose = false
        CloseTritonMenus(self.frame:GetName())
    end
    self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    self.frame:Show()
end
function method:Hide()
    local isShown = self.frame:IsShown()
    self.frame:Hide()
    if isShown then self:TriggerEvent("OnHide") end
end
function method:ToTop()
    self.frame:Hide()
    self.frame:Show()
end
function method:CleanItems()
    self.container.children = {}
    self.dynamicItems = nil
    self.submenuItemsDynamic = nil
end
function method:SetParent(parent)
    if parent then
        local f = self.frame
        if f:GetParent() ~= parent then
            f:SetParent(nil)
            f:SetParent(parent)
        end
    end
end
function method:GetContainerFrame()
    return self.container:GetChildrenFrame()
end
function method:SetItems(items)
    self.dynamicItems = false
    self.submenuItemsDynamic = false
    self.container.children = items
    for i, child in pairs(self.container.children) do
        if child.dynamic then
            if not self.dynamicItems then self.dynamicItems = {} end
            table.insert(self.dynamicItems, i)
            child.dynamic(child)
        end
        if child.submenuItemsDynamic then
            if not self.submenuItemsDynamic then self.submenuItemsDynamic = {} end
            table.insert(self.submenuItemsDynamic, i)
        end
    end
end
function method:Layout()
    Widget:Layout(self.container)
end
function method:UpdateDynamic()
    if not self.dynamicItems and not self.submenuItemsDynamic then return end
    if self.dynamicItems then
        for _, i in pairs(self.dynamicItems) do
            local child = self.container.children[i]
            child.dynamic(child)
        end
    end
    if self.submenuItemsDynamic then
        for _, i in pairs(self.submenuItemsDynamic) do
            local child = self.container.children[i]
            if self.openedItem == child.id then
                local changed
                changed, self.submenuItems = child.submenuItemsDynamic(child, self.submenuItems, self.submenu)
                if changed then self.submenu:SetItems(self.submenuItems) end
                self.submenu:Layout()
            end
        end
    end
    if self.refreshLayout then
        self.refreshLayout = false
        self:Layout()
    end
end
function method:CloseSubmenu()
    if self.openedItem then
        self.openedItem = false
        if self.submenu.openedItem then self.submenu:CloseSubmenu() end
        for i, submenuItem in pairs(self.submenuItems) do
            submenuItem:Release()
            self.submenuItems[i] = nil
        end
        self.submenu:Release()
        self.submenu = nil
    end
end
function method:MenuItemOnEnter(menuItem)
    if menuItem.items or menuItem.submenuItemsDynamic then
        if self.openedItem ~= menuItem.id then
            self:CloseSubmenu()
            self.submenu = Widget:Create("Menu", {parent = UIParent, level = self.level + 1})
            self.submenu:SetPoint("TOPLEFT", menuItem:GetFrame(), "TOPRIGHT", 5, 17)
            self.submenuItems = {}
            if menuItem.submenuItemsDynamic then
                _, self.submenuItems = menuItem.submenuItemsDynamic(menuItem, self.submenuItems, self.submenu)
            else
                local itemsFrame = self.submenu:GetContainerFrame()
                for _, itemOptions in pairs(menuItem.items(menuItem)) do
                    itemOptions["parent"] = itemsFrame
                    itemOptions["menuWidget"] = self.submenu
                    table.insert(self.submenuItems, Widget:Create("MenuItem", itemOptions))
                end
            end
            self.submenu:SetItems(self.submenuItems)
            self.submenu:Layout()
            self.submenu:Show()
            self.openedItem = menuItem.id
        end
    else
        self:CloseSubmenu()
    end
end
function method:MenuItemOnLeave(menuItem)

end
function method:MenuItemOnLeftClick()
    CloseTritonMenus()
end
function method:MenuItemOnLeftMouseUp()
    if self.submenu then
        self.submenu:ToTop()
    end
end

Widget:RegisterType("Menu", function()
    menusLen = menusLen + 1
    local f = CreateFrame("Button", "TritonMenu" .. menusLen, UIParent)
    f:Hide()
    f:SetSize(40, 32)
    f:SetScript("OnClick", frame_OnClick)
    f:SetClampedToScreen(true)
    f:SetToplevel(true)

    local backdrop = CreateFrame("Frame", nil, f, "TooltipBackdropTemplate")
    backdrop:SetAllPoints()
    backdrop:Show()

    local container = Widget:Create("Container", {
        parent = f,
        type = "Container",
        layout = "Menu",
        marginTop = UIDROPDOWNMENU_BORDER_HEIGHT,
        marginLeft = 15,
        marginRight = 15,
        marginBottom = UIDROPDOWNMENU_BORDER_HEIGHT,
    })
    container:SetPoint("TOPLEFT")
    container:SetPoint("BOTTOMRIGHT")
    container.SetHeight = container_SetHeight
    container.SetWidth = container_SetWidth

    local widget = {
        frame = f,
        backdrop = backdrop,
        container = container,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    f.widget, container.parentWidget = widget, widget
    return widget
end)