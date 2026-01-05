local ADDON_NAME, ns = ...
local sformat = string.format

C_Timer.After(1, function()
    print(sformat("ActionbarPlusV2::loaded: |cffffcc00%s|r", ADDON_NAME))
end)

