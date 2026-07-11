--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'V2AnnouncementDialog'
--- @class V2AnnouncementDialog_ABP_2_0
local o = {}; ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local DIALOG_WIDTH, DIALOG_HEIGHT = 420, 360
local BUTTON_LABEL = 'Got it!'

local function CreateDialog()
  local AceGUI = ns:AceGUI()

  --- @type AceGUIWindow
  local frame = AceGUI:Create('Window')
  frame:SetTitle('ActionbarPlus V2')
  frame:SetWidth(DIALOG_WIDTH)
  frame:SetHeight(DIALOG_HEIGHT)
  frame:SetLayout('Flow')
  frame:SetCallback('OnClose', function() AceGUI:Release(frame) end)
  frame.frame:SetClampedToScreen(true)

  local scroll = AceGUI:Create('ScrollFrame')
  scroll:SetLayout('Flow')
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  frame:AddChild(scroll)

  local label = AceGUI:Create('Label')
  label:SetFullWidth(true)
  label:SetText(ABP_V2_ANNOUNCEMENT or '')
  local fontPath, fontSize, fontFlags = label.label:GetFont()
  label.label:SetFont(fontPath, fontSize + 2, fontFlags)
  scroll:AddChild(label)

  local btn = AceGUI:Create('Button')
  btn:SetText(BUTTON_LABEL)
  btn:SetFullWidth(true)
  btn:SetCallback('OnClick', function() frame:Hide() end)
  frame:AddChild(btn)

  PlaySound(SOUNDKIT.GS_LOGIN)

  return frame
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:Show()
  local g = ns:g()
  if g.v2AnnouncementShown then return end
  g.v2AnnouncementShown = true
  C_Timer.After(2, function() CreateDialog() end)
end

