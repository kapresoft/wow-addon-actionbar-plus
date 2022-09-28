------------------------------------------------------------------------
-- test stuff.
------------------------------------------------------------------------
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class Developer
local L = {}
---@return LoggerTemplate
local p = O.LogFactory('Developer')

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function L:ResetBarConfig()

    for i = 1, 8 do
        local f = _G['ActionbarPlusF' .. i]
        ---@type FrameWidget
        local w = f.widget
        local cf = w:GetConfig()
        cf.enabled = nil
        cf.anchor = nil
        cf.widget.buttonSize = nil
    end

end

function L:AnchorX(frameIndex, x)
    local fw = self:F(frameIndex).widget
    local a = fw:GetConfig().anchor
    a.x = x
end

---@param frameIndex number
---@return Frame
function L:F(frameIndex)
    return _G['ActionbarPlusF' .. tostring(frameIndex)]
end


D = L

--[[-----------------------------------------------------------------------------
Frame
-------------------------------------------------------------------------------]]
local function OnEvent(frame, event, ...)
    p:log('%s| %s', frame:GetName(), event)
    if event == 'PLAYER_LEAVING_WORLD' then
        --TODO: NEXT: Save Anchors for all frames
    end
end

---@class DeveloperFrame
local frame = CreateFrame("Frame", 'DeveloperFrame', UIParent)
frame:SetScript('OnEvent', OnEvent)
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('PLAYER_LEAVING_WORLD')