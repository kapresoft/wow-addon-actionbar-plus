--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-TimeUtil-2-0', 1

--- @class Kapresoft-TimeUtil-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

--- Converts the given Unix timestamp to an ISO 8601 date format string.
--- @param optionalTimestamp number|nil The Unix timestamp to convert. If nil, the current time is used.
--- @return string|osdate The date and time in ISO 8601 format.
function o:TimeToISODate(optionalTimestamp)
    -- Use '!' to ensure the date is formatted as UTC.
    local isoDate = date("!%Y-%m-%dT%H:%M:%SZ", optionalTimestamp or time())
    return isoDate
end

--- The current time
--- @param optionalTimestamp number|nil The Unix timestamp to convert. If nil, the current time is used.
--- @return string|osdate The date and time in ISO 8601 format.
function o:TimeToDate(optionalTimestamp)
    return date("%Y-%m-%dT%H:%M:%S", optionalTimestamp or time())
end

--- The current timestamp hours:minute:seconds only
--- @param optionalTimestamp number|nil The Unix timestamp to convert. If nil, the current server time is used.
--- @return string|osdate The date and time in ISO 8601 format.
function o:NowInHoursMinSeconds(optionalTimestamp)
    return date("%H:%M:%S", optionalTimestamp or time())
end

--- Convert to unix timestamp
--- @param isoDate string The ISO Date. Example: 2024-03-22T17:34:00Z
--- @return number? - The UTC unix timestamp
--- @return string? - The reason for failure
function o:IsoDateToTimestamp(isoDate)
    local year, month, day, hour, minute, second = isoDate:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
    year, month, day, hour, minute, second = tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute), tonumber(second)

    if not year then
        return nil, "Invalid date format"
    end

    -- WoW's `time` function can convert a table to a Unix timestamp
    -- Adjusting for UTC: WoW's `time()` function uses the local time zone,
    -- so to get UTC, we subtract the time zone offset.
    local dateTable = {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = minute,
        sec = second
    }
    local utcTimeTable = date("!*t", time(dateTable))
    return time(utcTimeTable)
end
