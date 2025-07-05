--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tinsert = table.insert

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local TooltipDataProcessor = TooltipDataProcessor
local Enum, EmbeddedItemTooltip, ItemRefTooltip = Enum, EmbeddedItemTooltip, ItemRefTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, E, LibStub = ns.O, ns.GC, ns.M, ns.GC.E, ns.LibStub

local toMsg = GC.toMsg
local Table, P, MSG = ns:Table(), O.Profile, GC.M
local IsEmptyTable = Table.isEmpty
local ButtonFrameFactory = O.ButtonFrameFactory
local WAttr = ns.GC.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT, COMPANION, BATTLE_PET, EQUIPMENT_SET =
WAttr.SPELL, WAttr.ITEM, WAttr.MACRO,
WAttr.MOUNT, WAttr.COMPANION, WAttr.BATTLE_PET,
WAttr.EQUIPMENT_SET
--- @type ButtonUILib
local ButtonUI = O.ButtonUI
local WMX = O.WidgetMixin
local libName = M.ButtonFactory
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class ButtonFactory : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end; ns:AceEvent(L)
local p = ns:LC().BUTTON:NewLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)
--- @type table<string, AttributeSetter>
local AttributeSetters = {
    [SPELL]       = O.SpellAttributeSetter,
    [ITEM]        = O.ItemAttributeSetter,
    [MACRO]       = O.MacroAttributeSetter,
    [MOUNT]       = O.MountAttributeSetter,
    [COMPANION]   = O.CompanionAttributeSetter,
    [BATTLE_PET]   = O.BattlePetAttributeSetter,
    [EQUIPMENT_SET] = O.EquipmentSetAttributeSetter,
}

L.FRAMES = {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function InitButtonGameTooltipHooksLegacy()
    GameTooltip:HookScript(E.OnShow, function(tooltip, ...)
        if not WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)
    GameTooltip:HookScript(E.OnTooltipSetSpell, function(tooltip, ...)
        if WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)
    GameTooltip:HookScript(E.OnTooltipSetItem, function(tooltip, ...)
        if WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)
end

local function InitButtonGameTooltipHooksUsingTooltipDataProcessor()
    ---For macros not using spells
    GameTooltip:HookScript("OnShow", function(tooltip, ...)
        if not WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        WMX:SetupTooltipKeybindingInfo(tooltip)
    end)

    local onTooltipSetSpellFunction = function(tooltip, tooltipData)
        if WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        if (tooltip == GameTooltip or tooltip == EmbeddedItemTooltip) then
            WMX:SetupTooltipKeybindingInfo(tooltip)
        end
    end
    local onTooltipSetItemFunction = function(tooltip, tooltipData)
        if WMX:IsTypeMacro(tooltip:GetOwner()) then return end
        if (tooltip == GameTooltip or tooltip == ItemRefTooltip) then
            WMX:SetupTooltipKeybindingInfo(tooltip)
        end
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, onTooltipSetSpellFunction)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, onTooltipSetItemFunction)
end

local function InitButtonGameTooltipHooks()
    if TooltipDataProcessor then
        InitButtonGameTooltipHooksUsingTooltipDataProcessor()
        return
    end
    InitButtonGameTooltipHooksLegacy()
end

--- @param btnWidget ButtonUIWidget
local function OnMacroChanged(btnWidget)
    AttributeSetters[MACRO]:SetAttributes(btnWidget.button())
end

--- Autocorrect bad data if we have button data with
--- btnData[type] but no btnData.type
--- @param btnWidget ButtonUIWidget
--- @param btnData Profile_Button
local function GuessButtonType(btnWidget, btnData)
    for buttonType in pairs(AttributeSetters) do
        -- return the first data found
        if not IsEmptyTable(btnData[buttonType]) then
            return buttonType
        end
    end
    return nil
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
-- todo refactor:
function L:Init()
    local frameNames = ButtonFrameFactory:CreateActionbarFrames()
    for i in ipairs(frameNames) do
        local f = self:CreateActionbarGroup(i)
        tinsert(self.FRAMES, f)
        f:ShowGroupIfEnabled()
        -- TODO next: revisit whether scrubbing is needed since default profile ace config
        --            takes care of that
        --f:ScrubEmptyButtons()
    end
