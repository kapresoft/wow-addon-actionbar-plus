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
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local Assert, String = O.Assert, O.String
local IsBlank, IsNotBlank, AssertNotNil = String.IsBlank, String.IsNotBlank, Assert.AssertNotNil
local GC = O.GlobalConstants
local BAttr, WAttr, UAttr = GC.ButtonAttributes,  GC.WidgetAttributes, GC.UnitIDAttributes

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
    GameTooltip:SetOwner(btnUI, GC.C.ANCHOR_TOPLEFT)

    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end
    GameTooltip:SetSpellByID(spellInfo.id)
end

---@param btnUI ButtonUI The UIFrame
---@param btnData Profile_Button The button data
function _L:SetAttributes(btnUI, btnData)
    local w = btnUI.widget
    w:ResetWidgetAttributes()

    local spellInfo = w:GetButtonData():GetSpellInfo()
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local spellIcon = GC.Textures.TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    w:SetIcon(spellIcon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)

    btnUI:SetAttribute(WAttr.SPELL, spellInfo.id)
    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

    self:OnAfterSetAttributes(btnUI)
end

function _L:ShowTooltip(btnUI)

    local bd = btnUI.widget:GetButtonData()
    if not bd:ConfigContainsValidActionType() then return end

    local btnData = btnUI.widget:GetConfig()
    local spellInfo = btnData[WAttr.SPELL]
    if not spellInfo.id then return end
    GameTooltip:SetOwner(btnUI, GC.C.ANCHOR_TOPLEFT)
    GameTooltip:SetSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end
end

_L.mt.__index = Base
_L.mt.__call = _L.SetAttributes
