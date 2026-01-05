--[[-----------------------------------------------------------------------------
This controller handles both AutoRepeatSpell and IsCurrentSpell(nameOrId)
-------------------------------------------------------------------------------]]
local floor = math.floor

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local Compat, API, E, M = O.Compat, O.API, GC.E, GC.M
local ABH = O.ActionBarHandlerMixin

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'AutoRepeatSpellController'
--- @class AutoRepeatSpellController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
local ps = ns:LC().SPELL:NewLogger(libName)
--[[-----------------------------------------------------------------------------
Aliases
-------------------------------------------------------------------------------]]
--- @alias IsChecked boolean
--- @alias IsAutoRepeat boolean
--- @alias IsAutoAttack boolean

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
-- TODO: Need to add other auto repeat spells
---@param bw ButtonUIWidget
local function IsAutoRepeatSpellPredicate(bw)
    local spellID = bw:GetEffectiveSpellID()
    return API:IsShootSpell(spellID)
end

--- @param spellID SpellID
--- @return IsChecked, IsAutoRepeat, IsAutoAttack
local function ShouldCheck(spellID)
    local isAutoRepeat = Compat:IsAutoRepeatSpell(spellID)
    local isAutoAttack = API:IsCurrentlyAutoAttacking(spellID)
    local isShootSpell = API:IsShootSpell(spellID)
    return isAutoRepeat == true or isAutoAttack == true, isAutoRepeat, isAutoAttack, isShootSpell
end

--- @param w ButtonUIWidget
local function GetUniqueName(w) return libName .. '::' .. w:GetName() end

--- @param btn ButtonUI
--- @param elapsed TimeInMilli
local function OnUpdateFlashingHandler(btn, elapsed)
    local w       = btn.widget
    local spellID = w:GetEffectiveSpellID(); if not spellID then return end
    local tex = btn:GetNormalTexture(); if not tex then return end

    local shouldCheck, isAutoRepeat, isAutoAttack = ShouldCheck(spellID)
    w:SetChecked(shouldCheck)

    if isAutoRepeat or isAutoAttack then
        local t = floor(GetTime() * 10) % 8  -- cycle every 0.8s

        if t < 4 then
            tex:SetVertexColor(1, 0, 0, 1) -- red
        else
            tex:SetVertexColor(1, 1, 1, 1) -- white
        end
    else
        tex:SetVertexColor(1, 1, 1, 1)
        w:SetChecked(false)
        btn:RemoveOnUpdateCallback(GetUniqueName(w))
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o AutoRepeatSpellController | ControllerV2
local function PropsAndMethods(o)
    -- o.hasUIError = false

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:RegisterMessageCallbacks()
    end

    function o:RegisterMessageCallbacks()
        self:RegisterAddOnMessage(E.PLAYER_ENTER_COMBAT, o.OnPlayerEnterCombat)
        self:RegisterAddOnMessage(E.PLAYER_LEAVE_COMBAT, o.OnPlayerLeaveCombat)
        self:RegisterAddOnMessage(E.START_AUTOREPEAT_SPELL, o.OnStartAutoRepeatSpell)
        self:RegisterAddOnMessage(E.STOP_AUTOREPEAT_SPELL, o.OnStopAutoRepeatSpell)
        self:RegisterMessage(M.OnPostUpdateSpellUsable, o.OnPostUpdateSpellUsable)
        self:RegisterMessage(M.OnAfterDragStart, o.OnAfterDragStart)
    end

    --- When the action is dragged out, the button is EMPTY.
    --- @see ButtonUI#OnReceiveDrag
    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnAfterDragStart(msg, src, w)
        w.button():RemoveOnUpdateCallback(GetUniqueName(w))
    end

    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    function o.OnPlayerEnterCombat(msg, src)
        if Compat:IsCurrentSpell(API.AUTO_ATTACK_SPELL_ID) then
            o:ForEachMatchingSpellButton(API.AUTO_ATTACK_SPELL_ID, function(bw)
                bw:SetChecked(true)
            end)
        end
    end

    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    function o.OnPlayerLeaveCombat(msg, src)
        o:ForEachNonEmptyButton(function(bw)
            bw:SetChecked(false)
        end, function(bw)
            local spID = bw:GetEffectiveSpellID();
            return spID == API.AUTO_ATTACK_SPELL_ID
        end)
    end


    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    function o.OnStartAutoRepeatSpell(msg, src)
        ABH:ForEachAutoRepeatSpellButton(function(bw)
            bw:SetChecked(true)
            bw.button():AddOnUpdateCallback(GetUniqueName(bw), OnUpdateFlashingHandler)
        end)
    end

    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    function o.OnStopAutoRepeatSpell(msg, src)
        ABH:ForEachSpellButton(function(bw)
            bw:SetChecked(false)
            bw.button():RemoveOnUpdateCallback(GetUniqueName(bw))
        end, IsAutoRepeatSpellPredicate)
    end

    -- PLAYER_TARGET_SET_ATTACKING
    --- @param msg Name The message name
    --- @param src Name Should be from ButtonMixin
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnPostUpdateSpellUsable(msg, src, w)
        local spellID = w and w:GetEffectiveSpellID();
        if not spellID then return end

        local shouldCheck, isAutoRepeat, isAutoAttack, isShootSpell = ShouldCheck(spellID)
        -- The 'Shoot' spell returns isAuto=false if not actively shooting
        if not (isAutoRepeat or isAutoAttack or isShootSpell) then
            return
        end

        if not shouldCheck then
            w.button():RemoveOnUpdateCallback(GetUniqueName(w))
            return w:SetChecked(false)
        end

        w:SetChecked(true)
        w.AutoRepeatSpell = { flashing = 0, flashTime = 0 }
        w.button():AddOnUpdateCallback(GetUniqueName(w), OnUpdateFlashingHandler)
    end

end; PropsAndMethods(L)

