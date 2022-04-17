local addonName, addon = ...
local TrackerList = {}
addon.TrackerList = TrackerList
local Widget, Table, DB = addon.Widget, addon.Table, addon.param

function TrackerList:ConstructTracker()
    self.linesWidget = Widget:Create("Container", {
        parent = self.frame,
        type = "Container",
        layout = "Tracker",
        scroll = "TrackerScrollFrame",
    })
    self.linesWidget.order = {}
    self.linesWidget:SetPoint("TOPLEFT", self.topArea, "BOTTOMLEFT", 5, -1)
    self.linesWidget:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -5, 11)
    self.childOptions = {parent = self.linesWidget:GetChildrenFrame(), base = self}
    self.fillChildOptions = {parent = self.childOptions["parent"], base = self.childOptions["base"], fill = true}
end
function TrackerList:Tick(changed, messages)
    local children = self.linesWidget:GetChildren()
    local now = GetTime()
    if not changed then
        for _, line in pairs(children) do line:Tick(nil, now) end
    elseif not changed["add"] and not changed["delete"] and
            (changed["update"] or changed["who"]) and
            not changed["updateIds"] and
            not changed["whoIds"]
    then
        for _, line in pairs(children) do line:Tick(nil, now) end
        self.linesWidget.order = Table:GetSortedKeys(messages, "updated", false)
    else
        if changed["delete"] then
            for id in pairs(changed["deleteIds"]) do
                children[id]:Release()
                children[id] = nil
                changed["deleteIds"][id] = nil
            end
        end

        local update
        for id, message in pairs(messages) do
            if not children[id] then
                children[id] = Widget:Create("TrackerLine", self.childOptions)
                children[id]:Tick(true, now, id)
            else
                update = changed["updateIds"] and changed["updateIds"][id]
                if not update then
                    update = changed["whoIds"] and changed["whoIds"][message["playerInfo"]["name"]]
                end
                children[id]:Tick(update, now)
            end
        end

        self.linesWidget.order = Table:GetSortedKeys(messages, "updated", false)
    end
    Widget:Layout(self.linesWidget)
end
function TrackerList:Fill(changed, messages)
    if self.filled then return end
    self.filled = true
    self.linesWidget:ReleaseChildren()
    local children = self.linesWidget:GetChildren()
    local now = GetTime()
    for id in pairs(messages) do
        children[id] = Widget:Create("TrackerLine", (changed and changed["addIds"] and changed["addIds"][id]) and self.childOptions or self.fillChildOptions)
        children[id]:Tick(true, now, id)
    end
    self.linesWidget.order = Table:GetSortedKeys(messages, "updated", false)
    Widget:Layout(self.linesWidget)
end
function TrackerList:Update(messages, updateOutput, updateFontSize)
    local children = self.linesWidget:GetChildren()
    for _, line in pairs(children) do
        if updateOutput then line:Tick(true) end
        if updateFontSize then line:UpdateFontSize() end
    end
    self.linesWidget.order = Table:GetSortedKeys(messages, "updated", false)
    Widget:Layout(self.linesWidget)
end
function TrackerList:CleanLines()
    self.linesWidget:ReleaseChildren()
    wipe(self.linesWidget.order)
    Widget:Layout(self.linesWidget)
end
function TrackerList:ReleaseTracker()
    self.listWidth, self.listHeight = nil, nil
    self.filled = nil
    self:CleanLines()
end
function TrackerList:SetListWidth(value, fill)
    if fill then
        self.linesWidget:SetWidth(value)
        self.listWidth = "fill"
        return true
    end
    if self.listWidth ~= value then
        self.listWidth = value
        if value and value ~= "fill" then
            self.linesWidget:SetWidth(value)
        end
        return true
    end
end
function TrackerList:SetListHeight(value)
    if self.listHeight ~= value then
        self.listHeight = value
        if value then
            self.linesWidget:SetHeight(value)
        end
        return true
    end
end
function TrackerList:UpdateListLayout()
    Widget:Layout(self.linesWidget)
end

Widget:RegisterLayout("Tracker", function(containerWidget)
    local childrenFrame = containerWidget:GetChildrenFrame()
    local children = containerWidget:GetChildren()
    local order = containerWidget.order
    local contentWidth = containerWidget:GetContentWidth()
    local usedHeight = containerWidget.mt

    for _, id in pairs(order) do
        local child = children[id]
        child:ClearAllPoints()
        child:SetWidth(contentWidth, true)
        child:SetPoint("TOPLEFT", childrenFrame, "TOPLEFT", containerWidget.ml, -usedHeight)
        child:SetPoint("RIGHT", childrenFrame, "RIGHT", -containerWidget.mr, 0)
        usedHeight = usedHeight + (child:GetHeight() or 0)
        child:Show()
        child:Blink()
    end

    if containerWidget.AfterLayout then
        containerWidget:AfterLayout(usedHeight)
    end

    containerWidget:Show()
end)