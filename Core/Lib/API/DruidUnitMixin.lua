--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return DruidUnitMixin, Logger
local function CreateLib()
    local libName = M.DruidUnitMixin
    --- @class __DruidUnitMixin : UnitMixin
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:LC().UNIT:NewLogger(libName)
    --- @alias DruidUnitMixin __DruidUnitMixin | BaseLibraryObject
    O.UnitMixin:Embed(newLib)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--- @param o __DruidUnitMixin
local function PropsAndMethods(o)

    o.PROWL_SPELL_ID = 5215

    o.CAT_FORM_SPELL_ID = 768
    o.TRAVEL_FORM_SPELL_ID = 783
    o.AQUATIC_FORM_SPELL_ID = 1066
    o.BEAR_FORM_SPELL_ID = 5487
    o.MOONKIN_FORM_SPELL_ID = 24858
    o.FLIGHT_FORM_SPELLID = 40120
    o.SWIFT_FLIGHT_FORM_SPELL_ID = 40120

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
    function o:IsFlightForm(spellID) return spellID == self.SWIFT_FLIGHT_FORM_SPELL_ID end

    --- @param spellID SpellID
    --- @return Boolean
    function o:IsProwl(spellID) return spellID == self.PROWL_SPELL_ID end

    --- @return Boolean
    function o:IsFlightFormUsable() return true == IsUsableSpell(self.SWIFT_FLIGHT_FORM_SPELL_ID) end

    --- @param spellID SpellID
    --- @return Boolean
    function o:IsFlightFormAndUsable(spellID)
        return self:IsFlightForm(spellID) and self:IsFlightFormUsable()
    end

    --- @param spellId SpellID
    function o:IsDruidForm(spellId)
        return spellId == o.CAT_FORM_SPELL_ID
                or spellId == o.TRAVEL_FORM_SPELL_ID
                or spellId == o.AQUATIC_FORM_SPELL_ID
                or spellId == o.BEAR_FORM_SPELL_ID
                or spellId == o.MOONKIN_FORM_SPELL_ID
                or spellId == o.SWIFT_FLIGHT_FORM_SPELL_ID
    end

end; PropsAndMethods(L)


