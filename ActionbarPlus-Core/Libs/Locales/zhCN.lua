--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "zhCN", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = '插件'
L['Alpha']                 = '透明度'
L['Backdrop']              = '背景'
L['Background Color']      = '背景颜色'
L['Bar']                   = '动作条'
L['Bars']                  = '动作条'
L['Border Color']          = '边框颜色'
L['Bound']                 = '已绑定'
L['Button']                = '按钮'
L['Button Size']           = '按钮大小'
L['Columns']               = '列数'
L['Border Size']           = '边框粗细'
L['Enabled']               = '已启用'
L['General']               = '常规'
L['Keybind']               = '快捷键'
L['Masque Settings']       = 'Masque 设置'
L['Not Bound']             = '未绑定'
L['Options']               = '选项'
L['Padding']               = '内边距'
L['Reset']                 = '重置'
L['Rows']                  = '行数'
L['Settings']              = '设置'
L['Show Empty Buttons']    = '显示空按钮'
L['Drag Handle Location']  = '拖动把手位置'
L['Thickness']             = '粗细'
L['Extra Buttons']         = '额外按钮'
L['Button Count']          = '按钮数量'
L['Toggle Bars']                 = '切换动作条'
L['Reset to Default']            = '恢复默认设置'
L['Copy Backdrop from Bar']      = '从其他动作条复制背景'
L['Apply Backdrop to All Bars']  = '将背景应用到所有动作条'
L['Right-click for more options.'] = '右键点击以查看更多选项。'
L['Mouseover Glow']         = '鼠标悬停发光'
L['Mouseover Glow Tooltip'] = '启用后，鼠标悬停在按钮上时按钮会发光。'
L['Gap']                   = '间距'
L['Gap Tooltip']           = '动作条边框与额外按钮行之间的间距。'
L['Global']                = '全局'
L['Character Specific Frame Positions'] = '角色专属位置'
L['Character Specific Frame Positions Tooltip'] = '启用后，每个角色会保存自己的动作条位置。禁用后，使用该配置的所有角色将共享相同的位置。'
L['Anchor']                = '锚点'
L['Top']                   = '顶部'
L['Top Left']              = '左上'
L['Top Right']             = '右上'
L['Bottom']                = '底部'
L['Bottom Left']           = '左下'
L['Bottom Right']          = '右下'
L['Stone']                 = '石头'
L['Theme']                 = '主题'
L['Version']               = '版本'

-- Theme Names
L['None']                  = '无'
L['Minimalist']            = '极简'
L['Modern Dark']           = '现代暗色'
L['Abyss']                 = '深渊'
L['Glow']                  = '发光'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = '黑暗骑士'
L['Modern']                = '现代'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = '将鼠标悬停在所选位置的把手上以拖动动作条。'
L['At least one bar must remain enabled.']                       = '必须至少保留一个动作条处于启用状态。'
L['Toggle bar visibility from the right-click context menu.']    = '通过右键菜单切换动作条的可见性。'
L['Profiles']                                           = '配置'
L['Extra Buttons Tooltip'] = '放置在动作条边框之外的一行按钮。适合放置消耗品、饰品或临时需要的物品，使其靠近主动作条但又与之分开。'
L['Reset to default theme settings.']                   = '重置为默认主题设置。'
L['Open General Settings for all bars and profiles.']   = '打开所有动作条和配置的常规设置。'
L['Open Backdrop Settings for the current bar.']        = '打开当前动作条的背景设置。'

L['Right-Click'] = '右键点击'
L['Left-Click and Drag'] = '左键点击并拖动'
L['to show options menu'] = '以显示选项菜单'
L['bar frame or drag frame'] = '动作条边框或拖动边框'
L['to move the bar'] = '以移动动作条'

L['Really switch to general key bindings?'] = '确定要切换到通用快捷键吗？'
L['All key bindings specific to this character will be permanently deleted.'] = '此角色专属的所有快捷键都将被永久删除。'

L['ESC'] = 'ESC'
L['press the desired key'] = '按下想要的按键'
L['You are in Quick Keybind Mode']                      = '您正处于快捷键快速绑定模式'
L['Mouse over a button and %s to set its binding']      = '将鼠标悬停在按钮上并%s以设置其绑定'
L['or press %s to clear it']                            = '或按 %s 清除绑定'
L['Canceling will remove you from Quick Keybind Mode']  = '取消将使您退出快捷键快速绑定模式'
