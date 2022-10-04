---@class _Button : _Frame
---#### Doc: [https://wowpedia.fandom.com/wiki/UIOBJECT_Button](https://wowpedia.fandom.com/wiki/UIOBJECT_Button)
local A = {}


---Execute the click action of the button.
function A:Click() end

---Enable to the Button so that it may be clicked.
function A:Enable() end

---Disable the Button so that it cannot be clicked.
function A:Disable() end


---Return the current state ("PUSHED","NORMAL") of the Button.
function A:GetButtonState() end

---Return the font object for the Button when disabled - New in 1.10.
function A:GetDisabledFontObject() end

---Get the texture for this button when disabled - New in 1.11.
function A:GetDisabledTexture() end

---Get this button's label FontString - New in 1.11.
function A:GetFontString() end

---Return the font object for the Button when highlighted - New in 1.10.
function A:GetHighlightFontObject() end

---Get the texture for this button when highlighted.
function A:GetHighlightTexture() end

---Get whether the button is allowed to run its OnEnter and OnLeave scripts even while disabled - New in 3.3.
function A:GetMotionScriptsWhileDisabled() end

---Get the Font Object of the button.
function A:GetNormalFontObject() end

---Get the normal texture for this button - New in 1.11.
function A:GetNormalTexture() end

---Get the text offset when this button is pushed (x, y) - New in 1.11.
function A:GetPushedTextOffset() end

---Get the texture for this button when pushed - New in 1.11.
function A:GetPushedTexture() end

---Get the text label for the Button.
function A:GetText() end

---Get the height of the Button's text.
function A:GetTextHeight() end

---Get the width of the Button's text.
function A:GetTextWidth() end

---Determine whether the Button is enabled.
function A:IsEnabled() end

---Set the Button to always be drawn highlighted.
function A:LockHighlight() end


---Specify which mouse button up/down actions cause this button to receive an OnClick notification.
---@param clickType1 string AnyUp, AnyDown, LeftButtonDown, LeftButtonUp (default), MiddleButtonUp, MiddleButtonDown, RightButtonDown, RightButtonUp, Button4Up, Button4Down, Button5Up, Button5Down
---@param clickType2 string
---#### Doc [https://wowpedia.fandom.com/wiki/API_Button_RegisterForClicks](https://wowpedia.fandom.com/wiki/API_Button_RegisterForClicks)
function A:RegisterForClicks(clickType1, clickType2, ...) end
function A:RegisterForMouse() end

---Set the state of the Button ("PUSHED", "NORMAL") and whether it is locked.
function A:SetButtonState() end

function A:SetDisabledAtlas(atlasName) end


--[[


Button:RegisterForClicks(clickType1 [, clickType2, ...]) - Specify which mouse button up/down actions cause this button to receive an OnClick notification.
Button:RegisterForMouse()
Button:SetButtonState(state[, lock]) - Set the state of the Button ("PUSHED", "NORMAL") and whether it is locked.
Button:SetDisabledAtlas(atlasName)

Button:SetDisabledFontObject([font]) - Set the font object for settings when disabled - New in 1.10.
Button:SetDisabledTexture(texture or texturePath) - Set the disabled texture for the Button - Updated in 1.10.
Button:SetEnabled(boolean) - Same as Enable() or Disable()
Button:SetFontString(fontString) - Set the button's label FontString - New in 1.11.
Button:SetFormattedText(formatstring[, ...]) - Set the formatted text label for the Button. - New in 2.3.
Button:SetHighlightAtlas(atlasName[, blendmode)
Button:SetHighlightFontObject([font]) - Set the font object for settings when highlighted - New in 1.10.
Button:SetHighlightTexture(texture or texturePath[,alphaMode]) - Set the highlight texture for the Button.
Button:SetMotionScriptsWhileDisabled([bool]) - Set whether button should fire its OnEnter and OnLeave scripts even while disabled - New in 3.3.
Button:SetNormalAtlas(atlasName)
Button:SetNormalFontObject(FontObject) - Set the Font Object of the button.
Button:SetNormalTexture(texture or texturePath) - Set the normal texture for the Button - Updated in 1.10.
Button:SetPushedAtlas(atlasName)
Button:SetPushedTextOffset(x, y) - Set the text offset for this button when pushed - New in 1.11.
Button:SetPushedTexture(texture or texturePath) - Set the pushed texture for the Button - Updated in 1.10.
Button:SetText(text) - Set the text label for the Button.
Button:UnlockHighlight() - Set the Button to not always be drawn highlighted.




]]