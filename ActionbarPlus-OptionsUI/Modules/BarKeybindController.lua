--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local L = cns:GetLocale()
local attr = cns:constants()
local Str_IsBlank = cns:String().IsBlank
local AceHook = cns:NewAceHook()
local comp = O.Compat
local cfn = cns:ColorFn("679CEE")

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see OptionsUI_Modules_ABP_2_0
local libName = 'BarKeybindController'

--- @class BarKeybindController_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
local p, t = ns:log(libName)

local SUSPENDED_TYPE = libName .. '_type'

--- @type table<string, {new:string, old:string?, key2:string?, mode:number}>
local pendingBindings = {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- Replaces key1 for a binding while preserving key2.
--- Handles WoW's key promotion behavior when key1 is cleared.
--- @param bindingName string
--- @param newKey string
--- @param key2 string?
--- @return boolean ok
local function ReplaceKey1(bindingName, newKey, key2)
  local curKey1 = GetBindingKey(bindingName)
  if curKey1 then SetBinding(curKey1) end                      -- clear key1; key2 promotes to key1
  local promoted = key2 and GetBindingKey(bindingName) or nil  -- capture promoted key2
  if promoted then SetBinding(promoted) end                    -- clear promoted key2
  local ok = SetBinding(newKey, bindingName)                   -- set new as key1
  if key2 then SetBinding(key2, bindingName) end               -- always restore key2
  return ok
end

--- @param self Button_ABP_2_0_X
function o.Btn_OnEnter(self)

  if not self.__keyDownHooked then
    AceHook:RawHookScript(self, 'OnKeyDown', o.Btn_OnKeyDown)
    self.__keyDownHooked = true
  end

  local key = self.widget:GetHotKeyText()
  GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
  GameTooltip:ClearLines()
  GameTooltip:AddLine(self:GetNameLocalized(), 1, 1, 1)
  if key then
    local boundText = cfn(L['Bound'] .. ': ')
    GameTooltip:AddLine(boundText .. key, 1, 1, 1)
  else
    GameTooltip:AddLine(L['Not Bound'], 1, 0.1, 0.1)
  end
  GameTooltip:Show()
end

--- @param self Button_ABP_2_0_X
function o.Btn_OnLeave(self)
  AceHook:Unhook(self, 'OnKeyDown')
  self.__keyDownHooked = nil
end

--- @param self Button_ABP_2_0_X
local function Btn_SuspendButton(self)
  if not self.widget:IsEmpty() then
    local typ = self.widget:GetAttributeType()
    self.widget:ClearAttributeType()
    self:SetAttribute(SUSPENDED_TYPE, typ)
  end

  AceHook:RawHookScript(self, 'OnEnter', o.Btn_OnEnter)
  AceHook:RawHookScript(self, 'OnLeave', o.Btn_OnLeave)
end

--- @param self Button_ABP_2_0_X
local function Btn_UnsuspendButton(self)
  local typ = self:GetAttribute(SUSPENDED_TYPE)
  if not Str_IsBlank(typ) then
    self:SetAttribute(attr.type, typ)
  end

  for _, script in ipairs({ 'OnEnter', 'OnLeave', 'OnKeyDown' }) do
    AceHook:Unhook(self, script)
  end
  self.__keyDownHooked = nil
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:Init()
  self:RegisterMessage(ns:msg('OnQuickKeybindModeActive'), o.OnQuickKeybindModeActive, self)
  self:RegisterMessage(ns:msg('OnQuickKeybindModeNotActive'), o.OnQuickKeybindModeNotActive, self)
  self:RegisterMessage(ns:msg('OnQuickKeybindModeCommit'), o.OnQuickKeybindModeCommit, self)
end

--- @param self Button_ABP_2_0_X
function o.Btn_OnKeyDown(self, key)

  local binding, w = comp:GetModifierBinding(key), self.widget
  if not binding then return end

  local bindingName = w:GetBindingName()
  local pending = pendingBindings[bindingName]
  local key1, key2 = GetBindingKey(bindingName)
  -- capture original keys only on first bind this session
  local oldKey = not pending and key1 or nil
  local oldKey2 = not pending and key2 or nil

  if strupper(binding) == 'ESCAPE' then
    -- Escape clears the current binding (mirrors Blizzard behavior)
    if key1 then SetBinding(key1) end
    if not pending then
      pendingBindings[bindingName] = { old = oldKey, key2 = oldKey2, mode = GetCurrentBindingSet() }
    end
    pendingBindings[bindingName].new = nil
    o.Btn_OnEnter(self)
    return
  end

  -- track any other button that currently owns this key (will lose it when we steal it)
  local stolenFrom = GetBindingAction(binding)
  if not Str_IsBlank(stolenFrom) and not pendingBindings[stolenFrom] then
    local sKey1, sKey2 = GetBindingKey(stolenFrom)
    pendingBindings[stolenFrom] = { old = sKey1, key2 = sKey2, mode = GetCurrentBindingSet() }
    t('Stolen', 'stolenFrom=', stolenFrom, 'sKey1=', sKey1, 'sKey2=', sKey2)
  end

  local ok = ReplaceKey1(bindingName, binding, key2)
  if ok then
    -- only save old binding if not already tracked in this session
    if not pending then
      pendingBindings[bindingName] = { old = oldKey, key2 = oldKey2, mode = GetCurrentBindingSet() }
    end
    pendingBindings[bindingName].new = binding
  end
  o.Btn_OnEnter(self)
end


--- @param evt EventName
--- @param perChar boolean
function o:OnQuickKeybindModeCommit(evt, perChar)
  local mode = perChar and 2 or 1
  -- todo: show alert message going from char-specific -> account based
  SaveBindings(mode)
  pendingBindings = {}
  self:EnableButtons()
end

--- @param evt EventName
function o:OnQuickKeybindModeActive(evt)
  pendingBindings = {}
  o:DisableButtons()
end

--- @param evt EventName
function o:OnQuickKeybindModeNotActive(evt)
  -- revert any uncommitted bindings
  for bindingName, entry in pairs(pendingBindings) do
    if entry.old then
      ReplaceKey1(bindingName, entry.old, entry.key2)
    elseif entry.new then
      SetBinding(entry.new)  -- had no original binding; clear the new key
    end
  end
  pendingBindings = {}
  o:EnableButtons()
end

function o:DisableButtons()
  cns:BarsUI():ForEach(function(bm)
    bm:ForEach(Btn_SuspendButton)
  end)
end

function o:EnableButtons()
  cns:BarsUI():ForEach(function(bm)
    bm:ForEach(Btn_UnsuspendButton)
  end)
end

--[[-----------------------------------------------------------------------------
Call Init()
-------------------------------------------------------------------------------]]
o:Init()