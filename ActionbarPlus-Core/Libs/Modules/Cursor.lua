--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local au, comp = O.ActionUtil, O.Compat
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
--- @field macroIndex number
--- @field battlePetID PetGUID
--- @field equipmentSetID number
--- @field itemID ItemID
--- @field itemLink ItemLink
--- @field mountID MountID
--- @field spellID SpellID
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
    elseif self:IsMacro() then
      self.macroIndex = i.info1
    elseif self:IsMount() then
      self.mountID = ns.mountID or i.info1
    elseif self:IsBattlePet() then
      self.battlePetID = i.info1
    elseif self:IsPetAction() then
      self.petActionID = i.info1
    elseif self:IsEquipmentSet() then
      self.equipmentSetID = comp:GetEquipmentSetID(i.info1)
    end
  end

  --- @return boolean
  function CursorMixin:IsSpell() return self.isValid and au.IsSpell(self.type) end
  --- @return boolean
  function CursorMixin:IsItem() return self.isValid and au.IsItem(self.type) end
  --- @return boolean
  function CursorMixin:IsMacro() return self.isValid and au.IsMacro(self.type) end

  --- @return boolean
  function CursorMixin:IsMount()
    if not self.isValid then return false end

    local i = self.info
    if au.IsCompanion(self.type) and i.info2 == COMPANION_TYPE_MOUNT then
      return true -- legacy: MoP
    end
    return au.IsMount(self.type)
  end

  --- @return boolean
  function CursorMixin:IsBattlePet()
    return self.isValid and au.IsBattlePet(self.type)
  end
  --- @return boolean
  function CursorMixin:IsPetAction()
    return self.isValid and au.IsPetAction(self.type)
  end
  --- @return boolean
  function CursorMixin:IsEquipmentSet()
    return self.isValid and au.IsEquipmentSet(self.type)
  end

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
