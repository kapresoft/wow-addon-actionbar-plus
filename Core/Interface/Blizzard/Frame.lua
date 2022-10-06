---@class _Frame : _RegionAndScriptObject
local A = {}

---Register for notifications when an event occurs.
function A:RegisterEvent(event) end

---Register for notifications when events apply to certain units.
---@param event string name of the event, e.g. "UNIT_POWER".
---@param unit1 string unit to deliver the event for (UnitId).
---#### See [UnitId](https://wowpedia.fandom.com/wiki/UnitId)
function A:RegisterUnitEvent(event, unit1 , unit2, ...) end

---Register this frame to receive all events (For debugging only!)
function A:RegisterAllEvents() end

---Indicate that this frame should no longer be notified when event occurs.
---@param event string name of the event, e.g. "UNIT_POWER".
function A:UnregisterEvent(event) end

---Indicate that this frame should no longer be notified when any events occur.
function A:UnregisterAllEvents() end

---Returns true if the given event is registered to the frame.
---@param event string name of the event, e.g. "UNIT_POWER".
function A:IsEventRegistered(event) end

function A:DesaturateHierarchy() end

---Disables the specified draw layer.
---@param layer string defaults to "ARTWORK"
---@see _DrawLayer
function A:DisableDrawLayer(layer) end

---Enables the specified draw layer.
---@param layer string
---@see _DrawLayer
function A:EnableDrawLayer(layer) end

function A:GetBoundsRect() end

---Gets the modifiers used for limiting the frame from leaving the screen.
function A:GetClampRectInsets() end

---Returns the stereoscopic (3D) depth, relative to its parent if applicable.
function A:GetDepth() end

function A:GetDontSavePosition() end

---Returns the effective alpha of a frame.
function A:GetEffectiveAlpha() end

---Returns the absolute stereoscopic (3D) depth.
function A:GetEffectiveDepth() end

function A:GetEffectivelyFlattensRenderLayers() end

function A:GetFlattensRenderLayers() end

---Returns the level of this frame.
function A:GetFrameLevel() end

---Returns the strata of this frame.
function A:GetFrameStrata() end

---Gets the frame's hit rectangle inset distances
---@param left number
---@param right number
---@param top number
---@param bottom number
function A:GetHitRectInsets(left, right, top, bottom) end

---Returns the frame's maximum allowed resize bounds
---@param w number
---@param h number
function A:GetMaxResize(w, h) end

---Returns the frame's minimum allowed resize bounds
---@param w number
---@param h number
function A:GetMinResize(w, h) end

---@return boolean
function A:HasFixedFrameLevel() end

---@return boolean
function A:HasFixedFrameStrata() end

function A:IgnoreDepth() end

---Returns if the frame is prohibited from being dragged off screen.
function A:IsClampedToScreen() end

---@return boolean
function A:IsIgnoringDepth() end

---Returns if the frame is set as top level.
---@return boolean
function A:IsToplevel() end

---Lowers this frame behind other frames.
function A:Lower() end

---Raises this frame above other frames.
function A:Raise() end

---@param angleRadians number
---@param pivotX number
---@param pivotY number
function A:RotateTextures(angleRadians , pivotX, pivotY) end

---Sets whether the frame is prohibited from being dragged off screen.
function A:SetClampedToScreen() end

---Modify how much the frame may be dragged offscreen.
function A:SetClampRectInsets() end

---Set the stereoscopic (3D) depth, relative to its parent if applicable.
function A:SetDepth() end
function A:SetDontSavePosition() end

function A:SetDrawLayerEnabled(layer, mouseOver) end
---@param booleanValue boolean
function A:SetFixedFrameLevel(booleanValue) end
---@param booleanValue boolean
function A:SetFixedFrameStrata(booleanValue) end
---@param booleanValue boolean
function A:SetFlattensRenderLayers(booleanValue) end


---Controls whether or not the frame is rendered to its own framebuffer.
---@param enabled boolean
function A:SetFrameBuffer(enabled) end

---Positions the frame within a subdivision of its z-axis interval
---@param level number
function A:SetFrameLevel(level) end

---Positions the frame within a z-axis interval.
---@param strata string WORLD, BACKGROUND, LOW, MEDIUM, HIGH, DIALOG, FULLSCREEN, FULLSCREEN_DIALOG, TOOLTIP
---###Doc: [https://wowpedia.fandom.com/wiki/Frame_Strata](https://wowpedia.fandom.com/wiki/Frame_Strata)
function A:SetFrameStrata(strata) end

---Set the inset distances for the frame's hit rectangle.
---@param left number
---@param right number
---@param top number
---@param bottom number
function A:SetHitRectInsets(left, right, top, bottom) end

