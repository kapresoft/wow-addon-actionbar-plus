local LibStub = __K_Core:LibPack()
---@type String
local String = LibStub('String')
local tinsert, ipairs = table.insert, ipairs

---@class ActionType
local AT = {
    SPELL = 'spell',
    ITEM = 'item',
    MACRO = 'macro',
    MACRO_TEXT = 'macrotext',
}
---@type ActionType
ABP_ActionType = AT

-- ## Start Here ##

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
