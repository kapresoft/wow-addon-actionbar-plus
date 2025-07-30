--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local api = ns.O.API

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.MacroControllerCommon
--- @class MacroControllerCommon
local S = {}; ns:Register(libName, S)
local p = ns:LC().MACRO:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param bw ButtonUIWidget
function S:UpdateIcon(bw)
    local macroIndex = bw:GetMacroIndex(); if not macroIndex then return end
    local icon = api:GetMacroIcon(macroIndex)
    return icon and bw:SetIcon(icon)
end

--- @param ctrl ControllerV2
function S:UpdateMacros(ctrl)
    ctrl:ForEachMacroButton(function(bw)
        self:UpdateIcon(bw)
        bw:UpdateCooldown()
    end)
end
