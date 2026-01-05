--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, E = ns.O, ns.GC, ns.GC.E
local MSG, API, Compat = GC.M, O.API, O.Compat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'EquippedWeaponController'
--- @class EquippedWeaponController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
local ps = ns:LC().EQUIPMENT:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o EquippedWeaponController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:ConditionallyCheckItemButtons()
        self:RegisterMessageCallbacks()
    end

    --- @param bw ButtonUIWidget
    function o:OnUpdateSingleItem(bw)
        self:ConditionallyCheckSingleItemButton(bw)
    end

    --- @private
    function o:RegisterMessageCallbacks()
        self:RegisterAddOnMessage(E.PLAYER_EQUIPMENT_CHANGED, function(msg, source, ...)
                                      self:OnPlayerEquipmentChanged(...) end)
        self:RegisterMessage(MSG.OnUpdateItemState, function(msg, source, bw)
            self:OnUpdateSingleItem(bw)
        end)
    end

    --- Check if a specific item is equipped by item ID.
    --- @param itemID number The item ID to check.
    --- @return boolean
    function o:IsItemEquipped(itemID)
        for slot = 1, 19 do
            local link = GetInventoryItemLink("player", slot)
            if link then
                local equippedItemID = Compat:GetItemInfoInstant(link)
                if equippedItemID == itemID then return true end
            end
        end
        return false
    end

    --- @param slotID Identifier The slot number that changed
    --- @param hasItem Boolean true if an item is now in that slot, false if it's empty.
    function o:OnPlayerEquipmentChanged(slotID, hasItem)
        self:ConditionallyCheckItemButtons()
    end

    function o:ConditionallyCheckItemButtons()
        self:ForEachItemButton(function(bw)
            self:ConditionallyCheckSingleItemButton(bw) end)
    end

    --- @param bw ButtonUIWidget
    function o:ConditionallyCheckSingleItemButton(bw)
        local it = bw:GetItemData()
        if not it or not it.id or not bw:IsWeaponOrArmor(it.id) then return end
        bw:SetChecked(self:IsItemEquipped(it.id))
    end

end; PropsAndMethods(L)

