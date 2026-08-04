--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Name
local addon
--- @type Kapresoft_Base_Namespace
local ns
addon, ns = ...

local LibStub = LibStub
local LibUtil = ns.Kapresoft_LibUtil

--- This global var will be used by libraries for simplicity
--- @see _Init.lua#InitLazyLoaders()
--- @type Kapresoft_LibUtil_LibStub
Kapresoft_LibStub = LibUtil.LibStub

local function Lib(moduleName) return LibUtil:Lib(moduleName) end

--- @class Kapresoft_LibUtil_Modules
local M = {
    --- @type Kapresoft_LibUtil_Constants
    Constants = {},
    --- @type Kapresoft_LibUtil_AceConfigUtil
    AceConfigUtil = {},
    --- @type Kapresoft_LibUtil_AceLibrary
    AceLibrary = {},
    --- @type Kapresoft_LibUtil_AceLocaleUtil
    AceLocaleUtil = {},
    --- @type Kapresoft_LibUtil_Assert
    Assert = {},
    --- @type Kapresoft_LibUtil_ColorUtil
    ColorUtil = {},
    --- @type Kapresoft_LibUtil_AddonUtil
    AddonUtil = {},
    --- @type Kapresoft_LibUtil_AddonInfoUtil
    AddonInfoUtil = {},
    --- @type Kapresoft_LibUtil_IncrementerBuilder
    Incrementer = {},
    --- @type Kapresoft_LibUtil_Mixin
    Mixin = {},
    --- @type Kapresoft_LibUtil_String
    String = {},
    --- @type Kapresoft_LibUtil_Table
    Table = {},
    --- @type Kapresoft_LibUtil_TimeUtil
    TimeUtil = {},
    --- @type Kapresoft_LibUtil_LoggerMixin
    LoggerMixin = {},
    --- @type Kapresoft_LibUtil_CategoryMixin
    CategoryMixin = {},
    --- @type Kapresoft_LibUtil_Safecall
    Safecall = {},
    --- @type Kapresoft_LibUtil_SequenceMixin
    SequenceMixin = {},
    --- @type Kapresoft_LibUtil_PrettyPrint
    PrettyPrint = {},
    --- @type Kapresoft_LibUtil_AceLibrary
    AceLibrary = {},
    --- @type Kapresoft_LibUtil_LuaEvaluator
    LuaEvaluator = {},
    --- @type Kapresoft_LibUtil_LibFactoryMixin
    LibFactoryMixin = {},
    --- @type Kapresoft_LibUtil_LibModule
    LibModule = {},
    --- @type Kapresoft_LibUtil_LibStubMixin
    LibStubMixin = {},
    --- @type Kapresoft_LibUtil_CoreNamespaceMixin
    CoreNamespaceMixin = {},
    --- @type Kapresoft_LibUtil_NamespaceAceLibraryMixin
    NamespaceAceLibraryMixin = {},
    --- @type Kapresoft_LibUtil_NamespaceKapresoftLibMixin
    NamespaceKapresoftLibMixin = {},
}
for name in pairs(M) do
    --- @type Kapresoft_LibUtil_Module
    local module = M[name]
    module._name = name
    module._libName = Lib(name)
    module.mt = {
        --- @param m Kapresoft_LibUtil_Module
        __tostring = function(m) return "Module: " .. m._name .. ' (' .. m._libName .. ')' end,
        --- @param m Kapresoft_LibUtil_Module
        __call = function(m) return m._name end
    }
    setmetatable(module, module.mt)
end

LibUtil.M = M

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- README: Increment the minor version whenever a library is added
--- @class Kapresoft_LibUtil_Library
local L = LibStub:NewLibrary(Lib('Library'), 15); if not L then return end

L.Modules = M
L.Names = {}
--- @param module Kapresoft_LibUtil_Module
for _, module in pairs(L.Modules) do L.Names[module._name] = module._libName end

--[[-----------------------------------------------------------------------------
Namespace Objects
-------------------------------------------------------------------------------]]
---@type Kapresoft_LibUtil_LibFactoryMixin
local LibFactoryMixin = LibStub(Lib(M.LibFactoryMixin()))
local libFactory = LibFactoryMixin:New(L.Names)
--- @type Kapresoft_LibUtil_Modules
L.Objects = libFactory:GetObjects()

