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
Support Functions
-------------------------------------------------------------------------------]]
--- @param w ButtonUIWidget
local function GetUniqueName(w) return libName .. '::' .. w:GetName() end

--- @param btn ButtonUI
--- @param elapsed TimeInMilli
--- @param btn ButtonUI
--- @param elapsed TimeInMilli
local function OnUpdateFlashingHandlerXX(btn, elapsed)
    local w = btn.widget
    local spellName = w:GetEffectiveSpellName(); if not spellName then return end
    local tex = btn:GetNormalTexture(); if not tex then return end

    local d = w.AutoRepeatSpell or {}
    w.AutoRepeatSpell = d
    d.flashTime = (d.flashTime or 0) - elapsed

    local isAuto = Compat:IsAutoRepeatSpell(spellName)
    w:SetChecked(isAuto)

    if isAuto then
        if d.flashTime <= 0 then
            local r, g, b = tex:GetVertexColor()
            if r == 1 and g == 0 and b == 0 then
                tex:SetVertexColor(1, 1, 1, 1)
            else
                tex:SetVertexColor(1, 0, 0, 1)
            end
            d.flashTime = AUTO_REPEAT_SPELL_FLASH_TIME
        end
    else
        tex:SetVertexColor(1, 1, 1, 1)
        d.flashTime = nil
        w:SetChecked(false)
        btn:RemoveOnUpdateCallback(GetUniqueName(w))
        p:vv(function() return "Auto-repeat stopped for: %s", spellName end)
    end
end

local floor = math.floor

--- @param btn ButtonUI
--- @param elapsed TimeInMilli
local function OnUpdateFlashingHandler(btn, elapsed)
    local w = btn.widget
    local spellName = w:GetEffectiveSpellName(); if not spellName then return end
    local tex = btn:GetNormalTexture(); if not tex then return end

    local isAuto = Compat:IsAutoRepeatSpell(spellName)
    w:SetChecked(isAuto)

    if isAuto then
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
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnButtonAfterPostClick(msg, src, w)
        if not w:IsSpell() then return end
        local spId = w:GetEffectiveSpellID()
        local matchErrors = { LE_GAME_ERR_GENERIC_NO_TARGET, LE_GAME_ERR_SPELL_OUT_OF_RANGE }

        local checked = true
        if ns:uie():HasErrorCodes(T_Unpack(matchErrors)) then checked = false end
        w:SetChecked(checked)

        -- check all other auto repeat spells
        local predicateFn = function(bw) return spId == bw:GetEffectiveSpellID() end
        ABH:ForEachNonEmptyButton(function(bw)
            bw:SetChecked(checked)
        end, predicateFn)
    end

    --- @param msg Name The message name
    --- @param src Name Should be from ButtonMixin
    --- @param w ButtonUIWidget Only fires on a non-empty action slot
    function o.OnPostUpdateSpellUsable(msg, src, w)
        if w:IsEmpty() then return end
        local spellName = w:GetEffectiveSpellName();
        if not Compat:IsAutoRepeatSpell(spellName) then return w:SetChecked(false) end

        w.AutoRepeatSpell = { flashing = 0, flashTime = 0 }
        w.button():AddOnUpdateCallback(GetUniqueName(w), OnUpdateFlashingHandler)
    end

end; PropsAndMethods(L)