---Sets the maximum dimensions this frame can be resized to.
---@param minWidth number
---@param minHeight number
function A:SetMaxResize(minWidth, minHeight) end

---Sets the minimum dimensions this frame can be resized to.
---@param minWidth number
---@param minHeight number
function A:SetMinResize(minWidth, minHeight) end

---Sets whether the frame should raise itself when clicked
---@param isTopLevel boolean
function A:SetToplevel(isTopLevel) end

---Returns child Frames as multiple return values.
function A:GetChildren() end

---Returns the number of child Frames.
function A:GetNumChildren() end

function A:DoesClipChildren() end

---Sets the frame clipping its children.
function A:SetClipsChildren(clipped) end

---Returns the number of regions.
function A:GetNumRegions() end

---Returns the regions.
function A:GetRegions() end

---Creates a FontString
function A:CreateFontString() end

---Creates a Line
function A:CreateLine() end

---Creates a MaskTexture
function A:CreateMaskTexture() end

---Creates a Texture
function A:CreateTexture() end


---Whether to receive keyboard input.
---@param enableFlag boolean
function A:EnableKeyboard(enableFlag) end

---Whether to receives mouse input.
---@param enableFlag boolean
function A:EnableMouse(enableFlag) end

---Whether to receive mouse wheel notifications.
---@param enableFlag boolean
function A:EnableMouseWheel(enableFlag) end

function A:GetHyperlinksEnabled() end

---Returns if keyboard inputs propagate.
function A:GetPropagateKeyboardInput() end

---Returns if receiving keyboard input.
function A:IsKeyboardEnabled() end

---Returns if receiving mouse click inputs.
function A:IsMouseClickEnabled() end

---Returns if receiving mouse input.
function A:IsMouseEnabled() end

---hover notifications.
function A:IsMouseMotionEnabled() end

---Returns if receiving mouse wheel notifications.
function A:IsMouseWheelEnabled() end

---Returns if the frame can be moved.
function A:IsMovable() end

---Returns if the frame can be resized.
function A:IsResizable() end

---Returns if this frame has been relocated by the user.
function A:IsUserPlaced() end

---Direct the frame to monitor for mouse-dragging.
---@param buttonType string LeftButton, RightButton, MiddleButton, Button4, Button5, ..., ButtonN
function A:RegisterForDrag(buttonType, ...) end

function A:SetHyperlinksEnabled() end
function A:SetMouseClickEnabled() end
function A:SetMouseMotionEnabled() end

---Whether the frame should be moved.
---@param isMovable boolean
function A:SetMovable(isMovable) end

---Whether to propagate keyboard input to other frames.
function A:SetPropagateKeyboardInput(propagate) end

---Whether the frame should be resized.
---@param isResizable boolean
function A:SetResizable(isResizable) end

---Whether the frame is user-defined in the layout cache.
---@param isUserPlaced boolean
function A:SetUserPlaced(isUserPlaced) end

---Starts moving this frame.
function A:StartMoving() end

---Starts sizing this frame using the specified anchor point.
---@param point string TOPLEFT, CENTER, TOP, etc..
function A:StartSizing(point) end

---Stops moving and/or sizing this frame.
function A:StopMovingOrSizing() end


---@param enabled boolean
function A:EnableGamePadButton(enabled) end

---@param enabled boolean
function A:EnableGamePadStick(enabled) end

function A:IsGamePadButtonEnabled() end
function A:IsGamePadStickEnabled() end


---Returns the current value of an attribute matching a given pattern.
---@param name string
---@return any
function A:GetAttribute(name) end

---Sets an attribute on the frame.
---@param name string
---@param value any
function A:SetAttribute(name, value) end

---Sets an attribute on the frame without triggering the OnAttributeChanged script handler.
---@param name string
---@param value any
function A:SetAttributeNoHandler(name, value) end

function A:ExecuteAttribute(name, ...) end

---@return boolean
function A:CanChangeAttribute() end

---Returns the frame ID.
---@return string
function A:GetID() end

---Sets an ID on this frame.
---@param id string
function A:SetID(id) end

--[[

Frame:GetAttribute(prefix, name, suffix) - Returns the current value of an attribute matching a given pattern.
Frame:SetAttribute(name, value) - Sets an attribute on the frame.
Frame:SetAttributeNoHandler(name, value) - Sets an attribute on the frame without triggering the OnAttributeChanged script handler.
Frame:ExecuteAttribute(name [, ...])

Frame:CanChangeAttribute()
Frame:GetID() - Returns the frame ID.
Frame:SetID(id) - Sets an ID on this frame.

]]


























































