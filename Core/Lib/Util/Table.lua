-- ## External -------------------------------------------------
local table, unpack = table, unpack

-- ## Local ----------------------------------------------------
local LibStub = __K_Core:LibPack()
---@class Table
local _L = LibStub:NewLibrary('Table')

-- ## Functions ------------------------------------------------

---Trim Trailing and Leading Trim
local function Trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

function _L.parseSpaceSeparatedVar(text)
    local rt = {}
    for a in text:gmatch("%S+") do table.insert(rt, a) end
    return rt
end

function _L.parseCSV(text)
    local rt = {}
    for a,v in text:gmatch("([^,]+)") do
        local a2 = Trim(a)
        table.insert(rt, a2)
    end
    return rt
end

function _L.size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
function _L.isEmpty(t)
    if t == nil then return true end
    return _L.size(t) <= 0
end
function _L.members()
    print('table members: ')
    for key, _ in pairs(_L) do
        print(" " .. key);
    end
end

function _L.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function _L.append(source, target)
    local t2 = target or {}
    for k,v in pairs(source) do
        if t2[k] == nil then
            t2[k] = v
        end
    end
    return t2
end

function _L.sliceAndPack(t, startIndex)
    local sliced = _L.slice(t, startIndex)
    if type(unpack) ~= 'nil' then
        return _L.pack(unpack(sliced))
    end
    return _L.pack(_L.unpackIt(sliced))
end

---Fail-safe unpack
---@param t table The table to unpack
function _L.unpackIt(t)
    if type(unpack) == 'function' then
        return unpack(t)
    end
    return table.unpack(t)
end

function _L.slice (t, startIndex, stopIndex)
    local pos, new = 1, {}
    if not stopIndex then stopIndex = #t end
    for i = startIndex, stopIndex do
        new[pos] = t[i]
        pos = pos + 1
    end
    return new
end

function _L.concatkv(t)
    if type(t) ~= 'table' then return tostring(t) end
    local s = '{ '
    for k,v in pairs(t) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. _L.concatkv(v) .. ','
    end
    return s .. '} '
end

function _L.getSortedKeys(t)
    if type(t) ~= 'table' then return tostring(t) end
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)
    return keys
end

function _L.concatkvs(t, optionalAddNewline)
    local addNewLine = optionalAddNewline or false
    if type(t) ~= 'table' then return tostring(t) end
    local keys = _L.getSortedKeys(t)
    local s = '{ '
    if addNewLine then s = s .. '\n' end
    for _, k in pairs(keys) do
        local ko = k
        if type(k) ~= 'number' then k = '"'..k..'"' end
        if type(t[ko]) ~= 'function' then
            s = s .. '['..k..'] = ' .. _L.concatkvs(t[ko]) .. ','
        end
    end
    return s .. '} '
end

function _L.toString(t) return _L.concatkv(t) end
function _L.toStringSorted(t, optionalAddNewline) return _L.concatkvs(t, optionalAddNewline) end

function _L.toString2(t)
    if type(t) ~= 'table' then return tostring(t) end
    local s = '\n{'
    for k,v in pairs(t) do
        s = string.format("%s\n    %s: %s,", s, tostring(k), _L.toString2(v))
    end
    return s .. '\n}'
end

function _L.pack(...)
    return { len = select("#", ...), ... }
end

function _L.isTable(t) return type(t) == 'table' end
function _L.isNotTable(t) return not _L.isTable(t) end

function _L.print(t) print(_L.toString(t)) end
function _L.printkv(t) print(_L.concatkv(t)) end

function _L.printkvs(t)
    local keys = _L.getSortedKeys(t)
    for _, k in ipairs(keys) do print(k, t[k]) end
end

function _L.println(t)
    if type(t) ~= 'table' then return tostring(t) end
    for k,v in pairs(t) do
        print(string.format("%s: %s", tostring(k), _L.println(v)))
    end
end

function _L.printG() _L.printkvs(_G) end
function _L.printLoaded() _L.printkvs(package.loaded) end
