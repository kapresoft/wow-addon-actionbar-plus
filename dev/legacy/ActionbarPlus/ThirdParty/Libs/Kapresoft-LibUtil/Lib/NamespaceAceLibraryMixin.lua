--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)
local LU = ns.Kapresoft_LibUtil
local O, M = LU.Objects, LU.M
local LibStub, Ace = LU.LibStub, O.AceLibrary.O
local ModuleName = M.NamespaceAceLibraryMixin()

--[[-----------------------------------------------------------------------------
Type: LibPackMixin
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_NamespaceAceLibraryMixin
local L = LibStub:NewLibrary(ModuleName, 3)

-- return if already loaded (this object can exist in other addons)
if not L then return end

---@param o Kapresoft_LibUtil_NamespaceAceLibraryMixin
local function MethodsAndProps(o)

    --- Create a new instance of AceEvent or embed to an obj if passed
    --- @return AceEvent
    --- @param obj|nil The object to embed or nil
    function o:AceEvent(obj) return Ace.AceEvent:Embed(obj or {}) end

    --- Create a new instance of AceBucket or embed to an obj if passed
    --- @return AceBucket
    --- @param obj|nil The object to embed or nil
    function o:AceBucket(obj) return Ace.AceBucket:Embed(obj or {}) end

    --- @param obj|nil The object to embed or nil
    --- @return AceHook
    function o:AceHook(obj) return Ace.AceHook:Embed(obj or {}) end

    --- @return AceLocale
    function o:AceLocale() return Ace.AceLocale:GetLocale(self.addon, true) end

end; MethodsAndProps(L)
