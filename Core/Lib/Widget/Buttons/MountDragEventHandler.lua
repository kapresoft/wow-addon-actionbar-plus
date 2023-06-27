--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip, C_MountJournal = GameTooltip, C_MountJournal

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local BaseAPI, PH = O.BaseAPI, O.PickupHandler
local IsNil = O.Assert.IsNil
local WAttr, EMPTY_ICON = GC.WidgetAttributes, GC.Textures.TEXTURE_EMPTY

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local p = O.LogFactory(M.MountDragEventHandler)

---@class MountDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.MountDragEventHandler); if not L then return end

---@class MountAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.MountAttributeSetter); if not S then return end
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(M.BaseAttributeSetter)

---@param mount MountInfo
---@return boolean
local function IsInvalidMount(mount)
    if not mount then return true end
    return IsNil(mount.name) and IsNil(mount.spellID)
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
        local btnData = btnUI.widget.config()
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
    ---@param source string The source of the trigger, i.e. 'event'
    function a:SetAttributes(btnUI, source)
        local w = btnUI.widget
        w:ResetWidgetAttributes()

        local mount = w:GetMountData()
        if w:IsInvalidMount(mount) then return end

        if not InCombatLockdown() then
            btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
            btnUI:SetAttribute(WAttr.SPELL, mount.name)
        end

        if source ~= 'event' then self:SetActiveIcon(w, mount)
        else self:SetActiveIconDelayed(w, mount) end

        self:HandleGameTooltipCallbacks(btnUI)
    end

    ---@param w ButtonUIWidget
    ---@param mount Profile_Mount
    function a:SetActiveIconDelayed(w, mount)
        local delayInSec = 0.2
        if IsMounted() then delayInSec = 0 end
        C_Timer.After(delayInSec,  function() self:SetActiveIcon(w, mount) end)
    end

    ---@param w ButtonUIWidget
    ---@param mount Profile_Mount
    function a:SetActiveIcon(w, mount)
        local spellIcon, spell = EMPTY_ICON, mount.spell
        if spell.icon then spellIcon = spell.icon end

        local mountInfo = BaseAPI:GetMountInfoGeneric(mount)
        if not mountInfo then return end
        spellIcon = mountInfo.icon
        if mountInfo.isActive then spellIcon = GC.C.MOUNT_ACTIVE_TEXTURE end
        mount.spell.icon = spellIcon
        w:SetIcon(spellIcon)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        local w = btnUI.widget
        if not w:ConfigContainsValidActionType() then return end

        local mountInfo = w:GetMountData()
        if w:IsInvalidCompanion(mountInfo) then return end

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
