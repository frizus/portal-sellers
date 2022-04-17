local addonName, addon = ...
local Widget = addon.Widget

local method = {}
function method:OnAcquire(options)
    self:SetParent(options.parent)
    self:SetWidth(options.width or "fill")
    self:SetFontObject(options.font or GameFontHighlightSmall)
    self.fontString:SetText(options.text)
end
function method:OnRelease()
    if self.fontString:GetText() then
        self.fontString:SetText(nil)
    end
end
function method:SetFontObject(font)
    local lastFont = self.fontString:GetFontObject()
    if lastFont ~= font then
        self.fontString:SetFontObject(font)
    end
    if not self.noCJK or lastFont ~= font then
        self.noCJK = true
        self.fontString:SetFont(font:GetFont())
    end
end
function method:SetWidth(value, fill)
    if fill then
        self.frame:SetWidth(value)
        self.fontString:SetWidth(value)
        self:SetHeightNotTruncated()
        self.width = "fill"
    else
        if self.width ~= value then
            self.width = value
            if value and value ~= "fill" then
                self.frame:SetWidth(value)
                self.fontString:SetWidth(value)
                self:SetHeightNotTruncated()
            end
        end
    end
end
function method:SetHeight(value)
    if self.height ~= value then
        self.height = value
        if value then
            self.frame:SetHeight(value)
        end
    end
    if value then
        self.fontString:SetHeight(value)
    end
end
function method:GetHeight()
    return self.fontString:GetStringHeight()
end
function method:SetHeightNotTruncated()
    self.fontString:SetHeight(self.fontString:GetStringHeight() + 2000)
    self:SetHeight(self.fontString:GetStringHeight())
end

Widget:RegisterType("Text", function()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()
    frame:SetHeight(1)

    local fontString = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    fontString:SetNonSpaceWrap(true)
    fontString:SetPoint("TOPLEFT")

    local widget = {
        frame = frame,
        fontString = fontString,
    }
    for name, closure in pairs(method) do
        widget[name] = closure
    end

    return widget
end)