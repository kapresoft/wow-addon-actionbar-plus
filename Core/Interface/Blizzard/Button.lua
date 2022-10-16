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
---@param state string PUSHED, NORMAL
---@param lock boolean
function A:SetButtonState(state, lock) end

---@param atlasName string
function A:SetDisabledAtlas(atlasName) end

-- Set the font object for settings when disabled - New in 1.10.
---@param font any FontObject
function A:SetDisabledFontObject(font) end

-- Set the disabled texture for the Button - Updated in 1.10.
function A:SetDisabledTexture(textureOrtexturePath) end

-- Same as Enable() or Disable()
function A:SetEnabled(boolean) end

-- Set the button's label FontString - New in 1.11.
function A:SetFontString(fontString) end

-- Set the formatted text label for the Button. - New in 2.3.
function A:SetFormattedText(formatstring, ...) end

---@param atlasName string
---@param blendMode string
---@see _AlphaMode or
---@see _BlendMode
function A:SetHighlightAtlas(atlasName, blendMode) end

-- Set the font object for settings when highlighted - New in 1.10.
function A:SetHighlightFontObject(font) end

-- Set the highlight texture for the Button.
---@param textureOrTexturePath string
---@param alphaMode string
---@see _AlphaMode or
---@see _BlendMode
function A:SetHighlightTexture(textureOrTexturePath ,alphaMode) end

-- Set whether button should fire its OnEnter and OnLeave scripts even while disabled - New in 3.3.
---@param bool boolean
function A:SetMotionScriptsWhileDisabled(bool) end

-- Set the Font Object of the button.
function A:SetNormalFontObject(FontObject) end

-- Set the normal texture for the Button - Updated in 1.10.
---@param textureOrTexturePath string
function A:SetNormalTexture(textureOrTexturePath) end

-- Set the text offset for this button when pushed - New in 1.11.
---@param x number
---@param y number
function A:SetPushedTextOffset(x, y) end

-- Set the pushed texture for the Button - Updated in 1.10.
---@param textureOrTexturePath string
function A:SetPushedTexture(textureOrTexturePath) end

-- Set the text label for the Button.
---@param text string
function A:SetText(text) end

-- Set the Button to not always be drawn highlighted.
function A:UnlockHighlight() end

---@param atlasName string
function A:SetNormalAtlas(atlasName) end

---@param atlasName string
function A:SetPushedAtlas(atlasName) end


--[[






]]