--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local BEAR_SHAPESHIFT_FORM_INDEX = 1
local CAT_SHAPESHIFT_FORM_INDEX = 3
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- Converts a list of spellIDs into a set-style lookup table for fast boolean checks.
--- @param list number[] @An array of numeric spellIDs.
--- @return table<number, boolean> @A lookup table where each spellID is a key with value true.
local function LT(list)
    local t = {}
    for _, id in ipairs(list) do t[id] = true end
    return t
end

--- Merges the contents of a lookup table into another.
--- @param target table<number, boolean>
--- @param source table<number, boolean>
local function MergeLT(target, source)
    for spellID in pairs(source) do
        target[spellID] = true
    end
end

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
    O.UnitMixin:New(newLib, 'DRUID')
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--- @param o __DruidUnitMixin
local function PropsAndMethods(o)

    o.DRUID_FORM_ACTIVE_ICON = 136116

    o.PROWL_SPELL_ID = 5215
    o.CAT_FORM_SPELL_ID = 768
    o.TRAVEL_FORM_SPELL_ID = 783
    o.AQUATIC_FORM_SPELL_ID = 1066
    o.BEAR_FORM_SPELL_ID = 5487
    o.MOONKIN_FORM_SPELL_ID = 24858
    o.FLIGHT_FORM_SPELLID = 40120
    o.SWIFT_FLIGHT_FORM_SPELL_ID = 40120

    o.CATACLYSM_SWIPE_BEAR_SPELL_ID = 779
    o.CATACLYSM_SWIPE_CAT_SPELL_ID  = 62078

    o.CATACLYSM_MANGLE_BEAR_SPELL_ID  = 33878
    o.CATACLYSM_MANGLE_CAT_SPELL_ID  = 33876

    o.CATACLYSM_SKULL_BASH_BEAR_SPELL_ID  = 80964
    o.CATACLYSM_SKULL_BASH_CAT_SPELL_ID  = 80965

    o.CATACLYSM_FERAL_CHARGE_BEAR_SPELL_ID  = 16979
    o.CATACLYSM_FERAL_CHARGE_CAT_SPELL_ID  = 49376

    --- @type table<number, boolean>
    local CATACLYSM_CAT_SPELLS = LT({
                                        o.CATACLYSM_SWIPE_CAT_SPELL_ID,
                                        o.CATACLYSM_MANGLE_CAT_SPELL_ID,
                                        o.CATACLYSM_SKULL_BASH_CAT_SPELL_ID,
                                        o.CATACLYSM_FERAL_CHARGE_CAT_SPELL_ID,
                                    })
    --- @type table<number, boolean>
    local CATACLYSM_BEAR_SPELLS = LT({
                                         o.CATACLYSM_SWIPE_BEAR_SPELL_ID,
                                         o.CATACLYSM_MANGLE_BEAR_SPELL_ID,
                                         o.CATACLYSM_SKULL_BASH_BEAR_SPELL_ID,
                                         o.CATACLYSM_FERAL_CHARGE_BEAR_SPELL_ID,
                                     })

    -- TODO next: Retail Behavior
    -- Thrash works with SettAttribute('spell', 'Thrash')
    -- Need to handle tooltip correctly
    -- If bear, shows Thrash Bear (spID 7758)
    -- If cat, shows Thrash Cat (spID 106830)
    -- TBD: Thrash Bear returns nil if char is in cat form and vice versa
    -- IDEA: On Spec Change, go through all the dual Bear/Cat spells and reset attribute?

    --- @type table<number, boolean>
    local CATACLYSM_SPECIALIZED_SPELLS = (function()
        local sp = {}; MergeLT(sp, CATACLYSM_CAT_SPELLS); MergeLT(sp, CATACLYSM_BEAR_SPELLS); return sp
    end)();

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

    function o:IsCataclysmDruid() return ns:IsCataclysm() and self:IsUs() end

    --- Checks if the given spellID is part of the known Druid action spellIDs.
    --- @param spellID SpellID
    --- @return boolean
    function o:IsCataclysmDruidSpecializedSpell(spellID)
        if not self:IsCataclysmDruid() then return end
        return CATACLYSM_SPECIALIZED_SPELLS[spellID] == true
    end

    --- Checks if the given spellID is a known Cat Form spell in Cataclysm Classic.
    --- @param spellID SpellID
    --- @return boolean
    function o:IsCatSpell(spellID) return CATACLYSM_CAT_SPELLS[spellID] == true end

    --- Checks if the given spellID is a known Cat Form spell in Cataclysm Classic.
    --- @param spellID SpellID
    --- @return boolean
    function o:IsBearSpell(spellID) return CATACLYSM_BEAR_SPELLS[spellID] == true end

    function o:IsDruidClass()
        local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.DRUID.id == id
    end

    --- @param spellID SpellID
    --- @return boolean
    function o:IsCataclysmDruidSwipe(spellID)
        if not ns:IsCataclysm() and not self:IsUs() then return false end
        return o.CATACLYSM_SWIPE_BEAR_SPELL_ID == spellID
                or o.CATACLYSM_SWIPE_CAT_SPELL_ID == spellID
    end

    function o:GetCurrentFormName()
        local index = GetShapeshiftForm()
        local _, _, _, spellID = GetShapeshiftFormInfo(index)
        return spellID and GetSpellInfo(spellID)
    end

    function o:GetBearFormName()
        local _, _, _, spellID = GetShapeshiftFormInfo(BEAR_SHAPESHIFT_FORM_INDEX)
        return spellID and GetSpellInfo(spellID)
    end
    function o:GetCatFormName()
        local _, _, _, spellID = GetShapeshiftFormInfo(CAT_SHAPESHIFT_FORM_INDEX)
        return spellID and GetSpellInfo(spellID)
    end

    function o:GetFormActiveIcon() return o.DRUID_FORM_ACTIVE_ICON end

    --- @param spellInfo Profile_Spell
    --- @return Icon The shapeshift icon
    function o:GetShapeshiftIcon(spellInfo)
        if not spellInfo then return nil end
        if self:IsShapeShiftActive(spellInfo) then return self:GetFormActiveIcon() end
        return spellInfo.icon
    end
end; PropsAndMethods(L)


