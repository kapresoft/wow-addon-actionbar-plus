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
local p, t = ns:log('BarButtonUpdateFrameMixin')

--- =======================================================

--- @class ButtonUpdateFrameMixin_ABP_2_0 : Frame
--- @field frames table<Button_ABP_2_0_X, Button_ABP_2_0_X>
local o = {}; ButtonUpdateFrameMixin_ABP_2_0 = o

--- @class ButtonUpdateFrame_ABP_2_0 : ButtonUpdateFrameMixin_ABP_2_0

--- =======================================================

function o:OnLoad() self.frames = {}; end

function o:OnUpdate(elapsed)
  for k, frame in pairs(self.frames) do
    --- @type Button_ABP_2_0_X
    local btn = frame; btn:OnUpdate(elapsed);
  end
end

--- @param frame Button_ABP_2_0_X
function o:RegisterFrame(frame)
  self.frames[frame] = frame
end

--- @param frame Button_ABP_2_0_X
function o:UnregisterFrame(frame)
  self.frames[frame] = nil
end
