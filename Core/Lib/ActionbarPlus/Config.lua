local format, unpack, pack = string.format, table.unpackIt, table.pack
local ABP, ADDON_NAME, ABP_ACE_NEWLIB = ABP, ADDON_NAME, ABP_ACE_NEWLIB
local CFG = ABP_ACE_NEWLIB('Config')
if not CFG then return end

---- ## Start Here ----

function CFG:GetOptions(handler)
    return {
        name = ADDON_NAME,
        handler = handler,
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable",
                desc = format("Enable %s", ADDON_NAME),
                order = 0,
                get = function(_) return handler.profile.enabled end,
                set = function(_, v)
                    handler.profile.enabled = v
                    if v then handler:Enable() else handler:Disable() end
                end,
            }
        }
    }
end

