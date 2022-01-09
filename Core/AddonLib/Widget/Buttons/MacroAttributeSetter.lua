local BATTR, RWAttr, WidgetAttributes, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local LOG, AssertNotNil, format, IsNotBlank =
LogFactory, Assert.AssertNotNil, string.format, string.IsNotBlank
local GameTooltip = GameTooltip

local S = {}
SpellAttributeSetter = S
LOG:EmbedLogger(S, 'Widget::Buttons::SpellAttributeSetter')

--- `['ActionbarPlusF1Button1'] = {
---     ['type'] = 'spell',
---     ['spell'] = {
---         -- spellInfo
---     }
--- }`
function S:SetAttributes(btnUI, btnData)

end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    --local spellInfo = btnData[WidgetAttributes.SPELL]
    --GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    --GameTooltip:AddSpellByID(spellInfo.id)
    ---- Replace 'Spell' with 'Spell (Rank #Rank)'
    --if (IsNotBlank(spellInfo.rank)) then
    --    GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    --end
    --GameTooltip:AppendText(' ' .. string.replace(spellInfo.label, spellInfo.name, ''))
end

setmetatable(S, {
    __call = function (_, ...)
        return S:SetAttributes(...)
    end
})