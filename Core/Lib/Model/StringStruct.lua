function string.IsEmpty(str) return (str or '') == '' end
function string.IsNotEmpty(str) return not string.IsEmpty(str) end
function string.IsBlank(str) return string.len(string.TrimAll(str)) <= 0 end
function string.IsNotBlank(str) return not string.IsEmpty(str) end
function string.TrimAll(str) return string.gsub(str or '', "%s", "") end

function string.ToTable(args)
    -- print(string.format("args: %s, type=%s", args, type(args)))
    local rt = {}
    for a in args:gmatch("%S+") do table.insert(rt, a) end
    -- table.foreach(rt, print)
    return rt
end

function string.ToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. string.ToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function string.EqualsIgnoreCase(str1, str2)
    return string.lower(str1) == string.lower(str2)
end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function string.trim(s)
    -- from PiL2 20.4
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function string.ltrim(s)
    return (s:gsub("^%s*", ""))
end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function string.rtrim(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end

function string.replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub("%" .. match, replacement)
end

