--[[-------------------------------------------------------------------
ActionEventsFrameMixin

Purpose:
Global dispatcher for spell/action-specific events.
@see Blizz/Shared/ActionButton.lua#ActionBarActionEventsFrameMixin

Handles events that are tied to a particular spell or action
(e.g., spellcast lifecycle, icon updates, charge updates).

Examples:
- UNIT_SPELLCAST_START
- UNIT_SPELLCAST_STOP
- UNIT_SPELLCAST_INTERRUPTED
- SPELL_UPDATE_ICON
- SPELL_UPDATE_CHARGES
- SPELL_ACTIVATION_OVERLAY_GLOW_SHOW / HIDE
- LOSS_OF_CONTROL_UPDATE

Behavior:
- Maintains a registry of button frames (self.frames).
- For spellcast-related events:
  - Extracts spellID.
  - Calls frame:MatchesActiveButtonSpellID(spellID).
  - Dispatches only to matching buttons.
- For non-spellcast action events:
  - Broadcasts as needed.

Key Characteristics:
- Filtered dispatch.
- Spell-aware routing.
- Only buttons representing the affected spell receive the event.

This frame performs no state logic itself; it only routes events.
---------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local comp = cns.O.Compat
local p, t = ns:log('ActionEventsFrame')

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- =======================================================
--- @class ActionEventsFrameMixin_ABP_2_0 : Frame
--- @field frames table<Button_ABP_2_0_3, Button_ABP_2_0_3>
ActionEventsFrameMixin_ABP_2_0 = {};
--
--- @class ActionEventsFrame_ABP_2_0 : ActionEventsFrameMixin_ABP_2_0
--- =======================================================

local o = ActionEventsFrameMixin_ABP_2_0

function o:OnLoad()
  self.frames = {};
  self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
  --self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");		replaced with ACTION_USABLE_CHANGED
  self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
  self:RegisterEvent("SPELL_UPDATE_CHARGES");
  self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
  self:RegisterEvent("TRADE_SKILL_SHOW");
  self:RegisterEvent("TRADE_SKILL_CLOSE");
  --self:RegisterEvent("ARCHAEOLOGY_CLOSED");
  self:RegisterEvent("PLAYER_ENTER_COMBAT");
  self:RegisterEvent("PLAYER_LEAVE_COMBAT");
  self:RegisterEvent("START_AUTOREPEAT_SPELL");
  self:RegisterEvent("STOP_AUTOREPEAT_SPELL");
  self:RegisterEvent("UNIT_ENTERED_VEHICLE");
  self:RegisterEvent("UNIT_EXITED_VEHICLE");
  self:RegisterEvent("COMPANION_UPDATE");
  self:RegisterEvent("UNIT_INVENTORY_CHANGED");
  self:RegisterEvent("UNIT_SPELLCAST_SENT");
  self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player");
  self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
  self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player");
  self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
  self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
  self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
  self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
  --self:RegisterUnitEvent("UNIT_SPELLCAST_RETICLE_TARGET", "player");
  --self:RegisterUnitEvent("UNIT_SPELLCAST_RETICLE_CLEAR", "player");
  --self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player");
  --self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player");
  
  --self:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE");
  self:RegisterEvent("PET_STABLE_UPDATE");
  self:RegisterEvent("PET_STABLE_SHOW");
  self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
  self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
  self:RegisterEvent("UPDATE_SUMMONPETS_ACTION");
  self:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", "player");
  self:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", "player");
  self:RegisterEvent("SPELL_UPDATE_ICON");
  self:RegisterEvent("UPDATE_STEALTH");
  
  --[[EventRegistry:RegisterCallback("AssistedCombatManager.OnSetActionSpell", function(o)
    -- May not be the best way, but it is a unique string which is what the event system cares about
    self:OnEvent("AssistedCombatManager.OnSetActionSpell");
  end);]]
end

--- @param event EventName
function o:IsSpellcastEvent(event)
  if ( event == "UNIT_SPELLCAST_INTERRUPTED" or
          event == "UNIT_SPELLCAST_SUCCEEDED" or
          event == "UNIT_SPELLCAST_START" or
          event == "UNIT_SPELLCAST_STOP" or
          event == "UNIT_SPELLCAST_CHANNEL_START" or
          event == "UNIT_SPELLCAST_CHANNEL_STOP" or
          event == "UNIT_SPELLCAST_RETICLE_TARGET" or
          event == "UNIT_SPELLCAST_RETICLE_CLEAR" or
          event == "UNIT_SPELLCAST_EMPOWER_START" or
          event == "UNIT_SPELLCAST_EMPOWER_STOP" or
          event == "UNIT_SPELLCAST_SENT" or
          event == "UNIT_SPELLCAST_FAILED") then
    return true;
  else
    return false;
  end
end

---@param evt EventName
---@param ... any
function o:OnEvent(evt, ...)
  if ( evt == "UNIT_INVENTORY_CHANGED" ) then
    local unit = ...;
    if ( unit == "player" and self.tooltipOwner and GameTooltip:GetOwner() == self.tooltipOwner ) then
      self.tooltipOwner:SetTooltip();
    end
  elseif ( self:IsSpellcastEvent(evt) ) then
    ---@param btn Button_ABP_2_0_3
    for k, btn in pairs(self.frames) do
      local spellID;
      local unit = ...;
      
      if(evt == "UNIT_SPELLCAST_SENT") then
        spellID = select(4, ...)
      else
        spellID = select(3, ...)
      end
      
      if (unit == "player" and btn.widget:MatchesActiveButtonSpellID(spellID)) then
        btn:OnEvent(evt, ...);
        btn:OnPlayerMatchingSpellcastEvent(evt, spellID);
      end
    end
  else
    for k, btn in pairs(self.frames) do
      btn:OnEvent(evt, ...);
    end
  end
end

--- @param frame Button_ABP_2_0_3
function o:RegisterFrame(frame) self.frames[frame] = frame; end

--- @param frame Button_ABP_2_0_3
function o:UnregisterFrame(frame) self.frames[frame] = nil; end
