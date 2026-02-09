--[[-----------------------------------------------------------------------------
Type: ThrottledUpdaterMixin_Instance
-------------------------------------------------------------------------------]]
--- @class ThrottledUpdaterMixin_Instance

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local active = {}
local DEFAULT_THROTTLE_INTERVAL = 0.3
local msg1 = "Throttled update failed for obj %s: %s"
--- @type Frame
local driver
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.ThrottledUpdaterMixin
--- @class ThrottledUpdaterMixin
local o = ns:NewMixin(libName)
local p = ns:CreateDefaultLogger(libName)
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function assertObjOnUpdate(obj)
    assert(type(obj._OnUpdate) == "function", ns.sformat("%s<ThrottledUpdaterMixin>: missing _OnUpdate()", tostring(obj)))
end

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]

function o:GetActiveCount() return #active end

--- Sets the update throttle interval (in seconds)
--- @param interval number
function o:SetThrottleInterval(interval)
    assert(type(interval) == "number" and interval > 0, "Throttle interval must be a positive number")
    self._interval = interval
end

-- Starts throttled updates, using existing _interval or defaulting to 0.3 if not set
function o:StartThrottledUpdates()
    if not driver then return end
    if not self._interval then self._interval = 0.3 end
    self._nextCheck = 0

    for _, obj in ipairs(active) do
        if obj == self then return end
    end

    if not self._name then self._name = tostring(self) end

    table.insert(active, self)
    driver:Show()
end

function o:StopThrottledUpdates()
    if not driver then return end
    for i = #active, 1, -1 do
        if active[i] == self then
            table.remove(active, i)
            break
        end
    end

    if #active == 0 then
        driver:Hide()
    end
end


--[[-----------------------------------------------------------------------------
Global Function
-------------------------------------------------------------------------------]]
function ns.xml:ThrottledUpdaterMixin_OnLoad(frame)
    assert(frame, 'OnLoad()::Frame is expected here.')
    driver = frame
end

function ns.xml:ThrottledUpdaterMixin_OnUpdate(_, elapsed)
    -- this prevents index shifting from skipping over items.
    for i = #active, 1, -1 do
        local obj = active[i]
        obj._nextCheck = obj._nextCheck - elapsed
        if obj._nextCheck <= 0 then
            obj._interval = obj._interval or DEFAULT_THROTTLE_INTERVAL
            obj._nextCheck = obj._interval
            assertObjOnUpdate(obj)
            if obj._OnUpdate then
                local ok, err = pcall(obj._OnUpdate, obj, elapsed)
                if not ok then
                    table.remove(active, i)
                    p:w(function() return msg1, obj._name or tostring(obj), err end)
                end
            end
        end
    end
end
