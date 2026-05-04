--[[-------------------------------------------------------------------
WorldEventsFrameMixin (ButtonEventsFrameMixin)
@see Blizz/Shared/ActionButton.lua#ActionBarButtonEventsFrameMixin

Purpose:
Handles system-level events that affect all buttons,
regardless of the specific action assigned.

Examples:
    • PLAYER_ENTERING_WORLD
    • UPDATE_BINDINGS
    • ACTIONBAR_UPDATE_COOLDOWN
    • UPDATE_SHAPESHIFT_FORM
    • PET_BAR_UPDATE
    • PLAYER_MOUNT_DISPLAY_CHANGED

Behavior:
    • Maintains a registry of button frames
    • Broadcasts events to every registered button
    • Performs no spellID or action-based filtering

Does NOT:
    • Handle spellcast filtering
    • Inspect button action data
    • Apply action-specific logic

Key Characteristic:
Wide broadcast.
Environment-level changes.

Mental model:
> The world changed. All buttons re-evaluate.
---------------------------------------------------------------------]]

--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local p, t = ns:log('WorldEventsFrame')

--- =======================================================
--- Buttons register/unregister here to receive world/environment-level events.
--- @see Button_ABP_2_0_3#OnLoad
--- @class WorldEventsFrameMixin_ABP_2_0 : Frame
--- @field buttons table<Button_ABP_2_0_X, Button_ABP_2_0_X>
local o = {}; WorldEventsFrameMixin_ABP_2_0 = o

--
--- @class WorldEventsFrame_ABP_2_0 : WorldEventsFrameMixin_ABP_2_0
---

function o:OnLoad()
  
  self.buttons = {};
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
  self:RegisterUnitEvent("UNIT_AURA", "player");
  --self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
  --self:RegisterEvent("UPDATE_BINDINGS");
  --self:RegisterEvent("GAME_PAD_ACTIVE_CHANGED");
  --self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
  --self:RegisterEvent("PET_BAR_UPDATE");
  --self:RegisterUnitEvent("UNIT_FLAGS", "pet");
  --self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
  
  --CVarCallbackRegistry:SetCVarCachable(countdownForCooldownsCVarName);
  --CVarCallbackRegistry:RegisterCallback(countdownForCooldownsCVarName, self.OnCountdownForCooldownsChanged, self);
end

function o:OnEvent(event, ...)
  -- pass event down to the buttons
  for k, btn in pairs(self.buttons) do
    btn:OnEvent(event, ...);
  end
end

function o:OnCountdownForCooldownsChanged()
  for k, btn in pairs(self.buttons) do
    ActionButton_UpdateCooldownNumberHidden(btn);
  end
end

--- Unregister when bar modules are enabled
--- @param btn Button_ABP_2_0_3
function o:RegisterFrame(btn) self.buttons[btn] = btn end

--- Unregister when bar modules are disabled
--- @param frame Button_ABP_2_0_3
function o:UnregisterFrame(frame) self.buttons[frame] = nil end

--- @param func fun(frame:Button_ABP_2_0_3):void
function o:ForEachFrame(func)
  for k, btn in pairs(self.buttons) do func(btn); end
end

WorldEventsFrameMixinDerived_ABP_2_0 = CreateFromMixins(o)
