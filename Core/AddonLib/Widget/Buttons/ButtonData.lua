--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local G = O.LibGlobals
local String, P, LogFactory = O.String, O.Profile, O.LogFactory
local MX = O.Mixin
local SPELL, ITEM, MACRO = G:SpellItemMacroAttributes()
local IsBlank = String.IsBlank

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
    local btnTypes = { 'spell', 'macro', 'item'}
    removeElement(btnTypes, profileButton.type)
    for _, v in ipairs(btnTypes) do
        if v ~= nil then profileButton[v] = {} end
    end
end

--[[-----------------------------------------------------------------------------
New Instance: ButtonDataMixin
-------------------------------------------------------------------------------]]

---@class ButtonData
local _L = {
    profile = P
}

function _L:invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (IsBlank(d['id']) and IsBlank(d['index'])) end
    end
    return true
end

---@return ProfileButton
function _L:GetData()
    local profileButton = self.profile:GetButtonData(self.widget.frameIndex, self.widget.buttonName)
    -- self cleanup
    CleanupTypeData(profileButton)
    return profileButton
end

---@return ProfileTemplate
function _L:GetProfileData() return self.profile:GetProfileData() end
---@return boolean
function _L:IsHideWhenTaxi() return self.profile:IsHideWhenTaxi() end
---@return boolean
function _L:ContainsValidAction() return self:GetActionName() ~= nil end
---@return string
function _L:GetActionName()
    local conf = self:GetData()
    if not self:invalidButtonData(conf, SPELL) then return conf.spell.name end
    if not self:invalidButtonData(conf, ITEM) then return conf.item.name end
    if not self:invalidButtonData(conf, MACRO) then return conf.macro.name end
    return nil
end

--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]
---@type ButtonDataBuilder
local _B = LogFactory:NewLogger('ButtonDataBuilder', {})

---@param builder ButtonDataBuilder
local function ApplyBuilderMethods(builder)

    ---@param widget ButtonUIWidget
    ---@return ButtonData
    function builder:Create(widget)
        ---@class ButtonData_Constructor
        local bd = {}
        MX:Mixin(bd, _L)
        bd.widget = widget
        return bd
    end

end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewLibrary()
    ---@class ButtonDataBuilder
    local _N = LibStub:NewLibrary(Core.M.ButtonDataBuilder)
    ApplyBuilderMethods(_N)
    return _N
end

NewLibrary()
