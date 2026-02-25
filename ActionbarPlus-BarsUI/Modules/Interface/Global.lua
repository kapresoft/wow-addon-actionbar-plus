--[[-------------------------------------------------------------
World Events Frame
@see BarFrame.xml
---------------------------------------------------------------]]

--- Handles system-level events that affect all buttons, regardless of the specific action assigned.
--- Buttons register/unregister here to receive world/environment-level events.
--- @see BarFrame.xml#WorldEventsFrame_ABP_2_0
--- @type WorldEventsFrame_ABP_2_0
WorldEventsFrame_ABP_2_0 = {}

--- Buttons register/unregister dynamically here to receive world/environment-level events.
--- @see ABP_Button_2_0_3#Update
--- @see BarFrame.xml#ActionEventsFrame_ABP_2_0
--- @type ActionEventsFrame_ABP_2_0
ActionEventsFrame_ABP_2_0 = {}

--- Per-button update loop manager. Buttons register themselves only when needed.
--- @see BarFrame.xml#ButtonUpdateFrame_ABP_2_0
--- @type ButtonUpdateFrame_ABP_2_0
ButtonUpdateFrame_ABP_2_0 = {}
