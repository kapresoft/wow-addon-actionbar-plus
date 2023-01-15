--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
---@type _GameTooltip
local GameTooltip = GameTooltip
---### See: Interface/SharedXML/Constants.lua
local DESC_FORMAT = HIGHLIGHT_FONT_COLOR_CODE .. '\n%s' .. FONT_COLOR_CODE_CLOSE

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace()
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

---@class BattlePetDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(Core.M.BattlePetDragEventHandler)

---@class BattlePetAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(Core.M.BattlePetAttributeSetter)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(Core.M.BaseAttributeSetter)

---@param battlePet BattlePetInfo
---@return boolean
local function IsInvalidBattlePet(battlePet)
    return IsNil(battlePet) and IsNil(battlePet.guid) and IsNil(battlePet.name)
end

---@param pet BattlePetInfo
---@return Profile_BattlePet
local function ToProfileBattlePet(pet)
    return {
        type = 'battlepet',
        petType = pet.petType,
        guid = pet.guid,
        creatureID = pet.creatureID,
        speciesID = pet.speciesID,
        name = pet.name,
        icon = pet.icon,
    }
end


--[[-----------------------------------------------------------------------------
Methods: BattlePetDragEventHandler
-------------------------------------------------------------------------------]]
---@param e BattlePetDragEventHandler
local function eventHandlerMethods(e)

    ---Some battle pets are faction-based
    ---@param cursorInfo CursorInfo
    function e:Supports(cursorInfo)
        local petCursor = BaseAPI:ToBattlePetCursor(cursorInfo)
        if not petCursor then return false end
        return BaseAPI:CanSummonBattlePet(petCursor.guid)
    end

    ---@param btnUI ButtonUI
    ---@param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)
        local petCursor = BaseAPI:ToBattlePetCursor(cursorInfo)
        local battlePet = BaseAPI:GetBattlePetInfo(petCursor.guid)
        if not battlePet then return end

        if IsInvalidBattlePet(battlePet) then return end
        local btnData = btnUI.widget:GetConfig()
        local profileBattlePet = ToProfileBattlePet(battlePet)

        PH:PickupExisting(btnUI.widget)
        btnData[WAttr.TYPE] = WAttr.BATTLE_PET
        btnData[WAttr.BATTLE_PET] = profileBattlePet

        S(btnUI, btnData)
    end

end

--[[-----------------------------------------------------------------------------
Methods: BattlePetAttributeSetter
-------------------------------------------------------------------------------]]
---@param a BattlePetAttributeSetter
local function attributeSetterMethods(a)
    ---@param btnUI ButtonUI
    ---@param btnData Profile_Button
    function a:SetAttributes(btnUI, btnData)
        local w = btnUI.widget
        w:ResetWidgetAttributes()

        local battlePet = w:GetButtonData():GetBattlePetInfo()

        local spellIcon  = EMPTY_ICON
        if battlePet.icon then spellIcon = battlePet.icon end

        w:SetIcon(spellIcon)

        --- Note: Summoning a battle pet is not a secure call
        ---     * No Attributes need to be set.
        ---     * Summon is implemented on ButtonUI#PreClick()

        self:HandleGameTooltipCallbacks(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        if not btnUI then return end
        local bd = btnUI.widget:GetButtonData()
        if not bd:ConfigContainsValidActionType() then return end

        local battlePet = bd:GetBattlePetInfo()
        if bd:IsInvalidBattlePet(battlePet) then return end

        GameTooltip:SetText(battlePet.name)
        GameTooltip:AppendText(sformat(DESC_FORMAT, 'Instant'))
        GameTooltip:AppendText(sformat(DESC_FORMAT, 'Summons and dismisses your ' .. battlePet.name))
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
