--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local p, t1, t2 = ns:log()

C_Timer.After(1, function()
  t1('xx loaded....')
  p('xxR loaded...')
  print('xx loaded... tag=', ns.printer)
end)
XNS = ns
