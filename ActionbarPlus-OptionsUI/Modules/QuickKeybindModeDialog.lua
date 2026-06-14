--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'QuickKeybindModeDialog'
local globalVarName = 'ABP_QUICK_KEYBIND_DIALOG'
--- @class QuickKeybindModeDialog_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
o.perChar = false
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Constants
-------------------------------------------------------------------------------]]
local DIALOG_WIDTH  = 420
local DIALOG_HEIGHT = 200
local DIALOG_TITLE  = 'Quick Keybind Mode'

local CONFIRM_GENERAL_BINDINGS = 'ABP_CONFIRM_GENERAL_BINDINGS'
StaticPopupDialogs[CONFIRM_GENERAL_BINDINGS] = {
  text = 'Really switch to general key bindings?\nAll key bindings specific to this character will be permanently deleted.',
  button1 = 'Okay',
  button2 = 'Cancel',
  OnAccept = function()
    o.perChar = false
    if o.chk then o.chk:SetValue(false) end
  end,
  OnCancel = function()
    -- revert checkbox — find it via the dialog's stored ref
    if o.chk then o.chk:SetValue(true) end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

local TEXT_INSTRUCTIONS =
  'You are in Quick Keybind Mode. Mouse over a button and press the\n' ..
  'desired key to set the binding for that button.'
local TEXT_CANCEL_NOTICE =
  '\nCanceling will remove you from Quick Keybind Mode.'

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- @param frame AceGUIWidget
local function AddBodyText(frame)
  local AceGUI = cns:AceGUI()

  --- @type AceGUILabel
  local desc = AceGUI:Create('Label')
  desc:SetText('\n' .. TEXT_INSTRUCTIONS)
  desc:SetFullWidth(true)
  desc.label:SetJustifyH('CENTER')
  frame:AddChild(desc)

  --- @type AceGUILabel
  local notice = AceGUI:Create('Label')
  notice:SetText(TEXT_CANCEL_NOTICE)
  notice:SetFullWidth(true)
  notice.label:SetJustifyH('CENTER')
  frame:AddChild(notice)

end

--- @param frame AceGUIWidget
local function AddCheckbox(frame)
  local AceGUI = cns:AceGUI()

  --- @type AceGUISimpleGroup
  local grp = AceGUI:Create('SimpleGroup')
  grp:SetFullWidth(true)
  grp:SetLayout('Table')
  grp:SetUserData('table', { columns = { 0.2, 0.6, 0.2 } })
  frame:AddChild(grp)

  grp:AddChild(AceGUI:Create('Label'))  -- left spacer

  --- @type AceGUICheckBox
  local chk = AceGUI:Create('CheckBox')
  chk:SetLabel('Character Specific Key Bindings')
  chk:SetFullWidth(true)
  chk:SetValue(o.perChar)
  chk:SetCallback('OnValueChanged', function(widget, evt, val)
    if not val and o.perChar then
      -- switching from char-specific to general — confirm first
      chk:SetValue(true)  -- revert visually until confirmed
      StaticPopup_Show(CONFIRM_GENERAL_BINDINGS)
      return
    end
    o.perChar = val
  end)
  grp:AddChild(chk)
  o.chk = chk  -- store ref for StaticPopup OnCancel

  grp:AddChild(AceGUI:Create('Label'))  -- right spacer

  return chk
end

--- @param frame AceGUIWindow
--- @param chkCharacterSpecific AceGUICheckBox
local function AddButtons(frame, chkCharacterSpecific)
  local AceGUI = cns:AceGUI()

  --- @type AceGUISimpleGroup
  local btnGroup = AceGUI:Create('SimpleGroup')
  btnGroup:SetFullWidth(true)
  btnGroup:SetLayout('Table')
  btnGroup:SetUserData('table', {
    columns = { 0.48, 0.04, 0.48 },
    alignH  = 'center',
    alignV  = 'middle',
  })
  frame:AddChild(btnGroup)

  local btnOkay = AceGUI:Create('Button')
  btnOkay:SetText('Okay')
  btnOkay:SetFullWidth(true)
  btnOkay:SetCallback('OnClick', function()
    o:OnOkayClicked()
  end)
  btnGroup:AddChild(btnOkay)
  btnGroup:AddChild(AceGUI:Create('Label'))  -- spacer

  local btnCancel = AceGUI:Create('Button')
  btnCancel:SetText('Cancel')
  btnCancel:SetFullWidth(true)
  btnCancel:SetCallback('OnClick', function()
    o:OnCancelClicked()
  end)
  btnGroup:AddChild(btnCancel)

  btnGroup.frame:ClearAllPoints()
  btnGroup.frame:SetPoint('BOTTOM', frame.frame, 'BOTTOM', 0, 20)
  btnGroup.frame:SetWidth(DIALOG_WIDTH - 100)

  local checkboxG = chkCharacterSpecific.parent.frame
  checkboxG:ClearAllPoints()
  checkboxG:SetPoint('BOTTOM', btnGroup.frame, 'TOP', 0, 10)
end

--- @return AceGUIWindow
local function CreateDialogFrame()
  local AceGUI = cns:AceGUI()

  --- @type AceGUIWindow
  local frame = AceGUI:Create('Window'); _G[globalVarName] = frame.frame
  frame:SetTitle(DIALOG_TITLE)
  frame:SetWidth(DIALOG_WIDTH)
  frame:SetHeight(DIALOG_HEIGHT)
  frame:EnableResize(false)
  frame:SetLayout('Flow')

  -- This is the 'X' on Top-Right
  frame:SetCallback('OnClose', function(widget)
    o:OnFrameClose()
  end)

  AddBodyText(frame)
  --- @type AceGUICheckBox
  local chk = AddCheckbox(frame)
  AddButtons(frame, chk)

  tinsert(UISpecialFrames, globalVarName)

  return frame
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @type AceGUIWidget
local dialogFrame
--- @type 'okay'|'cancel'|'x'|nil
local closeReason

--- Open (or show) the Quick Keybind Mode dialog
function o:Open()
  if InCombatLockdown() then return end
  closeReason = nil
  if not dialogFrame then
    dialogFrame = CreateDialogFrame()
    dialogFrame.frame:SetClampedToScreen(true)
  end
  local f = dialogFrame.frame
  f:ClearAllPoints()
  f:SetPoint('CENTER', UIParent, 'CENTER', 0, 100)
  if InCombatLockdown() then return end
  o.perChar = GetCurrentBindingSet() == 2
  if o.chk then o.chk:SetValue(o.perChar) end
  dialogFrame:Show()
  self:SendMessage(ns:msg('OnQuickKeybindMode'), true)   -- Open
end

function o:OnFrameClose()
  closeReason = closeReason or 'x'

  if closeReason == 'okay' then
    self:SendMessage(ns:msg('OnQuickKeybindModeCommit'), o.perChar)
    closeReason = nil
    return
  end

  closeReason = nil
  self:SendMessage(ns:msg('OnQuickKeybindMode'), false)
end

function o:OnCancelClicked()
  closeReason = 'cancel'
  if not dialogFrame or not dialogFrame.frame:IsShown() then return end
  dialogFrame:Hide()
end

function o:OnOkayClicked()
  closeReason = 'okay'
  if not dialogFrame or not dialogFrame.frame:IsShown() then return end
  dialogFrame:Hide()
end

--- Invalidate cached frame (call after layout changes, before next Open)
function o:Reset()
  if dialogFrame then
    dialogFrame:Hide()
    dialogFrame = nil
    _G[globalVarName] = nil
  end
end
