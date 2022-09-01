--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local SPELL,ITEM,MACRO = 'spell','item','macro'
local _, _, String, LogFactory = ABP_LibGlobals:LibPackUtils()
local p = LogFactory:NewLogger('ButtonProfileMixin')

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local LibStub, M = ABP_LibGlobals:LibPack()

---@class ButtonProfileMixin
local _L = LibStub:NewLibrary(M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function _L:invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (String.IsBlank(d['id']) and String.IsBlank(d['index'])) end
    end
    return true
end


---#### Get Profile Button Config Data
---@return ProfileButton
function _L:GetConfig() return self.buttonData:GetData() end

function _L:GetConfigActionbarData(type)
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, type) then return nil end
    return btnData[type]
end

---@return SpellData
function _L:GetSpellData() return self:GetConfigActionbarData(SPELL) end
---@return ItemData
function _L:GetItemData() return self:GetConfigActionbarData(ITEM) end
---@return MacroData
function _L:GetMacroData() return self:GetConfigActionbarData(MACRO) end
---@return boolean
function _L:IsMacro() return self:IsMacroConfig(self:GetConfig()) end
---@return boolean
function _L:IsSpell() return self:IsSpellConfig(self:GetConfig()) end
---@return boolean
function _L:IsItem() return self:IsItemConfig(self:GetConfig()) end

---@param config ProfileButton
---@return boolean
function _L:IsMacroConfig(config) return config and config.type and MACRO == config.type end
---@param config ProfileButton
---@return boolean
function _L:IsSpellConfig(config) return config and config.type and SPELL == config.type end
---@param config ProfileButton
---@return boolean
function _L:IsItemConfig(config) return config and config.type and ITEM == config.type end
