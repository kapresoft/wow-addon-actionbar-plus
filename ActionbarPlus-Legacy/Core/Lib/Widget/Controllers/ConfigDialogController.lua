--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, MS = ns.O, ns.GC.M
local AceConfigDialog = ns:AceLibrary().AceConfigDialog
local libName = ns.M.ConfigDialogController
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ConfigDialogController
local L = ns:NewLib(libName, O.DruidUnitMixin)
local p = ns:CreateDefaultLogger(libName)
local pt = ns:LC().TRACE:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ConfigDialogController | ModuleV2
local function PropsAndMethods(o)

    --- @private
    --- This is called automatically
    --- @see ModuleV2Mixin#Init
    function o:OnAddOnReady()
        if ns.ConfigDialogControllerEventFrame then
            pt:f1('ConfigDialogControllerEventFrame already initialized...')
            return;
        end
        self:CreateDialogEventFrame()
    end

    --- @private
    function o:CreateDialogEventFrame()
        pt:f1(function() return 'CreateDialogEventFrame called with ConfigDialogControllerEventFrame: %s', type(ns.ConfigDialogControllerEventFrame) end)
        local frameName = ns.sformat("%s_%sEventFrame", ns.name, libName)
        --- @class ConfigDialogControllerEventFrame: _Frame
        local f = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
        f:Hide()
        f:SetScript("OnHide", function(self)
            if not AceConfigDialog.OpenFrames[ns.name] then return end
            AceConfigDialog:Close(ns.name)
        end)
        ns.ConfigDialogControllerEventFrame = f
        RegisterStateDriver(f, "visibility", "[combat]hide;show")
    end

end; PropsAndMethods(L)


