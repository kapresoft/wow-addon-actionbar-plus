--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @type __GameTooltip
local GameTooltip = GameTooltip
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local BaseAPI, PH = O.BaseAPI, O.PickupHandler
local WAttr, EMPTY_ICON = GC.WidgetAttributes, GC.Textures.TEXTURE_EMPTY
local AceEvent = ns:AceEvent()
local c1 = ns:ColorUtil():NewFormatterFromColor(HIGHLIGHT_LIGHT_BLUE)
local c2 = ns:ColorUtil():NewFormatterFromColor(VERY_LIGHT_GRAY_COLOR)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.EquipmentSetDragEventHandler
--- @class EquipmentSetDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(libName)
local p = ns:LC().DRAG_AND_DROP:NewLogger(libName)

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
        return true
    end

    --- @param btnUI ButtonUI
    --- @param cursorInfo CursorInfo
    function e:Handle(btnUI, cursorInfo)

        local equipmentSetInfo = BaseAPI:GetEquipmentSetInfo(cursorInfo)
        if not equipmentSetInfo then return end

        local config = btnUI.widget:conf()
        local equipmentSet = ToProfileEquipmentSet(equipmentSetInfo)
        p:d(30, function() return 'equipmentSet: %s', pformat(equipmentSet) end)

        PH:PickupExisting(btnUI.widget)
        config[WAttr.TYPE] = equipmentSet.type
        config[WAttr.EQUIPMENT_SET] = equipmentSet

        S(btnUI, config)

        AceEvent:SendMessage(GC.M.OnEquipmentSetDragComplete, libName, btnUI.widget)
    end

end

--[[-----------------------------------------------------------------------------
Methods: BattlePetAttributeSetter
-------------------------------------------------------------------------------]]
--- @param a EquipmentSetAttributeSetter
local function attributeSetterMethods(a)

    --- @param btnUI ButtonUI
    function a:SetAttributes(btnUI)
        local w = btnUI.widget; if not w then return end
        w:ResetWidgetAttributes()
        local equipmentSet = w:GetEquipmentSetData()
        if w:EquipmentSetMixin():IsInvalidEquipmentSet(equipmentSet) then return end

        local icon = EMPTY_ICON
        if equipmentSet.icon then icon = equipmentSet.icon end

        w:SetIcon(icon)
        self:HandleGameTooltipCallbacks(btnUI)
    end

    --- @param btnUI ButtonUI
    function a:RefreshTooltipAtMouse(btnUI)
        --- @type ButtonUI
        local f = GetMouseFocus()
        if not f then return end
        if f:GetName() ~= btnUI:GetName() then return end

        self:RefreshTooltip(f)
    end

    --- @param btnUI ButtonUI
    function a:RefreshTooltip(btnUI, setID)
        C_Timer.After(0.2, function() S:ShowTooltip(btnUI) end)
    end

    --- @param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        if not btnUI then return end
        local w = btnUI.widget; if w:IsEmpty() then return end
        local es = w:EquipmentSetMixin()
        if es:IsMissingEquipmentSet() then return end

        local equipmentSet = es:FindEquipmentSet()
        -- Use setID for all game versions
        GameTooltip:SetEquipmentSet(equipmentSet.id)

        if equipmentSet.isEquipped then
            -- todo next: localize
            local equippedLabel = c1(' (Equipped)')
            GameTooltip:AppendText(equippedLabel)
            GameTooltip:AddLine('Equipment set is ' .. c1('ACTIVE'))

            local talent = O.UnitMixin:GetTalentInfo()
            if talent then
                GameTooltip:AddLine(' ')
                local specText = sformat(LOOT_SPECIALIZATION_DEFAULT, c1(talent.spec)) .. ' ' .. (talent.icon or '')
                GameTooltip:AddDoubleLine(specText)
                if not ns:IsRetail() then
                    GameTooltip:AddLine('Talent Points:')
                    talent:ForEachTalent(function(name, points)
                        GameTooltip:AddDoubleLine(c2(name) .. ':', points)
                    end)
                end
            end
        else
            GameTooltip:AddLine(sformat('Click to %s equipment set', c1('activate')))
        end
        GameTooltip:Show()
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
end; Init()
