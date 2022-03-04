local addonName, addon = ...
local Widget = {}
addon.Widget = Widget
local widgetBase

Widget.objPools = {}
Widget.widgetRegistry = {}
Widget.layoutRegistry = {}

function Widget:Create(type, options)
    local widget = self:NewWidget(type)
    if widget.OnAcquire then
        widget:OnAcquire(options)
    end

    return widget
end

function Widget:RegisterType(name, constructor)
    self.widgetRegistry[name] = constructor
end

function Widget:RegisterLayout(name, closure)
    self.layoutRegistry[name] = closure
end

function Widget:Layout(widget)
    if self.layoutRegistry[widget.layout] then
        self.layoutRegistry[widget.layout](widget)
    end
end

function Widget:NewWidget(type)
    if not self.widgetRegistry[type] then
        error("Attempt to instantiate unknown widget type", 2)
    end

    if not self.objPools[type] then
        self.objPools[type] = {}
    end

    local newObj = next(self.objPools[type])
    if not newObj then
        newObj = self.widgetRegistry[type]()
        setmetatable(newObj, {__index = widgetBase})
        newObj.handlers = {}
        newObj.type = type
    else
        self.objPools[type][newObj] = nil
    end

    return newObj
end

function Widget:ReleaseWidget(widget)
    local f = widget.frame
    f:Hide()

    if widget.OnRelease then
        widget:OnRelease()
    end

    for eventName in pairs(widget.handlers) do
        widget.handlers[eventName] = nil
    end
    f:ClearAllPoints()
    f:Hide()
    f:SetParent(nil)
    f:SetParent(UIParent)
    f.width, f.height = nil, nil

    if self.objPools[widget.type] then
        self.objPools[widget.type][widget] = true
    end
end

widgetBase = {}
widgetBase.Release = function(self)
    Widget:ReleaseWidget(self)
end
widgetBase.GetFrame = function(self)
    return self.frame
end
widgetBase.AddEventHandler = function(self, eventName, closure)
    if not self.handlers[eventName] then
        self.handlers[eventName] = {}
    end
    table.insert(self.handlers[eventName], closure)
end
widgetBase.TriggerEvent = function(self, eventName, ...)
    if self.handlers[eventName] then
        for i = 1, #self.handlers[eventName] do
            local result = self.handlers[eventName][i](self, ...)
            if result == false then
                return false
            end
        end
    end

    return true
end
widgetBase.SetParent = function(self, parent)
    if parent then
        local frame = self.frame
        if frame:GetParent() ~= parent then
            frame:SetParent(nil)
            frame:SetParent(parent)
        end
    end
