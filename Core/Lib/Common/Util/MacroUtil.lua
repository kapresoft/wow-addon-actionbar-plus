--- @alias ItemCallbackFn fun(c:ButtonProfileConfigMixin, itemID:ItemID) : void
--- @alias SpellCallbackFn fun(c:ButtonProfileConfigMixin, spellID:SpellID) : void
--- @alias PreCallbackFn fun(bw:ButtonUIWidget, c:ButtonProfileConfigMixin) : void

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O = ns.O
local api, compat, cdu = O.API, O.Compat, O.CooldownUtil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.MacroUtil
--- @class MacroUtil
local S = {}; ns:Register(libName, S)
local p = ns:LC().MACRO:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function druid() return O.DruidUnitMixin end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param bw ButtonUIWidget
function S:Button_IsUsable(bw)
    local c = bw:conf(); if not c:IsMacro() then return end
    local macroIndex = c.macro.index

    local itid = api:GetMacroItem(macroIndex)
    if itid and itid.id then
        return compat:IsUsableItem(itid.id)
    end
    local spid = api:GetMacroSpellID(macroIndex)
    if spid then
        local usableSpell = compat:IsUsableSpell(spid)
        return usableSpell
    end

    -- return true by default so it will not disable the button
    return true
end

--- @param bw ButtonUIWidget
function S:Button_UpdateIcon(bw)
    local macroIndex = bw:GetMacroIndex(); if not macroIndex then return end
    local icon = api:GetMacroIcon(macroIndex)
    return icon and bw:SetIcon(icon)
end

--- @param bw ButtonUIWidget
--- @param spellID SpellID
function S:Button_UpdateCooldownBySpell(bw, spellID)
    if O.DruidUnitMixin:IsProwl(spellID) then return bw.cooldown():Clear() end
    bw:SetCooldownByDetails(bw:GetSpellCooldown(spellID))
end

--- @param bw ButtonUIWidget
function S:Button_UpdateCooldown(bw)
    bw:UpdateCooldown(cdu:GetMacroCooldown(bw))
end

--- @param bw ButtonUIWidget
function S:Button_UpdateUsable(bw)
    local usable = self:Button_IsUsable(bw)
    bw:SetActionUsable2(usable)
end

--- @private
--- @param bw ButtonUIWidget
--- @param preCallbackFn PreCallbackFn | "function(bw, c) print('hello') end"
--- @param itemCallbackFn ItemCallbackFn | "function(c, itemID) print(itemID) end"
--- @param spellCallbackFn SpellCallbackFn | "function(c, spellID) print(spellID) end"
function S:_Button_Update(bw, preCallbackFn, itemCallbackFn, spellCallbackFn)
    local c = bw:conf(); if not c:IsMacro() then return nil end

    bw:SetHighlightDefault()
    bw:SetNormalIconAlphaDefault()

    if preCallbackFn then preCallbackFn(bw, c) end

    if itemCallbackFn then
        local item = api:GetMacroItem(c.macro.index)
        if item and item.id then return itemCallbackFn(c, item.id) end
    end

    if spellCallbackFn then
        local spellID = api:GetMacroSpellID(c.macro.index)
        if spellID then return spellCallbackFn(c, spellID) end
    end

    return nil
end

-- ActionButton_UpdateState(self);
-- ActionButton_UpdateUsable(self);
-- ActionButton_UpdateCooldown(self);
-- ActionButton_UpdateCount(self): TODO
--- @param bw ButtonUIWidget
function S:Button_Update(bw)

    --- @type PreCallbackFn
    local preCallbackFn = function(bw, c)
        self:Button_UpdateIcon(bw)
    end

    --- @type ItemCallbackFn
    local handleItem = function(c, itemID)
        local usableItem = compat:IsUsableItem(itemID)
        bw:SetActionUsable2(usableItem)

        --- TODO
        --bw:nItem_UpdateCount(itemID)
        local itemInfo = api:GetItemInfo(itemID)
        bw:UpdateItemByItemInfo(itemInfo)

        local cd = cdu:GetItemCooldown(itemID)
        bw:UpdateCooldown(cd)
    end

    --- @type SpellCallbackFn
    local handleSpell = function(c, spellID)
        local usableSpell = compat:IsUsableSpell(spellID)
        if druid():IsProwl(spellID) then
            bw:SetChecked( O.DruidUnitMixin:IsStealthActive())
            usableSpell = true
        end
        bw:SetActionUsable2(usableSpell)
        self:Button_UpdateCooldownBySpell(bw, spellID)
    end

    self:_Button_Update(bw, preCallbackFn, handleItem, handleSpell)
end

--- @param ctrl ControllerV2
function S:UpdateCooldowns(ctrl)
    ctrl:ForEachMacroButton(function(bw) self:Button_UpdateCooldown(bw) end)
end

--- @param ctrl ControllerV2
function S:UpdateIcons(ctrl)
    ctrl:ForEachMacroButton(function(bw) self:Button_UpdateIcon(bw) end)
end

--- @param ctrl ControllerV2
function S:UpdateIconsDelayed(ctrl)
    C_Timer.After(0.001, function() self:UpdateIcons(ctrl) end)
end

--- @param ctrl ControllerV2
function S:ModifierStateChange_UpdateMacros(ctrl)
    ctrl:ForEachMacroButton(function(bw)
        self:Button_UpdateIcon(bw)
        bw:ru():Button_UpdateRangeIndicator(bw)
    end)
end
