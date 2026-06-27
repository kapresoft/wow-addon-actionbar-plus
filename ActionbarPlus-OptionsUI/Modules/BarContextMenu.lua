--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()

--- Lazily create a shared dropdown frame
--- @type UIDropDownMenuFrame
local dropdownFrame

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarContextMenu'
--- @class BarContextMenu_ABP_2_0
local o = {}; ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GENERAL = GENERAL or L['General']
local SETTINGS = SETTINGS or L['Settings']
local OPTIONS = OPTIONS or L['Options']
local QUICK_KEYBIND_MODE = QUICK_KEYBIND_MODE or L['Quick Keybind Mode']
local BACKDROP = BACKDROP or L['Backdrop']

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- One impl for all WoW versions
--- @param menuList table
--- @param frame UIDropDownMenuFrame
--- @param anchor string
--- @param x number
--- @param y number
local function ShowMenu(menuList, frame, anchor, x, y)
  if MenuUtil then
    -- Retail (Dragonflight+)
    MenuUtil.CreateContextMenu(frame, function(owner, rootDescription)
      for _, item in ipairs(menuList) do
        if item.isTitle then
          rootDescription:CreateTitle(item.text)
        elseif item.isSeparator then
          rootDescription:CreateDivider()
        elseif item.func then
          rootDescription:CreateButton(item.text, item.func)
        end
      end
    end)
  else
    -- Classic / TBC / Wrath / Cata / MoP
    frame.displayMode = 'MENU'
    frame.initialize = function(self, level)
      if level == 1 then
        for _, item in ipairs(menuList) do
          UIDropDownMenu_AddButton(item, level)
        end
      end
    end
    ToggleDropDownMenu(1, nil, frame, anchor or 'cursor', x or -10, y or -15)
  end
end

--- @return UIDropDownMenuFrame
local function GetDropdownFrame()
  if not dropdownFrame then
    dropdownFrame = CreateFrame('Frame', 'ABP_BarContextMenuFrame',
          ABP_Parent_2_0, 'UIDropDownMenuTemplate' --[[@as Template ]])
  end
  return dropdownFrame
end

--- @return BarOptionsDialog_ABP_2_0
local function optDialog() return ns.O.BarOptionsDialog end

--- @return BarBackdropDialog_ABP_2_0
local function backdropDialog() return ns.O.BarBackdropDialog end

--- @return QuickKeybindModeDialog_ABP_2_0
local function kbDialog() return ns.O.QuickKeybindModeDialog end

--- @return SettingsDialog_ABP_2_0
local function settingsDialog() return ns.O.SettingsDialog end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param barFrame BarFrame_ABP_2_0
function o:Show(barFrame)
  local menu = {
    { text = OPTIONS, notCheckable = true, func = function() optDialog():ShowDialog(barFrame.widget.index) end },
    { text = BACKDROP, notCheckable = true, func = function() backdropDialog():ShowDialog(barFrame.widget.index) end },
    { text = QUICK_KEYBIND_MODE, notCheckable = true, func = function() kbDialog():Open() end },
    { text = ('%s %s'):format(GENERAL, SETTINGS), notCheckable = true, func = function() settingsDialog():Open() end },
  }
  ShowMenu(menu, GetDropdownFrame(), 'cursor', -10, -15)
end
