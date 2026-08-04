--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local select, error, type, format = select, error, type, string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local MAJOR_VERSION = 'Kapresoft-Assert-1.0'
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

--- @class Kapresoft_Assert
local L = LibStub:NewLibrary(MAJOR_VERSION, 1); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param obj table The object to check
function L.IsNil(obj)
    return 'nil' == type(obj)
end

--- @param obj table The object to check
function L.IsNotNil(obj)
    return not L.IsNil(obj)
end

--- Example:
--- `if A.HasKey(obj, key) then doStuff() end`
--- @param obj table The object to check
--- @param key string The key to the object to check
function L.HasKey(obj, key)
    if type(obj) == 'nil' then return false end
    return 'nil' ~= type(obj[key])
end

--- Example:
--- `if A.HasNoKey(obj, key) then return end`
function L.HasNoKey(obj, key)
    return not L.HasKey(obj, key)
end


-- Option #1
-- 1: string format
-- 2: args
-- Option #2
-- 1: level
-- 2: string format
-- 3: args
function L.Throw(...)
    local count = select('#', ...)
    if count == 0 then error('Arguments required') end

    --Throw('An error occurred.')
    if count == 1 then
        local msg = select(1, ...)
        error(msg)
    end

    local level = 2
    local formatText
    local message = ''

     --Throw(1, 'An error occurred.')
     --Throw('An error occurred: %s and %s', "here", "there")
    local arg1, arg2 = select(1, ...)
    if count == 2 then
        if type(arg1) == 'number' then
            level = arg1
        else
            formatText = arg1
            message = format(formatText, arg2)
        end
        error(message, level)
    end

    -- Throw(1, 'An error occurred: %s and %s', "here", "there")
    -- Throw('An error occurred: %s and %s', "here", "there")
    -- Throw('An error occurred: %s, %s, and %s', "here", "there", 'everywhere')
    local formatArgs = {}
    arg1, arg2 = select(1, ...)
    if type(arg1) == 'number' then
        level = arg1
        formatText = arg2
        formatArgs = { select(3, ...) }
    else
        formatText = arg1
        formatArgs = { select(2, ...) }
    end
    error(format(formatText, unpack(formatArgs)), level)
end

--- Example:  AssertMethodArgNotNil(obj, 'name', 'OpenConfig(name)')
--- @param obj any The object to assert
--- @param paramName string The name of the object
--- @param methodSignature string The method signature
function L.AssertThatMethodArgIsNotNil(obj, paramName, methodSignature)
    if L.IsNotNil(obj) then return end
    error(format('The method argument %s in %s should not be nil', paramName, methodSignature), 2)
end

function L.AssertNotNil(obj, name)
    if L.IsNotNil(obj) then return end
    L.Throw(3, 'The following should not be nil: %s', name)
end
