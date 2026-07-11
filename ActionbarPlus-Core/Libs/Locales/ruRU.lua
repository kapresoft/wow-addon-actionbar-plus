--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "ruRU", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = 'Аддоны'
L['Alpha']                 = 'Прозрачность'
L['Backdrop']              = 'Фон'
L['Background Color']      = 'Цвет фона'
L['Bar']                   = 'Панель'
L['Bars']                  = 'Панели'
L['Border Color']          = 'Цвет рамки'
L['Bound']                 = 'Назначено'
L['Button']                = 'Кнопка'
L['Button Size']           = 'Размер кнопки'
L['Columns']               = 'Столбцы'
L['Border Size']           = 'Толщина рамки'
L['Enabled']               = 'Включено'
L['General']               = 'Общее'
L['Keybind']               = 'Привязка клавиш'
L['Masque Settings']       = 'Настройки Masque'
L['Not Bound']             = 'Не назначено'
L['Options']               = 'Настройки'
L['Padding']               = 'Отступ'
L['Reset']                 = 'Сбросить'
L['Rows']                  = 'Строки'
L['Settings']              = 'Настройки'
L['Show Empty Buttons']    = 'Показывать пустые кнопки'
L['Drag Handle Location']  = 'Расположение ручки перетаскивания'
L['Thickness']             = 'Толщина'
L['Extra Buttons']         = 'Дополнительные кнопки'
L['Button Count']          = 'Количество кнопок'
L['Toggle Bars']                 = 'Переключить панели'
L['Reset to Default']            = 'Сбросить по умолчанию'
L['Copy Backdrop from Bar']      = 'Скопировать фон с другой панели'
L['Apply Backdrop to All Bars']  = 'Применить фон ко всем панелям'
L['Right-click for more options.'] = 'Нажмите правой кнопкой мыши для дополнительных настроек.'
L['Mouseover Glow']         = 'Свечение при наведении'
L['Mouseover Glow Tooltip'] = 'Если включено, кнопки светятся при наведении курсора мыши.'
L['Gap']                   = 'Отступ'
L['Gap Tooltip']           = 'Расстояние между рамкой панели и рядом дополнительных кнопок.'
L['Global']                = 'Глобально'
L['Character Specific Frame Positions'] = 'Позиции для каждого персонажа'
L['Character Specific Frame Positions Tooltip'] = 'Если включено, каждый персонаж сохраняет своё расположение панелей. Если отключено, позиции панелей общие для всех персонажей, использующих этот профиль.'
L['Anchor']                = 'Привязка'
L['Top']                   = 'Сверху'
L['Top Left']              = 'Сверху слева'
L['Top Right']             = 'Сверху справа'
L['Bottom']                = 'Снизу'
L['Bottom Left']           = 'Снизу слева'
L['Bottom Right']          = 'Снизу справа'
L['Stone']                 = 'Камень'
L['Theme']                 = 'Тема'
L['Version']               = 'Версия'

-- Theme Names
L['None']                  = 'Нет'
L['Minimalist']            = 'Минимализм'
L['Modern Dark']           = 'Современный тёмный'
L['Abyss']                 = 'Бездна'
L['Glow']                  = 'Свечение'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = 'Тёмный рыцарь'
L['Modern']                = 'Современный'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = 'Перетащите панель, наведя курсор на ручку в выбранном месте.'
L['At least one bar must remain enabled.']                       = 'Хотя бы одна панель должна оставаться включённой.'
L['Toggle bar visibility from the right-click context menu.']    = 'Переключайте видимость панели через контекстное меню по правому клику.'
L['Profiles']                                           = 'Профили'
L['Extra Buttons Tooltip'] = 'Один ряд кнопок, расположенный за пределами рамки панели. Полезно для расходников, безделушек или ситуативных предметов, которые нужны под рукой, но отдельно от основной панели.'
L['Reset to default theme settings.']                   = 'Сбросить настройки темы по умолчанию.'
L['Open General Settings for all bars and profiles.']   = 'Открыть общие настройки для всех панелей и профилей.'
L['Open Backdrop Settings for the current bar.']        = 'Открыть настройки фона для текущей панели.'

L['ESC'] = 'ESC'
L['press the desired key'] = 'нажмите нужную клавишу'
L['You are in Quick Keybind Mode']                      = 'Вы находитесь в режиме быстрой привязки клавиш'
L['Mouse over a button and %s to set its binding']      = 'Наведите курсор на кнопку и %s, чтобы назначить привязку'
L['or press %s to clear it']                            = 'или нажмите %s, чтобы очистить её'
L['Canceling will remove you from Quick Keybind Mode']  = 'Отмена приведёт к выходу из режима быстрой привязки клавиш'
