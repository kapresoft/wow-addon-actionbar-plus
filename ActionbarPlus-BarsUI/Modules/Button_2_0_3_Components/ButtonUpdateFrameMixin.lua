--[[-------------------------------------------------------------------
BarButtonUpdateFrameMixin
> Per-frame update loop manager

@see Blizz/Shared/ActionButton.lua#ActionBarButtonUpdateFrameMixin

Purpose:
Centralized OnUpdate loop for buttons that need ticking behavior.

Behavior:
	•	Has self.frames
	•	OnUpdate(elapsed):
	•	Calls frame:OnUpdate(elapsed)

Buttons register themselves only when needed:

```
ActionBarButtonUpdateFrame:RegisterFrame(self)
```

Used for:
	•	Flashing
	•	Delayed state updates
	•	Dirty flag evaluation

Key Characteristic:

Time-based updates.
Not event-driven.
Performance-controlled.

Think of it as:

“You marked yourself dirty. I’ll tick you until you’re clean.”
---------------------------------------------------------------------]]

--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local p, pd, t, tf = ns:log('BarButtonUpdateFrameMixin')

--- =======================================================
--- @class ButtonUpdateFrameMixin_ABP_2_0
--- @field frames table<ABP_Button_2_0_3, ABP_Button_2_0_3>
ButtonUpdateFrameMixin_ABP_2_0 = {}
--
--- @alias ButtonUpdateFrame_ABP_2_0 ButtonUpdateFrameMixin_ABP_2_0 | FrameObj
--- =======================================================

--- @type ButtonUpdateFrameMixin_ABP_2_0 | ButtonUpdateFrame_ABP_2_0
local o = ButtonUpdateFrameMixin_ABP_2_0

function o:OnLoad() self.frames = {}; end

function o:OnUpdate(elapsed)
  for k, frame in pairs(self.frames) do
    frame:OnUpdate(elapsed);
  end
end

function o:RegisterFrame(frame)
  self.frames[frame] = frame;
end

--- @param frame ABP_Button_2_0_3
function o:UnregisterFrame(frame) self.frames[frame] = nil; end
