---@class BaseLibraryObject
local BaseLibrary = {
    ---@type table
    mt = { __tostring = function() end },
}
---@return LoggerTemplate
function BaseLibrary:GetLogger()  end
