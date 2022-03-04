local addonName, addon = ...
local Minimap = {}
addon.Minimap = Minimap
local Widget, L = addon.Widget, addon.L

local mainInterfaceCategory = string.format(
    L["bliz_options_panel_name"],
    GetAddOnMetadata(addonName, "Title")
)

function Minimap:Create()
    local minimapPin = Widget:Create("MinimapPin", {
        trackerWindowIsShown = function()
            -- TODO realisation
            return random(0,1) == 1
        end
    })
    minimapPin:AddEventHandler("OnClick", self.OnClick)
    minimapPin:Show()
end

function Minimap:OnClick(mouseButton)
    if mouseButton == "LeftButton" then
        InterfaceOptionsFrame_Show()
        InterfaceOptionsFrame_OpenToCategory(mainInterfaceCategory)
    end
end