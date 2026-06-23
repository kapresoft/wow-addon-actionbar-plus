--- @class BorderDef_ABP_2_0
--- @field label string @Display name shown in the theme dropdown
--- @field backdrop BackdropTemplate
--- @field bgColor RGBA @The {r,g,b,a} each value 0.0–1.0, example: `{ 0.1, 0.3, 0.7, 0.8 }`
--- @field borderColor RGBA @The {r,g,b,a} each value 0.0–1.0, example: `{ 0.1, 0.3, 0.7, 0.8 }`
--- @field borderPadBottom number @Internal-only extra bottom padding for themes whose border art needs more room at the bottom; not user-configurable
--- @field padding number @Default backdrop padding (uniform, all sides)
--- @field basePadding number @Internal-only base padding added around the button grid before user padding (default 8); not user-configurable
--- @field edgeSize EdgeSizeRange_ABP_2_0? @Slider default/min/max for this theme's Border Size control; falls back to backdrop.edgeSize/1/48 when absent
--- @field dialog BorderDefDialogConfig_ABP_2_0? @Controls which BarBackdropDialog widgets are shown for this theme

--- @class EdgeSizeRange_ABP_2_0
--- @field default number @Slider's starting value (the theme's intended default look); independent from backdrop.edgeSize, which insets are scaled against
--- @field min number @Minimum allowed edgeSize for this theme's slider (Blizzard treats edgeSize<=0 as "use default 39" unless the theme has no edgeFile)
--- @field max number @Maximum allowed edgeSize for this theme's slider

--- @class BorderDefDialogConfig_ABP_2_0
--- @field showBorderColor boolean? @Default true; set false for themes with no real border (e.g. minimalist)
--- @field showBgColor boolean? @Default true
--- @field showBorderSize boolean? @Default true; set false for themes with no edgeFile (no border art to resize)

--- @class BackdropTemplate
--- @field bgFile string|nil @Example `'Interface/Buttons/WHITE8x8'`
--- @field edgeFile string|nil @Example `'Interface/DialogFrame/UI-DialogBox-Border'`
--- @field tile boolean
--- @field tileSize number
--- @field edgeSize number
--- @field insets table @Example `{ left = 0, right = 0, top = 0, bottom = 0 }`
