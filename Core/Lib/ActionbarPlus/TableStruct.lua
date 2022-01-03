function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function table.append(source, target)
    local t2 = target or {}
    for k,v in pairs(source) do
        if t2[key] == nil then
            t2[k] = v
        end
    end
    return t2
end

function table.sliceAndPack(t, startIndex)
    local sliced = table.slice(t, startIndex)
    if type(unpack) ~= 'nil' then
        return table.pack(unpack(sliced))
    end
    return table.pack(table.unpack(sliced))
end

---Fail-safe unpack
---@param t table The table to unpack
function table.unpackIt(t)
    if type(unpack) == 'function' then
        return unpack(t)
    end
    return table.unpack(t)
end

function table.slice (t, startIndex, stopIndex)
    local pos, new = 1, {}
    if not stopIndex then stopIndex = #t end
    for i = startIndex, stopIndex do
        new[pos] = t[i]
        pos = pos + 1
    end
    return new
end

function table.print(t) print(table.concatkv(t)) end

function table.println(t)
    if type(t) ~= 'table' then return tostring(t) end
    for k,v in pairs(t) do
        print(string.format("%s: %s", tostring(k), table.println(v)))
    end
end

function table.concatkv(t)
    if type(t) ~= 'table' then return tostring(t) end
    local s = '{ '
    for k,v in pairs(t) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. table.concatkv(v) .. ','
    end
    return s .. '} '
end

function table.toString(t) return table.concatkv(t) end

function table.pack(...)
    return { len = select("#", ...), ... }
end