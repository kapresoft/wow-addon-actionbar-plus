--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "esES", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = 'AddOns'
L['Alpha']                 = 'Transparencia'
L['Backdrop']              = 'Fondo'
L['Background Color']      = 'Color de fondo'
L['Bar']                   = 'Barra'
L['Bars']                  = 'Barras'
L['Border Color']          = 'Color del borde'
L['Bound']                 = 'Asignado'
L['Button']                = 'Botón'
L['Button Size']           = 'Tamaño del botón'
L['Columns']               = 'Columnas'
L['Border Size']           = 'Grosor del borde'
L['Enabled']               = 'Activado'
L['General']               = 'General'
L['Keybind']               = 'Atajo de teclado'
L['Masque Settings']       = 'Configuración de Masque'
L['Not Bound']             = 'Sin asignar'
L['Options']               = 'Opciones'
L['Padding']               = 'Relleno'
L['Reset']                 = 'Restablecer'
L['Rows']                  = 'Filas'
L['Settings']              = 'Configuración'
L['Show Empty Buttons']    = 'Mostrar botones vacíos'
L['Drag Handle Location']  = 'Posición del asa de arrastre'
L['Thickness']             = 'Grosor'
L['Extra Buttons']         = 'Botones adicionales'
L['Button Count']          = 'Cantidad de botones'
L['Toggle Bars']                 = 'Alternar barras'
L['Reset to Default']            = 'Restablecer a valores predeterminados'
L['Copy Backdrop from Bar']      = 'Copiar fondo de otra barra'
L['Apply Backdrop to All Bars']  = 'Aplicar fondo a todas las barras'
L['Right-click for more options.'] = 'Clic derecho para más opciones.'
L['Mouseover Glow']         = 'Brillo al pasar el ratón'
L['Mouseover Glow Tooltip'] = 'Cuando está activado, los botones brillan al pasar el ratón sobre ellos.'
L['Gap']                   = 'Espacio'
L['Gap Tooltip']           = 'Espacio entre el borde de la barra y la fila de botones adicionales.'
L['Global']                = 'Global'
L['Character Specific Frame Positions'] = 'Posiciones específicas por personaje'
L['Character Specific Frame Positions Tooltip'] = 'Cuando está activado, cada personaje guarda su propia posición de las barras. Cuando está desactivado, las posiciones se comparten entre todos los personajes que usan este perfil.'
L['Anchor']                = 'Anclaje'
L['Top']                   = 'Arriba'
L['Top Left']              = 'Arriba a la izquierda'
L['Top Right']             = 'Arriba a la derecha'
L['Bottom']                = 'Abajo'
L['Bottom Left']           = 'Abajo a la izquierda'
L['Bottom Right']          = 'Abajo a la derecha'
L['Stone']                 = 'Piedra'
L['Theme']                 = 'Tema'
L['Version']               = 'Versión'

-- Theme Names
L['None']                  = 'Ninguno'
L['Minimalist']            = 'Minimalista'
L['Modern Dark']           = 'Moderno oscuro'
L['Abyss']                 = 'Abismo'
L['Glow']                  = 'Brillo'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = 'Caballero oscuro'
L['Modern']                = 'Moderno'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = 'Arrastra la barra pasando el ratón sobre el asa en la posición seleccionada.'
L['At least one bar must remain enabled.']                       = 'Al menos una barra debe permanecer activada.'
L['Toggle bar visibility from the right-click context menu.']    = 'Alterna la visibilidad de la barra desde el menú contextual del clic derecho.'
L['Profiles']                                           = 'Perfiles'
L['Extra Buttons Tooltip'] = 'Una sola fila de botones colocada fuera del borde de la barra. Útil para consumibles, baratijas u objetos situacionales que quieras cerca pero separados de tu barra principal.'
L['Reset to default theme settings.']                   = 'Restablecer a la configuración predeterminada del tema.'
L['Open General Settings for all bars and profiles.']   = 'Abrir la configuración general para todas las barras y perfiles.'
L['Open Backdrop Settings for the current bar.']        = 'Abrir la configuración de fondo para la barra actual.'

L['Right-Click'] = 'Clic derecho'
L['Left-Click and Drag'] = 'Clic izquierdo y arrastrar'
L['to show options menu'] = 'para mostrar el menú de opciones'
L['bar frame or drag frame'] = 'el marco de la barra o el marco de arrastre'
L['to move the bar'] = 'para mover la barra'

L['ESC'] = 'ESC'
L['press the desired key'] = 'pulsa la tecla deseada'
L['You are in Quick Keybind Mode']                      = 'Estás en el Modo de asignación rápida de teclas'
L['Mouse over a button and %s to set its binding']      = 'Pasa el ratón sobre un botón y %s para asignar su atajo'
L['or press %s to clear it']                            = 'o pulsa %s para borrarlo'
L['Canceling will remove you from Quick Keybind Mode']  = 'Cancelar te sacará del Modo de asignación rápida de teclas'
