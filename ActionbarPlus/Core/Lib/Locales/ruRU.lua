--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

local LocUtil = ns.O.LocalizationUtil

---@type AceLocale
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "ruRU");
if not L then return end
-- Translator ZamestoTV
--[[-----------------------------------------------------------------------------
Localization Keys That need to be defined for Bindings.xml
-------------------------------------------------------------------------------]]
local actionBarText = 'Панель действий'
local buttonBarText = 'Кнопка'

L['ABP_ACTIONBAR_BASE_NAME']                             = actionBarText
L['ABP_BUTTON_BASE_NAME']                                = buttonBarText
L['%s version %s by %s is loaded.'] = '%s версия %s от %s загружена.'
L['Type %s or %s for available commands.'] = 'Введите %s или %s для доступных команд.'

LocUtil:SetupKeybindNames(L, actionBarText, buttonBarText)

--[[-----------------------------------------------------------------------------
No Translations
-------------------------------------------------------------------------------]]
L['Version']                                  = 'Версия'
L['Curse-Forge']                              = 'Curse-Forge'
L['Bugs']                                     = 'Ошибки'
L['Repo']                                     = 'Репозиторий'
L['Last-Update']                              = 'Последнее обновление'
L['Interface-Version']                        = 'Версия интерфейса'
L['Game-Version']                             = 'Версия игры'
L['Locale']                                   = 'Локализация'
L['Use-KeyDown(cvar ActionButtonUseKeyDown)'] = 'Использовать нажатие клавиши (cvar ActionButtonUseKeyDown)'
L['Features']                                 = 'Особенности'

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['Addon Info']                                          = 'Информация о дополнении'
L['Addon Initialized Text Format']                       = '%s инициализировано. Введите %s в консоли для доступных команд.'
L['ALT']                                                 = 'ALT'
L['Available console commands']                          = 'Доступные консольные команды'
L['CTRL']                                                = 'CTRL'
L['Enable']                                              = 'Включить'
L['Hide']                                                = 'Скрыть'
L['Info Console Command Text']                           = 'Выводит дополнительную информацию о дополнении в консоли'
L['Options Dialog']                                      = 'Диалог настроек'
L['options']                                             = 'настройки'
L['Settings']                                            = 'Настройки'
L['SHIFT']                                               = 'SHIFT'
L['Show']                                                = 'Показать'
L['Shows the config UI (default)']                       = 'Показывает интерфейс настроек (по умолчанию)'
L['Shows this help']                                     = 'Показывает эту справку'
L['usage']                                               = 'использование'
L['No']                                                  = 'Нет'
L['Always']                                              = 'Всегда'
L['In-Combat']                                           = 'В бою'
L['Click and drag to move the action bar']               = 'Нажмите и перетащите, чтобы переместить панель действий'
L['Right-click to open the settings dialog']            = 'ПКМ, чтобы открыть диалог настроек'
L['General']                                             = 'Общие'
L['General Configuration']                               = 'Общие настройки'
L['Tooltip Options']                                     = 'Настройки всплывающих подсказок'
L['Tooltip Anchor']                                      = 'Якорь всплывающей подсказки'
L['Tooltip Anchor::Description']                         = 'Выберите, как и где должна отображаться игровая всплывающая подсказка при наведении на кнопку действия'
L['Debugging']                                           = 'Отладка'
L['Debugging::Description']                              = 'Настройки отладки для устранения неполадок'
L['Debugging Configuration']                             = 'Настройки отладки'
L['Debugging::Category::Enable All::Button']             = 'Включить все'
L['Debugging::Category::Enable All::Button::Desc']       = 'Включает все категории логов, указанные ниже.'
L['Debugging::Category::Disable All::Button']            = 'Отключить все'
L['Debugging::Category::Disable All::Button::Desc']      = 'Отключает все категории логов, указанные ниже. Обратите внимание, что категория по умолчанию (не показана здесь) всегда активна.'
L['Log Level']                                           = 'Уровень логов'
L['Log Level::Description']                              = 'Более высокие уровни логов создают больше записей:\nУровни логов: ERROR(5), WARN(10), INFO(15), DEBUG(20), FINE(25), FINER(30), FINEST(35), TRACE(50)'
L['Categories'] = 'Категории'

-- new

