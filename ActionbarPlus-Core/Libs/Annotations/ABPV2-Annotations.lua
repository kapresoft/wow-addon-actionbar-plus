--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @class LogHolder_ABP_2_0
--- @field printer fun(moduleName:Name) : LibPrettyPrint_PrintFn A simple printer
--- @field tracer fun(moduleName:Name) : TraceFn_ABP_2_0 A simple tracer

--[[-----------------------------------------------------------------------------
Bar Layout
-------------------------------------------------------------------------------]]
--- Interface implemented by each bar-layout module (grid, freeform, etc).
--- @class BarLayout_ABP_2_0
--- @field SupportsBackdrop fun(self:BarLayout_ABP_2_0):boolean Whether this layout renders a backdrop border/background
--- @field SupportsHorizontalSpacing fun(self:BarLayout_ABP_2_0):boolean Whether this layout uses button.spacing.horizontal
--- @field SupportsVerticalSpacing fun(self:BarLayout_ABP_2_0):boolean Whether this layout uses button.spacing.vertical
--- @field GetButtonCount fun(self:BarLayout_ABP_2_0, ui:BarUIConfig_ABP_2_0):number Total number of buttons this config requires
--- @field GetMaxButtonCount fun(self:BarLayout_ABP_2_0):number Upper bound for this layout's button-count slider
--- @field Apply fun(self:BarLayout_ABP_2_0, frame:BarFrame_ABP_2_0, ui:BarUIConfig_ABP_2_0) Sizes/positions the bar's buttons per the given config
--- @field ApplyExtraButtons fun(self:BarLayout_ABP_2_0, frame:BarFrame_ABP_2_0) Creates/positions the extra button row, if supported; no-op otherwise
--- @field ApplyDragHandle fun(self:BarLayout_ABP_2_0, frame:BarFrame_ABP_2_0, dragAnchor:string, thickness:number) Sizes/positions the drag handle against this layout's buttons; dragAnchor is 'TOPLEFT' | 'TOPRIGHT'
--- @field ApplyOptionsUI fun(self:BarLayout_ABP_2_0, tab:AceGUITabGroup, ui:BarUIConfig_ABP_2_0, onChanged:fun())|nil Optional: adds this layout's own controls (beyond the shared spacing sliders) to the Layout tab. Owns its own localization -- out-of-tree layouts should not rely on Core's locale table.
