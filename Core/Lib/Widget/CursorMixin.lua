--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local W = GC.WidgetAttributes
local IsBlank = ns:String().IsBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class CursorMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.CursorMixin); if not L then return end
local p = ns:LC().DRAG_AND_DROP:NewLogger(M.CursorMixin)

-- Add to Modules.lua
--CursorMixin = 'CursorMixin',
--
----- @type CursorMixin
--CursorMixin = {},
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param cursorInfo CursorInfo
local function GetMacroSubType(cursorInfo)
    if cursorInfo.type ~= W.MACRO then return nil end
    local macroSlot = cursorInfo.info1; if IsBlank(macroSlot) then return end
    local macroName = GetMacroInfo(macroSlot)
    if GC:IsM6Macro(macroName) then return W.MACRO_SUBTYPE_M6 end
    return nil
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param cursorInfo CursorInfo
function L:Init(cursorInfo)
    self.cursorInfo = cursorInfo
    if not self.cursorInfo then return end
    self.cursorInfo.subType = GetMacroSubType(self.cursorInfo)
end
function L:IsM6Macro() return self.cursorInfo.subType == W.MACRO_SUBTYPE_M6 end

--- @return boolean
function L:IsValid()
    if not self.cursorInfo or IsBlank(self.cursorInfo.type) then
        p:d( 'Received drag event with invalid cursor info. Skipping...')
        -- This can happen if a chat tab or others
        -- is dragged into the action bar.
        return false
    end
    p:f1(function() return 'Cursor is valid: %s', pformat(self.cursorInfo) end)
    return true
end
--- @return string
function L:GetType() return self.cursorInfo.type end

--- @return string The cursor subType, i.e. 'm6'
function L:GetSubType() return self.cursorInfo.subType end

--- @return CursorInfo
function L:GetCursor() return self.cursorInfo end

