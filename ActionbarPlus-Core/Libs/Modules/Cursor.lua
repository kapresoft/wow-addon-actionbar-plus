--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local au = O.ActionUtil
local Str_IsBlank = ns:String().IsBlank

--[[-----------------------------------------------------------------------------
Module::Cursor
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.CursorProvider()
--- @class CursorProvider_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)

--
--- @class Cursor_ABP_2_0 : CursorMixin_ABP_2_0
--

--- @class CursorMixin_ABP_2_0
--- @field type CursorType
--- @field info CursorInfo
--- @field isValid boolean
local CursorMixin = {}

local function CursorMixinMethods()

  --- @private
  --- @param info CursorInfo
  function CursorMixin:Init(info)
    self.info = info
    self.type = info and info.type
    self.isValid = info and not Str_IsBlank(info.type)
  end
  
  --- @return boolean
  function CursorMixin:IsSpell() return self.isValid and au.IsSpell(self.type) end
  --- @return boolean
  function CursorMixin:IsItem() return self.isValid and au.IsItem(self.type) end
  --- @return boolean
  function CursorMixin:IsMount() return self.isValid and au.IsMount(self.type) end

  --- @return SpellID
  function CursorMixin:GetSpellID()
    if not self:IsSpell() then return nil end
    return self.info.info3 --[[@as SpellID]]
  end

  --- @return MountID
  function CursorMixin:GetMountID()
    if not self:IsMount() then return nil end
    return self.info.info1 --[[@as MountID]]
  end

  --- @return ItemID?, ItemLink?
  function CursorMixin:GetItem()
    if not self:IsItem() then return nil, nil end
    return self.info.info1 --[[@as ItemID]], self.info.info2 --[[@as ItemLink]]
  end

  --- @return ItemID?
  function CursorMixin:GetItemID() return (self:GetItem()) end
  function CursorMixin:GetType() return self.info.type end

end; CursorMixinMethods()

--[[-----------------------------------------------------------------------------
Module::Cursor (Methods)
-------------------------------------------------------------------------------]]
--- [Documentation::GetCursorInfo](https://warcraft.wiki.gg/wiki/API_GetCursorInfo)
--- @return Cursor_ABP_2_0
function S:GetCursor()
  local type, info1, info2, info3, info4 = GetCursorInfo()
  --- @type CursorInfo
  local info = {
    type  = type,
    info1 = info1, info2 = info2, info3 = info3, info4 = info4
  }
  return CreateAndInitFromMixin(CursorMixin, info)
end
