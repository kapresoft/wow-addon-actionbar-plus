-- ## External -------------------------------------------------
local gsub, len, tinsert, pairs, type, tostring = string.gsub, string.len, table.insert , pairs, type, tostring

-- ## Local ----------------------------------------------------

local LibStub = __K_Core:LibPack()
---@class String
local _L = LibStub:NewLibrary('String')

-- ## Functions ------------------------------------------------

function _L.IsEmpty(str) return (str or '') == '' end
function _L.IsNotEmpty(str) return not _L.IsEmpty(str) end
function _L.IsBlank(str) return len(_L.TrimAll(str)) <= 0 end
function _L.IsNotBlank(str) return not _L.IsEmpty(str) end
function _L.TrimAll(str) return gsub(str or '', "%s", "") end

function _L.ToTable(args)
    -- print(string.format("args: %s, type=%s", args, type(args)))
    local rt = {}
    for a in args:gmatch("%S+") do tinsert(rt, a) end
    -- table.foreach(rt, print)
    return rt
end

function _L.ToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. _L.ToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function _L.EqualsIgnoreCase(str1, str2)
    return string.lower(str1) == string.lower(str2)
end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function _L.trim(s)
    -- from PiL2 20.4
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function _L.ltrim(s)
    return (s:gsub("^%s*", ""))
end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function _L.rtrim(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end

function _L.replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub("%" .. match, replacement)
end
