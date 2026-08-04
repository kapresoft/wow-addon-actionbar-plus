--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)
local LU = ns.Kapresoft_LibUtil
local O, M = LU.Objects, LU.M
local LibStub = LU.LibStub

local ModuleName = M.NamespaceKapresoftLibMixin()

--[[-----------------------------------------------------------------------------
Type: LibPackMixin
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_NamespaceKapresoftLibMixin
--- @deprecated Use Kapresoft_LibUtil_CoreNamespaceMixin
local L = LibStub:NewLibrary(ModuleName, 2)

-- return if already loaded (this object can exist in other addons)
if not L then return end

---@param o Kapresoft_LibUtil_NamespaceKapresoftLibMixin
local function MethodsAndProps(o)

    --- @return Kapresoft_LibUtil
    function o:K() return LU end
    --- @return Kapresoft_LibUtil_Modules
    function o:KO() return O  end

    --- @return Kapresoft_LibUtil_SequenceMixin
    --- @param startingSequence number|nil
    function o:CreateSequence(startingSequence) return O.SequenceMixin:New(startingSequence) end

    --- @param colorDef Kapresoft_LibUtil_ColorDefinition | Kapresoft_LibUtil_ColorDefinition2
    --- @return Kapresoft_LibUtil_ConsoleHelper
    function o:NewConsoleHelper(colorDef) return O.Constants:NewConsoleHelper(colorDef) end

end; MethodsAndProps(L)
