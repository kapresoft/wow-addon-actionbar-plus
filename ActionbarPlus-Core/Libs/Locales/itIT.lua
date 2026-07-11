--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "itIT", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = 'AddOn'
L['Alpha']                 = 'Trasparenza'
L['Backdrop']              = 'Sfondo'
L['Background Color']      = 'Colore di sfondo'
L['Bar']                   = 'Barra'
L['Bars']                  = 'Barre'
L['Border Color']          = 'Colore del bordo'
L['Bound']                 = 'Assegnato'
L['Button']                = 'Pulsante'
L['Button Size']           = 'Dimensione del pulsante'
L['Columns']               = 'Colonne'
L['Border Size']           = 'Spessore del bordo'
L['Enabled']               = 'Abilitato'
L['General']               = 'Generale'
L['Keybind']               = 'Associazione tasti'
L['Masque Settings']       = 'Impostazioni Masque'
L['Not Bound']             = 'Non assegnato'
L['Options']               = 'Opzioni'
L['Padding']               = 'Spaziatura interna'
L['Reset']                 = 'Ripristina'
L['Rows']                  = 'Righe'
L['Settings']              = 'Impostazioni'
L['Show Empty Buttons']    = 'Mostra pulsanti vuoti'
L['Drag Handle Location']  = 'Posizione della maniglia di trascinamento'
L['Thickness']             = 'Spessore'
L['Extra Buttons']         = 'Pulsanti extra'
L['Button Count']          = 'Numero di pulsanti'
L['Toggle Bars']                 = 'Attiva/disattiva barre'
L['Reset to Default']            = 'Ripristina predefiniti'
L['Copy Backdrop from Bar']      = 'Copia sfondo da un\'altra barra'
L['Apply Backdrop to All Bars']  = 'Applica sfondo a tutte le barre'
L['Right-click for more options.'] = 'Clic destro per altre opzioni.'
L['Mouseover Glow']         = 'Bagliore al passaggio del mouse'
L['Mouseover Glow Tooltip'] = 'Se abilitato, i pulsanti si illuminano quando il mouse ci passa sopra.'
L['Gap']                   = 'Spazio'
L['Gap Tooltip']           = 'Spazio tra il bordo della barra e la riga dei pulsanti extra.'
L['Global']                = 'Globale'
L['Character Specific Frame Positions'] = 'Posizioni specifiche per personaggio'
L['Character Specific Frame Positions Tooltip'] = 'Se abilitato, ogni personaggio salva la propria posizione delle barre. Se disabilitato, le posizioni sono condivise tra tutti i personaggi che usano questo profilo.'
L['Anchor']                = 'Ancoraggio'
L['Top']                   = 'Sopra'
L['Top Left']              = 'Alto sinistra'
L['Top Right']             = 'Alto destra'
L['Bottom']                = 'Sotto'
L['Bottom Left']           = 'Basso sinistra'
L['Bottom Right']          = 'Basso destra'
L['Stone']                 = 'Pietra'
L['Theme']                 = 'Tema'
L['Version']               = 'Versione'

-- Theme Names
L['None']                  = 'Nessuno'
L['Minimalist']            = 'Minimalista'
L['Modern Dark']           = 'Moderno scuro'
L['Abyss']                 = 'Abisso'
L['Glow']                  = 'Bagliore'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = 'Cavaliere oscuro'
L['Modern']                = 'Moderno'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = 'Trascina la barra passando il mouse sopra la maniglia nella posizione selezionata.'
L['At least one bar must remain enabled.']                       = 'Almeno una barra deve rimanere abilitata.'
L['Toggle bar visibility from the right-click context menu.']    = 'Attiva/disattiva la visibilità della barra dal menu contestuale del clic destro.'
L['Profiles']                                           = 'Profili'
L['Extra Buttons Tooltip'] = 'Una singola riga di pulsanti posizionata fuori dal bordo della barra. Utile per consumabili, ninnoli o oggetti situazionali che vuoi avere a portata di mano ma separati dalla barra principale.'
L['Reset to default theme settings.']                   = 'Ripristina le impostazioni predefinite del tema.'
L['Open General Settings for all bars and profiles.']   = 'Apri le impostazioni generali per tutte le barre e i profili.'
L['Open Backdrop Settings for the current bar.']        = 'Apri le impostazioni dello sfondo per la barra attuale.'

L['ESC'] = 'ESC'
L['press the desired key'] = 'premi il tasto desiderato'
L['You are in Quick Keybind Mode']                      = 'Sei in Modalità di associazione rapida dei tasti'
L['Mouse over a button and %s to set its binding']      = 'Passa il mouse su un pulsante e %s per impostare la sua associazione'
L['or press %s to clear it']                            = 'oppure premi %s per cancellarla'
L['Canceling will remove you from Quick Keybind Mode']  = 'Annullando uscirai dalla Modalità di associazione rapida dei tasti'
