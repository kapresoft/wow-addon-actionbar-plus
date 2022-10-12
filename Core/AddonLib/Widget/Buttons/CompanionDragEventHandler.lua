--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local Assert, String = O.Assert, O.String
local PH, GC = O.PickupHandler, O.GlobalConstants
local IsBlank, IsNotBlank, AssertNotNil, IsNil =
    String.IsBlank, String.IsNotBlank, Assert.AssertNotNil, Assert.IsNil
local WAttr, EMPTY_ICON = GC.WidgetAttributes, GC.Textures.TEXTURE_EMPTY
local BaseAPI = O.BaseAPI

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local p = O.LogFactory(Core.M.CompanionDragEventHandler)

---@class CompanionDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(Core.M.CompanionDragEventHandler)

---@class CompanionAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(Core.M.CompanionAttributeSetter)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(Core.M.BaseAttributeSetter)

---@param companion CompanionInfo
---@return boolean
local function IsInvalidCompanion(companion)
    return IsNil(companion)
            and IsNil(companion.creatureName)
            and IsNil(companion.creatureSpellID)
end
---@param companion CompanionInfo
---@return Profile_Companion
local function ToProfileCompanion(companion)
    return {
        type = 'companion',
        petType = companion.petType,
        mountType = companion.mountType,
        id = companion.creatureID,
        index = companion.index,
        name = 'Black Kingsnake',
        spell = {  id = companion.creatureSpellID, icon = companion.icon },
    }
end

--[[-----------------------------------------------------------------------------
Methods: CompanionDragEventHandler
-------------------------------------------------------------------------------]]
---@param e CompanionDragEventHandler
local function eventHandlerMethods(e)

    ---@param btnUI ButtonUI
    ---@param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)
        local companionCursor = BaseAPI:ToCompanionCursor(cursorInfo)

        local companion = BaseAPI:GetCompanionInfo(companionCursor.petType, companionCursor.index)
        if not companion then return end

        if IsInvalidCompanion(companion) then return end
        local btnData = btnUI.widget:GetConfig()
        local profileCompanion = ToProfileCompanion(companion)

        PH:PickupExisting(btnUI.widget)
        btnData[WAttr.TYPE] = WAttr.COMPANION
        btnData[WAttr.COMPANION] = profileCompanion

        S(btnUI, btnData)
    end

end

--[[-----------------------------------------------------------------------------
Methods: CompanionAttributeSetter
-------------------------------------------------------------------------------]]
---@param a CompanionAttributeSetter
local function attributeSetterMethods(a)
    ---@param btnUI ButtonUI
    ---@param btnData Profile_Button
    function a:SetAttributes(btnUI, btnData)
        --TODO: NEXT: Remove btnData
        local w = btnUI.widget
        w:ResetWidgetAttributes()
        local companion = w:GetButtonData():GetCompanionInfo()
        local spellIcon, spell = EMPTY_ICON, companion.spell
        if spell.icon then spellIcon = spell.icon end
        w:SetIcon(spellIcon)
        btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
        btnUI:SetAttribute(WAttr.SPELL, companion.name)

        self:HandleGameTooltipCallbacks(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        if not btnUI then return end
        local bd = btnUI.widget:GetButtonData()
        if not bd:ConfigContainsValidActionType() then return end

        local companion = bd:GetCompanionInfo()
        if bd:IsInvalidCompanion(companion) then return end

        GameTooltip:SetOwner(btnUI, GC.C.ANCHOR_TOPLEFT)
        GameTooltip:AddSpellByID(companion.spell.id)
    end
end

---@return MacroAttributeSetter
function L:GetAttributeSetter() return S
end

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
