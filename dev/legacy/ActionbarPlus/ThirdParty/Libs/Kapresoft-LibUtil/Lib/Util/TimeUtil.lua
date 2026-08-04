Kapresoft_TimeUtil_Debug = false

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)
local K = ns.Kapresoft_LibUtil
local LibStub = K.LibStub
local sformat = string.format
local time = time or os.time
local date = date or os.date
local ModuleName = K.M.TimeUtil()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_TimeUtil
local L = LibStub:NewLibrary(ModuleName, 3); if not L then return end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
function namespaceName() return (ns and ns.name) or '' end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Converts the given Unix timestamp to an ISO 8601 date format string.
--- @param optionalTimestamp number|nil The Unix timestamp to convert. If nil, the current time is used.
--- @return string The date and time in ISO 8601 format.
function L:TimeToISODate(optionalTimestamp)
    -- Use '!' to ensure the date is formatted as UTC.
    local isoDate = date("!%Y-%m-%dT%H:%M:%SZ", optionalTimestamp or time())
    return isoDate
end

--- The current time
--- @param optionalTimestamp number|nil The Unix timestamp to convert. If nil, the current time is used.
--- @return string The date and time in ISO 8601 format.
function L:TimeToDate(optionalTimestamp)
    return date("%Y-%m-%dT%H:%M:%S", optionalTimestamp or time())
end

--- The current timestamp hours:minute:seconds only
--- @param optionalTimestamp number|nil The Unix timestamp to convert. If nil, the current server time is used.
--- @return string The date and time in ISO 8601 format.
function L:NowInHoursMinSeconds(optionalTimestamp)
    return date("%H:%M:%S", optionalTimestamp or time())
end

--- Convert to unix timestamp
--- @param isoDate string The ISO Date. Example: 2024-03-22T17:34:00Z
--- @return number The UTC unix timestamp
function L:IsoDateToTimestamp(isoDate)
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

local function n(x)
    local name = sformat('{{|cFFB0C2FB%s|r}}::TimeUtil', namespaceName())
    return sformat(name .. '::%s()::', x)
end
local function dbg(lastUpdate, lastUpdateLong, expiryDate, expiryDateLong, isOutOfDate)
    print(n('::IsOutOfDate'),
            sformat('\nlastUpdate: %s (%s)', lastUpdateLong, lastUpdate),
            sformat('\nexpiryDate: %s (%s)', expiryDateLong, expiryDate),
            sformat('\nOutOfDate: %s', tostring(isOutOfDate)))
end

local function isOutOfDateWrapper(lastUpdate, expiryDate)
    local lastUpdateLong = L:IsoDateToTimestamp(lastUpdate)
    local expiryDateLong = L:IsoDateToTimestamp(expiryDate)
    local isOutOfDate = lastUpdateLong < expiryDateLong
    if Kapresoft_TimeUtil_Debug == true then
        dbg(lastUpdate, lastUpdateLong, expiryDate, expiryDateLong, isOutOfDate)
    end
    return isOutOfDate
end

--- @param lastUpdate string The last addon update in ISO. Example: 2024-03-22T17:34:00Z
--- @param expiryDate string The addon expiry date in ISO. Example: 2024-03-24T17:34:00Z
--- @return boolean
function L:IsOutOfDate(lastUpdate, expiryDate)
    local success, result = pcall(isOutOfDateWrapper, lastUpdate, expiryDate)
    if not success then
        local pre = '|cFFE64750[ERROR] |rUnexpected error while checking for an out-of-date version of |cFF6F97FFActionbarPlus|r. '
        local name = sformat('{{|cFFB0C2FB%s|r}}:', namespaceName())
        local info = sformat("lastUpdate=[%s] expiryDate=[%s]", tostring(lastUpdate), tostring(expiryDate))
        local additional = sformat('Error:: %s. Info:: %s', result, info)
        print(name, pre .. additional)
        return nil
    end
    return result
end
