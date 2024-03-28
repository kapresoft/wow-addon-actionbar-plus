--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local PH = O.PickupHandler
local WAttr, EMPTY_ICON = GC.WidgetAttributes, GC.Textures.TEXTURE_EMPTY
local BaseAPI = O.BaseAPI
local IsNil, IsNotBlank = O.Assert.IsNil, O.String.IsNotBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class CompanionDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.CompanionDragEventHandler); if not L then return end
local p = L.logger

---@class CompanionAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.CompanionAttributeSetter); if not S then return end
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(M.BaseAttributeSetter)

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
        petID = companion.petID,
        icon = companion.icon,
        id = companion.creatureID,
        index = companion.index,
        name = companion.creatureName,
        spell = {  id = companion.creatureSpellID, icon = companion.icon },
    }
end

--[[-----------------------------------------------------------------------------
Methods: CompanionDragEventHandler
-------------------------------------------------------------------------------]]
---@param e CompanionDragEventHandler
local function eventHandlerMethods(e)

    --- Note: Companions in classic-era are type 'item', see ItemDragEventHandler
    --- @param btnUI ButtonUI
    --- @param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)
        local companionCursor = BaseAPI:ToCompanionCursor(cursorInfo)

        local companion = BaseAPI:GetCompanionInfo(companionCursor.petType, companionCursor.index)
        if not companion then return end

        local btnData = btnUI.widget:conf()
        local profileCompanion = ToProfileCompanion(companion)

        if C_PetJournal and C_PetJournal.GetPetInfoByPetID then profileCompanion.spell = nil end

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
    function a:SetAttributes(btnUI)
        local w = btnUI.widget
        w:ResetWidgetAttributes()
        local companion = w:GetCompanionData(); if not companion then return end

        local spell = companion.spell
        local spellIcon = companion.icon or (spell and spell.icon) or EMPTY_ICON
        if not spellIcon then return end
        w:SetIcon(spellIcon)

        if not (C_PetJournal or C_PetJournal.GetPetInfoByPetID) then
            -- classic
            btnUI:SetAttribute(WAttr.TYPE, WAttr.SPELL)
            btnUI:SetAttribute(WAttr.SPELL, companion.name)
        end

        self:HandleGameTooltipCallbacks(btnUI)
        btnUI.widget:UpdateCompanionActiveState()
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        local w = btnUI.widget

        local conf = w:conf()
        if not w:ConfigContainsValidActionType() then return end
        local companion = w:GetCompanionData()
        if w:IsInvalidCompanion(companion) then return end

        local petID = C_PetJournal and C_PetJournal.GetPetInfoByPetID
                and conf.companion.petID
        if petID then GameTooltip:SetCompanionPet(petID); return end

        local spellID = companion and companion.spell and companion.spell.id
        if not spellID then return end
        GameTooltip:SetSpellByID(spellID)
    end
end

---@return MacroAttributeSetter
function L:GetAttributeSetter() return S
end

--- @param evt string
--- @param w ButtonUIWidget
local function OnClick(evt, source, w, ...)
    if InCombatLockdown() then return end
    local conf = w:conf()
    local petID = conf and conf.companion and IsNotBlank(conf.companion.petID) and conf.companion.petID
    return petID and C_PetJournal.SummonPetByGUID(petID)
end

--[[-----------------------------------------------------------------------------
Init
-------------------------------------------------------------------------------]]
local function Init()
    eventHandlerMethods(L)
    attributeSetterMethods(S)

    S.mt.__index = BaseAttributeSetter
    S.mt.__call = S.SetAttributes

    ns:AceEvent():RegisterMessage(GC.M.OnButtonClickCompanion, OnClick)
end

Init()
