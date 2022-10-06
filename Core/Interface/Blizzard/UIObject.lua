---@class _UIObject
local A = {}

---@return string Returns the widget object's global name.
function A:GetName() end
---@return string Returns the widget type
function A:GetObjectType() end
---@param objectType boolean True if the object belongs to a given widget type or its subtypes.
function A:IsObjectType(objectType) end

