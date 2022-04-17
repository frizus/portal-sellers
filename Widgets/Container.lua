local addonName, addon = ...
local Widget = addon.Widget
local Table = addon.Table

local method = {}
function method:OnAcquire(options)
    self:SetParent(options.parent)
    self.layout = options.layout
    self:SetWidth(options.width or "fill")
    self.maxHeight = options.scroll and options.maxHeight or nil
    self:Scroll(options.scroll)
    self.mt = options.marginTop or 0
    self.mr = options.marginRight or 0
    self.ml = options.marginLeft or 0
    self.mb = options.marginBottom or 0
end
function method:OnRelease()
    self.mt, self.mr, self.ml, self.mb = nil, nil, nil, nil
    self.layout, self.haveScroll = nil, nil
    self:ReleaseChildren()
    self:ReleaseScroll()
end
function method:ReleaseChildren()
    for i, child in pairs(self.children) do
        child.mt, child.mr, child.ml = nil, nil, nil
        child:Release()
        self.children[i] = nil
    end
end
function method:SetWidth(value, fill)
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
        self.scrollWidget:CalculateContentWidth()
    end
end
function method:SetHeight(value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
    if self.haveScroll then
        self.scrollWidget:CalculateContentWidth()
    end
end
function method:GetContentWidth()
    if self.haveScroll then
        return self.scrollWidget:GetContentWidth()
    end
    return self.frame:GetWidth()
end
function method:GetContentHeight()
    return self:GetHeight()
end
function method:GetChildrenFrame()
    return self.haveScroll and self.scrollWidget:GetContentFrame() or self.frame
end
function method:GetChildren()
    return self.children
end
function method:SetChildren(children, layoutConfig)
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
function method:Scroll(haveScroll)
    if haveScroll then
        self.haveScroll = true
        if not self.scrollWidget then
            self.scrollWidget = Widget:Create(type(haveScroll) == "string" and haveScroll or "ScrollFrame", {parent = self.frame})
            self.scrollWidget:SetPoint("TOPLEFT")
            self.scrollWidget:SetPoint("BOTTOMRIGHT")
        end
    else
        self.haveScroll = nil
        self:ReleaseScroll()
    end
end
function method:ReleaseScroll()
    if self.scrollWidget then
        self.scrollWidget:Release()
        self.scrollWidget = nil
    end
end
function method:Show()
    if self.haveScroll then
        self.scrollWidget:Show()
    end
    self.frame:Show()
end
function method:Hide()
    if self.haveScroll then
        self.scrollWidget:Hide()
    end
    self.frame:Hide()
end
function method:AfterLayout(height)
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