end
widgetBase.SetWidth = function(self, value, fill)
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
end
widgetBase.SetHeight = function(self, value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
end
local frameMethods = {
    "ClearAllPoints",
    "SetPoint",
    "Show",
    "Hide",
    "GetWidth",
    "GetHeight",
    "GetParent",
}
for i = 1, #frameMethods do
    widgetBase[frameMethods[i]] = function(self, ...)
        return self.frame[frameMethods[i]](self.frame, ...)
    end
end

local function trigger_OnEnter(self)
    self.widget:ShowTooltip()
end
local function trigger_OnLeave(self)
    self.widget:HideTooltip()
end
widgetBase.InitTooltip = function(self, trigger, title, tooltip)
    if type(title) == "function" then
        trigger:SetScript("OnEnter", title)
        trigger:SetScript("OnLeave", trigger_OnLeave)
    else
        if tooltip and tooltip ~= "" then
            self.title = title
            self.tooltip = tooltip
            trigger:SetScript("OnEnter", trigger_OnEnter)
            trigger:SetScript("OnLeave", trigger_OnLeave)
        end
    end

end
widgetBase.RemoveTooltip = function(self, trigger)
    self.title = nil
    self.tooltip = nil
    trigger:SetScript("OnEnter", nil)
    trigger:SetScript("OnLeave", nil)
    self:HideTooltip()
end
widgetBase.ShowTooltip = function(self)
    GameTooltip:SetOwner(self.frame, "ANCHOR_TOPRIGHT")
    GameTooltip_AddNormalLine(GameTooltip, self.title, true)
    GameTooltip_AddColoredLine(GameTooltip, self.tooltip, TOOLTIP_DEFAULT_COLOR, true)
    GameTooltip:Show()
end
widgetBase.HideTooltip = function(self)
    if GameTooltip:GetOwner() == self.frame and GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end


local fastBase = {}
fastBase.Release = function(self)
    Widget:FastRelease(self)
end

Widget.fastPools = {}

function Widget:FastCreate(type, options, constructor)
    if not self.fastPools[type] then
        self.fastPools[type] = {}
    end

    local newObj = next(self.fastPools[type])
    if not newObj then
        newObj = constructor(options)
        newObj.Release = fastBase.Release
        newObj.type = type
    else
        self.fastPools[type][newObj] = nil
    end

    return newObj
end

function Widget:FastReleaseAndDelete(widget)
    widget:ClearAllPoints()

    if self.fastPools[widget.type] then
        self.fastPools[widget.type][widget] = true
    end
end

Widget:RegisterLayout("Flow", function(containerWidget)
    local containerWidth = containerWidget:GetWidth()
    local childrenFrame = containerWidget:GetChildrenFrame()
    local children = containerWidget:GetChildren()
    local contentWidth = containerWidget:GetContentWidth() - containerWidget.ml - containerWidget.mr
    local rowsExtraSpace = 3
    local rowMaxHeight = 0
    local usedHeight = containerWidget.mt
    local usedRowWidth = 0

    for i = 1, #children do
        local child = children[i]
        local width = child.width or child:GetWidth() or 0

        child:ClearAllPoints()
        if width == "fill" then
            child:SetWidth(contentWidth - child.ml - child.mr, true)
            usedHeight = usedHeight + (rowMaxHeight > 0 and (rowMaxHeight + rowsExtraSpace) or 0)
            child:SetPoint("TOPLEFT", childrenFrame, "TOPLEFT", containerWidget.ml + child.ml, -(usedHeight + child.mt))
            child:SetPoint("RIGHT", childrenFrame, "RIGHT", -containerWidget.mr - child.mr, 0)
            if child.layout then
                Widget:Layout(child)
            end
            rowMaxHeight = (child.height or child:GetHeight() or 0) + child.mt
            usedRowWidth = 0
        else
            -- add in row
            if i > 1 and usedRowWidth > 0 and (usedRowWidth + width) <= containerWidth then
                child:SetWidth(width - child.ml - child.mr)
                child:SetPoint("TOPLEFT", children[i-1]:GetFrame(), "TOPRIGHT", child.ml, child.mt)
                usedRowWidth = usedRowWidth + width
                if child.layout then
                    Widget:Layout(child)
                end
                rowMaxHeight = math.max(rowMaxHeight, (child.height or child:GetHeight() or 0) + child.mt)
            else -- new row
                -- second or subsequent row
                usedHeight = usedHeight + (children[i-1] and (rowMaxHeight + rowsExtraSpace) or 0)
                child:SetWidth(width - child.ml - child.mr)
                child:SetPoint("TOPLEFT", childrenFrame, "TOPLEFT", containerWidget.ml + child.ml, -(usedHeight + child.mt))
                if usedRowWidth > contentWidth and contentWidth > 1 then
                    child:SetPoint("RIGHT", childrenFrame, "RIGHT", -containerWidget.mr - child.mr, 0)
                    usedRowWidth = 0
                else
                    usedRowWidth = width
                end
                if child.layout then
                    Widget:Layout(child)
                end
                rowMaxHeight = (child.height or child:GetHeight() or 0) + child.mt
            end
        end

        child:Show()
    end

    if containerWidget.AfterLayout then
        containerWidget:AfterLayout(usedHeight + (rowMaxHeight > 0 and rowMaxHeight or 0))
    end

    containerWidget:Show()
end)