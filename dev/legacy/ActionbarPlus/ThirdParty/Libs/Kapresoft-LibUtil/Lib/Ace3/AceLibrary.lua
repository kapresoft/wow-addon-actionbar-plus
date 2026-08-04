--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)

local K = ns.Kapresoft_LibUtil
local LibStub, M = K.LibStub, K.M

local ModuleName = M.AceLibrary()

--- @class Kapresoft_LibUtil_AceLibrary
local L = LibStub:NewLibrary(ModuleName, 4)
-- return if already loaded (this object can exist in other addons)
if not L then return end

--[[-----------------------------------------------------------------------------
Type: Kapresoft_LibUtil_AceLibraryObjects
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_AceLibraryObjects
--- @field AceAddon AceAddon The AceAddon object.
--- @field AceBucket AceBucket The AceBucket object.
--- @field AceConfig AceConfig The AceConfig object.
--- @field AceConfigDialog AceConfigDialog The AceConfigDialog object.
--- @field AceConfigRegistry AceConfigRegistry The AceConfigRegistry object.
--- @field AceConsole AceConsole The AceConsole object.
--- @field AceDB AceDB The AceDB object.
--- @field AceDBOptions AceDBOptions The AceDBOptions object.
--- @field AceEvent AceEvent The AceEvent object.
--- @field AceGUI AceGUI The AceGUI object.
--- @field AceHook AceHook The AceHook object.
--- @field AceLibSharedMedia AceLibSharedMedia The AceLibSharedMedia object.
--- @field AceLocale AceLocale_Lib The AceLocale object.

L.Names = {
    AceAddon = "AceAddon-3.0",
    AceBucket = 'AceBucket-3.0',
    AceConfig = 'AceConfig-3.0',
    AceConfigDialog = 'AceConfigDialog-3.0',
    AceConfigRegistry = 'AceConfigRegistry-3.0',
    AceConsole = 'AceConsole-3.0',
    AceDB = 'AceDB-3.0',
    AceDBOptions = 'AceDBOptions-3.0',
    AceEvent = 'AceEvent-3.0',
    AceGUI = 'AceGUI-3.0',
    AceHook = 'AceHook-3.0',
    AceLibSharedMedia = 'LibSharedMedia-3.0',
    AceLocale = 'AceLocale-3.0',
}

---@type Kapresoft_LibUtil_LibFactoryMixin
local LibFactoryMixin = LibStub('LibFactoryMixin')
local libFactory = LibFactoryMixin:New(L.Names)

--- @type Kapresoft_LibUtil_AceLibraryObjects
L.O = libFactory:GetObjects()
