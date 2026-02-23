--[[-------------------------------------------------------------------
BarButtonUpdateFrameMixin
> Per-frame update loop manager

@see Blizz/Shared/ActionButton.lua#ActionBarButtonUpdateFrameMixin

-- /dump EventRegistry:TriggerEvent('CURSOR_CHANGED', false, 3, 0 , 0)
-- /dump EventRegistry:TriggerEvent('ACTIONBAR_SHOWGRID')
-- /dump EventRegistry:TriggerEvent('Actionbar.Hello', ABP_2_0_F1Button1)

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

pd('xxx Loaded...')