L['Hide during taxi']                                    = 'Скрывать во время полета'
L['Hide during taxi::Description']                       = 'Скрывает панели действий, пока игрок находится в такси; перелетает из одной точки в другую.'
L['Mouseover Glow']                                      = 'Свечение при наведении'
L['Mouseover Glow::Description']                         = 'Включает свечение кнопок действий при наведении курсора'
L['Hide text for smaller buttons']                       = 'Скрывать текст для маленьких кнопок'
L['Hide text for smaller buttons::Description']          = 'Если отмечено, эта опция скрывает количество предметов, текст привязки и индекс, когда размер кнопок меньше 35.'
L['Hide countdown numbers on cooldowns']                 = 'Скрывать числа обратного отсчета на перезарядке'
L['Hide countdown numbers on cooldowns::Description']    = 'Если отмечено, эта опция скрывает числа обратного отсчета для заклинаний, предметов, макросов и т.д.'
L['Tooltip Visibility']                                  = 'Видимость всплывающей подсказки'
L['Tooltip Visibility::Description']                     = 'Выберите, когда всплывающая подсказка должна отображаться вне боя. Если выбран модификатор, необходимо удерживать его, чтобы показать подсказку.'
L['Combat Override Key']                                 = 'Клавиша переопределения в бою'
L['Combat Override Key::Description']                    = 'Выберите, когда всплывающая подсказка должна отображаться во время боя. Если выбран модификатор, необходимо удерживать его, чтобы показать подсказку.'
L['Character Specific Frame Positions']                  = 'Индивидуальные позиции рамок для персонажей'
L['Character Specific Frame Positions::Description']     = 'По умолчанию все позиции рамок (или якорей) являются глобальными для всех персонажей. Если отмечено, позиции рамок сохраняются на уровне персонажа.'
L['Reset Anchor']                                        = 'Сбросить якорь'
L['Reset Anchor::Description']                           = 'Сбрасывает якорь (позицию) группы панели действий в центр экрана. Это может быть полезно, если рамка перетаскивания панели действий выходит за пределы экрана.'
L['Show empty buttons']                                  = 'Показывать пустые кнопки'
L['Show empty buttons::Description']                     = 'Отметьте эту опцию, чтобы всегда показывать кнопки на панели действий, даже если они пустые.'
L['Show Button Numbers']                                 = 'Показывать номера кнопок'
L['Show Button Numbers::Description']                    = 'Показывать индекс каждой кнопки на %s'
L['Show Keybind Text']                                   = 'Показывать текст привязки'
L['Show Keybind Text::Description']                      = 'Показывать текст привязки каждой кнопки на %s'
L['Alpha']                                               = 'Прозрачность'
L['Alpha::Description']                                  = 'Установить прозрачность панели действий'
L['Size (Width & Height)']                               = 'Размер (ширина и высота)'
L['Size (Width & Height)::Description']                  = 'Ширина и высота кнопок'
L['Rows']                                                = 'Ряды'
L['Rows::Description']                                   = 'Количество рядов для кнопок'
L['Columns']                                             = 'Колонки'
L['Columns::Description']                                = 'Количество колонок для кнопок'

L['Lock Actionbar']                                      = 'Заблокировать панель действий'
L['Lock Actionbar::Description']                         = [[

Опции:
  Всегда: блокировать рамку всегда.
  В бою: блокировать рамку во время боя.

Примечание: эта опция только предотвращает перемещение рамки и не блокирует отдельные элементы действий.]]

L['Mouseover']                                           = 'При наведении'
L['Mouseover::Description']                              = 'Скрывать перемещатель рамки в верхней части панели действий по умолчанию. Наведите курсор, чтобы сделать его видимым для перемещения рамки.'

L['Frame Handle Settings']                               = 'Настройки ручки рамки'

--[[-----------------------------------------------------------------------------
Needs Translations
-------------------------------------------------------------------------------]]
L['Requires ActionbarPlus-M6::Message']    = "Эта функция требует ActionbarPlus-M6."
L['ActionbarPlus-M6 URL']                  = "См. https://www.curseforge.com/wow/addons/actionbarplus-m6"
L['Talents Switch Success Message Format'] = 'Панели действий для специализации [%s] активированы.'

L['Primary']             = 'Основная'
L['Secondary']           = 'Вторичная'
L['Equipment set is %s'] = 'Набор экипировки: %s'
L['Equipped']            = 'Экипировано'
L['Talent Points']       = 'Очки талантов'
