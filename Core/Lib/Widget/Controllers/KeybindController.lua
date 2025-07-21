--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.KeybindController
--- @class KeybindController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o KeybindController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:RegisterMessage(MSG.OnAfterReceiveDrag, o.OnAfterReceiveDrag)
        self:RegisterMessage(MSG.OnActionButtonShowGrid, o.OnActionButtonShowGrid)
        self:RegisterMessage(MSG.OnActionButtonHideGrid, o.OnActionButtonHideGrid)
        self:RegisterMessage(MSG.OnActionBarShowGroup, o.OnActionBarShowGroup)
        self:RegisterMessage(MSG.OnActionBarHideGroup, o.OnActionBarHideGroup)
        self:RegisterMessage(MSG.OnShowKeybindTextSettingsUpdated, o.OnShowKeybindTextSettingsUpdated)
        self:RegisterMessage(MSG.OnShowEmptyButtons, o.OnShowEmptyButtons)
        self:RegisterAddOnMessage(GC.E.UPDATE_BINDINGS, o.OnUpdateBindings)
        C_Timer.After(0.01, function()
            o:ActionBars_UpdateAllKeybindTextState()
        end )
    end

    function o.OnShowEmptyButtons()
        o:ActionBars_UpdateAllKeybindTextState()
    end

    --- When a new keybind is assigned
    function o.OnUpdateBindings()
        ns:RetrieveKeyBindingsMap()
        o:ActionBars_UpdateAllKeybindTextState()
    end

    --- @param msg string
    --- @param src string
    --- @param fw ActionBarFrameWidget
    function o.OnShowKeybindTextSettingsUpdated(msg, src, fw)
        o:ActionBars_UpdateAllKeybindTextState()
    end

    --- @param msg string
    --- @param src string
    --- @param fw ActionBarFrameWidget
    function o.OnActionBarShowGroup(msg, src, fw)
        o:ActionBars_UpdateAllKeybindTextState()
    end

    --- Nothing to do here, for now.
    --- @param msg string
    --- @param src string
    --- @param fw ActionBarFrameWidget
    function o.OnActionBarHideGroup(msg, src, fw) end

    --- Always show the keybind text when showing the grid
    --- @param msg string
    --- @param src string
    --- @param bw ButtonUIWidget
    function o.OnActionButtonShowGrid(msg, src, bw) bw.kbt:UpdateKeybindTextState()
    end

    --- Nothing to do here, for now.
    --- @param msg string
    --- @param src string
    --- @param bw ButtonUIWidget
    function o.OnActionButtonHideGrid(msg, src, bw) end

    function o.OnAfterReceiveDrag() o:ActionBars_UpdateAllKeybindTextState() end

    --[[-------------------------------------------------------
    Support Methods
    ---------------------------------------------------------]]

    --- Show the Keybind Text based on the settings
    function o:ActionBars_UpdateAllKeybindTextState()
        self:ForEachButton(function(bw)
            if bw:IsEmpty() then
                if not bw:IsShowEmptyButtons() then return bw.kbt:HideKeybindText() end
                if bw:IsShowKeybindText() then
                    bw.kbt:UpdateKeybindTextState()
                else
                    bw.kbt:HideKeybindText()
                end
            else
                if bw:IsShowKeybindText() then
                    bw.kbt:UpdateKeybindTextState()
                else
                    bw.kbt:HideKeybindText()
                end
            end
        end)
    end

end; PropsAndMethods(L)

