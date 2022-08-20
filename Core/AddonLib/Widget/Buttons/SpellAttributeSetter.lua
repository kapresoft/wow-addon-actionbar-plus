-- Wow APIs
local GameTooltip = GameTooltip

-- Lua APIs
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

local LibStub, M, Assert, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local PrettyPrint, Table, String, LOG = ABP_LibGlobals:LibPackUtils()
local IsNotBlank, AssertNotNil = String.IsNotBlank, Assert.AssertNotNil
local BAttr, WAttr, UAttr = W:LibPack_WidgetAttributes()
local WU = ABP_LibGlobals:LibPack_WidgetUtil()
local ANCHOR_TOPLEFT = ANCHOR_TOPLEFT

local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING = ABP_WidgetConstants:GetButtonTextures()

---@class SpellAttributeSetter
local _L = LibStub:NewLibrary(M.SpellAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

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
---@param btnUI ButtonUI The UIFrame
---@param btnData table The button data
function _L:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes()

    -- TODO: replace
    --local btnData = btnUI.widget:GetConfig()

    ---@type SpellInfo
    local spellInfo = btnData[WAttr.SPELL]
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local spellIcon = TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    btnUI.widget:SetTextures(spellIcon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)

    btnUI:SetAttribute(WAttr.SPELL, spellInfo.id)
    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI)  end)
end

function _L:ShowTooltip(btnUI)
    if not btnUI then return end
    local w = btnUI.widget
    local btnData = w:GetConfig()
    if not btnData then return end
    if String.IsBlank(btnData.type) then return end

    local spellInfo = btnData[WAttr.SPELL]
    if not spellInfo.id then return end
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
        WU:AddKeybindingInfo(w)
    end
end

--- So that we can call with SetAttributes(btnUI)
_L.mt.__call = _L.SetAttributes
