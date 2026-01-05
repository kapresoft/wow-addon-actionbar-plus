--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return DebuggingSettingsGroup, LoggerV2
local function CreateLib()
    local libName = M.DebuggingSettingsGroup
    --- @class DebuggingSettingsGroup : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local LIB, p = CreateLib(); if not LIB then return end

local dbgSeq = ns:CreateSequence()

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o DebuggingSettingsGroup
local function PropsAndMethods(o)
    --- spacer
    local sp = '                                                                   '
    local L = ns:AceLocale()

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
            },
        }
        self:QuickLogLevelButtons(debugConf, dbgSeq)
        self:AddLogLevelSlider(debugConf)
        self:AddCategories(debugConf)

        return debugConf;
    end

    --- @param debugConf AceConfigOption
    function o:AddLogLevelSlider(debugConf)
        local a = debugConf.args
        a.log_level = {
            type = 'range',
            order = dbgSeq:next(),
            step = 5, min = 0, max = 50,
            width = 1.5,
            name = L['Log Level'],
            desc = L['Log Level::Description'],
            get = function(_) return ns:GetLogLevel() end,
            set = function(_, v) ns:SetLogLevel(v) end,
        }
        a.spacer1b = { type="description", name=sp, width="full", order = dbgSeq:next() }
    end

    --- @param debugConf AceConfigOption
    --- @param seq Kapresoft_SequenceMixin
    function o:QuickLogLevelButtons(debugConf, seq)
        local a = debugConf.args
        a.off = {
            name = 'Off', type = "execute", order = seq:next(), width = 0.4, desc = "Turn Off Logging",
            func = function() a.log_level.set({}, 0) end,
        }
        a.info = {
            name = 'Info', type = "execute", order = seq:next(), width = 0.4, desc = "Info Log Level (15)",
            func = function() a.log_level.set({}, 15) end,
        }
        a.debugBtn = {
            name = 'Debug', type = "execute", order = seq:next(), width = 0.5, desc = "Debug Log Level (20)",
            func = function() a.log_level.set({}, 20) end,
        }
        a.fineBtn = {
            name = 'F1', type = "execute", order = seq:next(), width = 0.3, desc = "Fine Log Level (25)",
            func = function() a.log_level.set({}, 25) end,
        }
        a.finerBtn = {
            name = 'F2', type = "execute", order = seq:next(), width = 0.3, desc = "Finer Log Level (30)",
            func = function() a.log_level.set({}, 30) end,
        }
        a.finestBtn = {
            name = 'F3', type = "execute", order = seq:next(), width = 0.3, desc = "Finest Log Level (35)",
            func = function() a.log_level.set({}, 35) end,
        }
        a.traceBtn = {
            name = 'Trace', type = "execute", order = seq:next(), width = 0.4, desc = "Trace Log Level (50)",
            func = function() a.log_level.set({}, 50) end,
        }

        a.qlb_spacer = { type="description", name=sp, width="full", order = seq:next() }
    end

    --- @param conf AceConfigOption
    function o:AddCategories(conf)
        conf.args.desc_cat = { name = ' ' .. L['Categories'] .. ' ', type = "header", order = dbgSeq:next() }
        conf.args.spacer1d = { type="description", name=sp, width="full", order = dbgSeq:next() }

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

        ns.CategoryLogger():ForEachCategory(function(cat)
            local elem = {
                type = 'toggle', name=cat.labelFn(), order=dbgSeq:next(), width=1.2,
                get = function() return ns:IsLogCategoryEnabled(cat.name) end,
                set = function(_, val) ns:SetLogCategory(cat.name, val) end
            }
            conf.args[cat.name] = elem
        end)
    end

end; PropsAndMethods(LIB)

