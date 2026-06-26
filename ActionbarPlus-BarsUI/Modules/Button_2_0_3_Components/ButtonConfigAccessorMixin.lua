--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local dsu, unit = cns.O.DatabaseSchema.Util, cns.O.UnitUtil

--[[-----------------------------------------------------------------------------
Module::ButtonConfigMixin
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.ButtonConfigAccessorMixin()
--- @class ButtonConfigAccessorMixin_ABP_2_0
local S = {}; ns:Register(libName, S)
--
--- @class ButtonConfigAccessor_ABP_2_0 : ButtonConfigAccessorMixin_ABP_2_0
--
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::ButtonConfigMixin (Methods)
-------------------------------------------------------------------------------]]
local o = S

--- @return ProfileConfig_ABP_2_0
function o:GetProfileConfig() return cns:a():p() end

--- @return BarConfig_ABP_2_0?
function o:GetBarConfig() return cns:a():bar(self.widget.barIndex) end

--- Returns the button config for the current spec, or nil if no action has been saved yet.
--- Does NOT create the slot — use GetOrCreateButtonConfig() when writing.
--- @return ButtonConfig_ABP_2_0?
function o:GetButtonConfig()
  local barConf = self:GetBarConfig()
  if not barConf then return nil end
  local btnGroup = barConf.buttons[self:__buttonGroupKey()]
  if not btnGroup then return nil end
  return btnGroup[self:__buttonActiveSpecGroupKey()]
end

--- Returns the button config for the current spec, creating the slot if missing.
--- Use only when writing (SaveAction).
--- @return ButtonConfig_ABP_2_0
function o:GetOrCreateButtonConfig()
  local barConf = self:GetBarConfig()
  local btnGroupKey = self:__buttonGroupKey()
  if not barConf.buttons[btnGroupKey] then barConf.buttons[btnGroupKey] = {} end
  local btnGroup = barConf.buttons[btnGroupKey]
  local specGroupKey = self:__buttonActiveSpecGroupKey()
  if not btnGroup[specGroupKey] then btnGroup[specGroupKey] = {} end
  return btnGroup[specGroupKey] --[[@as ButtonConfig_ABP_2_0 ]]
end

function o:ResetButtonConfig()
  --- @type ButtonConfig_ABP_2_0 | MacroButtonConfig_ABP_2_0
  local bc = self:GetButtonConfig()
  if not bc then return end
  bc.type, bc.id, bc.hash = nil, nil, nil
end

--- @return string
function o:__buttonActiveSpecGroupKey() return dsu.specGroupKey(unit:GetActiveSpecGroupIndex()) end

--- @private
--- @return string
function o:__buttonGroupKey()
  local idx = self.widget.index
  if idx > dsu.EXTRA_BTN_ENCODED_OFFSET then
    return dsu.extraButtonKey(idx - dsu.EXTRA_BTN_ENCODED_OFFSET)
  end
  return dsu.buttonKey(idx)
end
