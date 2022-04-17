local addonName, addon = ...
local L = {}
addon.L = setmetatable(L, {
    __index = function (self, key)
        return key
    end
})

local gameLocale = GetLocale()
if gameLocale == "enGB" then
    gameLocale = "enUS"
end

L["welcome_message"] = "|cff33ff99" .. addonName .. " (" .. GetAddOnMetadata(addonName, "Version") .. ")|r: type /triton to show tracker"

L["bliz_options_panel_name"] = addonName
L["bliz_options_title"] = addonName .. " (" .. GetAddOnMetadata(addonName, "Version") .. ")"
L["tracker_title"] = addonName
L["say"] = string.utf8lower(SAY)
L["yell"] = string.utf8lower(YELL)
L["level_abbr"] = string.utf8lower(LEVEL_ABBR)

L["minimap_pin_tooltip_tracker_window_hidden"] = "|cffffff00Click|r to show tracker."
L["minimap_pin_tooltip_tracker_window_shown"] = "|cffffff00Click|r to hide tracker."

L["tracker_line_seconds"] = "%ss"

L["tracker_menu_choose_option"] = "Choose operation"
L["tracker_menu_similars"] = "%d |1similar;similars;"
L["tracker_menu_invite_to_party"] = "Invite"
L["tracker_menu_invite_to_party_hotkey"] = "ctrl-lmb"
L["tracker_menu_whisper"] = "Whisper"
L["tracker_menu_who"] = "User details"
L["tracker_menu_who_hotkey"] = "shift-lmb"
L["tracker_menu_copy_user_name"] = "Copy user name"
L["tracker_menu_block_user"] = "Block user"
L["tracker_menu_unblock_user"] = "Unblock user"
L["tracker_menu_add_friend"] = "Add to friends"
L["tracker_menu_remove_friend"] = "Remove from friends"
L["tracker_menu_user_spam_score"] = "User spam score"
L["tracker_menu_delete"] = "Delete line"
L["tracker_menu_delete_hotkey"] = "alt-lmb"
L["tracker_menu_cancel"] = "Cancel"
L["tracker_action_unblock_user"] = ERR_IGNORE_REMOVED_S
L["tracker_action_remove_friend"] = ERR_FRIEND_REMOVED_S
L["tracker_action_user_spam_score"] = "%s's spam score is %s"
L["tracker_action_user_spam_score_install"] = "Please install Acamar auto-learning spam filtering addon to obtain user's spam score."

