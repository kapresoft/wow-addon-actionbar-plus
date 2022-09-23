--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local String, Assert = O.String, O.Assert
local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

local IsBlank, IsNil = String.IsBlank, Assert.IsNil

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function removeElement(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then tbl[i] = nil end
    end
end

---@param profileButton ProfileButton
local function CleanupTypeData(profileButton)
    if profileButton == nil or profileButton.type == nil then return end
    local btnTypes = { SPELL, MACRO, ITEM, MOUNT}
    removeElement(btnTypes, profileButton.type)
    for _, v in ipairs(btnTypes) do
        if v ~= nil then profileButton[v] = {} end
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param bd ButtonData
local function methods(bd)
    function bd:invalidButtonData(o, key)
        if type(o) ~= 'table' then return true end
        if type(o[key]) ~= 'nil' then
            local d = o[key]
            if type(d) == 'table' then return (IsBlank(d['id']) and IsBlank(d['index'])) end
        end
        return true
    end

    ---@return ProfileButton
    function bd:GetData()
        local w = self.widget
        local profile = w.profile
        local profileButton = profile:GetButtonData(w.frameIndex, w.buttonName)
        -- self cleanup
        CleanupTypeData(profileButton)
        return profileButton
    end

    ---@return ProfileTemplate
    function bd:GetProfileData() return self.widget.profile:GetProfileData() end
    ---@return boolean
    function bd:IsHideWhenTaxi() return self.widget.profile:IsHideWhenTaxi() end
    ---@return boolean
    function bd:ContainsValidAction() return self:GetActionName() ~= nil end
    ---@return string
    function bd:GetActionName()
        local conf = self:GetData()
        if not self:invalidButtonData(conf, SPELL) then return conf.spell.name end
        if not self:invalidButtonData(conf, ITEM) then return conf.item.name end
        if not self:invalidButtonData(conf, MACRO) then return conf.macro.name end
        return nil
    end

    ---@return SpellInfo
    function bd:GetSpellInfo() return self:GetData()[SPELL] end
    function bd:GetItemInfo() return self:GetData()[ITEM] end
    function bd:GetMacroInfo() return self:GetData()[MACRO] end
    ---@return MountInfo
    function bd:GetMountInfo() return self:GetData()[MOUNT] end

    ---@param mountInfo MountInfo
    function bd:IsInvalidMountInfo(mountInfo)
        return IsNil(mountInfo)
                and IsNil(mountInfo.name)
                and IsNil(mountInfo.spell)
                and IsNil(mountInfo.spell.id)
    end

end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local _B = LibStub:NewLibrary(Core.M.ButtonData)

---@param widget ButtonUIWidget
---@return ButtonData
function _B:Constructor(widget)
    ---@class ButtonData
    local o = { widget = widget }
    methods(o)
    return o
end

_B.mt.__call = _B.Constructor
