--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-DebugChatFrameMixin-2-0', 1

--- @class Kapresoft-DebugChatFrameMixin-2-0
--- @field chatFrame ChatLogFrame
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Type: DebugChatFrameMixin
-------------------------------------------------------------------------------]]
local o = S

local FONT_SIZE_ERR_MSG = 'Invalid:: Font size must be 10, 12, 14, 16, and 18'

--- @return ChatLogFrame
function o:ChatFrame() return self.chatFrame end

--- @return boolean
function o:HasChatFrame() return self:ChatFrame() ~= nil end

--- @return boolean
function o:IsChatFrameTabShown()
  return self:HasChatFrame() and self:ChatFrame():IsShown()
end

--- Set the Font Size of the ChatFrame Console
--- @param fontSize number Font Size between 12 and 18
function o:SetChatFrameFontSize(fontSize)
  if not self.chatFrame then return end

  fontSize = fontSize or 14
  assert((fontSize % 2) == 0, FONT_SIZE_ERR_MSG)
  assert(fontSize >= 10 and fontSize <= 18, FONT_SIZE_ERR_MSG)
  local font, _, outline = self.chatFrame:GetFont()
  return font and self.chatFrame:SetFont(font, fontSize, outline)
end

---@param chatFrame ChatLogFrame
function o:RegisterChatFrame(chatFrame) self.chatFrame = chatFrame end
