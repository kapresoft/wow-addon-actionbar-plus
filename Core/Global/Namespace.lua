--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
local _addon, _ns = ...
local MixinAndInit = K_CreateAndInitFromMixin
local CreateIncrementer = Kapresoft_LibUtil_CreateIncrementer

---This absolutely does NOTHING but make EmmyLua work better in IDEs for code
---completions.
--- @param o Namespace
local function Define_InterfaceMethods(o)

    --- @see CursorMixin.lua
    --- @return CursorUtil
    --function o:CreateCursorUtil() end

    --- @see UtilWrapper.lua
    --- @param start number
    --- @param increment number
    --- @return Kapresoft_LibUtil_Incrementer
    function o:CreateIncrementer(start, increment) end

end

Define_InterfaceMethods(_ns)

--- @class LibPackMixin
local LibPackMixin = {

    --- @type fun(self:LibPackMixin) : GlobalObjects, LocalLibStub
    LibPack = function(self) return self.O, self.O.LibStub end,

    --- @type fun(self:LibPackMixin) : GlobalObjects, GlobalConstants
    LibPack2 = function(self) return self.O, self.O.GlobalConstants end,
}
--- @generic A : AceEvent
--- @return A
function LibPackMixin:AceEvent() return self.O.AceLibrary.AceEvent:Embed({}) end


--- @return Namespace
local function CreateNamespace(...)
    --- @type string
    local addon
    --- @type Namespace
    local ns

    addon, ns = ...

    --- this is in case we are testing outside of World of Warcraft
    addon = addon or ABP_GlobalConstants.C.ADDON_NAME

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- The AddOn Name, i.e. "ActionbarPlus"
    --- @type string
    ns.name = addon
    --- @type ActionbarPlus_AceDB
    ns.db = ns.db or {}

    --- @type Module
    ns.M = ns.M or {}


    --- LibStub exists in both ns.LibStub and ns.O.LibStub
    --- @see _LocalLibStub
    --- @type LocalLibStub
    ns.LibStub = ns.LibStub or nil

    K_Mixin(ns, LibPackMixin)

    --- @param o Namespace
    local function Methods(o)
        --- @return CursorUtil
        function o:CreateCursorUtil() return MixinAndInit(o.O.CursorMixin, o.O.API:GetCursorInfo()) end
        --- @param start number
        --- @param increment number
        --- @return Kapresoft_LibUtil_Incrementer
        function o:CreateIncrementer(start, increment) return CreateIncrementer(start, increment) end

        --- @param moduleName string The module name, i.e. Logger
        --- @return string The complete module name, i.e. 'ActionbarPlus-Logger-1.0'
        function o:LibName(moduleName) return self.name .. '-' .. moduleName .. '-1.0' end

        --- @param name string The module name
        --- @param o any The object to register
        function o:Register(name, o)
            if not (name or o) then return end
            ns.O[name] = o
        end
    end

    Methods(ns)

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    return ns
end

if _ns.name then return end

CreateNamespace(...)
