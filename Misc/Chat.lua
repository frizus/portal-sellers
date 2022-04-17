local addonName, addon = ...
local Chat = {}
addon.Chat = Chat

function Chat:SendText(text)
    local visible, cursorPosition, chatType, lastText, language, tellTarget, channelTarget
    local editBox = ChatEdit_GetActiveWindow()
    if editBox then
        visible = editBox:IsVisible()
        cursorPosition = editBox:GetCursorPosition()
        chatType = editBox:GetAttribute("chatType")
        lastText = editBox:GetText()
        language = editBox.language

        if chatType == "WHISPER" or chatType == "BN_WHISPER" then
            tellTarget = editBox:GetAttribute("tellTarget")
        elseif chatType == "BN_CONVERSATION" or chatType == "CHANNEL" then
            channelTarget = tonumber(editBox:GetAttribute("channelTarget"))
        end
    else
        editBox = DEFAULT_CHAT_FRAME.editBox
    end

    editBox:SetText(text)
    ChatEdit_SendText(editBox, 0)

    if chatType then editBox:SetAttribute("chatType", chatType) end
    if tellTarget then editBox:SetAttribute("tellTarget", tellTarget) end
    if channelTarget then editBox:SetAttribute("channelTarget", channelTarget) end
    if lastText then editBox:SetText(lastText) end
    if language then editBox.language = language end
    if cursorPosition then editBox:SetCursorPosition(cursorPosition) end
    if visible then ChatEdit_ActivateChat(editBox) end
end