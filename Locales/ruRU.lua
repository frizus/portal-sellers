local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ruRU")
if not L then return end

L["welcome_message"] = "|cFF33FF99%s (%s)|r: введите /triton для вызова окна отслеживания сообщений"
L["minimap_pin_tooltip_tracker_window_hidden"] = "|cffffff00Нажмите|r, чтобы показать главное окно."
L["minimap_pin_tooltip_tracker_window_shown"] = "|cffffff00Нажмите|r, чтобы скрыть главное окно."