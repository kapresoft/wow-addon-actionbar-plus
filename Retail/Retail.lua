--- @type string
local addon
--- @type Namespace | Kapresoft_Base_Namespace
local kns
addon, kns = ...

--- @type Namespace
local ns = select(2, ...)
ns.gameVersion = 'retail'

--- The colors selected here should be available for all versions
local co = BRIGHTBLUE_FONT_COLOR or BLUE_FONT_COLOR
local sco = YELLOW_FONT_COLOR

--- This function is just a safeguard, since we declared Blizzard_Professions
--- as a dependency then the LoadAddon() won't occur.
--- This is needed for professions action type, like Leatherworking, etc.
--- see Retail TOC: ## OptionalDeps: Blizzard_Professions
--- see Blizzard FrameXML/UIParent.lua
local function InitBlizzardAddonsIfNeeded()
    local professions = 'Blizzard_Professions'
    if not IsAddOnLoaded(professions) then
        LoadAddOn(professions);
        local pre = '{{' .. co:WrapTextInColorCode(addon .. '::')
                .. sco:WrapTextInColorCode('Retail.lua') .. '}}:'
        print(pre, 'Dependent addOn loaded:', professions)
    end
end; InitBlizzardAddonsIfNeeded()
