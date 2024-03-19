--- @alias EquipmentSetController __EquipmentSetController | ActionBarHandlerMixin
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, MSG, E = ns.O, ns.GC, ns.GC.M, ns.GC.E

local AceBucket = ns:AceBucket()
local toMsg = GC.toMsg
local ES = O.EquipmentSetMixin
local libName = 'EquipmentSetController'
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class __EquipmentSetController : BaseActionBarController
local L = ns:NewActionBarHandler(libName);
local p = ns:CreateDefaultLogger(libName)
p:v(function() return "Loaded: %s", libName end)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __EquipmentSetController | EquipmentSetController
local function PropsAndMethods(o)

    --- @private
    function o:RegisterMessageCallbacks()
        self:RegisterMessage(MSG.OnAddOnReady, function() self:OnAddOnReady()  end)
        self:RegisterAddonMessage(E.EQUIPMENT_SETS_CHANGED, function(evt) self:OnEquipmentSetsChanged() end)
        self:RegisterAddonMessage(E.EQUIPMENT_SWAP_FINISHED, function(evt, source, success, setID)
            self:OnEquipmentSwapFinished(success, setID) end)
    end

    function o:OnAddOnReady()
        p:f3('OnEquipmentSetsChanged called...')

        self:ForEachEquipmentSetButton(function(bw)
            local equipped, set = ES:New(bw):IsAllEquipped()
            p:d(function() return 'Is-Equipped::%s[%s]?: %s',
                bw:GN(), set.name ,tostring(equipped) end)
            bw:SetChecked(equipped)
        end)
    end

    --- @param frameWidget FrameWidget
    --- @param event string
    --- @private
    function o:OnEquipmentSetsChanged(frameWidget, event)
        p:f3('OnEquipmentSetsChanged called...')
        self:ForEachEquipmentSetButton(function(bw)
            ES:New(bw):UpdateEquipmentSet()
        end)
    end

    --- @param success boolean
    --- @param setID Identifier
    function o:OnEquipmentSwapFinished(success, setID)
        p:f3(function() return 'OnEquipmentSwapFinished called: equip-success=%s setID=%s',
                tostring(success), tostring(setID) end)

        self:ForEachEquipmentSetButton(function(bw)
            local es = ES:New(bw)
            es:RefreshTooltip(setID)
            local d = bw:GetEquipmentSetData()
            if d.id ~= setID then return bw:SetChecked(false) end

            es:GlowButtonConditionally()
            bw:SetChecked(true)
        end)
    end

    o:RegisterMessageCallbacks()
end; PropsAndMethods(L)

