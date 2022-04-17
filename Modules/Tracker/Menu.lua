local addonName, addon = ...
local TrackerMenu = {}
addon.TrackerMenu = TrackerMenu
local Widget = addon.Widget

function TrackerMenu:CreateMenu(lineWidget)
    if addon.isBusy then
        addon:LockBusy(self.CreateMenuItems, {self, lineWidget})
        return
    end
    addon.busy = true
    if not self.widget then
        self.widget = Widget:Create("Menu", {parent = UIParent})
        self.widget:AddEventHandler("OnHide", self)
    end
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    cursorX = cursorX / uiScale
    cursorY = cursorY / uiScale
    self.widget:ClearAllPoints()
    self.widget:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", cursorX, cursorY)
    self:CreateMenuItems(lineWidget)
    self.widget:Layout()
    self.widget:Show()
    addon.busy = false
end

function TrackerMenu:ReleaseMenu()
    if self.widget then
        self.widget:CleanItems()
        self.widget:Release()
        self.widget = nil
    end
end

function TrackerMenu:OnHide(menu)
    if menu.trackerLine then
        menu.trackerLine:RemoveEventHandler("OnRelease")
        menu.trackerLine = nil
    end
end

function TrackerMenu:TrackerLineOnRelease(trackerLine)
    if self.widget:IsShown() then
        self.widget:Hide()
        self.widget.trackerLine = nil
    end
end

function TrackerMenu:MenuUpdate()
    if self.widget and self.widget:IsShown() then
        if self.widget.trackerLine and addon.Message.trackedMessages[self.widget.trackerLine.id] then
            self.widget:UpdateDynamic()
        end
    end
end

function TrackerMenu:LineOnClick(_, lineWidget, mouseButton)
    if mouseButton == "LeftButton" then
        local control = IsControlKeyDown()
        local shift = IsShiftKeyDown()
        local alt = IsAltKeyDown()
        if control and not shift and not alt then
            self:InviteToParty(lineWidget)
        elseif shift and not control and not alt then
            self:Who(lineWidget)
        elseif alt and not control and not shift then
            self:Delete(lineWidget)
        else
            self:Whisper(lineWidget)
        end
    elseif mouseButton == "RightButton" then
        self:CreateMenu(lineWidget)
    end
end