--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip, C_MountJournal = GameTooltip, C_MountJournal

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace()
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local Assert, String = O.Assert, O.String
local BaseAPI, PH, GC = O.BaseAPI, O.PickupHandler, O.GlobalConstants
local IsBlank, IsNotBlank, AssertNotNil, IsNil =
    String.IsBlank, String.IsNotBlank, Assert.AssertNotNil, Assert.IsNil
local WAttr, EMPTY_ICON = GC.WidgetAttributes, GC.Textures.TEXTURE_EMPTY

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

---@param mount MountInfo
---@return boolean
local function IsInvalidMount(mount)
    return IsNil(mount) and IsNil(mount.name) and IsNil(mount.spellID)
end

---@param mountInfo MountInfo
---@param cursorInfo CursorInfo
---@return Profile_Mount
local function ToProfileMount(mountInfo, cursorInfo)
    ---@type Profile_Mount_Spell
    local spell = {
        ---@type number
        id = mountInfo.spellID,
        ---@type number
        icon = mountInfo.icon }

    ---@type Profile_Mount
    local info = {
        type = 'mount',
        ---@type string
        name = mountInfo.name,
        ---@type number
        id = mountInfo.id,
        ---@type number
        index = mountInfo.index,
        ---@type Profile_Mount_Spell
        spell = spell
    }
    if C_MountJournal then info.index = cursorInfo.info2 end
    return info
end

--[[-----------------------------------------------------------------------------
Methods: MountDragEventHandler
-------------------------------------------------------------------------------]]
---@param e MountDragEventHandler
local function eventHandlerMethods(e)

    ---@param btnUI ButtonUI
    ---@param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)
        local mountInfoApi = BaseAPI:GetMountInfo(cursorInfo)
        if IsInvalidMount(mountInfoApi) then return end
        local btnData = btnUI.widget:GetConfig()
        local mount = ToProfileMount(mountInfoApi, cursorInfo)

        PH:PickupExisting(btnUI.widget)
        btnData[WAttr.TYPE] = WAttr.MOUNT
        btnData[WAttr.MOUNT] = mount

        S(btnUI, btnData)
    end

end

--[[-----------------------------------------------------------------------------
Methods: MountAttributeSetter
-------------------------------------------------------------------------------]]
---@param a MountAttributeSetter
local function attributeSetterMethods(a)
    ---@param btnUI ButtonUI
    ---@param btnData Profile_Button
    function a:SetAttributes(btnUI, btnData)
        --TODO: NEXT: Remove btnData
        local w = btnUI.widget
        w:ResetWidgetAttributes()

        local mount = w:GetButtonData():GetMountInfo()
        if w:GetButtonData():IsInvalidMount(mount) then return end
        local spellIcon, spell = EMPTY_ICON, mount.spell
        if spell.icon then spellIcon = spell.icon end
        w:SetIcon(spellIcon)
        btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
        btnUI:SetAttribute(WAttr.SPELL, mount.name)

        self:HandleGameTooltipCallbacks(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        local bd = btnUI.widget:GetButtonData()
        if not bd:ConfigContainsValidActionType() then return end

        local mountInfo = bd:GetMountInfo()
        if bd:IsInvalidCompanion(mountInfo) then return end

        GameTooltip:SetSpellByID(mountInfo.spell.id)
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
