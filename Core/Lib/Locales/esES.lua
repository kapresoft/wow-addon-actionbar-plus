--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

local LocUtil = ns.O.LocalizationUtil

---@type AceLocale
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "esES");
if not L then return end

--[[-----------------------------------------------------------------------------
Localization Keys That need to be defined for Bindings.xml
-------------------------------------------------------------------------------]]
local actionBarText = 'Barra'
local buttonBarText = 'Botón'

L['ABP_ACTIONBAR_BASE_NAME']                             = actionBarText
L['ABP_BUTTON_BASE_NAME']                                = buttonBarText

LocUtil:SetupKeybindNames(L, actionBarText, buttonBarText)

--[[-----------------------------------------------------------------------------
Keybinding Localization
The contents below this block will be generated automatically.
-------------------------------------------------------------------------------]]

--@localization(locale="esES", format="lua_additive_table", handle-subnamespaces="concat")@
