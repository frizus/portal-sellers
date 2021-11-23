local addonName, addon = ...
local Minimap = {}
addon.Minimap = Minimap

function Minimap:Create()
    addon.Widget:Create("TritonMinimapPin", {
        minimapFrame = _G["Minimap"],
        params = addon.param.minimap,
        onPinClick = function(...) self:OnClick(...) end,
        trackerWindowIsShown = function()
            -- TODO realisation
            return random(0,1) == 1
        end
    })
end

function Minimap:OnClick(button, mouseButton)
    if mouseButton == "LeftButton" then
        print("show tracker window")
    end
end