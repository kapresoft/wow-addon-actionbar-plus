--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "deDE", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = 'AddOns'
L['Alpha']                 = 'Transparenz'
L['Backdrop']              = 'Hintergrund'
L['Background Color']      = 'Hintergrundfarbe'
L['Bar']                   = 'Leiste'
L['Bars']                  = 'Leisten'
L['Border Color']          = 'Rahmenfarbe'
L['Bound']                 = 'Belegt'
L['Button']                = 'Schaltfläche'
L['Button Size']           = 'Schaltflächengröße'
L['Columns']               = 'Spalten'
L['Border Size']           = 'Rahmenstärke'
L['Enabled']               = 'Aktiviert'
L['General']               = 'Allgemein'
L['Keybind']               = 'Tastenbelegung'
L['Masque Settings']       = 'Masque-Einstellungen'
L['Not Bound']             = 'Nicht belegt'
L['Options']               = 'Optionen'
L['Padding']               = 'Innenabstand'
L['Reset']                 = 'Zurücksetzen'
L['Rows']                  = 'Reihen'
L['Settings']              = 'Einstellungen'
L['Show Empty Buttons']    = 'Leere Schaltflächen anzeigen'
L['Drag Handle Location']  = 'Position des Ziehgriffs'
L['Thickness']             = 'Stärke'
L['Extra Buttons']         = 'Zusätzliche Schaltflächen'
L['Button Count']          = 'Anzahl der Schaltflächen'
L['Toggle Bars']                 = 'Leisten umschalten'
L['Reset to Default']            = 'Auf Standard zurücksetzen'
L['Copy Backdrop from Bar']      = 'Hintergrund von Leiste kopieren'
L['Apply Backdrop to All Bars']  = 'Hintergrund auf alle Leisten anwenden'
L['Right-click for more options.'] = 'Rechtsklick für weitere Optionen.'
L['Mouseover Glow']         = 'Leuchten bei Mauszeiger'
L['Mouseover Glow Tooltip'] = 'Wenn aktiviert, leuchten Schaltflächen, sobald sich der Mauszeiger über ihnen befindet.'
L['Gap']                   = 'Abstand'
L['Gap Tooltip']           = 'Abstand zwischen dem Rahmen der Leiste und der Reihe zusätzlicher Schaltflächen.'
L['Global']                = 'Global'
L['Character Specific Frame Positions'] = 'Charakterspezifische Positionen'
L['Character Specific Frame Positions Tooltip'] = 'Wenn aktiviert, speichert jeder Charakter seine eigene Position der Leisten. Wenn deaktiviert, werden die Positionen von allen Charakteren geteilt, die dieses Profil verwenden.'
L['Anchor']                = 'Ankerpunkt'
L['Top']                   = 'Oben'
L['Top Left']              = 'Oben links'
L['Top Right']             = 'Oben rechts'
L['Bottom']                = 'Unten'
L['Bottom Left']           = 'Unten links'
L['Bottom Right']          = 'Unten rechts'
L['Stone']                 = 'Stein'
L['Theme']                 = 'Design'
L['Version']               = 'Version'

-- Theme Names
L['None']                  = 'Kein'
L['Minimalist']            = 'Minimalistisch'
L['Modern Dark']           = 'Modern Dunkel'
L['Abyss']                 = 'Abgrund'
L['Glow']                  = 'Leuchten'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = 'Dunkler Ritter'
L['Modern']                = 'Modern'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = 'Ziehe die Leiste, indem du den Mauszeiger über den Griff an der ausgewählten Position hältst.'
L['At least one bar must remain enabled.']                       = 'Mindestens eine Leiste muss aktiviert bleiben.'
L['Toggle bar visibility from the right-click context menu.']    = 'Schalte die Sichtbarkeit der Leiste über das Rechtsklick-Kontextmenü um.'
L['Profiles']                                           = 'Profile'
L['Extra Buttons Tooltip'] = 'Eine einzelne Reihe von Schaltflächen außerhalb des Leistenrahmens. Nützlich für Verbrauchsgüter, Schmuckstücke oder situative Gegenstände, die griffbereit, aber getrennt von der Hauptleiste sein sollen.'
L['Reset to default theme settings.']                   = 'Auf die Standard-Designeinstellungen zurücksetzen.'
L['Open General Settings for all bars and profiles.']   = 'Allgemeine Einstellungen für alle Leisten und Profile öffnen.'
L['Open Backdrop Settings for the current bar.']        = 'Hintergrundeinstellungen für die aktuelle Leiste öffnen.'

L['ESC'] = 'ESC'
L['press the desired key'] = 'drücke die gewünschte Taste'
L['You are in Quick Keybind Mode']                      = 'Du befindest dich im Schnellzuweisungsmodus'
L['Mouse over a button and %s to set its binding']      = 'Bewege die Maus über eine Schaltfläche und %s, um ihre Belegung festzulegen'
L['or press %s to clear it']                            = 'oder drücke %s, um sie zu löschen'
L['Canceling will remove you from Quick Keybind Mode']  = 'Abbrechen entfernt dich aus dem Schnellzuweisungsmodus'
