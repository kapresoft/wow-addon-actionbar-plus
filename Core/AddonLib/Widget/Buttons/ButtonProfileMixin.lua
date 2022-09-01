--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local SPELL,ITEM,MACRO = 'spell','item','macro'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local LibStub, M = ABP_LibGlobals:LibPack()

---@class ButtonProfileMixin
local _L = LibStub:NewLibrary(M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function _L:IsMacro() return self:IsMacroConfig(self:GetConfig()) end
function _L:IsSpell() return self:IsSpellConfig(self:GetConfig()) end
function _L:IsItem() return self:IsItemConfig(self:GetConfig()) end

---@param config ProfileButton
function _L:IsMacroConfig(config)
    return config and config.type and MACRO == config.type
end

---@param config ProfileButton
function _L:IsSpellConfig(config)
    return config and config.type and SPELL == config.type
end

---@param config ProfileButton
function _L:IsItemConfig(config)
    return config and config.type and ITEM == config.type
end
