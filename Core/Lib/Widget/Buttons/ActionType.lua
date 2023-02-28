--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tinsert, ipairs = table.insert, ipairs

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

local W = ns.O.GlobalConstants.WidgetAttributes
local String = ns.O.String
local EqualsIgnoreCase = String.EqualsIgnoreCase

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class ActionType
local AT = {
    SPELL = W.SPELL,
    ITEM = W.ITEM,
    MACRO = W.MACRO,
    MACRO_TEXT = W.MACRO_TEXT,
    COMPANION = W.COMPANION,
    PET_ACTION = W.PET_ACTION,
    BATTLE_PET = W.BATTLE_PET,
    EQUIPMENT_SET = W.EQUIPMENT_SET,

    --- @type table<number, string>
    names = {
        W.SPELL, W.ITEM, W.MACRO, W.MACRO_TEXT,
        W.PET_ACTION, W.COMPANION, W.MOUNT, W.BATTLE_PET,
        W.EQUIPMENT_SET
    }
}
ns:Register(ns.M.ActionType, AT)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return table<number, string>
function AT:GetNames() return ns:K():CreateFromMixins(self.names) end

---@param exceptMe ActionTypeName
function AT:GetOtherNamesExcept(exceptMe)
    local match = {}
    for _, actionType in ipairs(self:GetNames()) do
        if not EqualsIgnoreCase(actionType, exceptMe) then tinsert(match, actionType) end
    end
    return match
end
