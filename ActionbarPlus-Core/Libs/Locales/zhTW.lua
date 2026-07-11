--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "zhTW", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = '外掛'
L['Alpha']                 = '透明度'
L['Backdrop']              = '背景'
L['Background Color']      = '背景顏色'
L['Bar']                   = '動作條'
L['Bars']                  = '動作條'
L['Border Color']          = '邊框顏色'
L['Bound']                 = '已綁定'
L['Button']                = '按鈕'
L['Button Size']           = '按鈕大小'
L['Columns']               = '欄數'
L['Border Size']           = '邊框粗細'
L['Enabled']               = '已啟用'
L['General']               = '一般'
L['Keybind']               = '快捷鍵'
L['Masque Settings']       = 'Masque 設定'
L['Not Bound']             = '未綁定'
L['Options']               = '選項'
L['Padding']               = '內邊距'
L['Reset']                 = '重設'
L['Rows']                  = '列數'
L['Settings']              = '設定'
L['Show Empty Buttons']    = '顯示空按鈕'
L['Drag Handle Location']  = '拖曳把手位置'
L['Thickness']             = '粗細'
L['Extra Buttons']         = '額外按鈕'
L['Button Count']          = '按鈕數量'
L['Toggle Bars']                 = '切換動作條'
L['Reset to Default']            = '恢復預設值'
L['Copy Backdrop from Bar']      = '從其他動作條複製背景'
L['Apply Backdrop to All Bars']  = '將背景套用到所有動作條'
L['Right-click for more options.'] = '按右鍵以查看更多選項。'
L['Mouseover Glow']         = '滑鼠懸停發光'
L['Mouseover Glow Tooltip'] = '啟用後，滑鼠懸停在按鈕上時按鈕會發光。'
L['Gap']                   = '間距'
L['Gap Tooltip']           = '動作條邊框與額外按鈕列之間的間距。'
L['Global']                = '全域'
L['Character Specific Frame Positions'] = '角色專屬位置'
L['Character Specific Frame Positions Tooltip'] = '啟用後，每個角色會儲存自己的動作條位置。停用後，使用該設定檔的所有角色將共用相同的位置。'
L['Anchor']                = '錨點'
L['Top']                   = '頂部'
L['Top Left']              = '左上'
L['Top Right']             = '右上'
L['Bottom']                = '底部'
L['Bottom Left']           = '左下'
L['Bottom Right']          = '右下'
L['Stone']                 = '石頭'
L['Theme']                 = '主題'
L['Version']               = '版本'

-- Theme Names
L['None']                  = '無'
L['Minimalist']            = '極簡'
L['Modern Dark']           = '現代暗色'
L['Abyss']                 = '深淵'
L['Glow']                  = '發光'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = '黑暗騎士'
L['Modern']                = '現代'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = '將滑鼠懸停在所選位置的把手上以拖曳動作條。'
L['At least one bar must remain enabled.']                       = '必須至少保留一個動作條處於啟用狀態。'
L['Toggle bar visibility from the right-click context menu.']    = '透過右鍵選單切換動作條的顯示狀態。'
L['Profiles']                                           = '設定檔'
L['Extra Buttons Tooltip'] = '放置在動作條邊框之外的一列按鈕。適合放置消耗品、飾品或臨時需要的物品，使其靠近主動作條但又與之分開。'
L['Reset to default theme settings.']                   = '重設為預設主題設定。'
L['Open General Settings for all bars and profiles.']   = '開啟所有動作條和設定檔的一般設定。'
L['Open Backdrop Settings for the current bar.']        = '開啟目前動作條的背景設定。'

L['Right-Click'] = '按右鍵'
L['Left-Click and Drag'] = '按左鍵並拖曳'
L['to show options menu'] = '以顯示選項選單'
L['bar frame or drag frame'] = '動作條邊框或拖曳邊框'
L['to move the bar'] = '以移動動作條'

L['Really switch to general key bindings?'] = '確定要切換到通用快捷鍵嗎？'
L['All key bindings specific to this character will be permanently deleted.'] = '此角色專屬的所有快捷鍵都將被永久刪除。'

L['ESC'] = 'ESC'
L['press the desired key'] = '按下想要的按鍵'
L['You are in Quick Keybind Mode']                      = '您目前處於快捷鍵快速綁定模式'
L['Mouse over a button and %s to set its binding']      = '將滑鼠懸停在按鈕上並%s以設定其綁定'
L['or press %s to clear it']                            = '或按下 %s 清除綁定'
L['Canceling will remove you from Quick Keybind Mode']  = '取消將使您離開快捷鍵快速綁定模式'
