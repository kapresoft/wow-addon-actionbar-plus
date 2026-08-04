--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local MAJOR_VERSION = 'Kapresoft-LibFactoryMixin-1.0'
local logPrefix = '{{Kapresoft-LibFactoryMixin}}:'

--- @type Kapresoft_Base_Namespace
local ns = select(2, ...); assert(ns, sformat('%s: Namespace not available.', logPrefix))

--- @type Kapresoft_LibUtil
local K = ns.Kapresoft_LibUtil
logPrefix = K.CH:CreateLogPrefix('LibFactoryMixin')
local c1 = K:cf(ORANGE_THREAT_COLOR)
local c2 = K:cf(HIGHLIGHT_LIGHT_BLUE)

local WARN_TEXT = c1('WARN')
local printp = function(...) print(logPrefix, ...)  end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- Usage:
--- ```
--- local libNames = { AceAddon = 'AceAddon-3.0' }
--- local Objects = {
---     ---@type AceAddon
---     AceAddon = nil
--- }
--- local libFactory = LibFactoryMixin:New(libNames)
--- ---@type <ObjectType>
--- local aceLib = libFactory:GetObjects()
--- local aceAddon = aceLib.AceAddon
--- ```
---@class Kapresoft_LibFactoryMixin
local L = LibStub:NewLibrary(MAJOR_VERSION, 4); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local assertMsgFmt = 'The library name [%s] is invalid. Is it registered in Kapresoft Library.lua? [%s]'
local libFailedMsgFmt = 'Failed to load library MajorVersion=%s ModuleName=%s. [%s]'

local function assertLibName(libName, varToAssert)
    if varToAssert then return true end
    printp(WARN_TEXT, sformat(assertMsgFmt, libName, c2(tostring(L))))
    return false
end

local function handleIfLibFailed(success, prefix, libName, libNameMajor)
    if success then return end
    printp(WARN_TEXT, sformat(libFailedMsgFmt, tostring(libNameMajor), tostring(libName), c2(tostring(L))))
end

---@param anyTable Kapresoft_LibUtil_LibFactoryMixin
local function LibStubLazyLoad(anyTable, libName)
    assert(libName, logPrefix .. 'Library name is required.')
    --- @class _AnyInstance : Kapresoft_LibUtil_LibFactoryMixin
    local mixinInstance = anyTable.mixinInstance
    local libNameMajor = mixinInstance.libNames[libName]
    -- In case of a new Kapresoft Lib Module, try again using K:Lib()
    if not libNameMajor then libNameMajor = K:Lib(libName) ..'x' end
    local validLibName = assertLibName(libName, libNameMajor)
    if not validLibName then return end

    local success, libInstanceOrErrorMsg = pcall(LibStub, libNameMajor)
    handleIfLibFailed(success, logPrefix, libName, libNameMajor)
    if not success then return nil end

    local libInstance = libInstanceOrErrorMsg
    if (Kapresoft_LibUtil_LogLevel_LibFactory or 0) >= 10 then
        print(sformat("%s Loaded[%s] %s", logPrefix, tostring(libNameMajor), tostring(libInstance)))
    end
    return libInstance
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Called Automatically by Mixin upon creation
--- @param libNames table
--- @param nameGeneratorFunction function(libName:string)
function L:Init(libNames, nameGeneratorFunction)
    assert('table' == type(libNames), logPrefix .. 'libNames arg is required')
    self.libNames = {}

    if K_Constants:TableSize(libNames)  > 0 then
        if 'function' == type(nameGeneratorFunction) then
            for k, v in pairs(libNames) do
                local libNameGen = nameGeneratorFunction(v)
                if (Kapresoft_LibUtil_LogLevel_LibFactory or 0) >= 10 then
                    print(logPrefix, 'libNameGenerator returned:', tostring(libNameGen))
                end
                self.libNames[k] = libNameGen
            end
        else
            self.libNames = libNames
        end
    end

    self.objects = {}
    self.objects.mixinInstance = self
    --- We want to be able to just do `Instance.<LibraryName>` to get the object
    self.objects.mt = { __index = LibStubLazyLoad }
    setmetatable(self.objects, self.objects.mt)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o Kapresoft_LibFactoryMixin
local function Methods(o)
    --- ### Usage 1
    --- ```
    --- local Names = { AceConsole = 'AceConsole-3.0' }
    --- local libFactory = LibFactoryMixin:New(Names:table)
    --- ```
    --- ### Usage 2: With a name generator function as a second argument
    --- ```
    --- local Names = { AceConsole = 'AceConsole' }
    --- local libFactory = LibFactoryMixin:New(Names:table, function(moduleName) return moduleName .. '-3.0') end)
    --- ```
    --- @vararg any
    --- @see Interface/SharedXML/Mixin.lua#CreateAndInitFromMixin
    --- @return Kapresoft_LibUtil_LibFactoryMixin
    function o:New(...)
        ---Calls Init(...)
        return K_Constants:CreateAndInitFromMixin(o, ...)
    end

    function o:GetObjects() return self.objects end
end

Methods(L)
