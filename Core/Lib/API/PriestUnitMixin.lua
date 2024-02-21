--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns, O, GC, M, LibStub = ABP_NS:namespace(...)
local SHADOW_FORM_SPELL_ID = 15473

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return PriestUnitMixin, LoggerV2
local function CreateLib()
    local libName = M.PriestUnitMixin
    --- @class __PriestUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    --- @alias PriestUnitMixin __PriestUnitMixin | BaseLibraryObject
    O.UnitMixin:Embed(newLib)
    return newLib, ns:CreateDefaultLogger(libName)
end; local L, p = CreateLib(); if not L then return end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __PriestUnitMixin
local function PropsAndMethods(o)
    o.SHADOW_FORM_SPELL_ID = SHADOW_FORM_SPELL_ID

    function o:IsPriestClass()
        local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.PRIEST.id == id;
    end

    --- @return boolean
    function o:IsShapeShifted() return GetShapeshiftForm() > 0 end

    ---@param spellID SpellID
    function o:IsInShadowFormSpell(spellID) return spellID == SHADOW_FORM_SPELL_ID end

    --- @return boolean
    function o:IsInShadowForm() return self:IsBuffActive(SHADOW_FORM_SPELL_ID) end

end; PropsAndMethods(L)

