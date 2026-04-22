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
--- @class ButtonEventsFrameMixin_ABP_2_0
--- @field frames table<Button_ABP_2_0_3, Button_ABP_2_0_3>
WorldEventsFrameMixin_ABP_2_0 = {};
--
--- @alias WorldEventsFrame_ABP_2_0 ButtonEventsFrameMixin_ABP_2_0 | FrameObj
--- =======================================================

--- @type ButtonEventsFrameMixin_ABP_2_0 | WorldEventsFrame_ABP_2_0
local o = WorldEventsFrameMixin_ABP_2_0

function o:OnLoad()
  
  self.frames = {};
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  --self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
  --self:RegisterEvent("UPDATE_BINDINGS");
  --self:RegisterEvent("GAME_PAD_ACTIVE_CHANGED");
  self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
  --self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
  --self:RegisterEvent("PET_BAR_UPDATE");
  --self:RegisterUnitEvent("UNIT_FLAGS", "pet");
  self:RegisterUnitEvent("UNIT_AURA", "player");
  --self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
  
  --CVarCallbackRegistry:SetCVarCachable(countdownForCooldownsCVarName);
  --CVarCallbackRegistry:RegisterCallback(countdownForCooldownsCVarName, self.OnCountdownForCooldownsChanged, self);
end

function o:OnEvent(event, ...)
  -- pass event down to the buttons
  for k, frame in pairs(self.frames) do
    frame:OnEvent(event, ...);
  end
end

function o:OnCountdownForCooldownsChanged()
  for k, frame in pairs(self.frames) do
    ActionButton_UpdateCooldownNumberHidden(frame);
  end
end

--- Unregister when bar modules are enabled
--- @param frame Button_ABP_2_0_3
function o:RegisterFrame(frame) self.frames[frame] = frame end

--- Unregister when bar modules are disabled
--- @param frame Button_ABP_2_0_3
function o:UnregisterFrame(frame) self.frames[frame] = nil end

--- @param func fun(frame:Button_ABP_2_0_3):void
function o:ForEachFrame(func)
  for k, frame in pairs(self.frames) do func(frame); end
end

WorldEventsFrameMixinDerived_ABP_2_0 = CreateFromMixins(o)
