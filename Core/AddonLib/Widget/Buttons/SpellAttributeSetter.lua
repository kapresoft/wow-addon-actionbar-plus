local BATTR, RWAttr, TEXTURE_HIGHLIGHT = ButtonAttributes, ResetWidgetAttributes, TEXTURE_HIGHLIGHT
local LOG = LogFactory
local AssertNotNil = Assert.AssertNotNil
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
    local spellInfo = btnData[ButtonAttributes.SPELL]
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')
    local btnName = btnUI:GetName()
    local abInfo = btnUI:GetActionbarInfo()
    local p = { name=btnName, ab=abInfo, spell=spellInfo.name }
    --self:logp('btnData', p)

    local spellIcon = TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    btnUI:SetNormalTexture(spellIcon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    btnUI:SetAttribute(BATTR.TYPE, 'spell')
    btnUI:SetAttribute(BATTR.SPELL, spellInfo.id)
    btnUI:SetAttribute(BATTR.UNIT2, 'focus')
end

function S:Validate(btnUI, btnData)

end

setmetatable(S, {
    __call = function (_, ...)
        return S:SetAttributes(...)
    end
})