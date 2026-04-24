--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local comp, au = O.Compat, O.ActionUtil
local attr, atyp = cns:constants()
local Str_IsBlank = cns:String().IsBlank

--[[-----------------------------------------------------------------------------
Module::ButtonWidgetMixin
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = ns.M.ButtonWidgetMixin()
--- @class ButtonWidgetMixin_ABP_2_0
--- @field __suspendAttributeChangeHandler boolean
--- @field button Button_ABP_2_0_X
--- @field index Index The button index
--- @field barIndex Index The owner frame index
local S = {}; ns:Register(libName, S)
--
--- @class ButtonWidget_ABP_2_0 : ButtonWidgetMixin_ABP_2_0
--
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::ButtonWidgetMixin (Methods)
-------------------------------------------------------------------------------]]
local o = S

--- @param btn Button_ABP_2_0_X
--- @param btnIndex Index
--- @param parentFrameIndex Index
function o:Init(btn, btnIndex, parentFrameIndex)
  self.button = btn
  self.index = btnIndex
  self.barIndex = parentFrameIndex
  --@do-not-package@
  --- __logID() is needed by DeveloperSetup_ABP_2_0.ButtonLogMixin(o)
  function self:__logID() return self.button:GetName() end
  -- todo: DeveloperSetup_ABP_2_0.ButtonLogMixin(self, libName) end
  DeveloperSetup_ABP_2_0.ButtonLogMixin(self, p, t)
  --@end-do-not-package@
end

function o:OnAttributeChanged(name, val)
  if self.__suspendAttributeChangeHandler then return end
  self:UpdateAction(name, val)
end

--- If type is invalid (blank or nil) then return quickly
--- Clear Icon When: type=spell|item|etc and val is invalid (blank or nil)
--- @param name Name
--- @param val string
function o:UpdateAction(name, val)
  if not au.IsSupportedAction(name) then return end
  if Str_IsBlank(val) then self.button.icon:SetTexture(nil); return end
  
  -- if name == 'abp_clear' then
  if name == atyp.spell then
    local info = comp:GetSpellInfo(val)
    --local _sp = ('%s(%s)'):format(tostring(info.name), tostring(info.spellID))
    --self:t('UpdateAction','spell=', _sp, 'attr-name=', name)
    if not (info and info.iconID) then return end
    self.button.icon:SetTexture(info.iconID)
  elseif name == atyp.item then
    --self:t('UpdateAction','item=', val, 'attr-name=', name)
  end
  
  self.button:Update()
end

--- @return boolean
function o:HasAction()
  local actionType = self:GetAttribute(attr.type)
  if not actionType then return false end
  local id = self:GetAttribute(actionType)
  return id ~= nil
end

function o:ApplyButtonConfig()
  local btn = self.button
  btn:SetButtonStateNormal()
  
  local bc = btn:GetButtonConfig()
  if not (bc and bc.type and bc.id) then self:ResetButton(); return end
  
  self:SetAttribute(attr.type, bc.type)
  self:SetAttribute(bc.type, bc.id)
end

--- @param cursor Cursor_ABP_2_0
function o:ApplyCursorAction(cursor)
  if not cursor then return end
  --- @type ButtonConfig_ABP_2_0
  local btnC = self:conf(true)
  
  if cursor.type == 'spell' then
    cursor:IfSpell(function(spell)
      self:SetActionSpell(spell)
      btnC.type = atyp.spell
      btnC.id = spell.spellID
    end)
  end
  
  self.button:UpdateState()
  self.button:UpdateFlash()
end

function o:ResetButton()
  self:__ResetAttributes()
  self:__ResetVisuals()
end

--- @private
--- Reset button UI to original empty state
function o:__ResetVisuals()
  local btn = self.button
  -- Clear icon
  if btn.icon then
    btn.icon:SetTexture(nil)
    btn:SetIconNormalVertex()
  end
  
  -- Clear cooldown
  if btn.cooldown then
    btn.cooldown:Clear()
  end
  
  -- Clear checked state
  btn:SetChecked(false)
  btn:SetButtonStateNormal()
  
  -- Stop flashing if you use it
  if btn.ClearFlash then btn:ClearFlash() end
  
  -- Remove any desaturation
  if btn.icon then btn.icon:SetDesaturated(false) end
