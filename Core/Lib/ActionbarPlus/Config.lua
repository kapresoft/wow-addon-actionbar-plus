local format, unpack, pack = string.format, table.unpackIt, table.pack
local ADDON_NAME, ABP_ACE_NEWLIB = ADDON_NAME, ABP_ACE_NEWLIB
local C = ABP_ACE_NEWLIB('Config')
if not C then return end

---- ## Start Here ----

function C:GetOptions(handler)
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

function C:CreateButtonDef(baseId, settings, handler)
    local btnId = 'Boxer' .. baseId;
    local buttonDef = {
        order = 0, type = "group", name = baseId,
        args = {
            button_label = {
                type = 'input', order = 1, width = "normal", name = 'Spell, Macro, or Tooltip',
                desc = 'Spell Name, Macro Name or Tooltip label for macrotext type.',
                get = function(_) return settings:GetButtonSettings(btnId).label end,
                set = function(_, v) handler:OnButtonLabelUpdate(btnId, v) end,
            },
            button_type = {
                type = "select", style = "dropdown", order = 2, width = "normal", name = 'Type',
                values = settings.ButtonTypeNames,
                get = function(_) return settings:GetButtonSettings(btnId).typeIndex or 1 end,
                set = function(_, v) handler:OnButtonTypeUpdate(btnId, v) end,
            },
            button_icon = {
                type = 'input', order = 3, width = "normal", name = 'Icon', desc="This option nly applies to macros.",
                get = function(_) return settings:GetButtonSettings(btnId).icon end,
                set = function(_, v) handler:OnButtonIconUpdate(btnId, v) end,
            },
            button_value = {
                type = 'input', order = 4, width = "full", multiline = true, name = 'Macro Text',
                desc = 'This field only applies when type is macrotext.',
                get = function(_) return settings:GetButtonSettings(btnId).value or '' end,
                set = function(_, v) handler:OnButtonValueUpdate(btnId, v) end,
            },
        }
    }

    return buttonDef
end
