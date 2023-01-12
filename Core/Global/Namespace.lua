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

    --- @return GlobalObjects, LocalLibStub, Namespace
    --- @param self LibPackMixin
    LibPack = function(self) return self.O, self.O.LibStub, self end,

    --- @param self LibPackMixin
    --- @return GlobalObjects, GlobalConstants, Namespace
    LibPack2 = function(self) return self.O, self.O.GlobalConstants, self end,

    --- @param self LibPackMixin
    AceEvent = function(self) return self.O.AceLibrary.AceEvent:Embed({}) end,

}

---###Usage:
---```
---local addon, ns = ABP_Namespace(...)
---```
---#### See: [https://wowpedia.fandom.com/wiki/Using_the_AddOn_namespace](https://wowpedia.fandom.com/wiki/Using_the_AddOn_namespace)
--- @return Namespace
function ABP_Namespace(...)
    --- @type string
    local addon

    --- @type Namespace
    local ns
    addon, ns = ...
    assert(ns, "Did you pass `...` when calling ABP_Namespace(...)?")

    ---this is in case we are testing outside of World of Warcraft
    addon = addon or ABP_GlobalConstants.C.ADDON_NAME

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- The AddOn Name, i.e. "ActionbarPlus"
    --- @type string
    ns.name = addon
    --- @type ActionbarPlus_AceDB
    ns.db = ns.db or {}
    --- Core exists in both ns.Core and ns.O.Core
    --- @type Core
    ns.Core = ns.Core or nil

    --- @type Module
    ns.M = ns.M or {}

    --- LibStub exists in both ns.LibStub and ns.O.LibStub
    --- @type LocalLibStub
    ns.LibStub = ns.LibStub or nil

    K_Mixin(ns, LibPackMixin)

    --- @param o Namespace
    local function Methods(o)
        --- @return CursorUtil
        function o:CreateCursorUtil() return MixinAndInit(L, O.API:GetCursorInfo()) end
        --- @param start number
        --- @param increment number
        --- @return Kapresoft_LibUtil_Incrementer
        function o:CreateIncrementer(start, increment) return CreateIncrementer(start, increment) end
    end

    Methods(ns)

    return ns
end

--- ```
--- local O, LibStub, ns = ABP_LibPack(...)
--- ```
--- @return GlobalObjects, LocalLibStub, Namespace
function ABP_LibPack(...) return ABP_Namespace(...):LibPack()  end
--- ```
--- local O, GC, ns = ABP_LibPack2(...)
--- ```
--- @return (GlobalObjects, GlobalConstants, Namespace)
function ABP_LibPack2(...) return ABP_Namespace(...):LibPack2()  end
