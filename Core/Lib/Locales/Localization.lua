--[[
    ActionbarPlus Addon
--]]
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

local LocUtil = ns.O.LocalizationUtil

---@type AceLocale
local L = LibStub("AceLocale-3.0"):GetLocale(ns.name)
if not L then return end

-- General
ABP_TITLE                                    = "ActionbarPlus"
ABP_CATEGORY                                 = "AddOns/" .. ABP_TITLE

-- Key binding localization text
BINDING_HEADER_ABP                           = ABP_TITLE
BINDING_HEADER_ABP_CATEGORY                  = ABP_CATEGORY
BINDING_NAME_ABP_OPTIONS_DLG                 = L['Options Dialog']
BINDING_HEADER_ABP_GENERAL                   = L['General']


--[[-----------------------------------------------------------------------------
Localization
-------------------------------------------------------------------------------]]

ABP_ACTIONBAR_BASE_NAME                      = L['ABP_ACTIONBAR_BASE_NAME']
ABP_BUTTON_BASE_NAME                         = L['ABP_BUTTON_BASE_NAME']

LocUtil:MapBindingsXMLNames(L, ABP_ACTIONBAR_BASE_NAME, ABP_TITLE)

