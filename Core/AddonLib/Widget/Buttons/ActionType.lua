--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tinsert, ipairs = table.insert, ipairs

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, GC, ns = ABP_LibPack()
local String = O.String

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class ActionType
local AT = {
    SPELL = 'spell',
    ITEM = 'item',
    MACRO = 'macro',
    MACRO_TEXT = 'macrotext',
}
ns:Register(ns.M.ActionType, AT)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
AT.Types = { AT.SPELL, AT.ITEM, AT.MACRO, AT.MACRO_TEXT }

function AT:GetOtherTypes(exceptMe)
    local match = {}
    for _, actionType in ipairs(self.Types) do
        if not String.EqualsIgnoreCase(actionType, exceptMe) then
            tinsert(match, actionType)
        end
    end
    return match
end
