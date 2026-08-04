--- @type Kapresoft_Base_Namespace
local _, ns = ...
local LibUtil = ns.Kapresoft_LibUtil

--- @type Kapresoft_LibUtil_PrettyPrint
local P = LibStub('Kapresoft-LibUtil-PrettyPrint-1.0')

--- @class WrappedPrettyPrint
local pformatWrapper = { pprint = P }
LibUtil.pformat = pformatWrapper

do
    local o = pformatWrapper
    local pprint = o.pprint

    --- No new lines
    --- @return WrappedPrettyPrint
    function o:Default()
        pprint.setup({ use_newline = false, wrap_string = false, indent_size=4, sort_keys=true, level_width=120, depth_limit = true,
                       show_all=false, show_function = false })
        return self;
    end
    --- No new lines
    --- @return WrappedPrettyPrint
    function o:D2()
        pprint.setup({ use_newline = false, wrap_string = false, indent_size=4, sort_keys=true,
                       level_width=120, depth_limit = true, show_all=false, show_function = false })
        return self;
    end

    --- Show functions, New Lines
    --- @return WrappedPrettyPrint
    function o:A()
        pprint.setup({ use_newline = true, wrap_string = true, indent_size=4, sort_keys=true,
                       level_width=120, show_all=false, show_function = true, depth_limit = true })
        return self;
    end

    --- Show All, Single line, Compact
    --- @return WrappedPrettyPrint
    function o:B()
        pprint.setup({ use_newline = false, wrap_string = true, indent_size=2, sort_keys=true,
                       level_width=120, show_all=true, depth_limit = true })
        return self;
    end

    --- @return string
    function o:pformat(obj, option, printer)
        return pprint.pformat(obj, option, printer)
    end
    o.mt = { __call = function (_, ...) return o.pformat(o, ...) end }
    setmetatable(o, o.mt)

    o:Default()
end

do
    local o = LibUtil
    function o.dump(msg) DevTools_DumpCommand(msg) end
    function o.dumpv(any)
        local tmp = {}
        print('Dump Value:')
        table.insert(tmp, any)
        DevTools_Dump(tmp)
    end
end
