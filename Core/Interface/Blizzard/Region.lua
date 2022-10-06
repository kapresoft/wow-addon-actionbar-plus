---@class _Region : _ParentedObject
---#### Doc [UIOBJECT_Region](https://wowpedia.fandom.com/wiki/UIOBJECT_Region)
local A = {}

---Returns the script name and line where the region was created.
function A:GetSourceLocation() end

---Parents this to another object. Parented objects will inherit their scale & visibility.
---@param parent _Region | _ParentedObject | string
function A:SetParent(parent) end

---True if this Region or its Parent is being dragged. - New in 3.1.0
function A:IsDragging() end

---Checks whether the mouse is over the frame (or within specified offsets).
---@param top number
---@param bottom number
---@param left number
---@param right number
function A:IsMouseOver(top, bottom, left, right) end

function A:IsObjectLoaded() end

---Indicates if this object can be manipulated in certain ways by tainted code in combat or not
function A:IsProtected() end

---@return boolean
function A:CanChangeProtectedState() end

---Returns the details of the indexth anchor point defined for this frame (point, relativeTo, relativePoint, xofs, yofs).
function A:GetPoint(index) end

---Defines an attachment point of this region.
---@param point string
---@param relativeTo _Region | _ParentedObject | string
---@param relativePoint string
---@param ofsx number
---@param ofsy number
function A:SetPoint(point, relativeTo, relativePoint, ofsx, ofsy) end

---Defines attachment points for this region to match edges of the specified frame.
---@param frame _Region | _ParentedObject | string
function A:SetAllPoints(frame) end

---Removes all previously-defined attachment points for this region.
function A:ClearAllPoints() end

---Returns the number of anchor points defined for this frame.
function A:GetNumPoints() end

---@return boolean
function A:IsAnchoringRestricted() end

function A:GetPointByName() end
function A:ClearPointByName() end

---Shifts a region by adjusting all anchors.
---@param adjustX number
---@param adjustY number
function A:AdjustPointsOffset(adjustX, adjustY) end

---Zeroizes the x and y offsets on all anchors.
function A:ClearPointsOffset() end

---Returns the distance of the region's left edge from the left side of the screen (scale dependent).
function A:GetLeft() end

---Returns the distance of the region's right edge from the left side of the screen (scale dependent).
function A:GetRight() end

---Returns the distance of the region's top edge from the bottom of the screen (scale dependent).
function A:GetTop() end

---Returns the distance of the region's bottom edge from the bottom of the screen (scale dependent).
function A:GetBottom() end

---Returns the distance of the region's middle from the bottom left of the screen (scale dependent).
function A:GetCenter() end

---Returns the location and size (scale dependent), as shorthand for GetBottom(), GetLeft(), GetWidth() and GetHeight()
function A:GetRect() end


---Returns the location and size in a standard coordinate space (as if effectiveScale = 1).
---### Example
---```
---left, bottom, width, height = GetRect()
---left, bottom, width, height = GetScaledRect()   -- multiplied by GetEffectiveScale()
---```
function A:GetScaledRect() end

---Indicates the region has been sufficiently defined for placement on the screen.
---@return boolean
function A:IsRectValid() end

---Returns the width of this object (scale dependent).
------@param explicitSize boolean If true, will only return the explicit size of this region and ignores any implicit size inferred from anchor points or contents.
function A:GetWidth(explicitSize) end

---Defines the width of the object (scale dependent).
---@param width number
function A:SetWidth(width) end

---Returns the height of this object (scale dependent).
------@param explicitSize boolean If true, will only return the explicit size of this region and ignores any implicit size inferred from anchor points or contents.
function A:GetHeight(explicitSize) end

---Defines the height of the object (scale dependent).
---@param height number
function A:SetHeight(height) end

---Returns the width and height (scale dependent).
---### Example
---```
--- width = region:GetWidth([explicitSize]);
--- height = region:GetHeight([explicitSize]);
--- width, height = region:GetSize([explicitSize]);
---```
---@param explicitSize boolean If true, will only return the explicit size of this region and ignores any implicit size inferred from anchor points or contents.
function A:GetSize(explicitSize) end

---Defines the width and the height, as shorthand for SetWidth() and SetHeight()
---@param width number
---@param height number
function A:SetSize(width, height) end

---Returns the set scale (normally relative to its parent).
function A:GetScale() end

---Defines the scale relative to an immediate parent or standard coordinate space, depending on IsIgnoringParentScale()
---@param scale number
function A:SetScale(scale) end

---Returns the net scale, inclusive of all parents.
function A:GetEffectiveScale() end

---Directs the region to scale itself manually without inheritence.
---@param booleanValue boolean
function A:SetIgnoreParentScale(booleanValue) end

---Indicates the region scales itself manually without inheritence.
function A:IsIgnoringParentScale() end

---Directs the region to appear and permits its children to appear also, but not while the region's parent (if any) is hidden
function A:Show() end

---Directs the region and its children to disappear
function A:Hide() end

---Directs the region to appear or disappar, as an alternative to Hide() and Show()
function A:SetShown() end

---Indicates the region will appear, but only while its parent appears or if it has no parent
function A:IsShown() end

---Indicates the region and its parent (if any) are currently appearing
function A:IsVisible() end

---Returns the object's set opacity between 0 and 1 (normally relative to its parent)
function A:GetAlpha() end

---Defines the object's opacity between 0 and 1 (normally relative to its parent)
---@param alpha number between 0.0 and 1.0
function A:SetAlpha(alpha) end

---Directs the region to adopt a manually defined opacity uninherited from its parent
---@param booleanValue boolean
function A:SetIgnoreParentAlpha(booleanValue) end

---Indicates the region has a manually defined opacity uninherited from its parent
function A:IsIgnoringParentAlpha() end

--Constructs a new AnimationGroup as a child of this Region. - New in 3.1.0
function A:CreateAnimationGroup() end

--Returns all AnimationGroups that are children of this Region. - New in 3.1.0
function A:GetAnimationGroups() end

--Halts any active Animations on the Region and its children - New in 3.1.0
function A:StopAnimating() end








































