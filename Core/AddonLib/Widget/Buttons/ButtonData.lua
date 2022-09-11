-- #ButtonData.lua

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local G = __K_Core:LibPack_Globals()
local LibStub, M, P, LogFactory = G:LibPack_NewLibrary()
local SPELL, ITEM, MACRO = G:SpellItemMacroAttributes()

---@type String
local String = G(M.String)

local IsBlank = String.IsBlank
local MX = G(M.Mixin)

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

---@class ButtonDataOperations
local _L = {}
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

function _L:IsHideWhenTaxi() return self.profile:IsHideWhenTaxi() end
function _L:ContainsValidAction() return self:GetActionName() ~= nil end

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
    function builder:Create(widget)
        ---@class ButtonData : ButtonDataOperations
        local bd = {
            ---@type Profile
            profile = P,
            widget = widget
        }
        MX:Mixin(bd, _L)

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
    local _L = LibStub:NewLibrary(M.ButtonDataBuilder, 1)
    ApplyBuilderMethods(_L)
    return _L
end

NewLibrary()
