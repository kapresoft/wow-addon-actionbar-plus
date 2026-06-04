--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local L = cns:GetLocale()

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
local QUICK_KEYBIND_MODE = QUICK_KEYBIND_MODE or L['Quick Keybind Mode']

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- One impl for all WoW versions
--- @param menuList table
--- @param frame Frame
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

--- Lazily create a shared dropdown frame
local dropdownFrame
local function GetDropdownFrame()
  if not dropdownFrame then
    dropdownFrame = CreateFrame('Frame', 'ABP_BarContextMenuFrame', UIParent, 'UIDropDownMenuTemplate')
  end
  return dropdownFrame
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param barFrame BarFrame_ABP_2_0
function o:Show(barFrame)
  local menuTitle = 'Bar #' .. barFrame.widget.index
  local menu = {
    { text = menuTitle, isTitle = true, notCheckable = true },
    { text = ' ', notClickable = true, notCheckable = true },
    { text = QUICK_KEYBIND_MODE, notCheckable = true, func = function()
        ns.O.QuickKeybindModeDialog:Open()
      end
    },
    { text = 'Formation', notCheckable = true, func = function()
        t('Show', 'Formation clicked')
        -- todo: enter edit mode
      end
    },
  }
  ShowMenu(menu, GetDropdownFrame(), 'cursor', -10, -15)
end
