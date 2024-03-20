--- @alias EquipmentSetController __EquipmentSetController | ActionBarHandlerMixin
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, MSG, E = ns.O, ns.GC, ns.GC.M, ns.GC.E

local BaseAPI = O.BaseAPI
local libName = ns.M.EquipmentSetController
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class __EquipmentSetController : BaseActionBarController
local L = ns:NewActionBarHandler(libName);
local p = ns:LC().EQUIPMENT:NewLogger(libName)
local pd = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o __EquipmentSetController | EquipmentSetController
local function PropsAndMethods(o)

    --- @private
    function o:RegisterMessageCallbacks()
        self:RegisterMessage(MSG.OnAddOnReady, function() self:OnAddOnReady()  end)
        self:RegisterMessage(GC.M.OnButtonClickEquipmentSet,
                function(evt, source, ...) self:OnClick(...)  end)
        self:RegisterMessage(GC.M.OnEquipmentSetDragComplete,
                function(evt, source, ...) self:OnEquipmentSetDragComplete(...)  end)
        self:RegisterAddonMessage(E.PLAYER_EQUIPMENT_CHANGED,
                function(evt, source, ...) self:OnPlayerEquipmentChanged(...) end)
        self:RegisterAddonMessage(E.EQUIPMENT_SETS_CHANGED,
                function(evt) self:OnEquipmentSetsChanged() end)
        self:RegisterAddonMessage(E.EQUIPMENT_SWAP_FINISHED,
                function(evt, source, success, setID) self:OnEquipmentSwapFinished(success, setID) end)
    end

    --- @private
    --- @param bw ButtonUIWidget
    function o:OnEquipmentSetDragComplete(bw)
        local name = bw and bw:GN()
        p:f3(function()
            return 'OnEquipmentSetDragComplete called: widget=%s', name end)
        self:CheckIfEquipped(bw:EquipmentSetMixin())
    end

    --- @private
    --- @param invSlotID Identifier
    --- @param hasCurrent boolean True when a slot becomes empty, false when filled.
    function o:OnPlayerEquipmentChanged(invSlotID, hasCurrent)
        p:f3(function()
            return 'OnPlayerEquipmentChanged called: slotID=%s hasCurrent=%s', invSlotID, tostring(hasCurrent) end)
        self:ConditionallyCheckButtons()
    end

    --- @private
    function o:OnAddOnReady()
        p:f3('OnEquipmentSetsChanged called...')
        self:ConditionallyCheckButtons()
    end

    --- Called when an equipment-set is saved, deleted, renamed
    --- @private
    function o:OnEquipmentSetsChanged()
        p:f3('OnEquipmentSetsChanged called...')
        self:ForEachEquipmentSetButton(function(bw)
            bw:EquipmentSetMixin():UpdateEquipmentSet()
        end)
        self:ConditionallyCheckButtons()
    end

    --- @private
    --- @param success boolean
    --- @param setID Identifier
    function o:OnEquipmentSwapFinished(success, setID)
        p:f3(function() return 'OnEquipmentSwapFinished called: equip-success=%s setID=%s',
                tostring(success), tostring(setID) end)

        self:ForEachEquipmentSetButton(function(bw)
            local es = bw:EquipmentSetMixin()
            es:RefreshTooltip(setID)
            self:CheckIfEquipped(es)
            local d = bw:GetEquipmentSetData()
            if d.id ~= setID then return end
            es:GlowButtonConditionally()
        end)
    end

    --- @private
    --- @param w ButtonUIWidget
    function o:OnClick(w)
        assert(w, "ButtonUIWidget is missing")
        if not w:CanChangeEquipmentSet() or InCombatLockdown() then return end

        --- @type _Frame
        local PDF = PaperDollFrame
        C_EquipmentSet.UseEquipmentSet(w:GetEquipmentSetData().id)
        PlaySound(SOUNDKIT.GUILD_BANK_OPEN_BAG)

        local profile = w:GetProfileConfig()
        if profile.equipmentset_open_character_frame then
            if not PDF:IsVisible() then
                ToggleCharacter('PaperDollFrame')
                self:OpenEquipmentMgrConditionally(w, profile)
            else self:OpenEquipmentMgrConditionally(w, profile) end
        end
    end

    --- @private
    function o:ConditionallyCheckButtons()
        self:ForEachEquipmentSetButton(function(bw)
            self:CheckIfEquipped(bw:EquipmentSetMixin())
        end)
    end
    --- @private
    --- @param esm EquipmentSetButtonMixin
    function o:CheckIfEquipped(esm)
        local equipped, set = esm:IsAllEquipped()
        p:d(function()
            return 'Is-Equipped::%s[%s]?: %s', esm.w:GN(), set.name ,tostring(equipped)
        end)
        esm.w:SetChecked(equipped)
    end

    --- @private
    --- @param w ButtonUIWidget
    --- @param profile Profile_Config
    function o:OpenEquipmentMgrConditionally(w, profile)
        if profile.equipmentset_open_equipment_manager == true then
            --- @type _Frame
            local gmDlg = GearManagerDialog
            if gmDlg and gmDlg:IsVisible() then self:ClickEquipmentSetButtonDelayed(w) return end
        end

        --- Buttons:
        --- • GearManagerToggleButton (pre-retail)
        --- • PaperDollSidebarTab3 (retail)
        --- @type _Button
        local gmButton = GearManagerToggleButton or PaperDollSidebarTab3
        if profile.equipmentset_open_equipment_manager ~= true then return end
        C_Timer.After(0.1, function()
            gmButton:Click()
            self:ClickEquipmentSetButtonDelayed(w)
        end)
    end

    --- @private
    --- @param w ButtonUIWidget
    function o:ClickEquipmentSetButtonDelayed(w)
        C_Timer.After(0.2, function() self:ClickEquipmentSetButton(w) end)
    end

    --- @private
    --- @param bw ButtonUIWidget
    function o:ClickEquipmentSetButton(bw)
        if bw:EquipmentSetMixin():IsMissingEquipmentSet() then return end

        local equipmentSet = bw:GetEquipmentSetData()
        local index = BaseAPI:GetEquipmentSetIndex(equipmentSet.id)

        local btnName = 'GearSetButton' .. (index)
        if _G[btnName] then _G[btnName]:Click() end
    end

    o:RegisterMessageCallbacks()
end; PropsAndMethods(L)

