local addonName, addon = ...
local TrackerMenu = addon.TrackerMenu
local Chat, L = addon.Chat, addon.L

function TrackerMenu:InviteToParty(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if message then InviteUnit(message["playerInfo"]["nameRealm"]) end
end

function TrackerMenu:Who(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if not message then return end
    addon.Message.requestedWho = message["playerInfo"]["name"]
    addon.Message.requestedWhoRealm = message["playerInfo"]["nameRealm"]
    addon.Message:BindWhoEvents()
    -- https://www.wowinterface.com/forums/showthread.php?t=41521
    local whoFrameText = WhoFrameEditBox:GetText()
    local whoFrameCursorPosition, start, finish
    if WhoFrameEditBox:HasFocus() then
        whoFrameCursorPosition = WhoFrameEditBox:GetCursorPosition()
        if whoFrameText and whoFrameText ~= "" then
            WhoFrameEditBox:Insert("")
            local textNew, cursorNew = WhoFrameEditBox:GetText(), WhoFrameEditBox:GetCursorPosition()
            start, finish = cursorNew, #whoFrameText - (#textNew - cursorNew)
        end
    end
    Chat:SendText(SLASH_WHO1 .. " " .. WHO_TAG_NAME .. message["playerInfo"]["nameRealm"])
    if whoFrameText then
        WhoFrameEditBox:SetText(whoFrameText)
        whoFrameText = nil
    end
    if whoFrameCursorPosition then
        WhoFrameEditBox:SetCursorPosition(whoFrameCursorPosition)
        if start and finish - start > 0 then
            WhoFrameEditBox:HighlightText(start, finish)
        end
        start, finish = nil, nil
        whoFrameCursorPosition = nil
    end
end

function TrackerMenu:Whisper(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if message then ChatFrame_SendTell(message["playerInfo"]["name"]) end
end

function TrackerMenu:Delete(lineWidget)
    if addon.isBusy then
        addon:LockBusy(self.Delete, {self, lineWidget})
        return
    end
    addon.busy = true
    if lineWidget.id and addon.Message.trackedMessages[lineWidget.id] then
        addon.Message:DeleteChanged(lineWidget.id)
        addon.Message:MarkChanged("delete", lineWidget.id)
        addon.Message.trackedMessages[lineWidget.id] = nil
        addon.Tracker:Update()
    end
    addon.busy = false
end

function TrackerMenu:CopyUserName(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if not message then return end
    local editBox = ChatEdit_ChooseBoxForSend()
    local text = editBox:GetText()
    local visible = editBox:IsVisible()
    local cursorPosition, start, finish
    if editBox:HasFocus() then
        cursorPosition = editBox:GetCursorPosition()
        if text and text ~= "" then
            editBox:Insert("")
            local textNew, cursorNew = editBox:GetText(), editBox:GetCursorPosition()
            start, finish = cursorNew, #text - (#textNew - cursorNew)
        end
    elseif text and text ~= "" then
        cursorPosition = #text
    else
        cursorPosition = 0
    end
    local name = message["playerInfo"]["name"]
    if start and finish - start > 0 then
        editBox:SetText(text)
        editBox:SetCursorPosition(cursorPosition)
        editBox:Insert(name)
        editBox:HighlightText(cursorPosition, cursorPosition + #name)
    elseif editBox:HasFocus() then
        if text and text ~= "" then
            editBox:Insert(name)
            editBox:HighlightText(cursorPosition, cursorPosition + #name)
        else
            editBox:SetText(name)
            editBox:HighlightText()
        end
    else
        if not visible then
            ChatEdit_ActivateChat(editBox)
        end
        editBox:Insert(name)
        editBox:HighlightText(cursorPosition, cursorPosition + #name)
    end
end

function TrackerMenu:BlockUser(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if message then C_FriendList.AddIgnore(message["playerInfo"]["name"]) end
end

function TrackerMenu:UnblockUser(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if not message then return end
    if C_FriendList.DelIgnore(message["playerInfo"]["name"]) then
        SendSystemMessage(string.format(
                L["tracker_action_unblock_user"],
                message["playerInfo"]["name"]
        ))
    end
end

function TrackerMenu:AddFriend(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if message then C_FriendList.AddFriend(message["playerInfo"]["name"]) end
end

function TrackerMenu:RemoveFriend(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if not message then return end
    if C_FriendList.RemoveFriend(message["playerInfo"]["name"]) then
        SendSystemMessage(string.format(
                L["tracker_action_remove_friend"],
                message["playerInfo"]["name"]
        ))
    end
end

function TrackerMenu:UserSpamScore(lineWidget)
    local message = addon.Message.trackedMessages[lineWidget.id]
    if not message then return end
    if AcamarAPIHelper then
        SendSystemMessage(string.format(
                L["tracker_action_user_spam_score"],
                message["playerInfo"]["name"],
                AcamarAPIHelper:SpamScore(message["playerInfo"]["guid"])
        ))
    else
        SendSystemMessage(L["tracker_action_user_spam_score_install"])
    end
end