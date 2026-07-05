--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()
local DS = O.DatabaseSchema

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
local OPTIONS = OPTIONS or L['Options']
local BAR = L['Bar']
local BAR_OPTIONS = BAR .. ' ' .. OPTIONS
local BAR_BACKDROP    = L['Backdrop']
local BAR_EXTRA_BTNS  = L['Extra Buttons']
local QUICK_KEYBIND_MODE = QUICK_KEYBIND_MODE or L['Quick Keybind Mode']
local PROFILES = PROFILES or L['Profiles']
local BARS = L['Toggle Bars']

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
        elseif item.submenu then
          local sub = rootDescription:CreateButton(item.text, function() end)
          local subitems = type(item.submenu) == 'function' and item.submenu() or item.submenu
          for _, si in ipairs(subitems) do
            sub:CreateButton(si.text, si.func)
          end
        elseif item.func then
          rootDescription:CreateButton(item.text, item.func)
        end
      end
    end)
  else
    -- Classic / TBC / Wrath / Cata / MoP
    frame.displayMode = 'MENU'
    frame.initialize = function(self, level, subMenuList)
      if level == 1 then
        for _, item in ipairs(menuList) do
          if item.isSeparator then
            UIDropDownMenu_AddButton({ text = '', disabled = true, notCheckable = true, isTitle = true }, level)
          elseif item.submenu then
            local items = type(item.submenu) == 'function' and item.submenu() or item.submenu
            UIDropDownMenu_AddButton({
              text = item.text, notCheckable = true,
              hasArrow = true, menuList = items,
            }, level)
          else
            UIDropDownMenu_AddButton(item, level)
          end
        end
      elseif level == 2 and subMenuList then
        for _, si in ipairs(subMenuList) do
          UIDropDownMenu_AddButton(si, level)
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

--- @return QuickKeybindModeDialog_ABP_2_0
local function kbDialog() return ns.O.QuickKeybindModeDialog end

--- @return SettingsDialog_ABP_2_0
local function settingsDialog() return ns.O.SettingsDialog end

local function ToggleBarEnabled(barIndex)
  local conf = cns:bar(barIndex)
  -- guard: don't disable the last enabled bar
  if conf.enabled then
    local count = 0
    for i = 1, DS:GetMaxBarCount() do if cns:bar(i).enabled then count = count + 1 end end
    if count <= 1 then return end
  end
  conf.enabled = not conf.enabled
  local BMF = cns:BarsUI():ns().O.BarModuleFactory
  BMF:ApplyBarEnabledState(barIndex)
end

--- @param currentBarIndex Index
--- @return table  list of bar submenu items
local function BuildBarsSubmenu(currentBarIndex)
  local enabledCount = 0
  for i = 1, DS:GetMaxBarCount() do
    if cns:bar(i).enabled then enabledCount = enabledCount + 1 end
  end
  local items = {}
  for i = 1, DS:GetMaxBarCount() do
    local enabled = cns:bar(i).enabled == true
    local isLastEnabled = enabled and enabledCount == 1
    local check = enabled and '|TInterface\\Buttons\\UI-CheckBox-Check:20:20:0:0|t ' or '|TInterface\\Buttons\\UI-CheckBox-Up:20:20:0:0|t '
    local label = BAR .. ' ' .. i
    if i == currentBarIndex then label = label .. ' (Current)' end
    local text = isLastEnabled and (check .. '|cFF808080' .. label .. '|r') or (check .. label)
    tinsert(items, {
      text = text,
      notCheckable = true,
      disabled = isLastEnabled,
      func = function() ToggleBarEnabled(i) end,
    })
  end
  return items
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param barFrame BarFrame_ABP_2_0
function o:Show(barFrame)
  local menu = {
    { text = BAR_OPTIONS,    notCheckable = true, func = function() optDialog():ShowDialog(barFrame.widget.index) end },
    { text = BAR_BACKDROP,   notCheckable = true, func = function() optDialog():ShowDialog(barFrame.widget.index, 'backdrop') end },
    { text = BAR_EXTRA_BTNS, notCheckable = true, func = function() optDialog():ShowDialog(barFrame.widget.index, 'extrabuttons') end },
    { isSeparator = true },
    { text = QUICK_KEYBIND_MODE, notCheckable = true, func = function() kbDialog():Open() end },
    { text = PROFILES, notCheckable = true, func = function() settingsDialog():OpenProfiles() end },
    { text = BARS, submenu = function() return BuildBarsSubmenu(barFrame.widget.index) end },
  }
  ShowMenu(menu, GetDropdownFrame(), 'cursor', -10, -15)
end
