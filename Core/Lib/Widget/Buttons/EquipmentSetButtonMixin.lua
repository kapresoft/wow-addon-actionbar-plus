--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return EquipmentSetButtonMixin, LoggerV2
local function CreateLib()
    local libName = M.EquipmentSetButtonMixin
    --- @class EquipmentSetButtonMixin : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o EquipmentSetButtonMixin
local function PropsAndMethods(o)

    --- @param widget ButtonUIWidget
    function o:Init(widget)
        assert(widget, "ButtonUIWidget is missing")
        self.w = widget
        self.configData = widget:GetEquipmentSetData()
        self.baseAPI = O.BaseAPI
    end

    --- @param widget ButtonUIWidget
    function o:Mixin(widget) ns:K():Mixin(widget, self:New(widget)) end

    --- @param widget ButtonUIWidget
    --- @return EquipmentSetButtonMixin
    function o:New(widget)
        return ns:K():CreateAndInitFromMixin(o, widget)
    end

    --- @return boolean, EquipmentSetInfo
    function o:IsAllEquipped()
        if self:IsMissingEquipmentSet() then return false end
        local equipmentSet = self:FindEquipmentSet()
        local isEquipped = equipmentSet and equipmentSet.isEquipped == true
        return isEquipped, equipmentSet
    end

    --- @return EquipmentSetInfo
    function o:FindEquipmentSet()
        local id, name = self.configData and self.configData.id, self.configData.name
        if not id then return end

        local index = self.baseAPI:GetEquipmentSetIndex(id)
        if not index then return nil end

        local equipmentSet = self.baseAPI:GetEquipmentSetInfoByName(name)
        if not equipmentSet then
            equipmentSet = self.baseAPI:GetEquipmentSetInfoBySetID(id)
        end
        return equipmentSet
    end

    --- @return boolean
    function o:IsMissingEquipmentSet()
        local d = self.configData
        local equipmentSetId = d and d.id
        if not equipmentSetId then return true end

        local equipmentSet = self:FindEquipmentSet()
        if not equipmentSet then return true end

        local index = self.baseAPI:GetEquipmentSetIndex(equipmentSet.id)
        if not index then return true end

        return equipmentSet.id ~= equipmentSetId
    end

    function o:GlowButtonConditionally()
        local profile = self.w:GetProfileConfig()
        if profile.equipmentset_show_glow_when_active ~= true then return end
        self.w:ShowOverlayGlow()
        C_Timer.After(0.8, function() self.w:HideOverlayGlow() end)
    end

    --- Note: Equipment Set Name cannot be updated.
    --- The Equipment Manager always creates a new unique name.
    function o:UpdateEquipmentSet()
        -- if index changed (similar to how macros are updated)
        -- if equipment set was deleted
        -- icon update
        if self:IsMissingEquipmentSet() then
            self.w:SetButtonAsEmpty()
            self.w:EnableMouse(false)
            return
        end

        local equipmentSet = self:FindEquipmentSet()
        if not equipmentSet then
            self.w:SetButtonAsEmpty()
            return
        end

        local btnData = self.w:GetEquipmentSetData()
        btnData.name = equipmentSet.name
        btnData.icon = equipmentSet.icon
        self.w:SetIcon(btnData.icon)
    end

    ---@param setID Identifier Equipment Set ID
    function o:RefreshTooltip(setID)
        local equipmentSet = O.BaseAPI:GetEquipmentSetInfoBySetID(setID)
        if not equipmentSet then return end
        -- retail GameTooltip uses setID
        GameTooltip:SetEquipmentSet(equipmentSet.id)
        local equippedLabel = ns:K().CH:FormatColor('0073FF', ' (Equipped)')
        GameTooltip:AppendText(equippedLabel)
    end

    --- @param equipmentData Profile_EquipmentSet
    --- @param equipmentData Profile_EquipmentSet
    --- @return boolean
    function o:IsInvalidEquipmentSet(equipmentData)
        if not equipmentData then return true end
        return equipmentData.name and equipmentData.index
    end

end; PropsAndMethods(L)

