--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Assert, String = O.Assert, O.String
local IsBlank, IsNotBlank, AssertNotNil = String.IsBlank, String.IsNotBlank, Assert.AssertNotNil
local CC, WC = O.CommonConstants, O.WidgetConstants
local BAttr, WAttr, UAttr = CC.ButtonAttributes,  CC.WidgetAttributes, CC.UnitAttributes

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class SpellAttributeSetter : BaseAttributeSetter
local _L = LibStub:NewLibrary(Core.M.SpellAttributeSetter)
---@type BaseAttributeSetter
local Base = LibStub(Core.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param link table The blizzard `GameTooltip` link
function _L:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local spellInfo = btnData[WAttr.SPELL]
    GameTooltip:SetOwner(btnUI, WC.C.ANCHOR_TOPLEFT)

    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end
    GameTooltip:AddSpellByID(spellInfo.id)
end

---@param btnUI ButtonUI The UIFrame
---@param btnData ProfileButton The button data
function _L:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes()

    -- TODO: replace
    --local btnData = btnUI.widget:GetConfig()

    ---@type SpellInfo
    local spellInfo = btnData[WAttr.SPELL]
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local spellIcon = WC.C.TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    btnUI.widget:SetIcon(spellIcon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)

    btnUI:SetAttribute(WAttr.SPELL, spellInfo.id)
    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

    self:HandleGameTooltipCallbacks(btnUI)
end

function _L:ShowTooltip(btnUI)
    if not btnUI then return end
    local w = btnUI.widget
    local btnData = w:GetConfig()
    if not btnData then return end
    if IsBlank(btnData.type) then return end

    local spellInfo = btnData[WAttr.SPELL]
    if not spellInfo.id then return end
    GameTooltip:SetOwner(btnUI, WC.C.ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
        --WU:AddKeybindingInfo(w)
    end
end

_L.mt.__index = Base
_L.mt.__call = _L.SetAttributes
