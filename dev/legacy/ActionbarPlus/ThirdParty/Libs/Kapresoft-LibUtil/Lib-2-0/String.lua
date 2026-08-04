--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local type = type
local str_gsub, str_len, str_lower, tbl_insert = string.gsub, string.len, string.lower, table.insert
local str_sub = string.sub

--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-- 2: Revised String.IsAnyOf() for improved efficiency, type safety,
      and case-insensitive matching; Removed String.ToString()--not needed
-- 3: Refactor of IsAnyOf
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-String-2-0', 4

--- @class Kapresoft-String-2-0
local o = LibStub:NewLibrary(MAJOR, MINOR); if not o then return end

local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR]  end }
setmetatable(o, mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Checks for a literal nothing.
--- ```
--- IsEmpty(nil)       -- true
--- IsEmpty("")        -- true
--- IsEmpty(" ")       -- false (space is still something!)
--- IsEmpty("hello")   -- false
--- ```
--- @param str any
--- @return boolean
function o.IsEmpty(str) return str == nil or str == '' end

--- Checks for an
--- @param str any
--- @return boolean
function o.IsNotEmpty(str) return not o.IsEmpty(str) end
--- ```
--- IsBlank(nil)        -- true
--- IsBlank("")         -- true
--- IsBlank("    ")     -- true
--- IsBlank("\n\t  ")   -- true
--- IsBlank("hello")    -- false
--- IsBlank(" h ")      -- false
--- ```
--- @param str any
--- @return boolean
function o.IsBlank(str)
    if str == nil then return true end
    if type(str) ~= "string" then return false end
    return not str:find("%S")
end

--- @param str any
--- @return boolean
function o.IsNotBlank(str) return not o.IsBlank(str) end

function o.TrimAll(str)
    if str == nil then return str end
    if type(str) ~= 'string' then error(string.format('expected a string type but got: %s', type(str))) end
    return str_gsub(str or '', "%s", "")
end

function o.ToTable(args)
    -- print(string.format("args: %s, type=%s", args, type(args)))
    local rt = {}
    for a in args:gmatch("%S+") do tbl_insert(rt, a) end
    -- table.foreach(rt, print)
    return rt
end

function o.EqualsIgnoreCase(str1, str2)
    return str_lower(str1) == str_lower(str2)
end

--- @param formatstring string The string format
function o.Format(formatstring, ...)
    return string.format(formatstring, ...)
end
--- @deprecated Use L#Format
function o.format(formatstring, ...) return o.Format(formatstring, ...) end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function o.Trim(s)
    -- from PiL2 20.4
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end; o.trim = o.Trim

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function o.LTrim(s)
    return (s:gsub("^%s*", ""))
end; o.ltrim = o.LTrim

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function o.RTrim(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end; o.rtrim = o.RTrim

function o.Replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub(match, replacement)
end
--- @deprecated Use L#Replace
function o.replace(str, match, replacement) return o.Replace(str, match, replacement) end

---Example: local charCount = Count('hello world', 'l') ; returns 3
--- @param str string The string to search
--- @param pattern string The pattern to count
function o.Count(str, pattern)
    return select(2, str_gsub(str, pattern, ""))
end

--- @param index number The index to replace
--- @param str string The text where we are replacing the index value of
--- @param r string The replacement text
function o.ReplaceChar(index, str, r)
    return str:sub(1, index - 1) .. r .. str:sub(index + 1)
end

--- @param str string The text where we are replacing the index value of
--- @param r string The replacement text
function o.ReplaceAllCharButLast(str, r)
    local c = o.Count(str, r)
    if c == 1 then return str end
    local ret = str
    for _ = 1, c - 1, 1
    do
        local index = ret:find(r)
        if index >= 1 then
            ret = o.ReplaceChar(index, ret, '')
        end
    end
    return ret
end

--- @class BindingDetails
--- @field action string
--- @field buttonName string
--- @field buttonPressed string

--- @param bindingName string The keybind name (see Bindings.xml) Example: ```'CLICK ActionbarPlusF1Button1:LeftButton'```
--- @return BindingDetails|nil
function o.ParseBindingDetails(bindingName)
    local startIndexMatch, _, a,b,c = string.find(bindingName, "(.+%s)(%w+):(%a+)")
    if not (startIndexMatch or b) then return nil end
    return { action = o.TrimAll(a), buttonName = o.TrimAll(b), buttonPressed = o.TrimAll(c) }
end

---The following example returns true:
---```
---local isValidType = String.IsAnyOf('spell', 'SPELL', 'Item', 'Macro')
---assertThat(isValidType).IsTrue()
---```
---
---The following example returns false:
---```
---local isValidType = String.IsAnyOf('macrotext', 'SPELL', 'Item', 'Macro')
---assertThat(isValidType).IsFalse()
---```
--- @param valueToMatch string @Case-insensitive match against remaining args
--- @return boolean
function o.IsAnyOf(valueToMatch, ...)
    if type(valueToMatch) ~= "string" then return false end
    local target = str_lower(valueToMatch)
    for i = 1, select('#', ...) do
        local val = select(i, ...)
        if type(val) == "string" and str_lower(val) == target then
            return true
        end
    end
    return false
end

---http://lua-users.org/wiki/StringRecipes
--- @param str string
--- @param start string The string start to match
function o.StartsWith(str, start) return str:sub(1, #start) == start end
--- @param str string
--- @param start string The string start to match
function o.StartsWithIgnoreCase(str, start) return str_lower(str:sub(1, #start)) == str_lower(start) end
--- @param str string
--- @param ending string The string ending to match
function o.EndsWith(str, ending) return ending == "" or str:sub(-#ending) == ending end
--- @param str string
--- @param ending string The string ending to match
function o.EndsWithIgnoreCase(str, ending) return ending == "" or str_lower(str:sub(-#ending)) == str_lower(ending) end
--- @param str string The value
--- @param match string The string value to match
function o.Contains(str, match)
    local matchStart = str:find(match)
    return matchStart ~= nil and matchStart >= 0
end
--- @param str string The value
--- @param match string The string value to match
function o.ContainsIgnoreCase(str, match) return o.Contains(str_lower(str), str_lower(match)) end

--- Truncates a string to a specified length and appends ellipses if the string is longer.
--- @param str string The string to potentially truncate.
--- @param len number The maximum allowed length of the string before truncation.
--- @param suffix string The string to add after truncate; defaults to ...
--- @return string The potentially truncated string.
function o.Truncate(str, len, suffix)
    assert(type(str) == "string", "String.Truncate(str, len): str must be a string", 2)
    assert(type(len) == 'number' and len > 0, "Truncate(str, len): len must be a number greater than zero")
    suffix = suffix or '...'
    if str_len(str) > len then
        return o.Trim(str_sub(str, 1, len)) .. suffix
    end
    return str
end

--- Truncates a string to a specified length and appends ellipses if the string is longer.
--- @param str string The string to potentially truncate.
--- @param len number The maximum allowed length of the string before truncation.
--- @param prefix string The string to add before the truncated str; defaults to ...
--- @return string The potentially truncated string.
function o.TruncateReversed(str, len, prefix)
    assert(type(len) == 'number' and len > 0, 'String.TruncateReversed(str, len): len must be a number greater than zero.')
    prefix = prefix or '...'; if str == nil then return prefix end
    str = o.Trim(str)
    local prefixLen = str_len(prefix)
    if (len <= prefixLen) or (str_len(str) < len) then return prefix end
    return prefix .. o.Trim(str_sub(str, -len + prefixLen))
end
