--- @type Namespace
local ns = select(2, ...)
ns.gameVersion = 'retail'
local c = ns.GC.ch
local cc = ns.GC.C.CONSOLE_COLORS

--- This function is just a safeguard, since we declared Blizzard_Professions
--- as a dependency then the LoadAddon() won't occur.
--- This is needed for professions action type, like Leatherworking, etc.
--- see Retail TOC: ## OptionalDeps: Blizzard_Professions
--- see Blizzard FrameXML/UIParent.lua
local function InitBlizzardAddonsIfNeeded()
    local professions = 'Blizzard_Professions'
    if not IsAddOnLoaded(professions) then
        LoadAddOn(professions);
        local pre = '{{' .. c:FormatColor(cc.primary, 'ActionbarPlus::Retail.lua') .. '}}:'
        print(pre, 'Dependent addOn loaded:', professions)
    end
end; InitBlizzardAddonsIfNeeded()
