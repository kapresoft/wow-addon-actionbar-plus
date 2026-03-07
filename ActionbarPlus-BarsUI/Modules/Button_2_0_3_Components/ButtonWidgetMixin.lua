--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local comp, au, spu, unit = cns.O.Compat, cns.O.ActionUtil, cns.O.SpellUtil, cns.O.UnitUtil
local dru, priest = cns.O.DruidUtil, cns.O.PriestUtil
local attr, atyp = cns:constants()
local Str_IsAnyOf, Str_IsBlank = cns.Str_IsAnyOf, cns.Str_IsBlank
local Tbl_IsEmpty = cns.O.Table.IsEmpty

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
--- @alias ButtonWidget_ABP_2_0 ButtonWidgetMixin_ABP_2_0
--
local p, pd, t, tf = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::ButtonWidgetMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type ButtonWidgetMixin_ABP_2_0 | ButtonWidget_ABP_2_0
local o = S

--- @param btn Button_ABP_2_0_X
--- @param btnIndex Index
--- @param parentFrameIndex Index
function o:Init(btn, btnIndex, parentFrameIndex)
  self.button = btn
  self.index = btnIndex
  self.barIndex = parentFrameIndex
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
  if name == attr.type and Str_IsBlank(val) then return end
  
  if not Str_IsAnyOf(name, atyp.spell, atyp.item) then return end
  if Str_IsBlank(val) then self.button.icon:SetTexture(nil); return end
  
  -- if name == 'abp_clear' then
  if name == atyp.spell then
    local info = comp:GetSpellInfo(val)
    local _sp = ('%s(%s)'):format(tostring(info.name), tostring(info.spellID))
    self:t('UpdateAction','spell=', _sp, 'attr-name=', name)
    if not (info and info.iconID) then return end
    self.button.icon:SetTexture(info.iconID)
  elseif name == atyp.item then
    self:t('UpdateAction','item=', val, 'attr-name=', name)
  end
  
  self.button:Update()
end

--- @return boolean
function o:HasAction()
  local type = self:GetAttribute(attr.type)
  if not type then return false end
  local id = self:GetAttribute(type)
  return id ~= nil
end

function o:ApplyButtonConfig()
  local btn = self.button
  btn:SetButtonStateNormal()
  
  local bc = btn:GetButtonConfig()
  if not (bc and bc.type and bc.id) then
    self:ClearAttributeType()
    self:ResetVisuals()
    return
  end
  
  self:SetAttribute(attr.type, bc.type)
  self:SetAttribute(bc.type, bc.id)
end

--- Reset button UI to original empty state
function o:ResetVisuals()
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

function o:ResetAttributes()
  local btn = self.button
  self.__suspendAttributeChangeHandler = true
  pcall(function() self:__ResetAttributes() end)
  self.__suspendAttributeChangeHandler = false
  -- This last one is to finally trigger btn:UpdateAction()
  btn:SetAttribute(atyp.spell, nil)
end

function o:__ResetAttributes()
  local btn = self.button
  for _, typeAttribute in ipairs(atyp) do
    btn:SetAttribute(typeAttribute, nil)
  end
end

function o:ClearAttributeType() self:SetAttribute(attr.type, nil) end
function o:GetAttributeType() return self.button:GetAttribute(attr.type) end
function o:GetAttributeSavedType() return self:GetAttribute(attr.saved_type) end

function o:DisableAttributeType()
  if not self:GetAttributeSavedType() then
    self:SetAttribute(attr.saved_type, self:GetAttributeType())
  end
  self:ClearAttributeType()
end

function o:ClearAttributeSavedType()
  if not self:GetAttributeSavedType() then return end
  self:SetAttribute(attr.saved_type, nil)
end

function o:RestoreAttributeType()
  if not self:GetAttributeSavedType() then return end
  self:SetAttribute(attr.type, self:GetAttribute(attr.saved_type))
  self:SetAttribute(attr.saved_type, nil)
end

function o:GetAttributeSpell() return self:GetAttribute(atyp.spell) end
function o:ClearAttributeSpell() self:SetAttribute(atyp.spell, nil) end

function o:MatchesActiveButtonSpellID(spellID)
  local _, id = self.button:GetActionInfo()
  return id and id == spellID;
end

function o:GetDebugName()
  return ('%s(Widget):: index=%s frameIndex=%s')
          :format(self.button:GetName(), self.index, self.barIndex)
end

--- @see Frame#GetAttribute
--- @param attributeName string
--- @return string value
function o:GetAttribute(attributeName) return self.button:GetAttribute(attributeName) end

--- @see Frame#SetAttribute(attributeName, value)
--- @param attributeName string
--- @param value any
function o:SetAttribute(attributeName, value) self.button:SetAttribute(attributeName, value) end

--[[-------------------------------------------------------------------
Logger/Trace Methods
---------------------------------------------------------------------]]
--- @param prefix Name
--- @param ... any
function o:t(prefix, ...) local a = { ... }; tf(self:pid(prefix), unpack(a)) end

--- @param prefix Name
--- @param ... any
function o:p(prefix, ...) local a = { ... }; p(self:pid(prefix), unpack(a)) end

--- @param prefix Name
--- @param ... any
function o:pd(prefix, ...) local a = { ... }; pd(self:pid(prefix), unpack(a)) end

--- @param prefix Name
function o:pid(prefix) return ("%s(%s)::"):format(prefix, self.button:GetName()) end
