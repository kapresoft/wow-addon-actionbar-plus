--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "ptBR", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = 'AddOns'
L['Alpha']                 = 'Transparência'
L['Backdrop']              = 'Fundo'
L['Background Color']      = 'Cor de fundo'
L['Bar']                   = 'Barra'
L['Bars']                  = 'Barras'
L['Border Color']          = 'Cor da borda'
L['Bound']                 = 'Vinculado'
L['Button']                = 'Botão'
L['Button Size']           = 'Tamanho do botão'
L['Columns']               = 'Colunas'
L['Border Size']           = 'Espessura da borda'
L['Enabled']               = 'Ativado'
L['General']               = 'Geral'
L['Keybind']               = 'Atalho de teclado'
L['Masque Settings']       = 'Configurações do Masque'
L['Not Bound']             = 'Não vinculado'
L['Options']               = 'Opções'
L['Padding']               = 'Espaçamento interno'
L['Reset']                 = 'Redefinir'
L['Rows']                  = 'Linhas'
L['Settings']              = 'Configurações'
L['Show Empty Buttons']    = 'Mostrar botões vazios'
L['Drag Handle Location']  = 'Posição da alça de arraste'
L['Thickness']             = 'Espessura'
L['Extra Buttons']         = 'Botões extras'
L['Button Count']          = 'Quantidade de botões'
L['Toggle Bars']                 = 'Alternar barras'
L['Reset to Default']            = 'Restaurar padrão'
L['Copy Backdrop from Bar']      = 'Copiar fundo de outra barra'
L['Apply Backdrop to All Bars']  = 'Aplicar fundo a todas as barras'
L['Right-click for more options.'] = 'Clique com o botão direito para mais opções.'
L['Mouseover Glow']         = 'Brilho ao passar o mouse'
L['Mouseover Glow Tooltip'] = 'Quando ativado, os botões brilham ao passar o mouse sobre eles.'
L['Gap']                   = 'Espaço'
L['Gap Tooltip']           = 'Espaço entre a borda da barra e a linha de botões extras.'
L['Global']                = 'Global'
L['Character Specific Frame Positions'] = 'Posições específicas por personagem'
L['Character Specific Frame Positions Tooltip'] = 'Quando ativado, cada personagem salva sua própria posição das barras. Quando desativado, as posições são compartilhadas entre todos os personagens que usam este perfil.'
L['Anchor']                = 'Ancoragem'
L['Top']                   = 'Cima'
L['Top Left']              = 'Superior esquerdo'
L['Top Right']             = 'Superior direito'
L['Bottom']                = 'Baixo'
L['Bottom Left']           = 'Inferior esquerdo'
L['Bottom Right']          = 'Inferior direito'
L['Stone']                 = 'Pedra'
L['Theme']                 = 'Tema'
L['Version']               = 'Versão'

-- Theme Names
L['None']                  = 'Nenhum'
L['Minimalist']            = 'Minimalista'
L['Modern Dark']           = 'Escuro moderno'
L['Abyss']                 = 'Abismo'
L['Glow']                  = 'Brilho'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = 'Cavaleiro das trevas'
L['Modern']                = 'Moderno'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = 'Arraste a barra passando o mouse sobre a alça na posição selecionada.'
L['At least one bar must remain enabled.']                       = 'Pelo menos uma barra deve permanecer ativada.'
L['Toggle bar visibility from the right-click context menu.']    = 'Alterne a visibilidade da barra pelo menu de contexto do botão direito.'
L['Profiles']                                           = 'Perfis'
L['Extra Buttons Tooltip'] = 'Uma única linha de botões posicionada fora da borda da barra. Útil para consumíveis, bugigangas ou itens situacionais que você queira por perto, mas separados da barra principal.'
L['Reset to default theme settings.']                   = 'Restaurar as configurações padrão do tema.'
L['Open General Settings for all bars and profiles.']   = 'Abrir as configurações gerais para todas as barras e perfis.'
L['Open Backdrop Settings for the current bar.']        = 'Abrir as configurações de fundo da barra atual.'

L['Right-Click'] = 'Clique com o botão direito'
L['Left-Click and Drag'] = 'Clique com o botão esquerdo e arraste'
L['to show options menu'] = 'para mostrar o menu de opções'
L['bar frame or drag frame'] = 'o quadro da barra ou o quadro de arraste'
L['to move the bar'] = 'para mover a barra'

L['ESC'] = 'ESC'
L['press the desired key'] = 'pressione a tecla desejada'
L['You are in Quick Keybind Mode']                      = 'Você está no Modo de Atalho Rápido'
L['Mouse over a button and %s to set its binding']      = 'Passe o mouse sobre um botão e %s para definir seu atalho'
L['or press %s to clear it']                            = 'ou pressione %s para limpá-lo'
L['Canceling will remove you from Quick Keybind Mode']  = 'Cancelar irá tirar você do Modo de Atalho Rápido'
