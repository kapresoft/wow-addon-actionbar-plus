--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LocUtil = ns.O.LocalizationUtil

---@type AceLocale
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "deDE");
if not L then return end

--[[-----------------------------------------------------------------------------
Localization Keys That need to be defined for Bindings.xml
-------------------------------------------------------------------------------]]
local actionBarText = 'Aktionsleiste'
local buttonBarText = 'Knopf'

L['ABP_ACTIONBAR_BASE_NAME']                             = actionBarText
L['ABP_BUTTON_BASE_NAME']                                = buttonBarText

LocUtil:SetupKeybindNames(L, actionBarText, buttonBarText)

--[[-----------------------------------------------------------------------------
Keybinding Localization
The contents below this block will be generated automatically.
-------------------------------------------------------------------------------]]

--@localization(locale="deDE", format="lua_additive_table", handle-subnamespaces="concat")@
