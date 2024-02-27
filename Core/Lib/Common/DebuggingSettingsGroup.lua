--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = abp_ns(...)
local GC, M, LibStub = ns.O.GlobalConstants, ns.M, ns.O.LibStub
local sformat = string.format

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return DebuggingSettingsGroup, LoggerV2
local function CreateLib()
    local libName = M.DebuggingConfigGroup
    --- @class DebuggingSettingsGroup : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local LIB, p = CreateLib(); if not LIB then return end

local dbgSeq = ns:CreateSequence()

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o DebuggingSettingsGroup
local function PropsAndMethods(o)
    --- spacer
    local sp = '                                                                   '
    local L = GC:GetAceLocale()


    --- @return AceConfigOption
    function o:CreateDebuggingGroup()

        --- @type AceConfigOption
        local debugConf = {
            type = "group",
            name = L['Debugging'],
            desc = L['Debugging::Description'],
            -- Place right before Profiles
            order = 90,

            --- @type AceConfigOption
            args = {
                desc = { name = sformat(" %s ", L['Debugging Configuration']), type = "header", order = dbgSeq:next() },
                spacer1a = { type="description", name=sp, width="full", order = dbgSeq:next() },
                log_level = {
                    type = 'range',
                    order = dbgSeq:next(),
                    step = 5,
                    min = 0,
                    max = 50,
                    width = 1.5,
                    name = L['Log Level'],
                    desc = L['Log Level::Description'],
                    get = function(_) return GC:GetLogLevel() end,
                    set = function(_, v) GC:SetLogLevel(v) end,
                },
                spacer1b = { type="description", name=sp, width="full", order = dbgSeq:next() },
                desc_cat = { name = "Categories", type = "header", order = dbgSeq:next() },
                spacer1c = { type="description", name=sp, width="full", order = dbgSeq:next() },
            },
        }

        self:AddCategories(debugConf)

        return debugConf;
    end

    ---@param conf AceConfigOption
    function o:AddCategories(conf)
        conf.args.enable_all = {
            name = L['Debugging::Category::Enable All::Button'], desc = L['Debugging::Category::Enable All::Button::Desc'],
            type = "execute", order = dbgSeq:next(), width = 'normal',
            func = function()
                for _, option in pairs(conf.args) do
                    if option.type == 'toggle' then option.set({}, true) end
                end
            end }
        conf.args.disable_all = {
            name = L['Debugging::Category::Disable All::Button'], desc = L['Debugging::Category::Disable All::Button::Desc'],
            type="execute", order=dbgSeq:next(), width = 'normal',
            func = function()
                for _, option in pairs(conf.args) do
                    if option.type == 'toggle' then option.set({}, false) end
                end
            end }
        conf.args.spacer2 = { type="description", name=sp, width="full", order = dbgSeq:next() },

        ns.LogCategory():ForEachCategory(function(cat)
            local elem = {
                type = 'toggle', name=cat.labelFn(), order=dbgSeq:next(), width=1.2,
                get = function() return ns:IsLogCategoryEnabled(cat.name) end,
                set = function(_, val) ns:SetLogCategory(cat.name, val) end
            }
            conf.args[cat.name] = elem
        end)
    end

end; PropsAndMethods(LIB)

