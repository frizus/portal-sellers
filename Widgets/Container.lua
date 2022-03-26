local addonName, addon = ...
local Widget = addon.Widget
local Table = addon.Table

local method = {}
method.OnAcquire = function(self, options)
    self:SetParent(options.parent)
    self.layout = options.layout
    self:SetWidth(options.width or "fill")
    self.maxHeight = options.scroll and options.maxHeight or nil
    self:Scroll(options.scroll)
    self.mt = options.marginTop or 0
    self.mr = options.marginRight or 0
    self.ml = options.marginLeft or 0
end
method.OnRelease = function(self)
    self.mt, self.mr, self.ml = nil, nil, nil
    self.layout, self.haveScroll = nil, nil
    self:ReleaseChildren()
    self:ReleaseScroll()
end
method.ReleaseChildren = function(self)
    if Table:NotEmpty(self.children) then
        for i = 1, #self.children do
            local child = self.children[i]
            child.mt, child.mr, child.ml = nil, nil, nil
            child:Release()
            self.children[i] = nil
        end
    end
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
    if self.haveScroll then
        self.scrollWidget:SetWidth(value)
    end
end
method.SetHeight = function(self, value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
    if self.haveScroll then
        self.scrollWidget:SetHeight(value)
    end
end
method.GetContentWidth = function(self)
    if self.haveScroll then
        return self.scrollWidget:GetContentWidth()
    end
    return self.frame:GetWidth()
end
method.GetContentHeight = function(self)
    return self:GetHeight()
end
method.GetChildrenFrame = function(self)
    return self.haveScroll and self.scrollWidget:GetContentFrame() or self.frame
end
method.GetChildren = function(self)
    return self.children
end
method.SetChildren = function(self, children, layoutConfig)
    self:ReleaseChildren()
    local childrenFrame = self:GetChildrenFrame()
    for i, child in ipairs(children) do
        local config = layoutConfig[i]
        child:SetParent(childrenFrame)
        child.mt = config.marginTop or 0
        child.mr = config.marginRight or 0
        child.ml = config.marginLeft or 0
        table.insert(self.children, child)
    end
end
method.Scroll = function(self, haveScroll)
    if haveScroll then
        self.haveScroll = true
        if not self.scrollWidget then
            self.scrollWidget = Widget:Create("ScrollFrame", {
                parent = self.frame,
            })
            self.scrollWidget:SetPoint("TOPLEFT")
            self.scrollWidget:SetPoint("BOTTOMRIGHT")
        end
    else
        self.haveScroll = nil
        self:ReleaseScroll()
    end
end
method.ReleaseScroll = function(self)
    if self.scrollWidget then
        self.scrollWidget:Release()
        self.scrollWidget = nil
    end
end
method.Show = function(self)
    if self.haveScroll then
        self.scrollWidget:Show()
    end
    self.frame:Show()
end
method.Hide = function(self)
    if self.haveScroll then
        self.scrollWidget:Hide()
    end
    self.frame:Hide()
end
method.AfterLayout = function(self, height)
    if self.maxHeight then
        self:SetHeight(math.min(self.maxHeight, height))
    else
        self:SetHeight(height)
    end

    if self.haveScroll then
        if self.scrollWidget:ScrollToggled(height) then
            Widget:Layout(self)
        end
    end
end

Widget:RegisterType("Container", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    local widget = {
        frame = frame,
        children = {},
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end
    frame.widget = widget

    return widget
end)