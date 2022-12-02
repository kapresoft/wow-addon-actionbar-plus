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
local L = LibStub:NewLibrary(Core.M.SpellAttributeSetter)
---@type LoggerTemplate
local p = L:GetLogger()

---@type BaseAttributeSetter
local Base = LibStub(Core.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param link table The blizzard `GameTooltip` link
function L:ShowTooltip(btnUI, btnData)
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
function L:SetAttributes(btnUI, btnData)
    local w = btnUI.widget
    w:ResetWidgetAttributes()

    local spellInfo = w:GetButtonData():GetSpellInfo()
    if type(spellInfo) ~= 'table' then return end
    if not spellInfo.id then return end
    AssertNotNil(spellInfo.id, 'btnData[spell].spellInfo.id')

    local isActive = O.DruidAPI:IsActiveForm('flightform')
    p:log(10, 'isActive|FlightForm: %s', isActive)

    local shapeShiftFormIndex = GetShapeshiftForm()
    local shapeShiftActive = false
    if shapeShiftFormIndex > 0 then
        local icon, active, castable, spellID = GetShapeshiftFormInfo(shapeShiftFormIndex)
        if spellID == spellInfo.id then shapeShiftActive = true end
    end


    local spellIcon = GC.Textures.TEXTURE_EMPTY
    if spellInfo.icon then spellIcon = spellInfo.icon end
    --136116
    local spellAttrValue = spellInfo.id
    if spellInfo.rank == 'Shapeshift' then
        spellAttrValue = spellInfo.name
        -- if isActive then use this icon
        if shapeShiftActive then spellIcon = 136116 end
    end
    --todo next: "set shapeshift icon as active icon?"


    w:SetIcon(spellIcon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)

    btnUI:SetAttribute(WAttr.SPELL, spellAttrValue)
    btnUI:SetAttribute(BAttr.UNIT2, UAttr.FOCUS)


    self:OnAfterSetAttributes(btnUI)
end

function L:ShowTooltip(btnUI)

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

L.mt.__index = Base
L.mt.__call = L.SetAttributes
