--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Assert, String = O.Assert, O.String
local PH, CC, WC = O.PickupHandler, O.CommonConstants, O.WidgetConstants
local IsBlank, IsNotBlank, AssertNotNil, IsNil =
    String.IsBlank, String.IsNotBlank, Assert.AssertNotNil, Assert.IsNil
local BAttr, WAttr, UAttr = CC.ButtonAttributes,  CC.WidgetAttributes, CC.UnitAttributes
local EMPTY_ICON = WC.C.TEXTURE_EMPTY

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local p = O.LogFactory(Core.M.MountDragEventHandler)

---@class MountDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(Core.M.MountDragEventHandler)

---@class MountAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(Core.M.MountAttributeSetter)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(Core.M.BaseAttributeSetter)

---@param mountInfo MountInfo
---@return boolean
local function IsInvalidMountInfo(mountInfo)
    return IsNil(mountInfo)
            and IsNil(mountInfo.name)
            and IsNil(mountInfo.spell)
            and IsNil(mountInfo.spell.id)
end

--[[-----------------------------------------------------------------------------
Methods: MountDragEventHandler
-------------------------------------------------------------------------------]]
---@param e MountDragEventHandler
local function eventHandlerMethods(e)
    ---@param btnUI ButtonUI
    ---@param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)
        local mountInfo = _API:GetMountInfo(cursorInfo)
        if IsInvalidMountInfo(mountInfo) then return end
        local btnData = btnUI.widget:GetConfig()
        PH:PickupExisting(btnData)
        btnData[WAttr.TYPE] = WAttr.MOUNT
        btnData[WAttr.MOUNT] = mountInfo

        S(btnUI, btnData)
    end
end

--[[-----------------------------------------------------------------------------
Methods: MountAttributeSetter
-------------------------------------------------------------------------------]]
---@param a MountAttributeSetter
local function attributeSetterMethods(a)
    ---@param btnUI ButtonUI
    ---@param btnData ProfileButton
    function a:SetAttributes(btnUI, btnData)
        --TODO: NEXT: Remove btnData
        local w = btnUI.widget
        w:ResetWidgetAttributes()

        local mountInfo = w:GetButtonData():GetMountInfo()
        if w:GetButtonData():IsInvalidMountInfo(mountInfo) then return end
        local spellIcon, spell = EMPTY_ICON, mountInfo.spell
        if spell.icon then spellIcon = spell.icon end
        w:SetIcon(spellIcon)
        btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
        btnUI:SetAttribute(WAttr.SPELL, mountInfo.name)

        self:HandleGameTooltipCallbacks(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        if not btnUI then return end
        local w = btnUI.widget
        local btnData = w:GetConfig()
        if not btnData then return end
        if IsBlank(btnData.type) then return end

        local mountInfo = w:GetButtonData():GetMountInfo()
        if w:GetButtonData():IsInvalidMountInfo(mountInfo) then return end

        GameTooltip:SetOwner(btnUI, WC.C.ANCHOR_TOPLEFT)
        GameTooltip:AddSpellByID(mountInfo.spell.id)
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


