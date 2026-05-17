--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local C_GetDisplayedMountID = C_MountJournal and C_MountJournal.GetDisplayedMountID

--[[-----------------------------------------------------------------------------
Module::MountJournalHook
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.MountJournalHook()
--- @class MountJournalHook_ABP_2_0
local o = {}; ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::MountJournalHook (Methods)
-------------------------------------------------------------------------------]]

--- Hooks C_MountJournal.Pickup to capture the real mountID before the cursor
--- state changes. Applies to MoP and later — GetCursorInfo() returns a display
--- index (info1) which doesn't reliably map to a mountID via any public API,
--- so the mountID is resolved at pickup time and cached in ns.mountID.
function o:Init()
  if not C_GetDisplayedMountID then return end
  hooksecurefunc(C_MountJournal, 'Pickup', o.OnPickupMount)
end

--- @see Compat_ABP_2_0.PickupMount()
--- @param displayIndex number @The mount display index
function o.OnPickupMount(displayIndex)
  ns.mountID = C_GetDisplayedMountID(displayIndex)
end
