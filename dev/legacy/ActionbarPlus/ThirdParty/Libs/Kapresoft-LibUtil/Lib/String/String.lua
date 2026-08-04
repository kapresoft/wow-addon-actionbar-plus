--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local pairs, type, tostring = pairs, type, tostring
local str_gsub, str_len, str_lower, tbl_insert = string.gsub, string.len, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local MAJOR_VERSION = 'Kapresoft-String-1.0'
--- @class Kapresoft_String
local L = LibStub:NewLibrary(MAJOR_VERSION, 3); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

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
function L.IsEmpty(str) return (str or '') == '' end
--- Checks for an
--- @param str any
--- @return boolean
function L.IsNotEmpty(str)
    if str == nil then return true end
    return not L.IsEmpty(str)
end
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
function L.IsBlank(str)
    if str == nil then return true end
    if type(str) ~= "string" then return false end
    return not str:find("%S")
end
--- @param str any
--- @return boolean
function L.IsNotBlank(str) return not L.IsBlank(str) end
function L.TrimAll(str)
    if str == nil then return str end
    if type(str) ~= 'string' then error(string.format('expected a string type but got: %s', type(str))) end
    return str_gsub(str or '', "%s", "")
end

function L.ToTable(args)
    -- print(string.format("args: %s, type=%s", args, type(args)))
    local rt = {}
    for a in args:gmatch("%S+") do tbl_insert(rt, a) end
    -- table.foreach(rt, print)
    return rt
end

function L.ToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. L.ToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function L.EqualsIgnoreCase(str1, str2)
    return string.lower(str1) == string.lower(str2)
end

--- @param formatstring string The string format
function L.Format(formatstring, ...)
    return string.format(formatstring, ...)
end
--- @deprecated Use L#Format
function L.format(formatstring, ...) return L.Format(formatstring, ...) end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function L.Trim(s)
    -- from PiL2 20.4
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
--- @deprecated Use L#Trim
function L.trim(s) return L.Trim(s) end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function L.LTrim(s)
    return (s:gsub("^%s*", ""))
end
--- @deprecated Use L#LTrim
function L.ltrim(s) return L.LTrim(s) end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function L.RTrim(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end
--- @deprecated Use L#RTrim
function L.rtrim(s) return L.RTrim(s) end

function L.Replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub(match, replacement)
end
--- @deprecated Use L#Replace
function L.replace(str, match, replacement) return L.Replace(str, match, replacement) end

---Example: local charCount = Count('hello world', 'l') ; returns 3
--- @param str string The string to search
--- @param pattern string The pattern to count
function L.Count(str, pattern)
    return select(2, string.gsub(str, pattern, ""))
end

--- @param index number The index to replace
--- @param str string The text where we are replacing the index value of
--- @param r string The replacement text
function L.ReplaceChar(index, str, r)
    return str:sub(1, index - 1) .. r .. str:sub(index + 1)
end

--- @param str string The text where we are replacing the index value of
--- @param r string The replacement text
function L.ReplaceAllCharButLast(str, r)
    local c = L.Count(str, r)
    if c == 1 then return str end
    local ret = str
    for _ = 1, c - 1, 1
    do
        local index = ret:find(r)
        if index >= 1 then
            ret = L.ReplaceChar(index, ret, '')
        end
    end
    return ret
end

--- @class BindingDetails
local BindingDetailsTemplate = { action="<CLICK>", buttonName="<buttonName>", buttonPressed="<LeftButton>" }

--- @param bindingName string The keybind name (see Bindings.xml) Example: ```'CLICK ActionbarPlusF1Button1:LeftButton'```
--- @return BindingDetails
function L.ParseBindingDetails(bindingName)
    local startIndexMatch, _, a,b,c = string.find(bindingName, "(.+%s)(%w+):(%a+)")
    if not (startIndexMatch or b) then return nil end
    return { action= L.TrimAll(a), buttonName = L.TrimAll(b), buttonPressed = L.TrimAll(c) }
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
--- @param valueToMatch string A case insensitive match against the variable argument #2.
--- @return boolean
function L.IsAnyOf(valueToMatch, ...)
    if not valueToMatch then return false end
    local args = {...}
    for i=1, #args do
        local val = args[i]
        if val and str_lower(val) == str_lower(valueToMatch) then return true end
    end
    return false
end

---http://lua-users.org/wiki/StringRecipes
--- @param str string
--- @param start string The string start to match
function L.StartsWith(str, start) return str:sub(1, #start) == start end
--- @param str string
--- @param start string The string start to match
function L.StartsWithIgnoreCase(str, start) return str_lower(str:sub(1, #start)) == str_lower(start) end
--- @param str string
--- @param ending string The string ending to match
function L.EndsWith(str, ending) return ending == "" or str:sub(-#ending) == ending end
--- @param str string
--- @param ending string The string ending to match
function L.EndsWithIgnoreCase(str, ending) return ending == "" or str_lower(str:sub(-#ending)) == str_lower(ending) end
--- @param str string The value
--- @param match string The string value to match
function L.Contains(str, match)
    local matchStart = str:find(match)
    return matchStart ~= nil and matchStart >= 0
end
--- @param str string The value
--- @param match string The string value to match
function L.ContainsIgnoreCase(str, match) return L.Contains(str_lower(str), str_lower(match)) end

--- Truncates a string to a specified length and appends ellipses if the string is longer.
--- @param str string The string to potentially truncate.
--- @param len number The maximum allowed length of the string before truncation.
--- @param suffix string The string to add after truncate; defaults to ...
--- @return string The potentially truncated string.
function L.Truncate(str, len, suffix)
    assert(type(str) == "string", "String.Truncate(str, len): str must be a string", 2)
    assert(type(len) == 'number' and len > 0, "Truncate(str, len): len must be a number greater than zero")
    suffix = suffix or '...'
    if string.len(str) > len then
        return L.Trim(string.sub(str, 1, len)) .. suffix
    end
    return str
end

--- Truncates a string to a specified length and appends ellipses if the string is longer.
--- @param str string The string to potentially truncate.
--- @param len number The maximum allowed length of the string before truncation.
--- @param prefix string The string to add before the truncated str; defaults to ...
--- @return string The potentially truncated string.
function L.TruncateReversed(str, len, prefix)
    assert(type(len) == 'number' and len > 0, 'String.TruncateReversed(str, len): len must be a number greater than zero.')
    prefix = prefix or '...'; if str == nil then return prefix end
    str = L.Trim(str)
    local prefixLen = string.len(prefix)
    if (len <= prefixLen) or (string.len(str) < len) then return prefix end
    return prefix .. L.Trim(string.sub(str, -len + prefixLen))
end
