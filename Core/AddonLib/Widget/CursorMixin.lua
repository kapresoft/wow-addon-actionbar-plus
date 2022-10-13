--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O
local MX, IsBlank = O.Mixin, O.String.IsBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class CursorMixin
local L = LibStub:NewLibrary(Core.M.CursorMixin)
---@type LoggerTemplate
local p = L:GetLogger()

-- Add to Modules.lua
--CursorMixin = 'CursorMixin',
--
-----@type CursorMixin
--CursorMixin = {},

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param cursorInfo CursorInfo
function L:Init(cursorInfo)
    self.cursorInfo = cursorInfo
end
---@return boolean
function L:IsValid()
    if not self.cursorInfo or IsBlank(self.cursorInfo.type) then
        p:log(20, 'Received drag event with invalid cursor info. Skipping...')
        -- This can happen if a chat tab or others
        -- is dragged into the action bar.
        return false
    end
    p:log(20, 'Cursor is valid: %s', self.cursorInfo)
    return true
end
---@return string
function L:GetType() return self.cursorInfo.type end
---@return CursorInfo
function L:GetCursor() return self.cursorInfo end

---@param cursorInfo CursorInfo
---@return CursorUtil
function ns:CreateCursorUtil(cursorInfo)
    assert(cursorInfo, "CursorInfo is required.")

    ---@class CursorUtil : CursorMixin
    local c = MX:MixinAndInit(L, cursorInfo)
    return c
end

---@param cursorInfo CursorInfo
---@return CursorUtil
ABP_CreateCursorUtil = function(cursorInfo) return ns:CreateCursorUtil(cursorInfo) end