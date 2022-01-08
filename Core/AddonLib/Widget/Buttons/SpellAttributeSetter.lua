local BATTR, RWAttr, TEXTURE_HIGHLIGHT = ButtonAttributes, ResetWidgetAttributes, TEXTURE_HIGHLIGHT
local LOG = LogFactory
local AssertNotNil = Assert.AssertNotNil
local SPELL_API = _API_Spell
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

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)
end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local spellInfo = btnData[WidgetAttributes.SPELL]
    local link = spellInfo.link or spellInfo.label or spellInfo.name
    --ABP:DBG('spellInfo', PrettyPrint.pformat(spellInfo))

    GameTooltip:SetOwner(btnUI, "ANCHOR_TOPLEFT")
    GameTooltip:SetHyperlink(link)
    GameTooltip:AddLine('\n' .. spellInfo.label)
    GameTooltip:Show()
end

function S:Validate(btnUI, btnData)

end

setmetatable(S, {
    __call = function (_, ...)
        return S:SetAttributes(...)
    end
})