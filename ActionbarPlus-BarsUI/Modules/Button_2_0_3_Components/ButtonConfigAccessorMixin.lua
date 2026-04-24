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

--- @return ButtonConfig_ABP_2_0
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

function o:ResetButtonConfig()
  local bc = self:GetButtonConfig()
  if not bc then return end
  bc.type, bc.id = nil, nil
end

--- @return string
function o:__buttonActiveSpecGroupKey() return dsu.specGroupKey(unit:GetActiveSpecGroupIndex()) end

--- @private
--- @return string
function o:__buttonGroupKey() return dsu.buttonKey(self.widget.index) end
