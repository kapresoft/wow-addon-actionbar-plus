--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns, O, GC, M, LibStub = ABP_NS:namespace(...)
local Table = O.Table
local IsAnyOf = O.String.IsAnyOf
local TableIsEmpty = O.Table.IsEmpty

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return UnitMixin, LoggerV2
local function CreateLib()
    local libName = M.UnitMixin
    --- @class UnitMixin : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    return newLib, ns:CreateUnitLogger(libName)
end; local L, p = CreateLib(); if not L then return end

--- Checks if the first argument matches any of the subsequent arguments.
--- @param toMatch number The value to match against the varargs.
--- @param ... SpellInfoShort The list of values to check for a match.
--- @return boolean True if `toMatch` is found in the varargs, false otherwise.
local function IsAnyOfBuff(toMatch, ...)
    for i = 1, select('#', ...) do
        --- @type SpellInfoShort
        local val = select(i, ...)
        local spellID = val and val.id
        if toMatch == spellID then return true end
    end
    return false
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o UnitMixin
local function PropsAndMethods(o)

    --- @return UnitMixin
    function o:New(obj)
        obj = obj or {}
        return ns:K():Mixin(obj, self)
    end
    function o:Embed(obj) return self:New(obj) end

    --- Class names are not locale-specific (The second return value of UnitClass())
    ---Example:
    --- @param optionalUnit string
    --- @see GlobalConstants#UnitId
    --- @see Blizzard_UnitId
    --- @return string, number One of DRUID, ROGUE, PRIEST, etc...
    function o:GetUnitClass(optionalUnit)
        optionalUnit = optionalUnit or 'player'
        return select(2, UnitClass(optionalUnit))
    end

    --- @see GC#UnitClasses
    --- @return string, number One of DRUID, ROGUE, PRIEST, etc...
    function o:GetPlayerUnitClass()
        return self:GetUnitClass(GC.UnitId.player)
    end

    --- /dump select(2, UnitClass('player'))
    ---Example:
    ---```
    ---local playerClass = 'DRUID'
    ---local isValidClass = IsPlayerClassAnyOf('DRUID','ROGUE', 'PRIEST')
    ---assertThat(isValidClass).IsTrue()
    ---```
    --- @param ... any list of class enum names.
    --- @return boolean
    function o:IsPlayerClassAnyOf(...)
        local unitClass = self:GetUnitClass()
        return unitClass and IsAnyOf(unitClass, ...)
    end

    --- @param ... any list of Unit Class IDs
    --- @return boolean
    function o:IsPlayerClassAnyOfID(...)
        local _, _, unitClassID = UnitClass('player')
        return unitClassID and GC:IsAnyOfNumber(unitClassID, ...)
    end

    --- @param index Index
    --- @return SpellID
    local function GetBuffSpellID(index)
        local _, _, _, _, _, _, _, _, _, unitBuffSpellId = UnitBuff("player", index)
        return unitBuffSpellId
    end

    --- Inefficient. Use #IsBuffActive
    function o:HasBuff(spellID)
        for i = 1, 40 do
            if spellID == GetBuffSpellID(i) then return true end
        end
        return false
    end

    --- @alias UnitBuffFilterFunction fun(spellID:SpellID) : void

    function o:GetShapeshiftSpells()
        return O.ShamanUnitMixin.GHOST_WOLF_SPELL_ID,
               O.PriestUnitMixin.SHADOW_FORM_SPELL_ID
    end

    function o:UpdateShapeshiftBuffs()
        self:UpdateBuffs(function(spellID)
            return GC:IsAnyOfNumber(spellID, self:GetShapeshiftSpells());
        end)
    end

    --- @param filterFn UnitBuffFilterFunction | "function(spellID)  end"
    function o:UpdateBuffs(filterFn)
        self:ClearBuffs()
        for i = 1, 40 do
            local spellID = GetBuffSpellID(i)
            if spellID then
                local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(spellID)
                if filterFn(spellID) then
                    --- @type SpellInfoShort
                    local spellInfo = { id = spellID, name = name }
                    table.insert(ns.playerBuffs, spellInfo)
                end
            end
        end
    end

    function o:ClearBuffs()
        ns.playerBuffs = {}
    end

    ---@param spellID SpellID
    function o:IsBuffActive(spellID)
        if TableIsEmpty(ns.playerBuffs) then return false end
        -- p:v(function() return 'playerBuffs: %s', pformat(ns.playerBuffs) end)
        return IsAnyOfBuff(spellID, Table.unpack(ns.playerBuffs))
    end

end; PropsAndMethods(L)

