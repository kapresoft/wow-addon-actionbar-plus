--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = abp_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()
local GHOST_WOLF_SPELL_ID = 2645

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

--- @return ShamanUnitMixin, Logger
local function CreateLib()
    local libName = M.ShamanUnitMixin
    --- @class __ShamanUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = LC.UNIT:NewLogger(libName)
    --- @alias ShamanUnitMixin __ShamanUnitMixin | BaseLibraryObject
    O.UnitMixin:Embed(newLib)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __ShamanUnitMixin
local function PropsAndMethods(o)
    o.GHOST_WOLF_SPELL_ID = GHOST_WOLF_SPELL_ID

    function o:IsShamanClass()
        return GC.UnitClasses.SHAMAN.name == self:GetUnitClass('player')
    end

    ---@param spellID SpellID
    function o:IsGhostWolfSpell(spellID) return spellID == GHOST_WOLF_SPELL_ID end

    --- @return boolean True if in Ghost Wolf form, false otherwise.
    function o:IsInGhostWolfForm() return self:IsBuffActive(GHOST_WOLF_SPELL_ID) end

end; PropsAndMethods(L)

