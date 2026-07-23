--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local BO = ns.O
local bd = BO.Backdrops

local cns, O = ns:cns()
local au = O.ActionUtil
local DS = O.DatabaseSchema

--- @param name string
--- @param parent Frame
--- @param encodedID number
--- @return Button_ABP_2_0_X
local function CreateButton(name, parent, encodedID)
  return CreateFrame("CheckButton", name, parent, ns.buttonTemplate, encodedID)
end

--[[-----------------------------------------------------------------------------
Module::GridLayout
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = ns.M.GridLayout()
--- @class GridLayout_ABP_2_0 : BarLayout_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function S:SupportsBackdrop() return true end

--- @return boolean
function S:SupportsHorizontalSpacing() return true end

--- @return boolean
function S:SupportsVerticalSpacing() return true end

--- @param ui BarUIConfig_ABP_2_0
--- @return number
function S:GetButtonCount(ui) return ui.layoutConfig.grid.colSize * ui.layoutConfig.grid.rowSize end

--- Grid drives its button count from separate colSize/rowSize sliders (each with
--- its own max in DatabaseSchema), so this is not used to bound a UI slider today --
--- provided only for interface completeness.
--- @return number
function S:GetMaxButtonCount() return 36 * 18 end

--- Adds Grid's own controls (Rows, Columns) to the Layout tab, beyond the shared
--- spacing sliders BarOptionsDialog.lua already builds generically.
--- @param tab AceGUITabGroup
--- @param ui BarUIConfig_ABP_2_0
--- @param onChanged fun()
function S:ApplyOptionsUI(tab, ui, onChanged)
  local AceGUI = cns:AceGUI()
  local L = cns:GetLocale()
  local gridConf = ui.layoutConfig.grid

  --- @type AceGUISlider
  local slRows = AceGUI:Create('Slider')
  slRows:SetLabel(L['Rows'])
  slRows:SetRelativeWidth(0.5)
  slRows:SetSliderValues(1, DS:GetMaxRowSize(), 1)
  slRows:SetValue(gridConf.rowSize)
  slRows:SetCallback('OnValueChanged', function(_, _, val)
    gridConf.rowSize = val
    onChanged()
  end)
  tab:AddChild(slRows)

  --- @type AceGUISlider
  local slCols = AceGUI:Create('Slider')
  slCols:SetLabel(L['Columns'])
  slCols:SetRelativeWidth(0.5)
  slCols:SetSliderValues(1, DS:GetMaxColSize(), 1)
  slCols:SetValue(gridConf.colSize)
  slCols:SetCallback('OnValueChanged', function(_, _, val)
    gridConf.colSize = val
    onChanged()
  end)
  tab:AddChild(slCols)
end

--- Sizes/positions the drag handle beside the first (TOPLEFT) or last-in-row-1 (TOPRIGHT) button.
--- @param frame BarFrame_ABP_2_0
--- @param dragAnchor string 'TOPLEFT' | 'TOPRIGHT'
--- @param thickness number
function S:ApplyDragHandle(frame, dragAnchor, thickness)
  local w = frame.widget
  local btn1 = w.buttons and w.buttons[1]
  if not btn1 then return end

  local handle = w:GetOrCreateDragHandle()
  handle:ClearAllPoints()
  local btnSize   = btn1:GetHeight()
  local heightPad = 6
  handle:SetHeight(btnSize - heightPad)
  handle:SetWidth(thickness)

  if dragAnchor == 'TOPRIGHT' then
    local ui = w:conf().ui
    local lastBtn1 = w.buttons[ui.layoutConfig.grid.colSize or 1]
    handle:SetPoint('LEFT', lastBtn1, 'RIGHT', 3, 0)
    handle:SetPoint('CENTER', lastBtn1, 'CENTER', thickness, 0)
  else
    handle:SetPoint('RIGHT', btn1, 'LEFT', -3, 0)
    handle:SetPoint('CENTER', btn1, 'CENTER', -thickness, 0)
  end
end

--- Applies the extra button row config — creates buttons lazily, repositions/resizes each call.
--- Buttons wrap into multiple rows when total count exceeds what fits within the bar's pixel width.
--- Row 1 is always closest to the bar; overflow rows grow away from it.
--- @param frame BarFrame_ABP_2_0
function S:ApplyExtraButtons(frame)
  local w = frame.widget
  local uic = w:conf().ui
  local eb  = uic.extraButton
  if not eb or not eb.enabled then
    if w.extraButtons then
      for _, btn in ipairs(w.extraButtons) do btn:Hide() end
    end
    return
  end

  local anchor   = eb.anchor  or 'TOPRIGHT'
  local size     = eb.size    or 30
  local cols     = eb.count or 1
  w.extraButtons = w.extraButtons or {}

  -- create any missing buttons
  for i = 1, cols do
    if not w.extraButtons[i] then
      local encodedID = au.encodeBarID(w.index, 900 + i)
      local btnName = ('ABP_2_0_F%sExtraBtn%s'):format(w.index, i)
      local btn = CreateButton(btnName, w.frame, encodedID)
      btn:SetClampedToScreen(true)
      btn.widget.isExtraButton = true
      w.extraButtons[i] = btn
    end
  end

  -- hide any buttons beyond the current count
  for i = cols + 1, #w.extraButtons do
    w.extraButtons[i]:Hide()
  end

  local isTop    = anchor == 'TOP' or anchor == 'TOPLEFT' or anchor == 'TOPRIGHT'
  local isLeft   = anchor == 'TOPLEFT'  or anchor == 'BOTTOMLEFT'
  local isRight  = anchor == 'TOPRIGHT' or anchor == 'BOTTOMRIGHT'
  local isNoneTheme = uic.backdrop.theme == 'none'
  -- theme 'none' has no border padding, so it needs a larger base gap to avoid
  -- extra buttons crowding the main bar
  local baseExtraButtonGap = isNoneTheme and 4 or 2
  local spacing  = 2
  local mainCols = uic.layoutConfig.grid.colSize or 1
  local mainRows = uic.layoutConfig.grid.rowSize or 1
  local mainSize = uic.button.size or 36
  local mainSpacing = uic.button.spacing.horizontal or 3
  -- wrap extra buttons when their row would exceed the pixel width of the main button grid
  local gridPixelWidth = mainCols * mainSize + (mainCols - 1) * mainSpacing
  local wrapCols = math.floor((gridPixelWidth + spacing) / (size + spacing))
  -- for TOP*: last button of row 1; for BOTTOM*: last button of the last row
  local lastBtnTop    = w.buttons and w.buttons[mainCols]
  local lastBtnBottom = w.buttons and w.buttons[mainCols * mainRows]
  local lastBtn1 = isTop and lastBtnTop or lastBtnBottom
  -- for BOTTOM* left anchor: first button of the last row
  local firstBtnBottom = w.buttons and w.buttons[mainCols * (mainRows - 1) + 1]

  local borderDef = bd.BORDER_DEFS[uic.backdrop.theme] or bd.DEFAULT_BACKDROP
  local borderPad = isNoneTheme
                    and 0
                    or (uic.backdrop.padding or borderDef.padding or 0) + (borderDef.basePadding or 8)
  local barGap = baseExtraButtonGap + borderPad + (eb.gap or 0)
  local gap = isTop and barGap or -barGap

  -- per-row Y step: rows grow away from the bar (up for TOP*, down for BOTTOM*)
  local rowStep = isTop and (size + spacing) or -(size + spacing)

  local showEmpty = eb.showEmptyButtons ~= false
  for i = 1, cols do
    local btn = w.extraButtons[i]
    btn:SetSize(size, size)
    cns:IfMasque(function(abpMasque) abpMasque:ReSkin(btn) end)
    btn:ClearAllPoints()
    btn:Show()
    if btn.widget then btn.widget:UpdateEmptyState(showEmpty) end
  end

  -- relative point on the grid button to attach to (top edge for TOP*, bottom edge for BOTTOM*)
  local gridRelPoint  = isTop and 'TOPLEFT'  or 'BOTTOMLEFT'
  local gridRelPointR = isTop and 'TOPRIGHT' or 'BOTTOMRIGHT'
  -- point on the extra button that meets the grid button edge
  local extraRelPoint  = isTop and 'BOTTOMLEFT'  or 'TOPLEFT'
  local extraRelPointR = isTop and 'BOTTOMRIGHT' or 'TOPRIGHT'

  local firstBtn = isTop and (w.buttons and w.buttons[1]) or firstBtnBottom

  -- layout index → (extraRow 1-based, col within that row 1-based)
  -- extraRow 1 is always closest to the bar; overflow rows grow outward
  local function extraRowCol(i)
    return math.ceil(i / wrapCols), ((i - 1) % wrapCols) + 1
  end

  if isLeft and firstBtn then
    for i = 1, cols do
      local eRow, eCol = extraRowCol(i)
      local offY = gap + (eRow - 1) * rowStep
      if eCol == 1 then
        w.extraButtons[i]:SetPoint(extraRelPoint, firstBtn, gridRelPoint, 1, offY)
      else
        w.extraButtons[i]:SetPoint('LEFT', w.extraButtons[i - 1], 'RIGHT', spacing, 0)
      end
    end
  elseif isRight and lastBtn1 then
    -- lay out right-to-left within each row so the rightmost button anchors to the bar corner
    for eRow = 1, math.ceil(cols / wrapCols) do
      local rowStart = (eRow - 1) * wrapCols + 1
      local rowEnd   = math.min(eRow * wrapCols, cols)
      local offY = gap + (eRow - 1) * rowStep
      -- rightmost button in this extra-row anchors to the bar
      w.extraButtons[rowEnd]:SetPoint(extraRelPointR, lastBtn1, gridRelPointR, 0, offY)
      -- chain remaining buttons leftward
      for i = rowEnd - 1, rowStart, -1 do
        w.extraButtons[i]:SetPoint('RIGHT', w.extraButtons[i + 1], 'LEFT', -spacing, 0)
      end
    end
  else
    -- TOP / BOTTOM centered: anchor Y to grid button edge (uniform gap), center X over the frame.
    -- Use actual frame pixel width so we don't need to recompute padLeft or spacing variants.
    local centerRefBtn = isTop and (w.buttons and w.buttons[1]) or firstBtnBottom
    local frameWidth   = w.frame:GetWidth()
    local rowCount     = math.ceil(cols / wrapCols)
    for eRow = 1, rowCount do
      local rowStart = (eRow - 1) * wrapCols + 1
      local rowEnd   = math.min(eRow * wrapCols, cols)
      local rowCols  = rowEnd - rowStart + 1
      local totalW   = rowCols * size + (rowCols - 1) * spacing
      local offY     = gap + (eRow - 1) * rowStep
      -- derive padLeft at runtime so we don't have to recompute theme padding math
      -- offX = frameCenter - rowCenter - padLeft, where padLeft = btnLeft - frameLeft
      local btnLeft   = centerRefBtn:GetLeft()
      local frameLeft = w.frame:GetLeft()
      local padLeft   = (btnLeft and frameLeft) and (btnLeft - frameLeft) or 0
      local offX      = (frameWidth / 2) - (totalW / 2) - padLeft
      w.extraButtons[rowStart]:SetPoint(extraRelPoint, centerRefBtn, gridRelPoint, offX, offY)
      for i = rowStart + 1, rowEnd do
        w.extraButtons[i]:SetPoint('LEFT', w.extraButtons[i - 1], 'RIGHT', spacing, 0)
      end
    end
  end
end

--- @param frame BarFrame_ABP_2_0
--- @param ui BarUIConfig_ABP_2_0
function S:Apply(frame, ui)
  local cols = ui.layoutConfig.grid.colSize
  local rows = ui.layoutConfig.grid.rowSize
  local size = ui.button.size
  local spacing = ui.button.spacing
  local isNoneTheme = ui.backdrop.theme == 'none'
  local borderDef = bd.BORDER_DEFS[ui.backdrop.theme] or bd.DEFAULT_BACKDROP
  -- theme 'none' has no visible border/background, so it should sit flush with no
  -- padding, regardless of the saved profile padding value (which stays untouched
  -- for when the user switches back to a bordered theme)
  local pad = isNoneTheme and 0 or (ui.backdrop.padding or borderDef.padding)
  local BASE_UI_PADDING = isNoneTheme and 0 or (borderDef.basePadding or 8)
  local borderPadBottom = isNoneTheme and 0 or (borderDef.borderPadBottom or 0)

  local padLeft   = pad + BASE_UI_PADDING
  local padRight  = pad + BASE_UI_PADDING
  local padTop    = pad + BASE_UI_PADDING
  local padBottom = pad + BASE_UI_PADDING + borderPadBottom

  local totalWidth  = padLeft + size*cols + spacing.horizontal*(cols - 1) + padRight
  local totalHeight = padTop  + size*rows + spacing.vertical*(rows - 1)   + padBottom
  frame:SetSize(totalWidth, totalHeight)

  local hotKeyFontSize = math.max(8, math.floor(size * 12 / 40))
  local hotKeyOffsetX  = math.floor(size * 5 / 40)
  local hotKeyOffsetY  = math.floor(size * 7 / 40)
  local startX = math.floor(padLeft + 0.5)
  local startY = -math.floor(padTop + 0.5)
  local visible = cols * rows

  for i, _btn in ipairs(frame.widget.buttons) do
    --- @type Button_ABP_2_0_X
    local btn = _btn

    btn:ClearAllPoints()
    if i <= visible then
      btn:SetSize(size, size)
      cns:IfMasque(function(abpMasque) abpMasque:ReSkin(btn) end)
      btn.HotKey:SetFont(btn.HotKey:GetFont(), hotKeyFontSize, 'OUTLINE')
      btn.HotKey:ClearAllPoints()
      btn.HotKey:SetPoint('TOPRIGHT', btn, 'TOPRIGHT', -hotKeyOffsetX, -hotKeyOffsetY)
      local idx = i - 1
      local c = (idx % cols) + 1
      local r = math.floor(idx / cols) + 1
      local x = startX + (size + spacing.horizontal) * (c - 1)
      local y = startY - (size + spacing.vertical)   * (r - 1)
      btn:SetPoint('TOPLEFT', frame, 'TOPLEFT', x, y)
      btn:Show()
      btn.widget:UpdateEmptyState(ui.showEmptyButtons)
    else
      btn:Hide()
    end
  end
end
