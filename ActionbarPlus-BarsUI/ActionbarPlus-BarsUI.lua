--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)
local p, t1, t2 = ns:log()

C_Timer.After(1, function()
    p('xx loaded...')
    t1('loaded...')
    t2('BarsUI', 'loaded...')
end)
