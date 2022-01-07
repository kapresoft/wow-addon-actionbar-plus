local select, error, type, format = select, error, type, string.format
local unpack, pformat = table.unpackIt, PrettyPrint.pformat
local A = {}

---@param obj table The object to check
function A.IsNil(obj)
    return 'nil' == type(obj)
end

---@param obj table The object to check
function A.IsNotNil(obj)
    return not A.IsNil(obj)
end

--- Example:
--- `if A.HasKey(obj, key) then doStuff() end`
---@param obj table The object to check
---@param key string The key to the object to check
function A.HasKey(obj, key)
    if type(obj) == 'nil' then return false end
    return 'nil' == type(obj[key])
end

--- Example:
--- `if A.HasNoKey(obj, key) then return end`
function A.HasNoKey(obj, key)
    return not A.HasKey(obj, key)
end

-- Option #1
-- 1: string format
-- 2: args
-- Option #2
-- 1: level
-- 2: string format
-- 3: args
function A.Throw(...)
    local count = select('#', ...)
    if count == 0 then error('Arguments required') end

    --Throw('An error occurred.')
    if count == 1 then
        local msg = select(1, ...)
        error(msg)
    end

    local level = 2
    local formatText = nil
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

---@param obj table The object to check
function A.IsNotNil(obj)
    return not A.IsNil(obj)
end

--- Example:  AssertMethodArgNotNil(obj, 'name', 'OpenConfig(name)')
---@param obj The object to assert
---@param paramName string The name of the object
---@param methodSignature string The method signature
function A.AssertThatMethodArgIsNotNil(obj, paramName, methodSignature)
    if A.IsNotNil(obj) then return end
    error(format('The method argument %s in %s should not be nil', paramName, methodSignature), 2)
end

function A.AssertNotNil(obj, name)
    if A.IsNotNil(obj) then return end
    A.Throw(3, 'The following should not be nil: %s', name)
end

Assert = A