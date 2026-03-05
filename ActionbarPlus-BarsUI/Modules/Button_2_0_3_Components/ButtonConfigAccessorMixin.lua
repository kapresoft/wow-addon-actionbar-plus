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
--- @alias ButtonConfigAccessor_ABP_2_0 ButtonConfigAccessorMixin_ABP_2_0
--
local p, pd, t, tf = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::ButtonConfigMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type ButtonConfigAccessorMixin_ABP_2_0 | ButtonConfigAccessor_ABP_2_0 | Button_ABP_2_0_3
local o = S

--- @type BarConfig_ABP_2_0
function o:GetBarConfig() return cns:a():bar(self.widget.barIndex) end

function o:GetButtonConfig()
  local barConf = self:GetBarConfig()
  local btnGroupKey = self:__buttonGroupKey()
  if not barConf.buttons[btnGroupKey] then barConf.buttons[btnGroupKey] = {} end
  local btnGroup = barConf.buttons[btnGroupKey]
  local specGroupKey = self:__buttonActiveSpecGroupKey()
  --p('GetButtonConfig:: btnGroupKey=', btnGroupKey,
  --        'specGroupKey=', specGroupKey, 'btnConf=', btnGroup[specGroupKey])
  if not btnGroup[specGroupKey] then btnGroup[specGroupKey] = {} end
  return btnGroup[specGroupKey]
end

function o:ClearButtonConf()
  local barConf = self:GetBarConfig()
  if not barConf.buttons then return end
  barConf.buttons[self:__buttonGroupKey()] = nil
end

--- @return string
function o:__buttonActiveSpecGroupKey() return dsu.specGroupKey(unit:GetActiveSpecGroupIndex()) end

--- @private
--- @return string
function o:__buttonGroupKey() return dsu.buttonKey(self.widget.index) end