end

--- @private
function o:__ResetAttributes()
  self.__suspendAttributeChangeHandler = true
  pcall(self.__ClearActionAttributes, self)
  self.__suspendAttributeChangeHandler = false
end

--- @private
function o:__ClearActionAttributes()
  self:SetAttribute(attr.type, nil)
  self:ClearAttributeSuspendedActionType()
  for _, typeAttribute in ipairs(atyp) do
    self:SetAttribute(typeAttribute, nil)
  end
end

function o:ClearAttributeType() self:SetAttribute(attr.type, nil) end
function o:GetAttributeType() return self.button:GetAttribute(attr.type) end

--- Temporarily suspends the button's secure action.
---
--- The current `type` attribute is saved to a global ABP attribute and then
--- cleared from the button. Clearing `type` prevents the SecureActionButton
--- from executing its action while we perform drag, pickup, or cursor swap
--- operations.
---
--- This is called from PreClick() and drag handlers before manipulating the
--- cursor or replacing the button's action.
function o:SuspendAction()
  local t = self:GetAttributeType()
  if not t then return end
  cns:SetGlobalAttribute(attr.suspended_type, self:GetAttributeType())
  self:ClearAttributeType()
end

--- Returns the action type temporarily suspended during drag/cursor operations.
--- This value is saved when SuspendAction() clears the button's `type`
--- so the button does not execute its secure action while we perform
--- pickup / swap logic. Used by PreClick/PostClick and drag handlers.
--- @return string
function o:GetAttributeSuspendedActionType()
  return cns:GetGlobalAttribute(attr.suspended_type)
end

--- Clears the globally stored suspended action type.
--- This value is set by SuspendAction() during PreClick/drag so the button's
--- `type` attribute can be temporarily removed without losing the original
--- action. Once the swap/apply operation is complete, this value must be
--- cleared to avoid leaking stale drag state across buttons.
function o:ClearAttributeSuspendedActionType()
  cns:ClearGlobalAttribute(attr.suspended_type)
end

--function o:RestoreAttributeType()
--  if not self:GetAttributeDraggedType() then return end
--  self:SetAttribute(attr.type, self:GetAttribute(attr.saved_type))
--  self:SetAttribute(attr.saved_type, nil)
--end

function o:GetAttributeSpell() return self:GetAttribute(atyp.spell) end

function o:MatchesActiveButtonSpellID(spellID)
  local _, id = self.button:GetActionInfo()
  return id and id == spellID;
end

function o:GetDebugName()
  return ('%s(Widget):: index=%s frameIndex=%s')
          :format(self.button:GetName(), self.index, self.barIndex)
end

--- If a SpellInfoData table is provided, it is assumed to be the
--- return value of Compat:GetSpellInfo().
--- @see Compat#GetSpellInfo(spellIDOrName) : SpellInfoData
--- @param spell number|SpellInfoData
function o:SetActionSpell(spell)
  if type(spell) == 'table' then
    self:SetAttribute(attr.type, atyp.spell)
    self:SetAttribute(atyp.spell, spell.spellID)
    return
  end
  if type(spell) ~= 'number' then return end
  comp:IfSpell(spell, function(sp)
    self:SetAttribute(attr.type, atyp.spell)
    self:SetAttribute(atyp.spell, sp.spellID)
  end)
end

--[[-------------------------------------------------------------------
Delegate Functions
---------------------------------------------------------------------]]
--- @return ButtonConfig_ABP_2_0
function o:conf() return self.button:GetButtonConfig() end

--- @see Frame#GetAttribute
--- @param attributeName string
--- @return string value
function o:GetAttribute(attributeName) return self.button:GetAttribute(attributeName) end

--- @see Frame#SetAttribute(attributeName, value)
--- @param attributeName string
--- @param value any
function o:SetAttribute(attributeName, value) self.button:SetAttribute(attributeName, value) end
