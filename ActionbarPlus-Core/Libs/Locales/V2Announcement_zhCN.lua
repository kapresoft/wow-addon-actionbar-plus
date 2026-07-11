if GetLocale() ~= 'zhCN' then return end

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

ABP_V2_ANNOUNCEMENT = [[|cffffd700ActionbarPlus V2 来了！|r

欢迎使用新一代 ActionbarPlus。V2 从头进行了重构，拥有更简洁的架构、更多功能以及更好的性能。

|cffffff00V2 组件（请保持启用）：|r
  • ActionbarPlus-Core
  • ActionbarPlus-BarsUI
  • ActionbarPlus-OptionsUI

|cffffff00可选：|r
  • ActionbarPlus-Masque — 用于按钮皮肤（需要 Masque 插件）

|cffffff00关于 V1：|r
ActionbarPlus（V1）目前仍与 V2 一起安装并处于启用状态。V1 现已冻结——将不再获得新功能或错误修复，未来的更新中会将其停用。

建议你在 V2 中配置动作条，并在方便时通过插件菜单禁用 V1（|cffaaaaaa ActionbarPlus|r）。

感谢你一直以来的支持！
— kapresoft]]
