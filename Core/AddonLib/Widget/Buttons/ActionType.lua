local String = ABP_String
local tinsert, ipairs = table.insert, ipairs

local AT = {
    SPELL = 'spell',
    ITEM = 'item',
    MACRO = 'macro',
    MACRO_TEXT = 'macrotext',
}
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
