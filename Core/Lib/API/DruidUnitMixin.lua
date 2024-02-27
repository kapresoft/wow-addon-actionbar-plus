--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = abp_ns(...)
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local FLIGHT_FORM_SPELLID = 40120
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return DruidUnitMixin, Logger
local function CreateLib()
    local libName = M.DruidUnitMixin
    --- @class __DruidUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateUnitLogger(libName)
    --- @alias DruidUnitMixin __DruidUnitMixin | BaseLibraryObject
    O.UnitMixin:Embed(newLib)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--- @param o __DruidUnitMixin
local function PropsAndMethods(o)

    function o:IsDruidClass()
        local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.DRUID.id == id
    end

    --- @param formSpellId number
    function o:IsActiveForm(formSpellId)
        local shapeShiftFormIndex = GetShapeshiftForm()
        local shapeShiftActive = false
        if shapeShiftFormIndex <= 0 then return shapeShiftActive end
        local icon, active, castable, spellID = GetShapeshiftFormInfo(shapeShiftFormIndex)
        return spellID == formSpellId and active
    end

    --- @param spellID SpellID
    --- @return Boolean
    function o:IsFlightForm(spellID) return spellID == FLIGHT_FORM_SPELLID end

    --- @return Boolean
    function o:IsFlightFormUsable() return true == IsUsableSpell(FLIGHT_FORM_SPELLID) end

    --- @param spellID SpellID
    --- @return Boolean
    function o:IsFlightFormAndUsable(spellID)
        return self:IsFlightForm(spellID) and self:IsFlightFormUsable()
    end

end; PropsAndMethods(L)


