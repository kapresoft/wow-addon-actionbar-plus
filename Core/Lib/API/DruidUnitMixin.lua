--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns, O, GC, M, LibStub = ABP_NS:namespace(...)

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
end; PropsAndMethods(L)


