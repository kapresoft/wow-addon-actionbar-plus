---@class _ScriptObject
---#### Doc: [UIOBJECT_ScriptObject](https://wowpedia.fandom.com/wiki/UIOBJECT_ScriptObject)
local A = {}

---Returns the widget's script handler.
---@return function
---@param scriptType string Name of the script type, e.g. "OnShow".
---@param bindingType number? Specifies an intrinsic frame's pre/post handler (optional)
function A:GetScript(scriptType, bindingType) end

---Sets the widget's script handler.
---@param scriptType string Name of the script type, e.g. "OnShow".
---@param handler function The function to call when handling the specified widget event, or nil to remove any existing script.
function A:SetScript(scriptType, handler) end

---Securely hooks a script handler.
---@param scriptType string Name of the script type, e.g. "OnShow".
---@param handler function The function to call when handling the specified widget event, or nil to remove any existing script.
---@param bindingType number? Specifies an intrinsic frame's pre/post handler (optional)
function A:HookScript(scriptType, handler, bindingType) end

---Returns whether the widget supports a script type.
---@param scriptType string Name of the script type, e.g. "OnShow".
function A:HasScript(scriptType) end

---Run when the frame is created.
---@param self _ScriptObject | _Frame
function A:OnLoad(self) end

---Run each time the screen is drawn by the game engine.
---@param self _ScriptObject | _Frame
---@param elapsed number The time in seconds since the last OnUpdate dispatch, but excluding time when the user interface was not being drawn such as while zoning into the game world
function A:OnUpdate(self, elapsed) end

