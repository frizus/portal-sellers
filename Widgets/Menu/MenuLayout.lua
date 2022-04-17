local addonName, addon = ...
local Widget = addon.Widget

Widget:RegisterLayout("Menu", function(containerWidget)
    local childrenFrame = containerWidget:GetChildrenFrame()
    local children = containerWidget:GetChildren()
    local usedHeight = containerWidget.mt
    local usedWidth = 0
    local maxWidth = containerWidget.maxWidth
    local width

    for _, child in pairs(children) do
        if not child["hidden"] then
            width = math.min(maxWidth, child:GetWidth() or 0)
            if width > usedWidth then usedWidth = width end
        end
    end
    containerWidget:SetWidth(containerWidget.ml + usedWidth + containerWidget.mr)

    for _, child in pairs(children) do
        if not child["hidden"] then
            child:ClearAllPoints()
            child:SetWidth(usedWidth)
            child:SetPoint("TOPLEFT", childrenFrame, "TOPLEFT", containerWidget.ml, -usedHeight)
            child:SetPoint("RIGHT", childrenFrame, "RIGHT", -containerWidget.mr, 0)
            usedHeight = usedHeight + (child:GetHeight() or 0)
            child:Show()
        elseif child:IsShown() then
            child:Hide()
        end
    end

    if containerWidget.AfterLayout then
        usedHeight = usedHeight + containerWidget.mb
        containerWidget:AfterLayout(usedHeight)
    end

    containerWidget:Show()
end)