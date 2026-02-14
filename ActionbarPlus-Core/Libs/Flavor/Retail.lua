--- @type string
local addon
--- @type Namespace_ABP_2_0
local ns
addon, ns = ...

ns.gameVersion = 'mainline'

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
    -- Check for compatibility with both Retail and Classic
    local _IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
    local _LoadAddOn = IsAddOnLoaded or C_AddOns.LoadAddOn

    if not _IsAddOnLoaded(professions) then
        _LoadAddOn(professions);
        local pre = '{{' .. co:WrapTextInColorCode(addon .. '::')
                .. sco:WrapTextInColorCode('Retail.lua') .. '}}:'
        print(pre, 'Dependent addOn loaded:', professions)
    end
end; InitBlizzardAddonsIfNeeded()
