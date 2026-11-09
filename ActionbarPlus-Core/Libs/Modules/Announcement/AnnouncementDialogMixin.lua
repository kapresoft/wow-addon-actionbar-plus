--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local Announcements = ns.O.Announcements

local ADDON_TITLE = 'ActionbarPlus'

--- @class AnnouncementScrollChild_ABP_2_0 : Frame
--- @field Body FontString

--- @class AnnouncementDialogFrame_ABP_2_0 : Frame, BackdropTemplate
--- @field Title FontString
--- @field ScrollFrame ScrollFrame
--- @field OkButton Button
--- @field scrollMarginX number @Dialog width minus viewport width
--- @field scrollMarginY number @Dialog height minus viewport height
AnnouncementDialogMixin_ABP_2_0 = {}
local o = AnnouncementDialogMixin_ABP_2_0

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  local scrollFrame = self.ScrollFrame
  scrollFrame:SetScrollChild(scrollFrame.ScrollChild)
  self.scrollMarginX = self:GetWidth() - scrollFrame:GetWidth()
  self.scrollMarginY = self:GetHeight() - scrollFrame:GetHeight()
end

--- @param def AnnouncementDef_ABP_2_0
function o:ApplySize(def)
  if not (def.width or def.height) then return end
  local width = def.width or self:GetWidth()
  local height = def.height or self:GetHeight()
  self:SetSize(width, height)
  self.ScrollFrame:SetSize(width - self.scrollMarginX, height - self.scrollMarginY)
end

--- @param def AnnouncementDef_ABP_2_0
function o:Configure(def)
  self.Title:SetText(('%s: %s'):format(ADDON_TITLE, Announcements:Localized(def, 'title')))
  self:ApplySize(def)

  --- @type AnnouncementScrollChild_ABP_2_0
  local scrollChild = self.ScrollFrame.ScrollChild
  scrollChild:SetWidth(self.ScrollFrame:GetWidth())
  local body = scrollChild.Body
  body:SetText(Announcements:Localized(def, 'content'))

  local viewportHeight = self.ScrollFrame:GetHeight()
  scrollChild:SetHeight(math.max(body:GetStringHeight(), viewportHeight))
end

function o:OnClickOk() self:Hide() end
