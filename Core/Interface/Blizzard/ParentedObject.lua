---@class _ParentedObject : _UIObject
local A = {}

---Returns the widget object's debug name.
---@return string
function A:GetDebugName() end

---Returns the widget's parent object.
---@return _UIObject, _ParentedObject
function A:GetParent() end

---Returns if this widget's methods may only be called from secure execution paths.
---@return boolean
function A:IsForbidden() end

---Sets the widget to be forbidden for insecure code.
function A:SetForbidden() end
