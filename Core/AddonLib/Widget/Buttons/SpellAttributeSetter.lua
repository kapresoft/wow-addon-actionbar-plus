--- Spell Attributes Setter
---@param RWAttr table ResetWidgetAttributes
local __def = function(LOG, BATTR, RWAttr, WAttr, UAttr,
                       GameTooltip, AssertNotNil, format, IsNotBlank,
                       TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT)

    --local BATTR, RWAttr, WAttr, UAttr, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
    --ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, UnitAttributes,
    --TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
    --local LOG, AssertNotNil, format, IsNotBlank =
    --LogFactory, Assert.AssertNotNil, string.format, string.IsNotBlank
    --local GameTooltip = GameTooltip

    local S = {}
    LOG:EmbedLogger(S, 'SpellAttributeSetter')

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

    --- So that we can call with SetAttributes(btnUI)
    S.mt.__call = S.SetAttributes

    return S
end

-- TODO: Rename to ABP_SpellAttributeSetter
SpellAttributeSetter = __def(
        LogFactory, ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, UnitAttributes,
        GameTooltip,
        Assert.AssertNotNil, string.format, string.IsNotBlank,
        TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
)