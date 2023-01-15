-- ## External -------------------------------------------------
local format = string.format
--- @type LibStub
local LibStub = LibStub

-- ## Local ----------------------------------------------------
local ns = ABP_Namespace()
local verboseLogging = false

local _G = _G
local pkg = ns.name
local Modules = ABP_Modules

-- ## ----------------------------------------------------------
-- ## LocalLibStub ---------------------------------------------
-- ## ----------------------------------------------------------




-- ## ----------------------------------------------------------
-- ## Core -----------------------------------------------------
-- ## ----------------------------------------------------------

--- @class Core
local _L = {
    addonName = addon,
    M = Modules.M
}

-- ## Functions ------------------------------------------------

---### Syntax:
---```
--- // Default Setup without functions being shown
--- local str = pformat(obj)
--- local str = pformat:Default()(obj)
--- // Shows functions, etc.
--- local str = pformat:A():pformat(obj)
---```
function _L:InitPrettyPrint()

    --- @type Kapresoft_LibUtil_PrettyPrint
    local pprint = Kapresoft_LibUtil.PrettyPrint
    --- @class pformat
    local o = { wrapped = pprint }
    --- @type pformat
    pformat = pformat or o

    --- @return pformat
    function o:Default()
        pprint.setup({ use_newline = true, wrap_string = false, indent_size=4, sort_keys=true, level_width=120, depth_limit = true,
                   show_all=false, show_function = false })
        return self;
    end
    ---no new lines
    --- @return pformat
    function o:D2()
        pprint.setup({ use_newline = false, wrap_string = false, indent_size=4, sort_keys=true, level_width=120, depth_limit = true,
                   show_all=false, show_function = false })
        return self;
    end

    ---Configured to show all
    --- @return pformat
    function o:A()
        pprint.setup({ use_newline = true, wrap_string = false, indent_size=4, sort_keys=true, level_width=120,
                       show_all=true, show_function = true, depth_limit = true })
        return self;
    end

    ---Configured to print in single line
    --- @return pformat
    function o:B()
        pprint.setup({ use_newline = false, wrap_string = true, indent_size=2, sort_keys=true,
                       level_width=120, show_all=true, show_function = true, depth_limit = true })
        return self;
    end

    --- @return string
    function o:pformat(obj, option, printer)
        local str = pprint.pformat(obj, option, printer)
        o:Default(o)
        return str
    end
    o.mt = { __call = function (_, ...) return o.pformat(o, ...) end }
    setmetatable(o, o.mt)

end

function _L:Init() self:InitPrettyPrint() end
_L:Init()

--- @type Core
--- @deprecated Use ns.core instead
__K_Core = _L
ns.O[Modules.M.Core] = _L
ns[Modules.M.Core] = _L
