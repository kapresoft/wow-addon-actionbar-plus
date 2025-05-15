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
local Compat, MSG = O.Compat, GC.M
local T_Unpack = ns:KO().Table.unpack
local AUTO_REPEAT_SPELL_FLASH_TIME = 0.4
local ABH                          = O.ActionBarHandlerMixin

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
--- @alias IsAuto boolean
--- @alias IsAutoAttack boolean

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param spellID SpellID
--- @return IsChecked, IsAuto, IsAutoAttack
local function IsChecked(spellID)
    local isAuto       = Compat:IsAutoRepeatSpell(spellID)
    local isAutoAttack = Compat:IsAutoAttackSpell(spellID)
    return isAuto == true or isAutoAttack == true, isAuto, isAutoAttack
end

--- @param w ButtonUIWidget
local function GetUniqueName(w) return libName .. '::' .. w:GetName() end

--- @param btn ButtonUI
--- @param elapsed TimeInMilli
local function OnUpdateFlashingHandler(btn, elapsed)
    local w       = btn.widget
    local spellID = w:GetEffectiveSpellID(); if not spellID then return end
    local tex = btn:GetNormalTexture(); if not tex then return end

    local checked, isAuto, isAutoAttack = IsChecked(spellID)
    w:SetChecked(checked)

    if isAuto or isAutoAttack then
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
        self:RegisterMessage(GC.M.OnButtonAfterPostClick, o.OnButtonAfterPostClick)
        self:RegisterMessage(GC.M.OnPostUpdateSpellUsable, o.OnPostUpdateSpellUsable)
        self:RegisterMessage(GC.M.OnAfterDragStart, o.OnAfterDragStart)
        self:RegisterAddOnMessage(GC.E.PLAYER_TARGET_SET_ATTACKING, o.OnPlayerStartAttacking)
    end

    --- When the action is dragged out, the button is EMPTY.
    --- @see ButtonUI#OnReceiveDrag
    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnAfterDragStart(msg, src, w)
        w.button():RemoveOnUpdateCallback(GetUniqueName(w))
    end

    --- When the action is dragged out, the button is EMPTY.
    --- @see ButtonUI#OnReceiveDrag
    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnPlayerStartAttacking(msg, src, w)
        o:ForEachMatchingSpellButton(6603, function(bw)
            bw:SetChecked(true)
            bw.button():AddOnUpdateCallback(GetUniqueName(bw), OnUpdateFlashingHandler)
        end)
    end

    --- @param msg Name The message name
    --- @param src Name Should be from 'ButtonUI'
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnButtonAfterPostClick(msg, src, w)
        if not w:IsSpell() then return end
        local spellID     = w:GetEffectiveSpellID()
        local checked, isAuto, isAutoAttack = IsChecked(spellID)
        local matchErrors = { LE_GAME_ERR_GENERIC_NO_TARGET, LE_GAME_ERR_SPELL_OUT_OF_RANGE }

        if isAuto then
            if ns:uie():HasErrorCodes(T_Unpack(matchErrors)) then checked = false end
            w:SetChecked(checked)
        elseif isAutoAttack then
            -- always check regardless
            checked = true
            w:SetChecked(checked)
        end
        ABH:ForEachMatchingSpellButton(spellID, function(bw) bw:SetChecked(checked) end)
    end

    -- PLAYER_TARGET_SET_ATTACKING
    --- @param msg Name The message name
    --- @param src Name Should be from ButtonMixin
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnPostUpdateSpellUsable(msg, src, w)
        local spellID = w and w:GetEffectiveSpellID();
        if not spellID then return end
        local isChecked, isAuto, isAutoAttack = IsChecked(spellID)

        if isChecked == true then
            w:SetChecked(isChecked)
        else
            w.button():RemoveOnUpdateCallback(GetUniqueName(w))
            return w:SetChecked(false)
        end

        w.AutoRepeatSpell = { flashing = 0, flashTime = 0 }
        if isAuto == true then
            -- The autoAttack is handled in #OnPlayerStartAttacking()
            w.button():AddOnUpdateCallback(GetUniqueName(w), OnUpdateFlashingHandler)
        end

    end

end; PropsAndMethods(L)

