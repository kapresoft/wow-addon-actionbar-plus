local ADDON_NAME, ns = ...

local function LoadSubAddon(name)
    local loaded, reason = LoadAddOn(name)
    if not loaded then
        print("ActionbarPlus: Failed to load sub-addon:", name, "Reason:", reason)
    end
    return loaded
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, addon)
    if addon ~= ADDON_NAME then return end

    -- ✔ SavedVariables are guaranteed loaded here
    ABP_PLUS_DB = ABP_PLUS_DB or {}
    ABP_PLUS_DB.mode = ABP_PLUS_DB.mode or "Legacy"

    -- Any other initialization
    print(ADDON_NAME, "SavedVariables loaded. Mode:", ABP_PLUS_DB.mode)


    ABP_Legacy = AceAddon:NewAddon("ActionbarPlusLegacy", "AceEvent-3.0")
    ABP_Next    = AceAddon:NewAddon("ActionbarPlusNext", "AceEvent-3.0")

    LoadSubAddon("ActionbarPlusLegacy")
    LoadSubAddon("ActionbarPlusNext")

    -- Decide which implementation to load
    if ABP_PLUS_DB.mode == "Legacy" then
        DisableAddOn("ActionbarPlusNext")
    else
    end

    -- Unregister, fire only once
    f:UnregisterEvent("ADDON_LOADED")
end)


