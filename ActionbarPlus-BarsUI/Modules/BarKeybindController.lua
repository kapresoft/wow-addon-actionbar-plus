--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local attr = cns:constants()
local Str_IsBlank = cns:String().IsBlank
local AceHook = cns:NewAceHook()
local comp = O.Compat


--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = 'BarKeybindController'

--- @class BarKeybindController_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
local p, t = ns:log(libName)

local SUSPENDED_TYPE = libName .. '_type'

--- @type table<string, {new:string, old:string?}>
local pendingBindings = {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param self Button_ABP_2_0_X
function o.Btn_OnEnter(self)

  if not self.__keyDownHooked then
    AceHook:RawHookScript(self, 'OnKeyDown', o.Btn_OnKeyDown)
    self.__keyDownHooked = true
    --t('Btn_OnEnter', '__keyDownHooked', 'btn=', self:GetName())
  end

  local key = self.widget:GetHotKeyText()
  GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
  GameTooltip:ClearLines()
  GameTooltip:AddLine(self:GetNameLocalized(), 1, 1, 1)
  if key then
    GameTooltip:AddLine(key, 1, 1, 1)
  else
    GameTooltip:AddLine('Not Bound', 1, 0.1, 0.1)
  end
  GameTooltip:Show()
end

--- @param self Button_ABP_2_0_X
function o.Btn_OnLeave(self)
  --t('Btn_OnLeaveKeybind', 'self=', self:GetName())
  AceHook:Unhook(self, 'OnKeyDown')
  self.__keyDownHooked = nil
end

--- @param self Button_ABP_2_0_X
local function Btn_SuspendButton(self)
  if self.widget:IsEmpty() then return end

  local typ = self.widget:GetAttributeType()
  self.widget:ClearAttributeType()
  self:SetAttribute(SUSPENDED_TYPE, typ)

  AceHook:RawHookScript(self, 'OnEnter', o.Btn_OnEnter)
  AceHook:RawHookScript(self, 'OnLeave', o.Btn_OnLeave)
end

--- @param self Button_ABP_2_0_X
local function Btn_UnsuspendButton(self)
  local typ = self:GetAttribute(SUSPENDED_TYPE)
  if Str_IsBlank(typ) then return end

  self:SetAttribute(attr.type, typ)
  for _, script in ipairs({ 'OnEnter', 'OnLeave', 'OnKeyDown' }) do
    AceHook:Unhook(self, script)
  end
  self.__keyDownHooked = nil
  --self:UpdateHotKey()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param self Button_ABP_2_0_X
function o.Btn_OnKeyDown(self, key)
  -- todo: capture modifier keys, shift key
  -- todo: save keybind

  local binding, w = comp:GetModifierBinding(key), self.widget
  if not binding then return end

  if binding and strupper(binding) == 'ESCAPE' then
    t('Btn_OnKeyDown', 'ERROR:Key not allowed', 'key=', key)
    return
  end

  local bindingName = w:GetBindingName()
  local pending = pendingBindings[bindingName]
  -- capture original key only on first bind this session
  local oldKey = not pending and GetBindingKey(bindingName) or nil
  local key1, key2 = GetBindingKey(bindingName)
  t('Btn_OnKeyDown', 'key1=', key1, 'key2=', key2, 'binding=', binding)
  if key1 then SetBinding(key1) end                              -- clear key1; key2 promotes to key1
  local promoted = key2 and GetBindingKey(bindingName) or nil   -- capture promoted key2
  if promoted then SetBinding(promoted) end                      -- clear promoted key2
  local ok = SetBinding(binding, bindingName)                    -- set new as key1
  if key2 then SetBinding(key2, bindingName) end                -- always restore key2
  if ok then
    -- only save old binding if not already tracked in this session
    if not pendingBindings[bindingName] then
      pendingBindings[bindingName] = { old = oldKey, mode = GetCurrentBindingSet() }
    end
    pendingBindings[bindingName].new = binding
    t('Pending', 'bindingName=', bindingName, 'new=', binding, 'old=', pendingBindings[bindingName].old)
  end
  self:UpdateHotKey()
  o.Btn_OnEnter(self)
end


--- @param evt EventName
--- @param perChar boolean
function o:OnQuickKeybindModeCommit(evt, perChar)
  local mode = perChar and 2 or 1
  t('OnQuickKeybindModeCommit', 'saving', 'mode=', mode)
  SaveBindings(mode)
  pendingBindings = {}
  self:EnableButtons()
end

--- @param evt EventName
--- @param enabled boolean
function o:OnQuickKeybindMode(evt, enabled)
  t('OnQuickKeybindMode', 'enabled=', enabled)
  if enabled then
    pendingBindings = {}
    o:DisableButtons()
  else
    -- revert any uncommitted bindings
    for bindingName, entry in pairs(pendingBindings) do
      if entry.old then
        SetBinding(entry.old, bindingName, entry.mode)
      else
        SetBinding(bindingName, nil, entry.mode)  -- clear it
      end
      t('Revert', 'bindingName=', bindingName, 'old=', entry.old)
    end
    pendingBindings = {}
    o:EnableButtons()
  end
end

function o:DisableButtons()
  ns:a():ForEach(function(bm)
    bm:ForEach(Btn_SuspendButton)
  end)
end

function o:EnableButtons()
  ns:a():ForEach(function(bm)
    bm:ForEach(Btn_UnsuspendButton)
  end)
end

--[[-----------------------------------------------------------------------------
Register Messages
-------------------------------------------------------------------------------]]
o:RegisterMessage(ns:msg('OnQuickKeybindMode'), 'OnQuickKeybindMode')
o:RegisterMessage(ns:msg('OnQuickKeybindModeCommit'), 'OnQuickKeybindModeCommit')