end

function L:Fire(event, sourceEvent, ...)
    local args = ...
    --- @param frameWidget FrameWidget
    self:ApplyForEachFrames(function(frameWidget)
        if frameWidget then frameWidget:Fire(event, sourceEvent, args) end
    end)
end

function L:FireOnFrame(frameIndex, event, sourceEvent, ...)
    local args = ...
    self.FRAMES[frameIndex]:Fire(event, sourceEvent, args)
end

--- @param applyFunction FrameHandlerFunction | "function(frameWidget) print(frameWidget:GetName()) end"
function L:ApplyForEachFrames(applyFunction)
    local frames = P:GetAllFrameNames()
    if #frames <= 0 then return end
    -- `_` is the index
    for _,f in ipairs(frames) do applyFunction(_G[f].widget) end
end

--- @param applyFunction FrameHandlerFunction | "function(frameWidget) print(frameWidget:GetName()) end"
function L:ApplyForEachVisibleFrames(applyFunction)
    local frames = P:GetAllBarFrames()
    if #frames <= 0 then return end
    for _,f in ipairs(frames) do
        local fw = f.widget
        if fw and fw:IsShownInConfig() then applyFunction(fw) end
    end
end
--- Alias for #ApplyForEachVisibleFrames(applyFunction)
--- @param applyFunction FrameHandlerFunction | "function(frameWidget) print(frameWidget:GetName()) end"
function L:fevf(applyFunction) self:ApplyForEachVisibleFrames(applyFunction) end

function L:UpdateKeybindText()
    local frames = P:GetAllFrameNames()
    for i,name in ipairs(frames) do
        local f = _G[name]
        if f and f.widget then
            --- @type FrameWidget
            local fw = f.widget
            if P:IsBarIndexEnabled(i) then fw:UpdateKeybindText() end
        end
    end
end

function L:RefreshActionbar(frameIndex)
    P:GetFrameWidgetByIndex(frameIndex):RefreshActionbarFrame()
end

function L:CreateActionbarGroup(frameIndex)
    local barConfig = P:GetBar(frameIndex)
    local widget = barConfig.widget
    local f = ButtonFrameFactory:New(frameIndex)
    self:CreateButtons(f, widget.rowSize, widget.colSize)
    f:SetInitialState()
    return f
end

--- @param fw FrameWidget
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

--- @param frameWidget FrameWidget
--- @param row number
--- @param col number
--- @param btnIndex number The button index number
--- @return ButtonUIWidget
function L:CreateSingleButton(frameWidget, row, col, btnIndex)
    local btnUI = frameWidget:GetButtonUI(btnIndex)
    local btnWidget = btnUI and btnUI.widget
    if not btnWidget then
        btnWidget = ButtonUI:WidgetBuilder():Create(frameWidget, row, col, btnIndex)
    end
    btnWidget:ClearAllText()
    btnWidget:ResetCooldown()

    btnWidget:SetButtonAttributes()
    btnWidget:SetCallback("OnMacroChanged", OnMacroChanged)
    btnWidget:UpdateStateDelayed(0.05)
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
    pm:f3('OnPlayerMount called...')
    L:ApplyForEachVisibleFrames(function(fw)
        fw:ApplyForEachButtonCondition(
                function(bw) return bw:IsMount() end,
                function(bw) O.MountAttributeSetter:SetAttributes(bw.button(), 'event') end
        )
    end)
end

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function InitButtonFactory()
    InitButtonGameTooltipHooks()
    L:RegisterMessage(MSG.OnAddOnEnabled, function(msg, source, addOn)
        L:Init()
    end)

    L:RegisterMessage(toMsg(E.PLAYER_MOUNT_DISPLAY_CHANGED), OnPlayerMount)
    L:RegisterMessage(toMsg(E.ZONE_CHANGED_NEW_AREA), OnPlayerMount)
end

InitButtonFactory()
