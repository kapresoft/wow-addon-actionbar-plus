--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local au = O.ActionUtil
local Str_IsBlank = ns:String().IsBlank
local COMPANION_TYPE_MOUNT = 'MOUNT'

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
--- @field mountID MountID
--- @field spellID SpellID
--- @field itemID ItemID
--- @field itemLink ItemLink
local CursorMixin = {}

local function CursorMixinMethods()

  --- @private
  --- @param info CursorInfo
  function CursorMixin:Init(info)
    self.info = info
    self.type = info and info.type
    self.isValid = info and not Str_IsBlank(info.type)

    self:InitIdentifiers()
  end

  function CursorMixin:InitIdentifiers()
    local i = self.info
    if self:IsSpell() then
      self.spellID = i.info3
    elseif self:IsItem() then
      self.itemID, self.itemLink = i.info1, i.info2
    elseif self:IsMount() then
      self.mountID = ns.mountID or i.info1
    end
  end

  function CursorMixin:GetType() return self.info.type end

  --- @return boolean
  function CursorMixin:IsSpell() return self.isValid and au.IsSpell(self.type) end
  --- @return boolean
  function CursorMixin:IsItem() return self.isValid and au.IsItem(self.type) end

  --- @return boolean
  function CursorMixin:IsMount()
    local i = self.info
    if au.IsCompanion(self.type) and i.info2 == COMPANION_TYPE_MOUNT then
      return self.isValid and true -- legacy: MoP
    end
    return self.isValid and au.IsMount(self.type)
 end

  --- @return SpellID?
  function CursorMixin:GetSpellID() return self.spellID end

  --- @return MountID?
  function CursorMixin:GetMountID() return self.mountID end

  --- @return ItemID?, ItemLink?
  function CursorMixin:GetItem() return self.itemID, self.itemLink end

  --- @return ItemID?
  function CursorMixin:GetItemID() return self.itemID end

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
