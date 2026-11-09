--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local Announcements = ns.O.Announcements

local warnColor = ns:ColorFn(ns.colorDef.error)
local headingColor = ns:ColorFn(NORMAL_FONT_COLOR)

--- @class RetailForeverNoticeText_ABP_2_0
--- @field title string
--- @field warning string
--- @field affected string
--- @field cooldowns string
--- @field otherFeatures string
--- @field stillWorks string
--- @field everythingElse string
--- @field thanks string

--- @type table<string, RetailForeverNoticeText_ABP_2_0>
local texts = {
  enUS = {
    title = 'Retail & Forever Compatibility',
    warning = "ActionbarPlus won't fully work on Retail or Forever realms.",
    affected = "What's affected",
    cooldowns = 'Cooldowns in combat: cooldown values are now "secret" in combat,'
      .. " so action buttons can't show cooldown timers correctly.",
    otherFeatures = 'Other secret-value features: anything else that relies on'
      .. " these secret values also won't work properly in combat.",
    stillWorks = 'What still works',
    everythingElse = 'Everything else. ActionbarPlus remains usable and will stay'
      .. ' available to download for both Retail and Forever.',
    thanks = 'Thanks for your patience, and for sticking with the addon.',
  },
  deDE = {
    title = 'Kompatibilität mit Retail & Forever',
    warning = 'ActionbarPlus funktioniert auf Retail- und Forever-Realms nicht vollständig.',
    affected = 'Was betroffen ist',
    cooldowns = 'Abklingzeiten im Kampf: Abklingzeitwerte sind im Kampf jetzt „geheim“,'
      .. ' daher können Aktionsbuttons Abklingzeit-Timer nicht korrekt anzeigen.',
    otherFeatures = 'Andere Funktionen mit geheimen Werten: Alles andere, was auf diese'
      .. ' geheimen Werte angewiesen ist, funktioniert im Kampf ebenfalls nicht richtig.',
    stillWorks = 'Was weiterhin funktioniert',
    everythingElse = 'Alles andere. ActionbarPlus bleibt nutzbar und bleibt für Retail'
      .. ' und Forever zum Download verfügbar.',
    thanks = 'Danke für deine Geduld und dass du dem Addon treu bleibst.',
  },
  esES = {
    title = 'Compatibilidad con Retail y Forever',
    warning = 'ActionbarPlus no funcionará del todo en los reinos de Retail o Forever.',
    affected = 'Qué se ve afectado',
    cooldowns = 'Tiempos de reutilización en combate: ahora los valores de reutilización'
      .. ' son "secretos" en combate, así que los botones de acción no pueden mostrar'
      .. ' bien los temporizadores.',
    otherFeatures = 'Otras funciones con valores secretos: todo lo demás que dependa de'
      .. ' estos valores secretos tampoco funcionará bien en combate.',
    stillWorks = 'Qué sigue funcionando',
    everythingElse = 'Todo lo demás. ActionbarPlus sigue siendo utilizable y seguirá'
      .. ' disponible para descargar tanto en Retail como en Forever.',
    thanks = 'Gracias por tu paciencia y por seguir con el addon.',
  },
  esMX = {
    title = 'Compatibilidad con Retail y Forever',
    warning = 'ActionbarPlus no funcionará por completo en los reinos de Retail o Forever.',
    affected = 'Qué se ve afectado',
    cooldowns = 'Tiempos de reutilización en combate: ahora los valores de reutilización'
      .. ' son "secretos" en combate, por lo que los botones de acción no pueden mostrar'
      .. ' correctamente los temporizadores.',
    otherFeatures = 'Otras funciones con valores secretos: cualquier otra cosa que dependa'
      .. ' de estos valores secretos tampoco funcionará correctamente en combate.',
    stillWorks = 'Qué sigue funcionando',
    everythingElse = 'Todo lo demás. ActionbarPlus sigue siendo usable y seguirá'
      .. ' disponible para descargar tanto en Retail como en Forever.',
    thanks = 'Gracias por tu paciencia y por seguir usando el addon.',
  },
  frFR = {
    title = 'Compatibilité Retail et Forever',
    warning = 'ActionbarPlus ne fonctionnera pas entièrement sur les royaumes Retail ou Forever.',
    affected = 'Ce qui est concerné',
    cooldowns = 'Temps de recharge en combat : les valeurs de temps de recharge sont'
      .. ' désormais « secrètes » en combat, les boutons d’action ne peuvent donc pas'
      .. ' afficher correctement les minuteurs.',
    otherFeatures = 'Autres fonctions à valeurs secrètes : tout ce qui dépend de ces'
      .. ' valeurs secrètes ne fonctionnera pas correctement non plus en combat.',
    stillWorks = 'Ce qui fonctionne toujours',
    everythingElse = 'Tout le reste. ActionbarPlus reste utilisable et restera disponible'
      .. ' au téléchargement pour Retail et Forever.',
    thanks = 'Merci pour votre patience, et de rester fidèle à l’addon.',
  },
  itIT = {
    title = 'Compatibilità con Retail e Forever',
    warning = 'ActionbarPlus non funzionerà completamente sui reami Retail o Forever.',
    affected = 'Cosa è interessato',
    cooldowns = 'Tempi di recupero in combattimento: ora i valori dei tempi di recupero'
      .. ' sono "segreti" in combattimento, quindi i pulsanti azione non possono mostrare'
      .. ' correttamente i timer.',
    otherFeatures = 'Altre funzioni con valori segreti: anche tutto ciò che dipende da'
      .. ' questi valori segreti non funzionerà correttamente in combattimento.',
    stillWorks = 'Cosa funziona ancora',
    everythingElse = 'Tutto il resto. ActionbarPlus resta utilizzabile e rimarrà'
      .. ' disponibile per il download sia per Retail che per Forever.',
    thanks = 'Grazie per la pazienza e per continuare a usare l’addon.',
  },
  koKR = {
    title = '리테일 및 Forever 호환성',
    warning = 'ActionbarPlus는 리테일 또는 Forever 서버에서 완전히 작동하지 않습니다.',
    affected = '영향을 받는 기능',
    cooldowns = '전투 중 재사용 대기시간: 이제 전투 중에는 재사용 대기시간 값이 "비밀"로'
      .. ' 처리되어 행동 버튼에 재사용 대기시간 타이머가 제대로 표시되지 않습니다.',
    otherFeatures = '기타 비밀 값 기능: 이 비밀 값에 의존하는 다른 기능도 전투 중에는'
      .. ' 제대로 작동하지 않습니다.',
    stillWorks = '계속 작동하는 기능',
    everythingElse = '그 외 모든 기능. ActionbarPlus는 계속 사용할 수 있으며 리테일과'
      .. ' Forever 모두에서 계속 다운로드할 수 있습니다.',
    thanks = '기다려 주시고 애드온을 계속 사용해 주셔서 감사합니다.',
  },
  ptBR = {
    title = 'Compatibilidade com Retail e Forever',
    warning = 'O ActionbarPlus não funcionará totalmente em reinos Retail ou Forever.',
    affected = 'O que é afetado',
    cooldowns = 'Recargas em combate: os valores de recarga agora são "secretos" em'
      .. ' combate, então os botões de ação não conseguem exibir os temporizadores'
      .. ' corretamente.',
    otherFeatures = 'Outros recursos com valores secretos: qualquer outra coisa que'
      .. ' dependa desses valores secretos também não funcionará direito em combate.',
    stillWorks = 'O que continua funcionando',
    everythingElse = 'Todo o resto. O ActionbarPlus continua utilizável e seguirá'
      .. ' disponível para download tanto no Retail quanto no Forever.',
    thanks = 'Obrigado pela paciência e por continuar com o addon.',
  },
  ruRU = {
    title = 'Совместимость с Retail и Forever',
    warning = 'ActionbarPlus не будет полностью работать в игровых мирах Retail и Forever.',
    affected = 'Что затронуто',
    cooldowns = 'Перезарядка в бою: значения перезарядки в бою теперь «секретные»,'
      .. ' поэтому кнопки действий не могут правильно показывать таймеры перезарядки.',
    otherFeatures = 'Другие функции с секретными значениями: всё остальное, что зависит'
      .. ' от этих секретных значений, тоже не будет корректно работать в бою.',
    stillWorks = 'Что по-прежнему работает',
    everythingElse = 'Всё остальное. ActionbarPlus остаётся рабочим и по-прежнему будет'
      .. ' доступен для загрузки как для Retail, так и для Forever.',
    thanks = 'Спасибо за терпение и за то, что остаётесь с аддоном.',
  },
  zhCN = {
    title = '正式服与 Forever 兼容性',
    warning = 'ActionbarPlus 在正式服或 Forever 服务器上无法完全正常运行。',
    affected = '受影响的内容',
    cooldowns = '战斗中的冷却：战斗中的冷却数值现在是“秘密”的，因此动作按钮无法正确显示冷却计时。',
    otherFeatures = '其他依赖秘密值的功能：任何依赖这些秘密值的功能在战斗中也无法正常工作。',
    stillWorks = '仍然可用的内容',
    everythingElse = '其他一切。ActionbarPlus 仍然可以使用，并将继续为正式服和 Forever 提供下载。',
    thanks = '感谢你的耐心，也感谢你一直支持本插件。',
  },
  zhTW = {
    title = '正式服與 Forever 相容性',
    warning = 'ActionbarPlus 在正式服或 Forever 伺服器上無法完全正常運作。',
    affected = '受影響的內容',
    cooldowns = '戰鬥中的冷卻：戰鬥中的冷卻數值現在是「秘密」的，因此快捷列按鈕無法正確顯示冷卻計時。',
    otherFeatures = '其他依賴秘密值的功能：任何依賴這些秘密值的功能在戰鬥中也無法正常運作。',
    stillWorks = '仍然可用的內容',
    everythingElse = '其他一切。ActionbarPlus 仍然可以使用，並將繼續為正式服和 Forever 提供下載。',
    thanks = '感謝你的耐心，也感謝你一直支持本插件。',
  },
}

--- @param s RetailForeverNoticeText_ABP_2_0
--- @return string
local function BuildContent(s)
  return table.concat({
    warnColor(s.warning),
    '',
    headingColor(s.affected),
    '- ' .. s.cooldowns,
    '- ' .. s.otherFeatures,
    '',
    headingColor(s.stillWorks),
    s.everythingElse,
    '',
    s.thanks,
  }, '\n')
end

--- @type AnnouncementDef_ABP_2_0
local def = {
  dbKey = 'retailForeverCompatibility',
  width = 480,
  height = 320,
  isAvailable = function() return ns:HasSecretValues() end,
  title = texts.enUS.title,
  content = BuildContent(texts.enUS),
}

for locale, s in pairs(texts) do
  if locale ~= 'enUS' then
    def['title_' .. locale] = s.title
    def['content_' .. locale] = BuildContent(s)
  end
end

Announcements:Register(def)
