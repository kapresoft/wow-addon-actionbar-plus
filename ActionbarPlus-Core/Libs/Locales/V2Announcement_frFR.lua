if GetLocale() ~= 'frFR' then return end

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

ABP_V2_ANNOUNCEMENT = [[|cffffd700ActionbarPlus V2 est arrivé !|r

Bienvenue dans la nouvelle génération d'ActionbarPlus. V2 a été entièrement reconstruit avec une architecture plus propre, plus de fonctionnalités et de meilleures performances.

|cffffff00Composants V2 (à garder activés) :|r
  • ActionbarPlus-Core
  • ActionbarPlus-BarsUI
  • ActionbarPlus-OptionsUI

|cffffff00Optionnel :|r
  • ActionbarPlus-Masque — pour habiller les boutons (nécessite l'addon Masque)

|cffffff00À propos de V1 :|r
ActionbarPlus (V1) est toujours installé et actif en parallèle de V2. V1 est désormais figé — il ne recevra plus de nouvelles fonctionnalités ni de corrections. Il sera désactivé lors d'une prochaine mise à jour.

Nous vous recommandons de configurer vos barres dans V2 et de désactiver V1 (|cffaaaaaa ActionbarPlus|r) depuis le menu des AddOns dès que possible.

Merci pour votre soutien continu !
— kapresoft]]
