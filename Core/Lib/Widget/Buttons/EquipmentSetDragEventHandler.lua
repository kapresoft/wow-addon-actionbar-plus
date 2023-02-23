--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @type _GamedTooltip
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

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

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

--- @param evt string
--- @param w ButtonUIWidget
local function OnClick(evt, w, ...)
    assert(w, "ButtonUIWidget is missing")
    p:log(30, 'Message[%s]: %s', evt, w:GetName())
    if not w:CanChangeEquipmentSet() or InCombatLockdown() then return end

    --- @type _Frame
    local PDF = PaperDollFrame
    --- @type _Frame
    local gmDlg = GearManagerDialog
    --- @type _Button
    local gmButton = GearManagerToggleButton

    p:log(20, 'Equipment Clicked: %s', w:GetEquipmentSetData())
    C_EquipmentSet.UseEquipmentSet(w:GetEquipmentSetData().id)

    -- PUT_DOWN_SMALL_CHAIN
    -- GUILD_BANK_OPEN_BAG
    PlaySound(SOUNDKIT.GUILD_BANK_OPEN_BAG)

    ActionButton_ShowOverlayGlow(w.button)
    C_Timer.After(0.8, function() ActionButton_HideOverlayGlow(w.button) end)

    if not PDF:IsVisible() then
        ToggleCharacter('PaperDollFrame')
        C_Timer.After(0.1, function()
            gmButton:Click()
        end)
    else
        if not gmDlg:IsVisible() then
            C_Timer.After(0.1, function()
                gmButton:Click()
            end)
        end
    end
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

        local config = btnUI.widget.config
        local equipmentSet = ToProfileEquipmentSet(equipmentSetInfo)
        p:log(30, 'equipmentSet: %s', equipmentSet)

        PH:PickupExisting(btnUI.widget)
        config[WAttr.TYPE] = equipmentSet.type
        config[WAttr.EQUIPMENT_SET] = equipmentSet

        S(btnUI, config)
    end

end

--[[-----------------------------------------------------------------------------
Methods: BattlePetAttributeSetter
-------------------------------------------------------------------------------]]
--- @param a EquipmentSetAttributeSetter
local function attributeSetterMethods(a)

    --- @param btnUI ButtonUI
    function a:SetAttributes(btnUI)
        local w = btnUI.widget
        w:ResetWidgetAttributes()
        local equipmentSet = w:GetEquipmentSetData()
        if w:IsInvalidEquipmentSet(equipmentSet) then return end

        local icon = EMPTY_ICON
        if equipmentSet.icon then icon = equipmentSet.icon end

        w:SetIcon(icon)
        self:HandleGameTooltipCallbacks(btnUI)
    end

    --- @param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        if not btnUI then return end
        local w = btnUI.widget
        if w:IsEmpty() then return end

        if not w:ConfigContainsValidActionType() then return end
        local equipmentSet = w:GetEquipmentSetData()
        if w:IsInvalidEquipmentSet(equipmentSet) then return end

        local equipmentSetInfo = BaseAPI:GetEquipmentSetInfoByName(equipmentSet.name)
        if equipmentSetInfo and (equipmentSet.id ~= equipmentSetInfo.id) then
            equipmentSet.id = equipmentSetInfo.id
        end

        -- todo next: add equipment set tooltip
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

    ns:AceEvent():RegisterMessage(GC.M.OnButtonClickEquipmentSet, OnClick)
end

Init()
