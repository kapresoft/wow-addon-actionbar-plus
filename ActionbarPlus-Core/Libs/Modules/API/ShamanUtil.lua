--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
--- @type string
local libName = ns.M.ShamanUtil()
--- @class ShamanUtil_ABP_2_0 : UnitUtil_ABP_2_0
local o = UnitUtil:New('SHAMAN'); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
o.GHOST_WOLF_SPELL_ID = 2645
o.GHOST_WOLF_FORM_ACTIVE_ICON = 136116

---@param spellID SpellID
function o:IsGhostWolfSpell(spellID) return spellID == o.GHOST_WOLF_SPELL_ID end

--- @return boolean @true if in Ghost Wolf form, false otherwise.
function o:IsInGhostWolfForm() return self:IsBuffActive(o.GHOST_WOLF_SPELL_ID) end

--- @return Icon @The icon if form is active
function o:GetFormActiveIcon() return o.GHOST_WOLF_FORM_ACTIVE_ICON end


