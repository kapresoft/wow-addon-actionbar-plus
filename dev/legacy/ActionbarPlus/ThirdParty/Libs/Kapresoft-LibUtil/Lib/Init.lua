--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat = string.format
local LibPrefix = 'Kapresoft-LibUtil'

--- @type Kapresoft_Base_Namespace
local addOn, ns = ...

--[[-----------------------------------------------------------------------------
Kapresoft_LibUtil Initialization
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil
--- @field LibStub Kapresoft_LibUtil_LibStub Lazy loaded
--- @field Objects Kapresoft_LibUtil_Modules Lazy loaded
--- @field pformat fun(fmt:string, ...)|fun(val:string)
--- @field dump fun(val:string)
--- @field dumpv fun(val:any)
local LibUtil = {
    LibPrefix = LibPrefix,
    --- @type Kapresoft_LibUtil_Modules
    M = {},

    --- @type Kapresoft_LibUtil_ConsoleHelper
    CH = K_ConsoleHelper,

    LogLevel = Kapresoft_LibUtil_LogLevel or 0,
    --- @param self Kapresoft_LibUtil
    --- @param logLevel number A zero or positive number
    ShouldLog = function(self, logLevel) return self.LogLevel <= (logLevel or 0)  end,

    --- @param self Kapresoft_LibUtil
    --- @param moduleName string
    Lib = function(self, moduleName) return sformat('%s-%s-1.0', self.LibPrefix, moduleName) end,

    --- @type Kapresoft_LibUtil_LibStubMixin
    LibStubMixin = {},
}

local LibStubMixin = LibUtil:Lib('LibStubMixin')
local Library = LibUtil:Lib('Library')
local Mixin = LibUtil:Lib('Mixin')
local IncrementerBuilder = LibUtil:Lib('IncrementerBuilder')

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function InitLazyLoaders()
    local lazyLoaders = {
        --- @type Kapresoft_LibUtil_Modules
        Objects = function()
            local lib = LibStub(Library, true); return (lib and lib.Objects) or {}
        end,
        --- @type Kapresoft_LibUtil_LibStub
        LibStub = function() return LibStub(LibStubMixin):New(LibUtil.LibPrefix, 1.0) end
    }
    --- @param o Kapresoft_LibUtil The LibUtil instance
    local function LibStubLazyLoad(o, libName)
        if lazyLoaders[libName] then
            o[libName] = lazyLoaders[libName]()
            return o[libName]
        end
        return nil
    end

    LibUtil.mt = { __index = LibStubLazyLoad }
    setmetatable(LibUtil, LibUtil.mt)
end

--- @return Kapresoft_LibUtil_Mixin
local function Mx() return LibStub(Mixin) end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Create a new color formatter function
--- @param color Color
--- @return fun(val:any) : string The color formatter function
function LibUtil:cf(color)
    return function(arg) return color:WrapTextInColorCode(tostring(arg)) end
end

--- Create a new color formatter function
--- @param RRGGBBAA HexColor | "'fc565656'"
--- @return fun(val:any) : string The color formatter function
function LibUtil:cfHex(RRGGBBAA) return self.Objects.ColorUtil:NewFormatterFromHex(RRGGBBAA) end

--- @param callbackFn fun()
function LibUtil.After100ms(callbackFn) C_Timer.After(0.1, callbackFn) end

--- @param callbackFn fun()
function LibUtil.After300ms(callbackFn) C_Timer.After(0.3, callbackFn) end

--- @param callbackFn fun()
function LibUtil.After500ms(callbackFn) C_Timer.After(0.5, callbackFn) end

--- @param callbackFn fun()
function LibUtil.After1s(callbackFn) C_Timer.After(1, callbackFn) end

--- @alias ModuleName string |"'String'"|"'Table'"|"'Mixin'"|"'Assert'"|"'Safecall'"|"'Incrementer'"
--- @alias TargetLibraryMajorVersion string |"'Kapresoft-Table-1.0'"|"'Kapresoft-String-1.0'"|"'Kapresoft-Mixin-1.0'"|"'Kapresoft-Assert-1.0'"|
--- @param moduleName ModuleName Example: 'Table' or 'String'
--- @param moduleRevision number
--- @param targetLibraryMajorVersion TargetLibraryMajorVersion The target library major version
function LibUtil:CreateLibWrapper(moduleName, moduleRevision, targetLibraryMajorVersion)
    local W = self.LibStub:NewLibrary(moduleName, moduleRevision); if not W then return end
    local L = self.LibStub:LibStub(targetLibraryMajorVersion); if not L then return end
    getmetatable(W).__index = L
    getmetatable(W).__tostring = function()
        local majorVersion = self:Lib(moduleName)
        return majorVersion .. '.' .. LibStub.minors[majorVersion]
    end
    if (Kapresoft_LibUtil_LogLevel_LibWrapper or 0) > 10 then
        local prefix = self.CH:CreateLogPrefix('Init')
        print(prefix, moduleName .. ':', self.pformat({lib=tostring(L), wrapper=tostring(W)}))
    end
    return W
end

--- @see Similar Interface/SharedXML/Mixin.lua#Mixin(object, ...)
--- @return any The new Mixin instance
function LibUtil:Mixin(object, ...) return Mx():Mixin(object, ...) end

--- @see Kapresoft_LibUtil_Mixin#MixinWithDefExc
--- @param object any The target object
--- @vararg any The objects to mixin
--- @return any The new Mixin instance
function LibUtil:MixinWithDefExc(object, ...) return Mx():MixinWithDefExc(object, ...) end

--- @see Kapresoft_LibUtil_Mixin#CreateFromMixins
--- @return any The new Mixin instance
function LibUtil:CreateFromMixins(...) return Mx():CreateFromMixins(...) end

--- @see Kapresoft_LibUtil_Mixin#CreateFromMixinsWithDefExc
--- @vararg any The mixins
--- @return any The new Mixin instance
function LibUtil:CreateFromMixinsWithDefExc(...) return Mx():CreateFromMixinsWithDefExc(...) end

--- @see Similar Interface/SharedXML/Mixin.lua#CreateAndInitFromMixin(...)
--- @param mixin table The mixin
--- @param ... any The arguments to the Init(...) call
--- @return any The new Mixin instance
function LibUtil:CreateAndInitFromMixin(mixin, ...) return Mx():CreateAndInitFromMixin(mixin, ...) end

--- @see Kapresoft_LibUtil_Mixin#CreateAndInitFromMixinWithDefExc
--- @param mixin table The mixin
--- @param ... any The arguments to the Init(...) call
--- @return any The new Mixin instance
function LibUtil:CreateAndInitFromMixinWithDefExc(mixin, ...)
    return Mx():CreateAndInitFromMixinWithDefExc(mixin, ...)
end

--- @param start number
--- @param increment number
--- @return Kapresoft_LibUtil_IncrementerBuilder
function LibUtil:CreateIncrementer(start, increment)
    return LibStub(IncrementerBuilder):New(start, increment)
end

--- ```
--- @type Kapresoft_Base_Namespace
--- local _, ns = ...
--- local O, LibStub, M, pformat, LibUtil = ns.Kapresoft_LibUtil:LibPack()
--- ```
--- @deprecated Deprecated. Don't use LibPack()
--- @return Kapresoft_LibUtil_Modules, Kapresoft_LibUtil_LibStub, Kapresoft_LibUtil_Modules, fun(fmt:string, ...)|fun(val:string), Kapresoft_LibUtil
function LibUtil:LibPack() return self.Objects, self.LibStub, self.M, self.pformat, self end

--[[-----------------------------------------------------------------------------
Lazy Load
-------------------------------------------------------------------------------]]
InitLazyLoaders()

--[[-----------------------------------------------------------------------------
Add to Namespace
-------------------------------------------------------------------------------]]
ns.Kapresoft_LibUtil = LibUtil
