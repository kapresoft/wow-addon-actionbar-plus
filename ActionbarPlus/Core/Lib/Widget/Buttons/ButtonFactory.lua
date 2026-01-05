--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tinsert = table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, E, LibStub = ns.O, ns.GC, ns.M, ns.GC.E, ns.LibStub

local toMsg = GC.toMsg
local Table, P, MSG = ns:Table(), O.Profile, GC.M
local IsEmptyTable = Table.isEmpty
local frameBuilder = O.ActionBarFrameBuilder
local WAttr        = ns.GC.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT, COMPANION, BATTLE_PET, EQUIPMENT_SET =
WAttr.SPELL, WAttr.ITEM, WAttr.MACRO,
WAttr.MOUNT, WAttr.COMPANION, WAttr.BATTLE_PET,
WAttr.EQUIPMENT_SET

--- @type ButtonUILib
local ButtonUI = O.ButtonUI
local WMX      = O.WidgetMixin
local libName  = M.ButtonFactory
local MAS      = O.MountAttributeSetter

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class ButtonFactory : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end; ns:AceEvent(L)
local p = ns:LC().BUTTON:NewLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)

-- todo next: Move Attribute setters to AttributeSetterRegistry #503
--- @type table<string, AttributeSetter>
local AttributeSetters = {
    [SPELL]         = O.SpellAttributeSetter,
    [ITEM]          = O.ItemAttributeSetter,
    [MACRO]         = O.MacroAttributeSetter,
    [MOUNT]         = MAS,
    [COMPANION]     = O.CompanionAttributeSetter,
    [BATTLE_PET]    = O.BattlePetAttributeSetter,
    [EQUIPMENT_SET] = O.EquipmentSetAttributeSetter,
}

L.FRAMES = {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function abh() return O.ActionBarHandlerMixin end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @NotCombatSafe
function L:Init()
    frameBuilder:CreateActionBarFrames(function(name, index)
        local f = self:CreateActionbarGroup(index)
        tinsert(self.FRAMES, f)
        f:ShowGroupIfEnabled()
    end)
end

--- @param frameIndex Index The index of the action bar
function L:CreateActionbarGroup(frameIndex)
    local barConfig = P:GetBar(frameIndex)
    local widget = barConfig.widget
    local f = frameBuilder:New(frameIndex)
    self:CreateButtons(f, widget.rowSize, widget.colSize)
    f:SetInitialState()
    return f
end

--- @param fw ActionBarFrameWidget
--- @param rowSize number
--- @param colSize number
function L:CreateButtons(fw, rowSize, colSize)
    fw:ClearButtons()
    local index = 0
    for row=1, rowSize do
        for col=1, colSize do
            index = index + 1
            local bw = self:CreateSingleButton(fw, row, col, index)
            fw:AddButtonFrame(bw.button())
        end
    end
    fw:LayoutButtonGrid()
end

--- @param frameWidget ActionBarFrameWidget
--- @param row number
--- @param col number
--- @param btnIndex number The button index number
--- @return ButtonUIWidget
function L:CreateSingleButton(frameWidget, row, col, btnIndex)
    local btnUI = frameWidget:GetButtonUI(btnIndex)
    local btnWidget = btnUI and btnUI.widget
    if not btnWidget then
        btnWidget = ButtonUI:WidgetBuilder():Create(frameWidget, row, col, btnIndex)
    else
        btnWidget:InitConfig()
    end
    btnWidget:ClearAllText()
    btnWidget:ResetCooldown()

    btnWidget:SetButtonAttributes()
    btnWidget:SetCallback("OnMacroChanged", OnMacroChanged)
    btnWidget:UpdateDelayed(0.05)
    btnWidget:CleanupActionTypeData()
    -- after a switch in spec, the buttons need to be cleared as needed
    if btnWidget:IsEmpty() then btnWidget:SetButtonAsEmpty() end
    return btnWidget
end

--[[-----------------------------------------------------------------------------
Event Handlers
-------------------------------------------------------------------------------]]
--- This event includes ZONE_CHANGED_NEW_AREA because the player could be mounted before
--- entering the portal and get dismounted upon zoning in to the new area
local function OnPlayerMount()
    abh():ForEachMountButton(function(bw)
        MAS:SetAttributes(bw.button(), 'event')
    end)
end

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function InitButtonFactory()
    L:RegisterMessage(MSG.OnAddOnEnabled, function(msg, source, addOn)
        L:Init()
    end)

    L:RegisterMessage(toMsg(E.PLAYER_MOUNT_DISPLAY_CHANGED), OnPlayerMount)
    L:RegisterMessage(toMsg(E.ZONE_CHANGED_NEW_AREA), OnPlayerMount)
end

InitButtonFactory()
