--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local TEMPLATE = 'AnnouncementDialogTemplate_ABP_2_0'

--- Self-contained, per-locale announcement content. A locale override is
--- a `title_<locale>` or `content_<locale>` field, e.g. `title_deDE`.
--- @class AnnouncementDef_ABP_2_0
--- @field dbKey string    @Unique key under global.announcementsShown; shown at most once
--- @field title string    @enUS title, the fallback
--- @field content string  @enUS content, the fallback; may span several lines
--- @field width number?
--- @field height number?
--- @field isAvailable (fun(): boolean)? @false skips it on this client, unmarked

--- @see Core_Modules_ABP_2_0
local libName = ns.M.Announcements()
--- @class Announcements_ABP_2_0
local o = {}; ns:Register(libName, o)

--- @type table<string, AnnouncementDef_ABP_2_0>
local registry = {}
--- @type string[]
local registrationOrder = {}

--- @return table<string, boolean>
local function ShownKeys() return ns:g().announcementsShown end

--- @param dbKey string
--- @return boolean
local function IsPending(dbKey)
  local def = registry[dbKey]
  if not def or ShownKeys()[dbKey] then return false end
  return not def.isAvailable or def.isAvailable()
end

--- @param def AnnouncementDef_ABP_2_0
local function ShowDialog(def)
  --- @type AnnouncementDialogFrame_ABP_2_0
  local frame = CreateFrame('Frame', nil, UIParent, TEMPLATE)
  frame:Configure(def)
  frame:Show()
end

--- @param def AnnouncementDef_ABP_2_0
--- @param field 'title'|'content'
--- @return string
function o:Localized(def, field) return def[field .. '_' .. GetLocale()] or def[field] end

--- Registers a definition without showing it
--- @param def AnnouncementDef_ABP_2_0
function o:Register(def)
  assertsafe(
    type(def) == 'table' and type(def.dbKey) == 'string',
    'Announcements:Register(def): {def.dbKey} is required'
  )
  if not registry[def.dbKey] then registrationOrder[#registrationOrder + 1] = def.dbKey end
  registry[def.dbKey] = def
end

--- A no-op if the key was already shown, isn't registered or isn't available
--- @param dbKey string
function o:ShowByKey(dbKey)
  if not IsPending(dbKey) then return end
  ShownKeys()[dbKey] = true
  ShowDialog(registry[dbKey])
end

--- Shows the first-registered pending announcement, at most one per call
function o:ShowNextUnseen()
  for _, dbKey in ipairs(registrationOrder) do
    if IsPending(dbKey) then return self:ShowByKey(dbKey) end
  end
end
