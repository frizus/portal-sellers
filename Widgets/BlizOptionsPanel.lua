local addonName, addon = ...
local Widget, DB, defaultDB, Table = addon.Widget, addon.param, addon.DB.default, addon.Table

local function frame_OnShow(self) self.widget:OnShow() end
local function frame_OnHide(self) self.widget:OnHide() end
local function frame_Okay(self) self.widget:Okay() end
local function frame_Cancel(self) self.widget:Cancel() end
local function frame_Refresh(self) self.widget:Refresh() end
local function frame_Default(self) self.widget:Default() end

local method = {}
function method:OnAcquire(options)
    local f = self.frame
    f.name = options.leftPanelName
    if options.parent then
        f.parent = options.parent
    end
    f.okay = frame_Okay
    f.cancel = frame_Cancel
    f.refresh = frame_Refresh
    f.default = frame_Default
    self.titleText = options.title
    self.childrenConfig = options.children
    self.setHandler = options.setHandler
end
function method:OnRelease()
    local f = self.frame
    f.name, f.parent = nil, nil
    f.okay, f.cancel, f.refresh, f.default = nil, nil, nil, nil
    self.titleText, self.childrenConfig = nil, nil
    self.setHandler = nil
    wipe(self.panelInputNames)
    wipe(self.panelChangedInputs)
    wipe(self.panelInput)
    wipe(self.panelInputOnSetHandlers)
    wipe(self.panelInputSetValueClosures)
    self:ReleaseTitle()
    self:ReleaseContent()
end
function method:OnShow()
    self.active = true
    self.titleWidget = Widget:Create("Text", {
        parent = self.frame,
        text = self.titleText,
        font = GameFontNormalLarge,
    })
    self.titleWidget:SetPoint("TOPLEFT", 10, -15)
    self.titleWidget:SetPoint("RIGHT", -10, 0)
    self.titleWidget:Show()
    self.contentWidget = Widget:Create("Container", {
        parent = self.frame,
        type = "Container",
        layout = "Flow",
        scroll = true,
    })
    self.contentWidget:SetChildren(self:BuildChildren(self.childrenConfig), self.childrenConfig)
    self:SetPanelInputsValues()
    self.contentWidget:SetPoint("TOP", self.titleWidget:GetFrame(), "BOTTOM", 0, -27)
    self.contentWidget:SetPoint("LEFT", self.frame, "LEFT", 10, 0)
    self.contentWidget:SetPoint("RIGHT", self.frame, "RIGHT", -10, 0)
    self.contentWidget:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 10)
    Widget:Layout(self.contentWidget)
    if self.debug then
        print("OnShow " .. self.titleText)
    end
end
function method:OnHide()
    self.active = nil
    self:ReleaseTitle()
    self:ReleaseContent()
    if self.debug then
        print("OnHide " .. self.titleText)
    end
end
function method:ProcessInput(config)
    local name = config.param
    if not self.panelInputNames[name] then
        self.panelInputNames[name] = true
        self.panelInputOnSetHandlers[name] = config.onSet
        self.panelInputSetValueClosures[name] = function(input)
            self.panelChangedInputs[name] = input:GetValue()
        end
    end
end
function method:Okay()
    if self.setHandler then
        self.setHandler(self)
        return
    end
    for param in pairs(self.panelChangedInputs) do
        local newValue, oldValue = self.panelChangedInputs[param], nil
        if self.globalOnSet or self.panelInputOnSetHandlers[param] then
            oldValue = Table:Get(DB, param)
        end
        Table:Set(DB, param, newValue)
        if self.panelInputOnSetHandlers[param] and oldValue ~= newValue and not (oldValue == nil and newValue == false) then
            self.panelInputOnSetHandlers[param](newValue)
        end
        self.panelChangedInputs[param] = nil
    end
    if self.debug then
        print("okay " .. self.titleText)
    end
end
function method:Cancel()
    for param in pairs(self.panelChangedInputs) do
        self.panelChangedInputs[param] = nil
    end
    if self.debug then
        print("cancel " .. self.titleText)
    end
end
function method:Refresh()
    if self.active then
        self:SetPanelInputsValues()
    end
    if self.debug then
        print("refresh " .. self.titleText)
    end
end
function method:Default()
    for param in pairs(self.panelInputNames) do
        self.panelChangedInputs[param] = Table:Get(defaultDB, param)
    end
    if self.debug then
        print("default " .. self.titleText)
    end
end
function method:ReleaseTitle()
    if self.titleWidget then
        self.titleWidget:Release()
        self.titleWidget = nil
    end
end
function method:ReleaseContent()
    if self.contentWidget then
        for key in pairs(self.panelInput) do
            self.panelInput[key] = nil
        end
        self.contentWidget:Release()
        self.contentWidget = nil
    end
end
function method:GetName()
    return self.frame.name
end
function method:BuildChildren(childrenConfig)
    local children = {}
    for i = 1, #childrenConfig do
        local config = childrenConfig[i]
        local widget = Widget:Create(config.type, config)
        if config.type == "Container" then
            widget:SetChildren(self:BuildChildren(config.children), config.children)
        end
        table.insert(children, widget)
        if config.param then
            self:ProcessInput(config)
            self.panelInput[config.param] = widget
            widget:AddEventHandler("SetValue", self.panelInputSetValueClosures[config.param])
        end
    end
    return children
end
function method:SetPanelInputsValues()
    for param, widget in pairs(self.panelInput) do
        if self.panelChangedInputs[param] ~= nil then
            widget:SetValue(self.panelChangedInputs[param])
        else
            local value = Table:Get(DB, param)
            if value ~= nil then
                widget:SetValue(value)
            else
                widget:SetValue(nil)
            end
        end
    end
end
Widget:RegisterType("BlizOptionsPanel", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()
    frame:SetScript("OnShow", frame_OnShow)
    frame:SetScript("OnHide", frame_OnHide)

    local widget = {
        frame = frame,
        panelInputNames = {},
        panelChangedInputs = {},
        panelInput = {},
        panelInputOnSetHandlers = {},
        panelInputSetValueClosures = {},
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget = widget

    return widget
end)