--[[-----------------------------------------------------------------------------
This Controller Handles keypress Updates
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, E, MSG = ns.O, ns.GC.E, ns.GC.E
local libName = 'ModifierStateChangeController'
local event2 = ns:AceEvent()
local toMsg = ns.GC.toMsg
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ModifierStateChangeController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ModifierStateChangeController | ControllerV2
local function PropsAndMethods(o)

    function o:OnAddOnReady()
        self:RegisterAddOnMessage(E.MODIFIER_STATE_CHANGED, function(evt, source, ...)
            self:OnModifierStateChanged(...)
        end)

        if not ns:IsRetail() then return end
        ----- Retail Only -----
        O.API:SyncUseKeyDownActionButtonSettings()
        event2:RegisterMessage(toMsg(E.MODIFIER_STATE_CHANGED), function(evt, source, ...)
            self:OnModifierStateChangedRetailOnly(...)
        end)
    end

    function o:OnModifierStateChanged(keyPressed, downPress)
        self:UpdateMacroButtons(keyPressed, downPress)
    end

    function o:OnModifierStateChangedRetailOnly(keyPressed, downPress)
        local isModKeyDown = O.API:IsDragKeyDown()
        if isModKeyDown ~= true then return end
        -- This will only occur if Mod key is on keyDown
        p:f1(function()
            return "keyPressed=%s downPress=%s modKey=%s OnModifierStateChangedRetailOnly()",
                        keyPressed, downPress, isModKeyDown end)

        O.API:SyncUseKeyDownActionButtonSettings()
    end

    function o:UpdateMacroButtons(key, down)
        down = down == 1 or false
        -- todo: Currently has issue with 'Fire Breath' spell
        self:ForEachMacroButton(function(bw)
            local m = bw:GetMacroData()
            local spell = bw:GetEffectiveSpell()
            local spn = spell and spell.name
            if not spn then return end

            C_Timer.After(0.01, function() bw:UpdateMacroState() end)

            local castSp = O.API:GetCurrentSpellCasting()
            if not castSp then return end
            -- p:d(function() return "Unit is casting: %s %s", castSp, GetTime() end)

            local castSpId = castSp.id

            C_Timer.NewTicker(0.02, function()
                local mSpN, mSpID = O.API:GetMacroSpell(m.index)
                if castSpId == mSpID then
                    bw:SetHighlightInUse()
                else
                    bw:SetHighlightDefault()
                end
            end, 2)
        end)
    end

end; PropsAndMethods(L)

