--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroSpell = GetMacroSpell

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, G = ABP_LibGlobals:LibPack()

local p = __K_Core:NewLogger('ButtonMixin')

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ButtonMixin : ButtonProfileMixin @ButtonMixin extends ButtonProfileMixin
local _L = LibStub:NewLibrary(M.ButtonMixin)
G:Mixin(_L, G:LibPack_ButtonProfileMixin())

function _L:_Button() return self.button end
function _L:_Widget() return self end

function _L:GetName() return self:_Button():GetName() end
function _L:GetIndex() return self.index end
function _L:GetFrameIndex() return self.dragFrameWidget:GetIndex() end

---@type BindingInfo
function _L:GetBindings()
    return (self.addon.barBindings and self.addon.barBindings[self.buttonName]) or nil
end

---@param spellID string The spellID to match
function _L:IsMatchingMacroOrSpell(spellID)
    ---@type ProfileButton
    local conf = self:GetConfig()
    if not conf and (conf.spell or conf.macro) then return false end
    if self:IsSpellConfig(conf) then
        return spellID == conf.spell.id
    elseif self:IsMacroConfig(conf) and conf.macro.index then
        local macroSpellId =  GetMacroSpell(conf.macro.index)
        return spellID == macroSpellId
    end

    return false;
end

