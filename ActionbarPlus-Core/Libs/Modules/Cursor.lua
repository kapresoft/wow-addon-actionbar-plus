--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function Str_IsBlank(str)
  if type(str) ~= "string" then return str == nil end
  return strtrim(str) == ""
end

--[[-----------------------------------------------------------------------------
Module::Cursor
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.Cursor()
--- @class Cursor_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)

--- @class CursorMixin_ABP_2_0
local CursorMixin = {}
local function CursorMixinMethods()
  
  --- @type CursorMixin_ABP_2_0
  local cm = CursorMixin
  
  --- @return CursorInfo
  function cm:GetCursorInfo()
    -- actionType string spell, item, macro, mount, etc..
    local actionType, info1, info2, info3 = GetCursorInfo()
    if Str_IsBlank(actionType) then return nil end
    
    --- @type CursorInfo
    local c = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    
    local info2Lc = strlower(c.info2 or '')
    if c.type == 'companion' and 'mount' == info2Lc then
      c.info2 = info2Lc
      c.originalCursor = { type = c.type, info1 = c.info1, info2 = info2 }
      c.type = c.info2
    end
    
    return c
  end
  
  
end; CursorMixinMethods()

--[[-----------------------------------------------------------------------------
Module::Cursor (Methods)
-------------------------------------------------------------------------------]]
function S:GetCursor()

end
