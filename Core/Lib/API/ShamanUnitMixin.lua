--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local GHOST_WOLF_SPELL_ID = 2645

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

--- @return ShamanUnitMixin, Logger
local function CreateLib()
    local libName = M.ShamanUnitMixin
    --- @class __ShamanUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:LC().UNIT:NewLogger(libName)
    --- @alias ShamanUnitMixin __ShamanUnitMixin | BaseLibraryObject
    O.UnitMixin:New(newLib, 'SHAMAN')
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __ShamanUnitMixin
local function PropsAndMethods(o)
    o.GHOST_WOLF_SPELL_ID = GHOST_WOLF_SPELL_ID
    o.GHOST_WOLF_FORM_ACTIVE_ICON = 136116

    ---@param spellID SpellID
    function o:IsGhostWolfSpell(spellID) return spellID == GHOST_WOLF_SPELL_ID end

    --- @return boolean True if in Ghost Wolf form, false otherwise.
    function o:IsInGhostWolfForm() return self:IsBuffActive(GHOST_WOLF_SPELL_ID) end

    --- @return Icon The icon if form is active
    function o:GetFormActiveIcon() return o.GHOST_WOLF_FORM_ACTIVE_ICON end

end; PropsAndMethods(L)

