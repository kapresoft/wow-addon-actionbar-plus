------------------------------------------------------------------------
-- test stuff.
------------------------------------------------------------------------
local format = string.format
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local SetCVar, GetCVarBool  = SetCVar, GetCVarBool

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.O.GlobalConstants

local AceEvent = O.AceLibrary.AceEvent
local BF = O.ButtonFactory
local P = O.Profile

ABP_enableV2 = false
ns.features.enableV2 = ABP_enableV2

--[[O.AceLibrary.AceEvent:RegisterMessage(GC.M.OnAddOnReady, function(evt, source, ...)
    --- @type table<string, boolean|number>
    ABP_DEBUG_ENABLED_CATEGORIES = {
        ADDON=1, FRAME=1, BUTTON=1,
        DRAG_AND_DROP=1,
        SPELL=0,
        EVENT=1, MESSAGE=1,
        BAG=1,
        ITEM=1, PET=1, MOUNT=1,
        UNIT=1,
        PROFILE=1,
    }
end)]]

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Developer : BaseLibraryObject_WithAceEvent
local L = {}; AceEvent:Embed(L); D = L
local p = ns:LC().DEV:NewLogger('Developer')

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function L:TT()
    self:SendMessage(GC.M.OnTooltipFrameUpdate)
end

--- down or up
function L:KDT()
    local useKeyDown = GetCVarBool("ActionButtonUseKeyDown")
    p:v(function() return 'ActionButtonUseKeyDown[before]: %s', tostring(useKeyDown) end)
    useKeyDown = not useKeyDown
    SetCVar("ActionButtonUseKeyDown", useKeyDown)
    p:v(function() return 'ActionButtonUseKeyDown[current]: %s', tostring(useKeyDown) end)
    return useKeyDown
end

function L:ResetBarConfig()

    for i = 1, 8 do
        local f = _G['ActionbarPlusF' .. i]
        --- @type FrameWidget
        local w = f.widget
        local cf = w:GetConfig()
        cf.enabled = nil
        cf.anchor = nil
        cf.widget.buttonSize = nil
    end

end

function L:GetGlobalProfile() return P:G() end


function L:AnchorX(frameIndex, x)
    local fw = self:F(frameIndex).widget
    local a = fw:GetConfig().anchor
    a.x = x
end
function L:AnchorReset(frameIndex)
    local fw = self:F(frameIndex).widget
    local barData = fw:GetConfig()
    --barData.anchor = {}
    local a = barData.anchor
    a.point = nil
    a.relativePoint = nil
    a.x = nil
    a.y = nil
    print('Anchor Reset Done')
end

--- @return FrameWidget
--- @param frameIndex Index
--- @param buttonIndex Index
function L:F(frameIndex, buttonIndex)
    if not buttonIndex then return _G['ActionbarPlusF' .. tostring(frameIndex)].widget end
    return self:B(frameIndex, buttonIndex)
end

--- @param frameIndex Index
--- @return Profile_Bar
function L:C(frameIndex) return self:F(frameIndex):GetConfig() end

function L:M() return GetMouseFocus() end

--- @param frameIndex Index
--- @param buttonIndex Index
--- @return ButtonUIWidget
function L:B(frameIndex, buttonIndex)
    local bn = string.format('ActionbarPlusF%sButton%s', frameIndex, buttonIndex)
    return _G[bn].widget
end

function L:API() return O.BaseAPI, O.API end
function L:NS() return ns end
function L:O() return ns.O end

function L:SM(msg) self:SendMessage(msg) end


--- Get the button attributes. Used only for debugging
--- @return table<string, string>
--- @param frameIndex Index
--- @param buttonIndex Index
function L:BA(frameIndex, buttonIndex)
    local ret = {}
    local attributes = {
        "type", "spell", "item", "unit", "macro", "toy",
        "harmbutton1", "harmbutton2", "helpbutton1", "helpbutton2",
        "spell-nuke1", "spell-nuke2", "alt-spell-nuke1", "alt-spell-nuke2",
        "target", "action", "actionbar", "flyout", "glyph", "stop",
        "focus", "assist", "click", "attribute", "togglemenu",
        "destroymenu",
    }
    local bw = self:B(frameIndex, buttonIndex)
    for _, attr in ipairs(attributes) do
        local value = bw.button():GetAttribute(attr)
        if value then ret[attr] = value; end
    end

    return ret
end

--[[-----------------------------------------------------------------------------
Frame
-------------------------------------------------------------------------------]]
--[[
local function OnEvent(frame, event, ...)
    p:v(function() return "OnEvent(): Received event=%s", event end)
end

--- @class DeveloperFrame
local frame = CreateFrame("Frame", 'DeveloperFrame')
frame:SetScript('OnEvent', OnEvent)
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('PLAYER_LEAVING_WORLD')
]]
