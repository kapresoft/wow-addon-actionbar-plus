--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "frFR", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = 'Extensions'
L['Alpha']                 = 'Transparence'
L['Backdrop']              = 'Arrière-plan'
L['Background Color']      = 'Couleur d\'arrière-plan'
L['Bar']                   = 'Barre'
L['Bars']                  = 'Barres'
L['Border Color']          = 'Couleur de la bordure'
L['Bound']                 = 'Assigné'
L['Button']                = 'Bouton'
L['Button Size']           = 'Taille des boutons'
L['Columns']               = 'Colonnes'
L['Border Size']           = 'Épaisseur de la bordure'
L['Enabled']               = 'Activé'
L['General']               = 'Général'
L['Keybind']               = 'Raccourci clavier'
L['Masque Settings']       = 'Paramètres de Masque'
L['Not Bound']             = 'Non assigné'
L['Options']               = 'Options'
L['Padding']               = 'Marge intérieure'
L['Reset']                 = 'Réinitialiser'
L['Rows']                  = 'Lignes'
L['Settings']              = 'Paramètres'
L['Show Empty Buttons']    = 'Afficher les boutons vides'
L['Drag Handle Location']  = 'Emplacement de la poignée de déplacement'
L['Thickness']             = 'Épaisseur'
L['Extra Buttons']         = 'Boutons supplémentaires'
L['Button Count']          = 'Nombre de boutons'
L['Toggle Bars']                 = 'Activer/désactiver les barres'
L['Reset to Default']            = 'Réinitialiser par défaut'
L['Copy Backdrop from Bar']      = 'Copier l\'arrière-plan d\'une barre'
L['Apply Backdrop to All Bars']  = 'Appliquer l\'arrière-plan à toutes les barres'
L['Right-click for more options.'] = 'Clic droit pour plus d\'options.'
L['Mouseover Glow']         = 'Lueur au survol'
L['Mouseover Glow Tooltip'] = 'Lorsque activé, les boutons s\'illuminent au survol de la souris.'
L['Gap']                   = 'Espacement'
L['Gap Tooltip']           = 'Espace entre la bordure de la barre et la rangée de boutons supplémentaires.'
L['Global']                = 'Global'
L['Character Specific Frame Positions'] = 'Positions spécifiques au personnage'
L['Character Specific Frame Positions Tooltip'] = 'Lorsque activé, chaque personnage enregistre sa propre position des barres. Lorsque désactivé, les positions sont partagées entre tous les personnages utilisant ce profil.'
L['Anchor']                = 'Ancrage'
L['Top']                   = 'Haut'
L['Top Left']              = 'Haut gauche'
L['Top Right']             = 'Haut droite'
L['Bottom']                = 'Bas'
L['Bottom Left']           = 'Bas gauche'
L['Bottom Right']          = 'Bas droite'
L['Stone']                 = 'Pierre'
L['Theme']                 = 'Thème'
L['Version']               = 'Version'

-- Theme Names
L['None']                  = 'Aucun'
L['Minimalist']            = 'Minimaliste'
L['Modern Dark']           = 'Moderne sombre'
L['Abyss']                 = 'Abysse'
L['Glow']                  = 'Lueur'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = 'Chevalier noir'
L['Modern']                = 'Moderne'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = 'Faites glisser la barre en survolant la poignée à l\'emplacement sélectionné.'
L['At least one bar must remain enabled.']                       = 'Au moins une barre doit rester activée.'
L['Toggle bar visibility from the right-click context menu.']    = 'Activez ou désactivez la visibilité de la barre depuis le menu contextuel du clic droit.'
L['Profiles']                                           = 'Profils'
L['Extra Buttons Tooltip'] = 'Une seule rangée de boutons placée à l\'extérieur de la bordure de la barre. Utile pour les consommables, babioles ou objets situationnels que vous voulez à portée de main, mais séparés de votre barre principale.'
L['Reset to default theme settings.']                   = 'Réinitialiser les paramètres par défaut du thème.'
L['Open General Settings for all bars and profiles.']   = 'Ouvrir les paramètres généraux pour toutes les barres et tous les profils.'
L['Open Backdrop Settings for the current bar.']        = 'Ouvrir les paramètres d\'arrière-plan pour la barre actuelle.'

L['Right-Click'] = 'Clic droit'
L['Left-Click and Drag'] = 'Clic gauche et glisser'
L['to show options menu'] = 'pour afficher le menu des options'
L['bar frame or drag frame'] = 'le cadre de la barre ou le cadre de déplacement'
L['to move the bar'] = 'pour déplacer la barre'

L['ESC'] = 'ESC'
L['press the desired key'] = 'appuyez sur la touche souhaitée'
L['You are in Quick Keybind Mode']                      = 'Vous êtes en Mode d\'assignation rapide des touches'
L['Mouse over a button and %s to set its binding']      = 'Survolez un bouton et %s pour définir son raccourci'
L['or press %s to clear it']                            = 'ou appuyez sur %s pour l\'effacer'
L['Canceling will remove you from Quick Keybind Mode']  = 'Annuler vous fera quitter le Mode d\'assignation rapide des touches'
