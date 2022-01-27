-- ## External -------------------------------------------------
local format = string.format
local GameTooltip = GameTooltip

-- ## Local ----------------------------------------------------
local LibStub, M, Assert, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local PrettyPrint, Table, String, LOG = ABP_LibGlobals:LibPackUtils()
local IsNotBlank, AssertNotNil = String.IsNotBlank, Assert.AssertNotNil
local BAttr, WAttr, UAttr = W:LibPack_WidgetAttributes()
local ANCHOR_TOPLEFT = ANCHOR_TOPLEFT

local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT = ABP_WidgetConstants:GetButtonTextures()

---@class SpellAttributeSetter
local _L = LibStub:NewLibrary(M.SpellAttributeSetter)

-- ## Functions ------------------------------------------------

---### Button Data Example
---
---```lua
---['ActionbarPlusF1Button1'] = {
---   ['type'] = 'spell',
---   ['spell'] = {
---       -- spellInfo
---   }
---}
---```
---@param btnUI table The UIFrame
---@param btnData table The button data
function _L:SetAttributes(btnUI, btnData)
    W:ResetWidgetAttributes(btnUI)

    ---@type SpellInfo
    local spellInfo = btnData[WAttr.SPELL]
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local spellIcon = TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    btnUI:SetNormalTexture(spellIcon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
    btnUI:SetAttribute(WAttr.SPELL, spellInfo.id)
    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)

    btnUI:RegisterForDrag('LeftButton')
    btnUI:SetScript("OnDragStart", function(_btnUI)
        if P:IsLockActionBars() and not IsShiftKeyDown() then return end
        _L:log(20, 'DragStarted| Actionbar-Info: %s', pformat(_btnUI:GetActionbarInfo()))
        PickupSpell(spellInfo.id)
        W:ResetWidgetAttributes(_btnUI)
        btnData[WAttr.SPELL] = {}
        btnUI:SetNormalTexture(TEXTURE_EMPTY)
        btnUI:SetScript("OnEnter", nil)
    end)

end

---@param link table The blizzard `GameTooltip` link
function _L:ShowTooltip(btnUI, btnData)
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
_L.mt.__call = _L.SetAttributes

