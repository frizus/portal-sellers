local addonName, addon = ...
local TrackerMenu = addon.TrackerMenu
local L, DB = addon.L, addon.param
local Widget, Table = addon.Widget, addon.Table

local RACE_ICON_TCOORDS_LOCAL
if not RACE_ICON_TCOORDS then
    RACE_ICON_TCOORDS_LOCAL = {
        ["HUMAN_MALE"]		= {0, 0.125, 0, 0.25},
        ["DWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
        ["GNOME_MALE"]		= {0.25, 0.375, 0, 0.25},
        ["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.25},

        ["TAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
        ["SCOURGE_MALE"]	= {0.125, 0.25, 0.25, 0.5},
        ["TROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
        ["ORC_MALE"]		= {0.375, 0.5, 0.25, 0.5},

        ["HUMAN_FEMALE"]	= {0, 0.125, 0.5, 0.75},
        ["DWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},
        ["GNOME_FEMALE"]	= {0.25, 0.375, 0.5, 0.75},
        ["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},

        ["TAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},
        ["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.75, 1.0},
        ["TROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0},
        ["ORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0},

        ["BLOODELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
        ["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0},

        ["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
        ["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75},
    }
else
    RACE_ICON_TCOORDS_LOCAL = RACE_ICON_TCOORDS
end
local raceTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES"
local RACE, rw, rh = {}, 128, 128
for raceIcon, c in pairs(RACE_ICON_TCOORDS_LOCAL) do
    RACE[raceIcon] = {
        c[1] * rw,
        c[2] * rw,
        c[3] * rh,
        c[4] * rh,
    }
end

local classTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
local CLASS, cw, ch = {}, 128, 128
for class, c in pairs(CLASS_ICON_TCOORDS) do
    CLASS[class] = {
        c[1] * cw,
        c[2] * cw,
        c[3] * ch,
        c[4] * ch,
    }
end

local menuTitle = 1
local raceClassWho = 2
local playerArea = 3
local matchInfo = 4
local similars = 5
local ignore = 12
local addFriend = 13

function TrackerMenu:CreateMenuItems(lineWidget)
    if not self.menuItems then
        local menuItemsOptions = {
            {
                isText = true,
            },
            {
                isText = true,
                dynamic = function(widget)
                    local message = addon.Message.trackedMessages[widget.menuWidget.trackerLine.id]
                    local playerInfo = message["playerInfo"]
                    local who = addon.Message.who[message["playerInfo"]["name"]]
                    local level = who and who["level"] or false
                    if widget.level ~= level then
                        widget.level = level

                        local c = CLASS[playerInfo["class"]]
                        local r = RACE[playerInfo["raceIcon"]]
                        local text = "|T" .. classTexture .. ":16:16:0:0:" .. cw .. ":" .. ch .. ":" .. c[1] .. ":" .. c[2] .. ":" .. c[3] .. ":" .. c[4] .. "|t"
                        text = text .. " |T" .. raceTexture .. ":16:16:0:0:" .. rw .. ":" .. rh .. ":" .. r[1] .. ":" .. r[2] .. ":" .. r[3] .. ":" .. r[4] .. "|t"
                        local tooltip = playerInfo["localizedClass"] .. ", " .. playerInfo["localizedRace"]
                        if widget.level then
                            tooltip = tooltip .. " " .. widget.level .. " " .. L["level_abbr"]
                            text = text .. " |cffffd100" .. widget.level .. " " .. L["level_abbr"] .. "|r"
                        end
                        widget:SetTooltip(tooltip)
                        widget:SetText(text)
                    end
                end,
                params = {
                    level = true,
                },
            },
            {
                isText = true,
                textColor = "ffcfcfcf",
                dynamic = function(widget)
                    local message = addon.Message.trackedMessages[widget.menuWidget.trackerLine.id]
                    local who = addon.Message.who[message["playerInfo"]["name"]]
                    local area = who and who["area"] or false
                    if area then
                        if widget.area ~= area then
                            widget.area = area
                            widget:SetText(widget.area)
                            if widget:IsHidden() then
                                if not widget.menuWidget.refreshLayout then
                                    widget.menuWidget.refreshLayout = true
                                end
                                widget:SetHidden(false)
                            end
                        end
                    elseif not widget:IsHidden() then
                        if not widget.menuWidget.refreshLayout then
                            widget.menuWidget.refreshLayout = true
                        end
                        widget:SetHidden(true)
                    end
                end,
                params = {
                    area = true,
                },
            },
            {
                isText = true,
            },
            {
                textColor = "ffffffaa",
                submenuItemsDynamic = function(widget, subItems, submenu)
                    local message = addon.Message.trackedMessages[widget.menuWidget.trackerLine.id]
                    local subItemsLen = #subItems
                    if subItemsLen ~= 0 and message["variantsSorted"] then
                        if message["variantsLen"] < subItemsLen then
                            for i = message["variantsLen"] + 1, subItemsLen do
                                subItems[i]:Release()
                                subItems[i] = nil
                            end
                        end
                        local now = GetTime()
                        for i, subItem in ipairs(subItems) do
                            subItem:SetText(widget.menuWidget.trackerLine:SimilarGlue(subItem, i, now, message["variants"][message["variantsOrder"][i]]["updated"]))
                        end
                        return nil, subItems
                    end

                    addon.Message:VariantsSort(message)
                    local itemsFrame = submenu:GetContainerFrame()
                    local newSubItems = {}
                    for i, id in pairs(message["variantsOrder"]) do
                        local have
                        for j, subItem in pairs(subItems) do
                            if id == subItem.variantId then
                                table.insert(newSubItems, subItem)
                                subItems[j] = nil
                                have = true
                                break
                            end
                        end
                        if not have then
                            local similar = widget.menuWidget.trackerLine:Similar(message, id, i)
                            similar["parent"] = itemsFrame
                            similar["menuWidget"] = submenu
                            table.insert(newSubItems, Widget:Create("MenuItem", similar))
                        end
                    end
                    for i, subItem in pairs(subItems) do
                        subItem:Release()
                        subItems[i] = nil
                    end
                    local now = GetTime()
                    for i, newSubItem in ipairs(newSubItems) do
                        newSubItem:SetText(widget.menuWidget.trackerLine:SimilarGlue(newSubItem, i, now, message["variants"][message["variantsOrder"][i]]["updated"]))
                    end
                    return true, newSubItems
                end,
                dynamic = function(widget)
                    local message = addon.Message.trackedMessages[widget.menuWidget.trackerLine.id]
                    if not DB.trackerHideSimilarMessages and message["variantsLen"] > 1 then
                        if widget.lastVariantsLen ~= message["variantsLen"] then
                            widget.lastVariantsLen = message["variantsLen"]
                            widget:SetText(
                                    string.format(L["tracker_menu_similars"],
                                            message["variantsLen"] - 1
                                    )
                            )
                            if widget:IsHidden() then
                                if not widget.menuWidget.refreshLayout then
                                    widget.menuWidget.refreshLayout = true
                                end
                                widget:SetHidden(false)
                            end
                        end
                    elseif not widget:IsHidden() then
                        if not widget.menuWidget.refreshLayout then
                            widget.menuWidget.refreshLayout = true
                        end
                        widget:SetHidden(true)
                    end
                end,
                params = {
                    lastVariantsLen = false,
                    variantId = true,
                    text1 = true,
                    text2 = true,
                },
                hidden = true,
            },
            {
                separator = true,
            },
            {
                text = L["tracker_menu_choose_option"],
                textColor = "ffffd100",
                isText = true,
            },
            {
                text = L["tracker_menu_invite_to_party"],
                desc = L["tracker_menu_invite_to_party_hotkey"],
                callback = function(widget)
                    self:InviteToParty(widget.menuWidget.trackerLine)
                end,
            },
            {
                text = L["tracker_menu_whisper"],
                callback = function(widget)
                    self:Whisper(widget.menuWidget.trackerLine)
                end,
            },
            {
                text = L["tracker_menu_who"],
                desc = L["tracker_menu_who_hotkey"],
                callback = function(widget)
                    self:Who(widget.menuWidget.trackerLine)
                end,
            },
            {
                text = L["tracker_menu_copy_user_name"],
                callback = function(widget)
                    self:CopyUserName(widget.menuWidget.trackerLine)
                end,
            },
            {
                text = L["tracker_menu_block_user"],
                params = {
                    added = false,
                },
                callback = function(widget)
                    if not widget.added then
                        self:BlockUser(widget.menuWidget.trackerLine)
                    else
                        self:UnblockUser(widget.menuWidget.trackerLine)
                    end
                end
            },
            {
                text = L["tracker_menu_add_friend"],
                params = {
                    added = false,
                },
                callback = function(widget)
                    if not widget.added then
                        self:AddFriend(widget.menuWidget.trackerLine)
                    else
                        self:RemoveFriend(widget.menuWidget.trackerLine)
                    end
                end
            },
            {
                text = L["tracker_menu_user_spam_score"],
                callback = function(widget)
                    self:UserSpamScore(widget.menuWidget.trackerLine)
                end
            },
            {
                text = L["tracker_menu_delete"],
                desc = L["tracker_menu_delete_hotkey"],
                callback = function(widget)
                    self:Delete(widget.menuWidget.trackerLine)
                end
            },
            {
                text = L["tracker_menu_cancel"],
            }
        }
        local itemsFrame = self.widget:GetContainerFrame()
        self.menuItems = {}
        for _, itemOptions in pairs(menuItemsOptions) do
            itemOptions["parent"] = itemsFrame
            itemOptions["menuWidget"] = self.widget
            table.insert(self.menuItems, Widget:Create("MenuItem", itemOptions))
        end
    end
    local message
    if self.widget.trackerLine then
        self.widget.trackerLine:RemoveEventHandler("OnRelease")
        self.widget.trackerLine = nil
    end
    self.widget.trackerLine = lineWidget
    lineWidget:AddEventHandler("OnRelease", self, "TrackerLineOnRelease")
    message = addon.Message.trackedMessages[lineWidget.id]

    local playerInfo = message["playerInfo"]
    self.menuItems[menuTitle]:SetText("|c" .. RAID_CLASS_COLORS[playerInfo["class"]]["colorStr"] .. playerInfo["name"] .. "|r")

    self.menuItems[raceClassWho]:ResetParam("level")
    self.menuItems[playerArea]:ResetParam("area")

    local alias = DB.filterGroups[message["matchInfo"]["filterGroupKey"]]["alias"]
    if alias then
        self.menuItems[matchInfo]:SetText("|cff889f9f" .. alias .. "|r")
    else
        self.menuItems[matchInfo]:SetText("|cffffff00" .. message["matchInfo"]["wordGroup"] .. "|r")
    end

    self.menuItems[similars]:ResetParam("lastVariantsLen")

    local ignored = C_FriendList.IsIgnored(message["playerInfo"]["name"])
    if self.menuItems[ignore].added then
        if not ignored then
            self.menuItems[ignore].added = false
            self.menuItems[ignore]:SetText(L["tracker_menu_block_user"])
        end
    else
        if ignored then
            self.menuItems[ignore].added = true
            self.menuItems[ignore]:SetText(L["tracker_menu_unblock_user"])
        end
    end

    local isFriend = C_FriendList.IsFriend(message["playerInfo"]["guid"])
    if self.menuItems[addFriend].added then
        if not isFriend then
            self.menuItems[addFriend].added = false
            self.menuItems[addFriend]:SetText(L["tracker_menu_add_friend"])
        end
    else
        if isFriend then
            self.menuItems[addFriend].added = true
            self.menuItems[addFriend]:SetText(L["tracker_menu_remove_friend"])
        end
    end
    self.widget:SetItems(self.menuItems)
end