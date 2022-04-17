local addonName, addon = ...
local ScrollFrameBasic = {}
addon.ScrollFrameBasic = ScrollFrameBasic

function ScrollFrameBasic:OnAcquire(options)
    self:SetParent(options.parent)
    self.scrollFrame.ScrollBar:Hide()
end
function ScrollFrameBasic:OnRelease()
    self.scrollShown = nil
    self.contentWidth = nil
end
function ScrollFrameBasic:GetContentFrame()
    return self.content
end
function ScrollFrameBasic:SetWidth(value, fill)
    if fill then
        self.frame:SetWidth(value)
        self.width = "fill"
    else
        if self.width ~= value then
            self.width = value
            if value and value ~= "fill" then
                self.frame:SetWidth(value)
                self:CalculateContentWidth()
            end
        end
    end
end
function ScrollFrameBasic:SetHeight(value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
end
function ScrollFrameBasic:CalculateContentWidth()
    local frameWidth = self.frame:GetWidth()
    local lastWidth = self.contentWidth

    if frameWidth then
        self.contentWidth = self.scrollShown and (frameWidth - self.scrollWidth) or frameWidth
        if lastWidth ~= self.contentWidth then
            self.content:SetWidth(self.contentWidth)
        end
    end
end
function ScrollFrameBasic:GetContentWidth()
    if not self.contentWidth then
        self:CalculateContentWidth()
    end
    return self.contentWidth
end
function ScrollFrameBasic:GetContentHeight()
    return self:GetHeight()
end
function ScrollFrameBasic:ScrollToggled(contentHeight)
    self.content:SetHeight(contentHeight)
    local viewHeight = self:GetHeight()

    if contentHeight > (viewHeight + 1) then
        if not self.scrollShown then
            self.scrollShown = true
            self.scrollFrame.ScrollBar:Show()
            self:CalculateContentWidth()
            return true
        end
    else
        if self.scrollShown then
            self.scrollShown = false
            self.scrollFrame.ScrollBar:Hide()
            self:CalculateContentWidth()
            return true
        elseif self.scrollShown == nil then
            self.scrollShown = false
            self:CalculateContentWidth()
        end
    end

    return false
end