local addonName, addon = ...
local Widget, DB, defaultDB = addon.Widget, addon.param, addon.DB.default

local function frame_OnShow(self) self.widget:OnShow() end
local function frame_OnHide(self) self.widget:OnHide() end
local function frame_Okay(self) self.widget:Okay() end
local function frame_Cancel(self) self.widget:Cancel() end
local function frame_Refresh(self) self.widget:Refresh() end
local function frame_Default(self) self.widget:Default() end

local method = {}
method.OnAcquire = function(self, options)
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
    self:FindInputNames(options.children)
    self.childrenConfig = options.children
end
method.OnRelease = function(self)
    local f = self.frame
    f.name, f.parent = nil, nil
    f.okay, f.cancel, f.refresh, f.default = nil, nil, nil, nil
    self.titleText, self.childrenConfig = nil, nil
    for name in pairs(self.panelInputNames) do
        self.panelInputNames[name] = nil
    end
    for param in pairs(self.panelChangedInputs) do
        self.panelChangedInputs[param] = nil
    end
    for param in pairs(self.panelInput) do
        self.panelInput[param] = nil
    end
    self:ReleaseTitle()
    self:ReleaseContent()
end
method.OnShow = function(self)
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
method.OnHide = function(self)
    self.active = nil
    self:ReleaseTitle()
    self:ReleaseContent()
    if self.debug then
        print("OnHide " .. self.titleText)
    end
end
method.FindInputNames = function(self, childrenConfig)
    for i = 1, #childrenConfig do
        local config = childrenConfig[i]
        if config.param then
            self.panelInputNames[config.param] = true
        end
        if config.type == "Container" then
            self:FindInputNames(config.children)
        end
    end
end
method.Okay = function(self)
    for param in pairs(self.panelChangedInputs) do
        DB[param] = self.panelChangedInputs[param]
        self.panelChangedInputs[param] = nil
    end
    if self.debug then
        print("okay " .. self.titleText)
    end
end
method.Cancel = function(self)
    for param in pairs(self.panelChangedInputs) do
        self.panelChangedInputs[param] = nil
    end
    if self.debug then
        print("cancel " .. self.titleText)
    end
end
method.Refresh = function(self)
    if self.active then
        self:SetPanelInputsValues()
    end
    if self.debug then
        print("refresh " .. self.titleText)
    end
end
method.Default = function(self)
    for param in pairs(self.panelInputNames) do
        self.panelChangedInputs[param] = defaultDB[param]
    end
    if self.debug then
        print("default " .. self.titleText)
    end
end
method.ReleaseTitle = function(self)
    if self.titleWidget then
        self.titleWidget:Release()
        self.titleWidget = nil
    end
end
method.ReleaseContent = function(self)
    if self.contentWidget then
        for key in pairs(self.panelInput) do
            self.panelInput[key] = nil
        end
        self.contentWidget:Release()
        self.contentWidget = nil
    end
end
method.GetName = function(self)
    return self.frame.name
end
method.BuildChildren = function(self, childrenConfig)
    local children = {}
    for i = 1, #childrenConfig do
        local config = childrenConfig[i]
        local widget = Widget:Create(config.type, config)
        if config.type == "Container" then
            widget:SetChildren(self:BuildChildren(config.children), config.children)
        end
        table.insert(children, widget)
        if config.param then
            self.panelInput[config.param] = widget
            widget:AddEventHandler("SetValue", function(input)
                self.panelChangedInputs[config.param] = input:GetValue()
            end)
        end
    end
    return children
end
method.SetPanelInputsValues = function(self)
    for param, widget in pairs(self.panelInput) do
        if self.panelChangedInputs[param] ~= nil then
            widget:SetValue(self.panelChangedInputs[param])
        elseif DB[param] ~= nil then
            widget:SetValue(DB[param])
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
    }
    widget.panelInputNames = {}
    widget.panelChangedInputs = {}
    widget.panelInput = {}
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget = widget

    return widget
end)