if gameLocale == "ruRU" then
    L["welcome_message"] = "|cff33ff99" .. addonName .. " (" .. GetAddOnMetadata(addonName, "Version") .. ")|r: введите /triton для вызова трекера"

    L["minimap_pin_tooltip_tracker_window_hidden"] = "|cffffff00Нажмите|r, чтобы показать трекер."
    L["minimap_pin_tooltip_tracker_window_shown"] = "|cffffff00Нажмите|r, чтобы скрыть трекер."

    L["bliz_options_addon_info"] = "|cffca99ffTriton|r — отслеживание сообщений с настраиваемыми фильтрами. Сообщения показываются в отдельном окне. Подходит для поиска групп для тех, кто еще ищет в чате, поиска покупателей порталов магу и прочего."
    L["bliz_options_tracked_message_lifetime"] = "Время жизни сообщения"
    L["bliz_options_tracked_message_lifetime_tooltip"] = "Сколько времени найденное сообщение остается в трекере (по умолчанию %d |4секунда:секунды:секунд;)"
    L["bliz_options_tracking_refresh_rate"] = "Скорость обновления"
    L["bliz_options_tracking_refresh_rate_tooltip"] = "Как быстро обновляется трекер: добавляются найденные и удаляются устаревшие сообщения (по умолчанию раз в %d |4секунду:секунды:секунд;)"
    L["bliz_options_tracker_hide_similar_messages"] = "Не запоминать похожие"
    L["bliz_options_tracker_hide_similar_messages_tooltip"] = "Трекер группирует сообщения от одного игрока по одинаковым ключевым словам. Если включить, то только последнее сообщение группы будет запоминаться (по умолчанию %s)"
    L["bliz_options_minimap_show"] = "Значок на миникарте"
    L["bliz_options_minimap_show_tooltip"] = "Показать/скрыть значок на миникарте (по умолчанию %s)"
    L["bliz_options_show_start_message"] = "Стартовое сообщение"
    L["bliz_options_show_start_message_tooltip"] = "Показывать стартовое сообщение в чате (по умолчанию %s)"
    L["bliz_options_do_track_when_closed"] = "Всегда отслеживать"
    L["bliz_options_do_track_when_closed_tooltip"] = "Отслеживать сообщения даже когда окно трекера закрыто (по умолчанию %s)"
    L["bliz_options_highlight_keywords"] = "Подсвечивать"
    L["bliz_options_highlight_keywords_tooltip"] = "Выделение искомых слов в найденных сообщениях (по умолчанию %s)"
    L["bliz_options_toggle_enabled"] = "включено"
    L["bliz_options_toggle_disabled"] = "выключено"
    L["bliz_options_tracker_messages_font_size"] = "Размер шрифта"
    L["bliz_options_tracker_messages_font_size_tooltip"] = "Размер шрифта сообщений в трекере (по умолчанию %.1f)"
    L["bliz_options_bottom"] = "Подсказка: поддерживается фильтрация по классу игрока и по искомым словам в сообщении.\n\n" ..
        "При вводе искомых слов поддерживаются следующие операторы (на примерах):\n" ..
        "|cff00ccccOYN,MC,BWL|r: сообщение содержит одно из: |cff00ccccOYN|r, |cff00ccccMC|r, |cff00ccccBWL|r\n" ..
        "|cff00ccccOYN&LFG|r: сообщение содержит |cff00ccccOYN|r и |cff00ccccLFG|r\n" ..
        "|cff00ccccOYN-Bad-fxxk|r: сообщение содержит |cff00ccccOYN|r, но не содержит |cff00ccccBad|r и |cff00ccccfxxk|r\n" ..
        "Доступно экранирование операторов с помощью |cff00cccc\\|r.\n\n" ..
        "Есть возможность задать сокращенное название для одной группы искомых слов. Оно будет выводиться в трекере вместо искомого слова.\n" ..
        "Также доступна опция поиска по целому слову: |cff00ccccOYN|r с включенной опцией найдется в |cff00ccccMC OYN BWL|r и |cff00ccccMC OYN(st) BWL|r, но не в |cff00ccccMC OYNst BWL|r.\n\n" ..
        "https://github.com/bayard/triton\n|cffca99ffTriton|r@匕首岭 (bǐ shǒu lǐng) 2020"

    L["tracker_line_seconds"] = "%sс"

    L["tracker_menu_choose_option"] = "Выберите действие"
    L["tracker_menu_similars"] = "%d |4схожее:схожих:схожих;"
    L["tracker_menu_invite_to_party"] = "Пригласить"
    L["tracker_menu_invite_to_party_hotkey"] = "ctrl-лкм"
    L["tracker_menu_whisper"] = "Шепнуть"
    L["tracker_menu_who"] = "Сведения об игроке"
    L["tracker_menu_who_hotkey"] = "shift-лкм"
    L["tracker_menu_copy_user_name"] = "Копировать имя игрока"
    L["tracker_menu_block_user"] = "Заблокировать игрока"
    L["tracker_menu_unblock_user"] = "Разблокировать игрока"
    L["tracker_menu_add_friend"] = "Добавить в друзья"
    L["tracker_menu_remove_friend"] = "Удалить из друзей"
    L["tracker_menu_user_spam_score"] = "Оценка спама"
    L["tracker_menu_delete"] = "Удалить сообщение"
    L["tracker_menu_delete_hotkey"] = "alt-лкм"
    L["tracker_menu_cancel"] = "Отмена"

    --L["tracker_action_ignore_male"] = "%s %s в черный список"
    L["tracker_action_user_spam_score"] = "%s оценка %s"
    L["tracker_action_user_spam_score_install"] = "Установите аддон самообучающейся фильтрации спама Acamar, чтобы получить спам-рейтинг игрока."
elseif gameLocale == "zhCN" then
    L["welcome_message"] = "点击显示" .. "|cff33ff99" .. addonName .. " (" .. GetAddOnMetadata(addonName, "Version") .. ")|r消息跟踪窗口"

    L["minimap_pin_tooltip_tracker_window_hidden"] = "|cffffff00点击|r 打开 Triton 窗口"
    L["minimap_pin_tooltip_tracker_window_shown"] = "|cffffff00点击|r 以关闭 Triton 窗口"

    L["tracker_menu_choose_option"] = "选择操作"
    L["tracker_menu_invite_to_party"] = "邀请"
    L["tracker_menu_whisper"] = "发私信"
    L["tracker_menu_who"] = "查看用户详情"
    L["tracker_menu_copy_user_name"] = "复制用户名"
    L["tracker_menu_block_user"] = "屏蔽此用户"
    L["tracker_menu_unblock_user"] = "取消屏蔽该用户"
    L["tracker_menu_add_friend"] = "加为好友"
    L["tracker_menu_remove_friend"] = "从朋友中删除"
    L["tracker_menu_user_spam_score"] = "玩家垃圾消息评分"
    L["tracker_menu_delete"] = "删除消息"
    L["tracker_menu_cancel"] = "取消"

    L["'s spam score is "] = "%s 的垃圾消息评分为 %s"
    L["tracker_action_user_spam_score_install"] = "请安装Acamar自学习垃圾消息过滤插件查看玩家的评分。"
end