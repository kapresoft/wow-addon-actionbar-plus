--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return RogueUnitMixin, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.RogueUnitMixin or 'RogueUnitMixin'
    --- @class __RogueUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:LC().UNIT:NewLogger(libName)
    --- @alias RogueUnitMixin __RogueUnitMixin | BaseLibraryObject
    O.UnitMixin:Embed(newLib)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o __RogueUnitMixin
local function PropsAndMethods(o)
    o.STEALTH_SPELL_ID = 1784

    function o:IsRogueClass()
        local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.ROGUE.id == id
    end

    --- @param spellID SpellID
    --- @return Boolean
    function o:IsStealth(spellID) return spellID == self.STEALTH_SPELL_ID end

end; PropsAndMethods(L)

