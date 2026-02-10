--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local s = ns.settings
s.developer = true
--s.enableTraceUI = true

print('DeveloperSetup::', 'loaded...')
