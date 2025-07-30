--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]

--- @class RangeIndicatorUtil_Instance
--- @field private New fun(self:RangeIndicatorUtil_Instance)
--- @field private Init fun(self:ButtonUIWidget)

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UnitIsFriend, UnitIsDead = UnitIsFriend, UnitIsDead

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local K, O, GC = ns:K(), ns.O, ns.GC
local u   = GC.UnitId
local compat = O.Compat
local api = O.API

--[[-----------------------------------------------------------------------------
Module
-------------------------------------------------------------------------------]]
local libName = ns.M.RangeIndicatorUtil
--- @class RangeIndicatorUtil
local S = {}
local p = ns:CreateDefaultLogger(libName)

--- @type RangeIndicatorUtil
local LIB = S; ns:Register(libName, LIB)

--- @return RangeIndicatorUtil_Instance
--- @param bw ButtonUIWidget
function LIB:New(bw)  return K:CreateAndInitFromMixin(S, bw) end
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
-- UnitCanAssist('player', 'target')
--local function PlayerCanAssistTarget() return UnitCanAssist(u.player, u.target) == true end
--local function TargetIsHarmful() return not PlayerCanAssistTarget() end
--local function SpellRangeFn(spellID, unitID) return api():IsSpellInRange(spellID, unitID) end
--local function ItemRangeFn(itemID, unitID) return api():IsSpellInRange(itemID, unitID) end

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]
--- @type RangeIndicatorUtil_Instance
local o = S

--- @param bw ButtonUIWidget
function o:Init(bw) self.w = bw end

--- @param bw ButtonUIWidget
--- @param unitID UnitID
function o:Button_UpdateRangeIndicator(bw, unitID)
    if type(unitID) ~= 'string' then unitID = UnitNameUnmodified(u.target) and u.target end

    local kbt            = bw.kbt
    local kbf            = kbt:GetKeybindText()
    local hasKeyBindings = kbt:HasKeybindings()

    -- The default indicator is a 'dot'
    if not hasKeyBindings then
        kbf:SetTextAsRangeIndicator()
    end

    local c = bw:conf()
    local inRange
    local itemID, itemN = bw:GetEffectiveItemID()
    if itemID then
        -- check item before spell because items can have spellIDs
        -- and we don't want to range check spellIDs for items
        inRange = api:IsItemInRange(itemID, unitID)
    else
        local spid = bw:GetEffectiveSpellID()
        inRange = spid and api:IsSpellInRange(spid, unitID)
    end

    -- inRange = nil means spell, item, etc., does not apply to target
    if inRange == nil then return end

    kbt:ShowKeybindText()
    if inRange == true then return kbf:SetVertexColorNormal() end
    kbf:SetVertexColorOutOfRange()
end

--- We don't know whether unit is friend or enemy
--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
--- @param spID EffectiveSpellIdentifier
--- @param unitID UnitID
--- @return boolean|nil Returns nil if the action does not apply to the unitId
function o:UpdateWhenUnitIsDead(bw, c, spID, unitID) end

--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
--- @param spID EffectiveSpellIdentifier
--- @param unitID UnitID
--- @return boolean|nil Returns nil if the action does not apply to the unitId
function o:InRangeHelpfulAction(bw, c, spID, unitID)
    --local neither, _, harmful = api:IsSpellNeitherHelpOrHarmful(spID)
    --if neither or harmful then return nil end
    return api:IsSpellInRange(spID, unitID)
end

--- @param bw ButtonUIWidget
--- @param c ButtonProfileConfigMixin
--- @param spID EffectiveSpellIdentifier
--- @param unitID UnitID
--- @return boolean|nil Returns nil if the action does not apply to the unitId
function o:InRangeHarmfulAction(bw, c, spID, unitID)
    --local neither, helpful = api:IsSpellNeitherHelpOrHarmful(spID)
    --if neither or helpful then return nil end
    return api:IsSpellInRange(spID, unitID)
end

function o:ClearRangeIndicator()
    local kbt = self.w.kbt
    local kbf = kbt:GetKeybindText()

    if not kbt:HasKeybindings() then
        kbt:HideKeybindText()
    else
        kbf:SetVertexColorNormal()
    end
end
