--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @type _GameTooltip
local GameTooltip = GameTooltip
---### See: Interface/SharedXML/Constants.lua
local DESC_FORMAT = HIGHLIGHT_FONT_COLOR_CODE .. '\n%s' .. FONT_COLOR_CODE_CLOSE

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local Assert, String = O.Assert, O.String
local PH = O.PickupHandler
local IsBlank, IsNotBlank, AssertNotNil, IsNil =
String.IsBlank, String.IsNotBlank, Assert.AssertNotNil, Assert.IsNil
local WAttr, EMPTY_ICON = GC.WidgetAttributes, GC.Textures.TEXTURE_EMPTY
local BaseAPI = O.BaseAPI

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

--- @class EquipmentSetDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.EquipmentSetDragEventHandler)
local p = L.logger

--- @class EquipmentSetAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.EquipmentSetAttributeSetter)
--- @type BaseAttributeSetter
local BaseAttributeSetter = LibStub(M.BaseAttributeSetter)

--- @param battlePet BattlePetInfo
--- @return boolean
local function IsInvalidBattlePet(battlePet)
    return IsNil(battlePet) and IsNil(battlePet.guid) and IsNil(battlePet.name)
end

--- @param equipmentSet EquipmentSetInfo
--- @return Profile_EquipmentSet
local function ToProfileEquipmentSet(equipmentSet)
    return {
        type = WAttr.EQUIPMENT_SET,
        name = equipmentSet.name,
        id = equipmentSet.id,
        icon = equipmentSet.icon,
    }
end


--[[-----------------------------------------------------------------------------
Methods: BattlePetDragEventHandler
-------------------------------------------------------------------------------]]
--- @param e EquipmentSetDragEventHandler
local function eventHandlerMethods(e)

    --- @param cursorInfo CursorInfo
    function e:Supports(cursorInfo)
        if not C_EquipmentSet then return false end
        if not C_EquipmentSet.CanUseEquipmentSets() then return false end

        local equipmentSetCursor = BaseAPI:ToEquipmentSetCursor(cursorInfo)
        if not equipmentSetCursor then return false end
        --return BaseAPI:CanSummonBattlePet(petCursor.guid)
        --p:log('Equipment Cursor: %s', equipmentSetCursor)
        return true
    end

    --- @param btnUI ButtonUI
    --- @param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)

        local equipmentSetInfo = BaseAPI:GetEquipmentSetInfo(cursorInfo)
        if not equipmentSetInfo then return end

        local btnData = btnUI.widget:GetConfig()
        local equipmentSet = ToProfileEquipmentSet(equipmentSetInfo)
        p:log(30, 'equipmentSet: %s', equipmentSet)

        PH:PickupExisting(btnUI.widget)
        btnData[WAttr.TYPE] = equipmentSet.type
        btnData[WAttr.EQUIPMENT_SET] = equipmentSet

        S(btnUI, btnData)
    end

end

--[[-----------------------------------------------------------------------------
Methods: BattlePetAttributeSetter
-------------------------------------------------------------------------------]]
--- @param a EquipmentSetAttributeSetter
local function attributeSetterMethods(a)

    --- @param btnUI ButtonUI
    --- @param btnData Profile_Button
    function a:SetAttributes(btnUI, btnData)
        local w = btnUI.widget
        w:ResetWidgetAttributes()
        if not (btnData and btnData[WAttr.EQUIPMENT_SET]) then return end
        local equipmentSet = btnData[WAttr.EQUIPMENT_SET]

        local icon = EMPTY_ICON
        if equipmentSet.icon then icon = equipmentSet.icon end

        w:SetIcon(icon)

        self:HandleGameTooltipCallbacks(btnUI)
    end

    --- @param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        if not btnUI then return end
        local bd = btnUI.widget:GetButtonData()
        if not bd:ConfigContainsValidActionType() then return end

        local w = btnUI.widget
        local btnData = w:GetButtonData():GetConfig()
        local equipmentSet = w:GetButtonData():GetEquipmentSetInfo()
        if not (equipmentSet and equipmentSet.name) then return end
        local equipmentSetInfo = BaseAPI:GetEquipmentSetInfoByName(equipmentSet.name)

        if equipmentSetInfo and (equipmentSet.id ~= equipmentSetInfo.id) then
            equipmentSet.id = equipmentSetInfo.id
        end

        -- validate equipment set

        --local battlePet = bd:GetBattlePetInfo()
        --if bd:IsInvalidBattlePet(battlePet) then return end
        --
        --GameTooltip:SetText(battlePet.name)
        --GameTooltip:AppendText(sformat(DESC_FORMAT, 'Instant'))
        --GameTooltip:AppendText(sformat(DESC_FORMAT, 'Summons and dismisses your ' .. battlePet.name))
    end
end

--- @return EquipmentSetAttributeSetter
function L:GetAttributeSetter() return S end

--[[-----------------------------------------------------------------------------
Init
-------------------------------------------------------------------------------]]
local function Init()
    eventHandlerMethods(L)
    attributeSetterMethods(S)

    S.mt.__index = BaseAttributeSetter
    S.mt.__call = S.SetAttributes
end

Init()
