local BATTR, RWAttr, WAttr, UAttr, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
    ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, UnitAttributes,
    TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
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
    RWAttr(btnUI)
    local spellInfo = btnData[WAttr.SPELL]
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')
    --local btnName = btnUI:GetName()
    --local abInfo = btnUI:GetActionbarInfo()
    --local p = { name=btnName, ab=abInfo, spell=spellInfo.name }
    --self:logp('btnData', p)

    local spellIcon = TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    btnUI:SetNormalTexture(spellIcon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
    btnUI:SetAttribute(WAttr.SPELL, spellInfo.id)
    btnUI:SetAttribute(BATTR.UNIT2, UAttr.FOCUS)

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)
end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local spellInfo = btnData[WAttr.SPELL]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end
end

function S:Validate(btnUI, btnData)

end

setmetatable(S, {
    __call = function (_, ...)
        return S:SetAttributes(...)
    end
})