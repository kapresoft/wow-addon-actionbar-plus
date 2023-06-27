--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local Table, String, SizeOf, IsAnyOf = O.Table, O.String, O.Table.Size, O.String.IsAnyOf
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ActionbarButtons : BaseLibraryObject
local L = LibStub:NewLibrary(M.ActionbarButtons); if not L then return end
local p = L.logger()

--- @alias ButtonUITable table<number, ButtonUI>

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionbarButtons
local function PropsAndMethods(o)
    --- @type table<SpellID, ButtonUITable>
    o.activeButtons = {}

    --- @return table<number, ButtonUI>
    --- @param spellID SpellID
    function L:GetActiveButtons(spellID)
        local buttons = self.activeButtons[spellID]
        if not buttons then buttons = {} end
        return buttons
    end

    function o:ClearActiveButtons()
        for k in pairs (self.activeButtons) do self.activeButtons[k] = nil end
        p:log(10, 'ClearActiveButtons: size=%s', #self.activeButtons)
    end

    function o:UpdateAll()
        for spellID, buttons in pairs(self.activeButtons) do
            for i, btn in ipairs(buttons) do
                btn.widget:UpdateCooldown()
                btn.widget:UpdateUsable()
                p:log(10, 'UpdateAll::%s: %s', btn:GetName(), tostring(btn.widget:GetAbilityName()))
            end
        end
    end

    --- @param spellID SpellID
    --- @param handlerFn ActionButtonHandlerFn
    function o:ApplyActionBySpellID(spellID, handlerFn) self:ApplyAction(self:GetActiveButtons(spellID), handlerFn) end

    --- @param buttons table<number, ButtonUI>
    --- @param handlerFn ActionButtonHandlerFn
    function o:ApplyAction(buttons, handlerFn)
        local size = buttons and #buttons
        if size <= 0 then return end
        p:log(10, 'ApplyAction: size=%s', size)
        for i, btn in ipairs(buttons) do
            --p:log(10, 'Show[%s]: s=%s spell=%s b=%s', spellID, size, spellName, btn:GetName())
            handlerFn(btn.widget)
        end
    end

    --- @param spellID SpellID
    ---@param isShown Boolean
    function o:ShowAsGlowing(spellID, isShown)
        self:ApplyActionBySpellID(spellID, function(w)
            if isShown == true then
                p:log(0, 'ShowAsGlowing[%s]: show=%s spell=%s', w:GetName() , isShown, spellID)
            end
            if isShown == true then w:ShowOverlayGlow() else w:HideOverlayGlow() end
        end)
    end

    --- Highlight In-Use
    --- @param spellID SpellID
    ---@param isChecked Boolean
    function o:SetChecked(spellID, isChecked)
        self:ApplyActionBySpellID(spellID, function(w)
            --p:log(0, 'SetChecked[%s]: checked=%s spell=%s', w:GetName() , isChecked, spellID)
            --if isChecked == true then w:SetHighlightInUse() else w:ResetHighlight() end
            if isChecked == true then w:SetButtonStatePushed() else w:SetButtonStateNormal() end
        end)
    end

    function o:GetSize()
        local c = 0
        for spellID, buttons in pairs(self.activeButtons) do
            c = c + #buttons
        end
        return c
    end

    function o:UpdateActiveButtons()
        self:ClearActiveButtons()

        ns:BF():fevf(function(fw)
            fw:fevb(function(bw)
                local c = bw:GetConfig(); if not c then return false end
                return IsAnyOf(c.type, 'spell','macro','item')
            end, function(bw)
                local spellID = bw:GetEffectiveSpellID()
                if not spellID then return end
                if not self.activeButtons[spellID] then self.activeButtons[spellID] = {} end
                table.insert(self.activeButtons[spellID], bw.button())
            end)
        end)

        --[[p:log(0, 'UpdateActiveButtons: unique-size=%s total-size=%s',
                SizeOf(self.activeButtons),
                self:GetSize())]]
    end

    ---@param btn _CheckButton
    function o:GetActionSpellID(cbtn)
        local action = cbtn.action
        local actionType, id = GetActionInfo(action)
        if actionType == 'spell' then return id end
        if actionType == 'macro' then return GetMacroSpell(id) end
        return nil
    end

    --- #### See: Interface/FrameXML/ActionButton.lua
    --- @param cbtn _CheckButton
    function o:HandleShowOverlayGlow(cbtn)
        if cbtn:GetObjectType() ~= 'CheckButton' then return end
        local spellID = self:GetActionSpellID(cbtn); if not spellID then return end
        self:ShowAsGlowing(spellID, true)
    end

    --- #### See: Interface/FrameXML/ActionButton.lua
    --- @param cbtn _CheckButton
    function o:HandleHideOverlayGlow(cbtn)
        if cbtn:GetObjectType() ~= 'CheckButton' then return end
        local spellID = self:GetActionSpellID(cbtn); if not spellID then return end
        self:ShowAsGlowing(spellID, false)
    end

end; PropsAndMethods(L)
