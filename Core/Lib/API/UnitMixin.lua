--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, Compat = ns.O, ns.GC, ns.M, ns.O.Compat

local Table, IsAnyOf = ns:Table(), ns:String().IsAnyOf
local TableIsEmpty, TableUnpack = Table.IsEmpty, Table.unpack

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.UnitMixin
--- @class UnitMixin : BaseLibraryObject
local L = ns:NewLibStd(libName)
local p = ns:LC().UNIT:NewLogger(libName)

--- Checks if the first argument matches any of the subsequent arguments.
--- @param toMatch number The value to match against the varargs.
--- @vararg string SpellInfoShort The list of values to check for a match.
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
        return ns:K():Mixin(obj, o)
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

    --- Inefficient. Use #IsBuffActive
    function o:HasBuff(spellID)
        for i = 1, 40 do
            if spellID == Compat:GetBuffSpellID(i) then return true end
        end
        return false
    end

    --- @alias UnitBuffFilterFunction fun(spellID:SpellID) : void

    function o:GetShapeshiftSpells()
        return O.ShamanUnitMixin.GHOST_WOLF_SPELL_ID,
               O.PriestUnitMixin.SHADOW_FORM_SPELL_ID,
               O.DruidUnitMixin.PROWL_SPELL_ID
    end

    function o:UpdateShapeshiftBuffs()
        self:UpdateBuffs(function(spellID)
            return GC:IsAnyOfNumber(spellID, self:GetShapeshiftSpells());
        end)
    end

    --- TODO: Move to API
    ---@param spellName SpellName
    function o:IsOwnSpell(spellName)
        if spellName == nil then return false end
        local name, spellID = O.API:GetSpellName(spellName)
        local isUsable = spellID ~= nil
        --p:t(function() return 'IsUsable Spell: id=%s name=%s: %s',
        --        tostring(spellID), tostring(spellName), tostring(isUsable) end)
        return isUsable
    end

    --- @param filterFn UnitBuffFilterFunction | "function(spellID)  end"
    function o:UpdateBuffs(filterFn)
        self:ClearBuffs()
        for i = 1, 40 do
            local spellID = Compat:GetBuffSpellID(i)
            if spellID then
                local spellName = O.API:GetSpellName(spellID)
                if filterFn(spellID) and self:IsOwnSpell(spellName) then
                    local name = O.API:GetSpellName(spellID)
                    p:t(function() return "Own spell: id=%s name=%s", spellID, tostring(name) end)
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
        p:d(function() return 'IsBuffActive(): Player-Buffs: %s', pformat(ns.playerBuffs) end)
        return IsAnyOfBuff(spellID, TableUnpack(ns.playerBuffs))
    end

    local function NewTalentInfo()
        --- @class TalentInfo
        local info = {
            --- @type table<number, Name>
            names = {},
            --- @type table<Name, number>
            points = {},
            --- @type string
            spec = nil,
            talentIndex = -1,
            --- @type string
            icon = nil,
        }
        return info
    end

    --- @class TalentTabInfoMixin
    local TalentTabInfoMixin = {}
    --- @param name Name
    --- @param icon TextureIDOrPath
    --- @param pointsSpent Number
    --- @return TalentTabInfo
    function TalentTabInfoMixin:New(name, icon, pointsSpent)
        --- @class TalentTabInfo
        local info = { name = name, icon = icon, pointsSpent = pointsSpent }
        return info
    end

    --- @return TalentInfo
    function o:GetTalentInfo()
        if ns:IsRetail() then return self:GetTalentInfoRetail() end
        if not GetNumTalentTabs then return nil end
        return self:GetTalentInfoPreRetail()
    end

    --- @param tabIndex Index
    local function GetTalentTabInfoPreCataclysm(tabIndex)
        local name, icon, pointsSpent = GetTalentTabInfo(tabIndex)
        return TalentTabInfoMixin:New(name, icon, pointsSpent)
    end

    --- @param tabIndex Index
    local function GetTalentTabInfo_Cataclysm(tabIndex)
        local id, name, talentDesc, icon, pointsSpent = GetTalentTabInfo(tabIndex)
        return TalentTabInfoMixin:New(name, icon, pointsSpent)
    end

    --- @private
    --- @return TalentInfo
    function o:GetTalentInfoPreRetail()
        local totalPoints = 0

        --- @type TalentInfo
        local info = NewTalentInfo()
        function info:summary()
            local s = {}
            for name, points in pairs(self.points) do
                points = points or 0
                table.insert(s, name .. ': ' .. tostring(points))
            end
            return table.concat(s, ', ')
        end
        --- @param callbackFn fun(name:string, points:number) | "function(name, points) end"
        function info:ForEachTalent(callbackFn)
            for name, points in pairs(self.points) do
                points = points or 0
                callbackFn(name, points)
            end
        end

        local max = 0
        -- /dump GetTalentTabInfo(1)
        for i = 1, GetNumTalentTabs() do
            --- @type TalentTabInfo
            local tabInfo
            if ns:IsCataclysm() then tabInfo = GetTalentTabInfo_Cataclysm(i)
            else tabInfo = GetTalentTabInfoPreCataclysm(i) end

            if tabInfo then
                table.insert(info.names, tabInfo.name)
                info.points[tabInfo.name] = tabInfo.pointsSpent
                --p:vv(function() return 'i-%s: PointsSpent=%s,%s Max=%s', i, type(pointsSpent), pointsSpent, type(max) end)
                if tabInfo.pointsSpent > max then
                    info.spec = tabInfo.name
                    info.talentIndex = i
                    info.icon = ns.sformat('|T%s:18:18:0:0|t', tabInfo.icon)
                    max = tabInfo.pointsSpent
                end
                totalPoints = totalPoints + tabInfo.pointsSpent
            end
        end
        return info
    end

    --- @private
    --- @return TalentInfo
    function o:GetTalentInfoRetail()
        --- @type TalentInfo
        local info = NewTalentInfo()
        function info:summary() return nil end

        --- @param callbackFn fun(name:string, points:number) | "function(name, points) end"
        function info:ForEachTalent(callbackFn) end

        local specIndex = GetSpecialization(); if not specIndex then return nil end
        local _, spec = GetSpecializationInfo(specIndex); info.spec = spec
        p:d(function() return 'TalentInfo(): Spec=%s', spec end)
        return info
    end

end; PropsAndMethods(L)

