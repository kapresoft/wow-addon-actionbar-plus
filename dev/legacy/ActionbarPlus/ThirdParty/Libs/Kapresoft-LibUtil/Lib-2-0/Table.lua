--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local table, unpack = table, unpack

--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-Table-2-0', 2

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft-Table-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
S.mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR]  end }
setmetatable(S, S.mt)

local o = S

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---Trim Trailing and Leading Trim
local function Trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

--- Splits a whitespace-delimited string into tokens.
---
--- Behavior:
--- - Splits on one or more whitespace characters.
--- - Ignores leading, trailing, and repeated spaces.
--- - Returns a dense array starting at index 1.
--- - Does not trim individual tokens beyond whitespace splitting.
---
--- @param text string Whitespace-separated string (e.g., "one two three")
--- @return table<number, string> Dense array of tokens
function o.SplitWhitespace(text)
  assert(type(text) == "string", "text must be string")
  local out = {}
  for token in text:gmatch("%S+") do out[#out + 1] = token end
  return out
end

--- @param t table
function o.Size(t)
    local count = 0
    if type(t) ~= "table" then return 0 end
    for _ in next, t do count = count + 1 end
    return count
end; o.size = o.Size

--- Returns true if the table is nil or contains no key-value pairs.
---
--- Behavior:
--- - Returns true when `t` is nil.
--- - Returns true when `t` is an empty table.
--- - Returns false if at least one key exists (array or map style).
--- - Does not evaluate nested tables.
---
--- @param t table|nil
--- @return boolean
function o.IsEmpty(t)
    if t == nil then return true end
    if type(t) ~= "table" then return false end
    return next(t) == nil
end

--- Returns a dense array of all keys in the table.
---
--- @generic K
--- @param t table<K, any>
--- @return table<number, K>
function o.Keys(t)
  assert(type(t) == "table", "t must be table")
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  return keys
end; o.keys = o.Keys

--- Returns a dense array of all values in the table.
---
--- @generic V
--- @param t table<any, V>
--- @return table<number, V>
function o.Values(t)
  assert(type(t) == "table", "t must be table")
  local out = {}
  for _, v in pairs(t) do out[#out + 1] = v end
  return out
end; o.values = o.Values

--- Performs a shallow copy of a table.
---
--- Behavior:
--- - Copies all key-value pairs into a new table.
--- - Nested tables are not copied (references are preserved).
--- - Metatables are not copied.
---
--- @generic T: table
--- @param t T
--- @return T
function o.ShallowCopy(t)
  assert(type(t) == "table", "ShallowCopy(t):: t must be table")
  local t2 = {}
    for k,v in pairs(t) do t2[k] = v end
    return t2
end

--- Performs a deep copy of a table.
--- Recursively copies keys and values.
--- Handles cyclic references.
--- Does not copy metatables.
--- @generic T: table
--- @overload fun(orig: T): T
--- @param orig T
--- @param seen table|nil @internal
--- @return T
function o.DeepCopy(orig, seen)
  if type(orig) ~= "table" then return orig end
  if seen and seen[orig] then return seen[orig] end
  
  local copy = {}
  seen = seen or {}
  seen[orig] = copy
  
  for k, v in pairs(orig) do
    copy[o.DeepCopy(k, seen)] = o.DeepCopy(v, seen)
  end
  
  return copy
end

--- Recursively merges `source` into `target`.
---
--- Behavior:
--- - Fills only missing keys in `target` (non-destructive).
--- - If both `source[k]` and `target[k]` are tables, merges recursively.
--- - Inserts deep copies of tables when adding new keys.
--- - Existing non-table values in `target` are preserved.
--- - Works for both map-style and array-style tables.
---
--- @generic T: table
--- @param source T
--- @param target T|nil
--- @return T
function o.MergeRecursive(source, target)
  assert(type(source) == "table", "source must be table")
  target = target or {}
  for k, v in pairs(source) do
    local tv = target[k]
    if tv == nil then
      if type(v) == "table" then target[k] = o.DeepCopy(v)
      else target[k] = v end
    elseif type(v) == "table" and type(tv) == "table" then
      o.MergeRecursive(v, tv)
    end
  end
  return target
end

--- Merges `source` into `target` treating tables as atomic values.
---
--- Behavior:
--- - Fills only missing keys in `target` (non-destructive).
--- - Does NOT recurse into nested tables.
--- - Inserts deep copies of tables when adding new keys.
--- - Existing values in `target` are preserved entirely.
--- - Works for both map-style and array-style tables.
---
--- @generic T: table
--- @param source T
--- @param target T|nil
--- @return T
function o.MergeAtomic(source, target)
  assert(type(source) == "table", "source must be table")
  target = target or {}
  for k, v in pairs(source) do
    if target[k] == nil then
      if type(v) == "table" then target[k] = o.DeepCopy(v)
      else target[k] = v end
    end
  end
  return target
end

--- Returns a packed slice of an array starting at `startIndex`.
---
--- Behavior:
--- - Slices `t` from `startIndex` to `#t`.
--- - Re-indexes starting at 1.
--- - Returns a packed table with a `len` field preserving argument count.
--- - Useful when slicing vararg-style tables where nil values must be preserved.
---
--- @generic T
--- @param t table
--- @param startIndex number
--- @return { len: number, [number]: T }
function o.SliceAndPack(t, startIndex)
    local sliced = o.Slice(t, startIndex)
    return o.Pack(o.Unpack(sliced))
end


--- Packs varargs into a table preserving nil values.
---
--- Behavior:
--- - Stores arguments sequentially starting at index 1.
--- - Preserves trailing nil values.
--- - Adds a `len` field containing the exact argument count.
--- - Equivalent to Lua 5.2+ table.pack.
---
--- @generic T
--- @vararg T
--- @return { len: number, [number]: T }
function o.Pack(...) return { len = select("#", ...), ... } end
o.pack = o.Pack

--- Unpacks an array-style table into varargs.
--- Uses table.unpack when available, falling back to global unpack
--- for compatibility with different WoW Lua environments.
---
--- @generic T
--- @param t table<number, T> Array-style table to unpack
--- @return T, T, T, T @vararg -- depends on the size of array
function o.Unpack(t) return unpack(t) end
o.unpack = o.Unpack

--- Returns a shallow slice of an array-style table.
---
--- Behavior:
--- - Copies values from `startIndex` to `stopIndex` (inclusive).
--- - Defaults `startIndex` to 1 if nil.
--- - Defaults `stopIndex` to #t if nil.
--- - Re-indexes results starting at 1.
--- - Does not preserve `len` (use SliceAndPack for packed tables).
---
--- @generic T
--- @param t table<number, T> Array-style table
--- @param startIndex number|nil
--- @param stopIndex number|nil
--- @return table<number, T>
function o.Slice(t, startIndex, stopIndex)
  assert(type(t) == "table", "t must be table")
  startIndex = startIndex or 1
  stopIndex = stopIndex or #t
  
  local pos, new = 1, {}
  for i = startIndex, stopIndex do
    new[pos] = t[i]
    pos = pos + 1
  end
  return new
end
