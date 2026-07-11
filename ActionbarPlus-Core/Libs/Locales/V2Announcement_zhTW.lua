if GetLocale() ~= 'zhTW' then return end

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

ABP_V2_ANNOUNCEMENT = [[|cffffd700ActionbarPlus V2 來了！|r

歡迎使用新一代 ActionbarPlus。V2 從頭進行了重構，擁有更簡潔的架構、更多功能以及更好的效能。

|cffffff00V2 元件（請保持啟用）：|r
  • ActionbarPlus-Core
  • ActionbarPlus-BarsUI
  • ActionbarPlus-OptionsUI

|cffffff00選用：|r
  • ActionbarPlus-Masque — 用於按鈕外觀（需要 Masque 外掛）

|cffffff00關於 V1：|r
ActionbarPlus（V1）目前仍與 V2 一起安裝並處於啟用狀態。V1 現已凍結——將不再取得新功能或錯誤修正，未來的更新中會將其停用。

建議你在 V2 中設定動作條，並在方便時透過外掛選單停用 V1（|cffaaaaaa ActionbarPlus|r）。

感謝你一直以來的支持！
— kapresoft]]
