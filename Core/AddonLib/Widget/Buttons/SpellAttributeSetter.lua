--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
---@type _GameTooltip
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, strlower = string.format, string.lower

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace()
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local Assert, String = O.Assert, O.String
local IsBlank, IsNotBlank, AssertNotNil = String.IsBlank, String.IsNotBlank, Assert.AssertNotNil
local API, GC = O.API, O.GlobalConstants
local BAttr, WAttr, UAttr = GC.ButtonAttributes,  GC.WidgetAttributes, GC.UnitIDAttributes
local IsAnyOf = String.IsAnyOf
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class SpellAttributeSetter : BaseAttributeSetter
local L = LibStub:NewLibrary(Core.M.SpellAttributeSetter)
---@type LoggerTemplate
local p = L:GetLogger()

---@type BaseAttributeSetter
local Base = LibStub(Core.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param btnUI ButtonUI The UIFrame
---@param btnData Profile_Button The button data
function L:SetAttributes(btnUI, btnData)
    local w = btnUI.widget
    w:ResetWidgetAttributes()

    local spellInfo = w:GetButtonData():GetSpellInfo()
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local spellIcon = GC.Textures.TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = API:GetSpellIcon(spellInfo) end
    w:SetIcon(spellIcon)

    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)

    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
    local spellAttrValue = API:GetSpellAttributeValue(spellInfo)
    btnUI:SetAttribute(WAttr.SPELL, spellAttrValue)

    self:OnAfterSetAttributes(btnUI)
end

function L:ShowTooltip(btnUI)

    local bd = btnUI.widget:GetButtonData()
    if not bd:ConfigContainsValidActionType() then return end

    local btnData = btnUI.widget:GetConfig()
    local spellInfo = btnData[WAttr.SPELL]
    if not spellInfo.id then return end

    GameTooltip:SetSpellByID(spellInfo.id)
    -- Replace 'Spell' with 'Spell (Rank #Rank)'
    if (IsNotBlank(spellInfo.rank)) then
        GameTooltip:AppendText(format(' |cff565656(%s)|r', spellInfo.rank))
    end

end

L.mt.__index = Base
L.mt.__call = L.SetAttributes
