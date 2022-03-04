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

L["welcome_message"] = "|cFF33FF99%s (%s)|r: type /triton to show tracker"
L["bliz_options_panel_name"] = "%s"

if gameLocale == "ruRU" then
    L["welcome_message"] = "|cFF33FF99%s (%s)|r: введите /triton для вызова трекера"
    L["minimap_pin_tooltip_tracker_window_hidden"] = "|cffffff00Нажмите|r, чтобы показать трекер."
    L["minimap_pin_tooltip_tracker_window_shown"] = "|cffffff00Нажмите|r, чтобы скрыть трекер."
    L["bliz_options_title"] = "%s (%s)"
    L["bliz_options_addon_info"] = "|cffca99ffTriton|r — отслеживание сообщений с настраиваемыми фильтрами. Сообщения показываются в отдельном окне. Подходит для поиска групп для тех, кто еще ищет в чате, поиска покупателей порталов магу и прочего."
    L["bliz_options_tracked_message_lifetime"] = "Время жизни сообщения"
    L["bliz_options_tracked_message_lifetime_tooltip"] = "Сколько времени найденное сообщение остается в трекере (по умолчанию %d |4секунда:секунды:секунд;)"
    L["bliz_options_tracking_refresh_rate"] = "Скорость обновления"
    L["bliz_options_tracking_refresh_rate_tooltip"] = "Как быстро обновляется трекер: добавляются найденные и удаляются устаревшие сообщения (по умолчанию раз в %d |4секунду:секунды:секунд;)"
    L["bliz_options_tracker_hide_channel"] = "Не показывать канал"
    L["bliz_options_tracker_hide_channel_tooltip"] = "Не выводить канал у найденного сообщения в трекере (по умолчанию %s)"
    L["bliz_options_tracker_hide_similar_messages"] = "Не запоминать похожие"
    L["bliz_options_tracker_hide_similar_messages_tooltip"] = "Трекер группирует сообщения от одного игрока по одинаковым ключевым словам. Если включить, то только последнее сообщение группы будет запоминаться (по умолчанию %s)"
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
end