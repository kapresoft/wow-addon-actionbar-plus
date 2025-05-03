--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

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
    o.SHADOW_FORM_SPELL_ID = 15473
    o.SHADOW_FORM_SPELL_ID_RETAIL = 232698

    function o:IsPriestClass()
        local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.PRIEST.id == id;
    end

    --- @return boolean
    function o:IsShapeShifted() return GetShapeshiftForm() > 0 end

    ---@param spellID SpellID
    function o:IsInShadowFormSpell(spellID)
        return spellID == self.SHADOW_FORM_SPELL_ID
                or spellID == self.SHADOW_FORM_SPELL_ID_RETAIL end

    --- @return boolean
    function o:IsInShadowForm()
        return self:IsBuffActive(self.SHADOW_FORM_SPELL_ID)
                or self:IsBuffActive(self.SHADOW_FORM_SPELL_ID_RETAIL) end

end; PropsAndMethods(L)

