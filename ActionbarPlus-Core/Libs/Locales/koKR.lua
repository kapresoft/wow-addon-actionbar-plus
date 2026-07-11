--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "koKR", false)
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']                = '애드온'
L['Alpha']                 = '투명도'
L['Backdrop']              = '배경'
L['Background Color']      = '배경 색상'
L['Bar']                   = '바'
L['Bars']                  = '바'
L['Border Color']          = '테두리 색상'
L['Bound']                 = '지정됨'
L['Button']                = '버튼'
L['Button Size']           = '버튼 크기'
L['Columns']               = '열'
L['Border Size']           = '테두리 두께'
L['Enabled']               = '활성화됨'
L['General']               = '일반'
L['Keybind']               = '단축키'
L['Masque Settings']       = 'Masque 설정'
L['Not Bound']             = '지정되지 않음'
L['Options']               = '옵션'
L['Padding']               = '여백'
L['Reset']                 = '초기화'
L['Rows']                  = '행'
L['Settings']              = '설정'
L['Show Empty Buttons']    = '빈 버튼 표시'
L['Drag Handle Location']  = '드래그 핸들 위치'
L['Thickness']             = '두께'
L['Extra Buttons']         = '추가 버튼'
L['Button Count']          = '버튼 개수'
L['Toggle Bars']                 = '바 전환'
L['Reset to Default']            = '기본값으로 초기화'
L['Copy Backdrop from Bar']      = '다른 바에서 배경 복사'
L['Apply Backdrop to All Bars']  = '모든 바에 배경 적용'
L['Right-click for more options.'] = '더 많은 옵션을 보려면 우클릭하세요.'
L['Mouseover Glow']         = '마우스오버 광채'
L['Mouseover Glow Tooltip'] = '활성화하면 마우스를 올렸을 때 버튼이 빛납니다.'
L['Gap']                   = '간격'
L['Gap Tooltip']           = '바 테두리와 추가 버튼 행 사이의 간격입니다.'
L['Global']                = '전역'
L['Character Specific Frame Positions'] = '캐릭터별 위치'
L['Character Specific Frame Positions Tooltip'] = '활성화하면 각 캐릭터가 자신의 바 위치를 별도로 저장합니다. 비활성화하면 이 프로필을 사용하는 모든 캐릭터가 위치를 공유합니다.'
L['Anchor']                = '고정점'
L['Top']                   = '위'
L['Top Left']              = '왼쪽 위'
L['Top Right']             = '오른쪽 위'
L['Bottom']                = '아래'
L['Bottom Left']           = '왼쪽 아래'
L['Bottom Right']          = '오른쪽 아래'
L['Stone']                 = '돌'
L['Theme']                 = '테마'
L['Version']               = '버전'

-- Theme Names
L['None']                  = '없음'
L['Minimalist']            = '미니멀'
L['Modern Dark']           = '모던 다크'
L['Abyss']                 = '심연'
L['Glow']                  = '광채'
L['Shadowmoon']            = 'Shadowmoon'
L['Dark Knight']           = '어둠의 기사'
L['Modern']                = '모던'
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = '선택한 위치의 핸들 위에 마우스를 올려 바를 드래그하세요.'
L['At least one bar must remain enabled.']                       = '최소 하나의 바는 활성화 상태로 유지되어야 합니다.'
L['Toggle bar visibility from the right-click context menu.']    = '우클릭 메뉴에서 바의 표시 여부를 전환하세요.'
L['Profiles']                                           = '프로필'
L['Extra Buttons Tooltip'] = '바 테두리 밖에 배치되는 한 줄짜리 버튼 행입니다. 소모품, 장신구 또는 상황에 따라 필요한 아이템을 메인 바와 분리하여 가까이 두고 싶을 때 유용합니다.'
L['Reset to default theme settings.']                   = '테마 설정을 기본값으로 초기화합니다.'
L['Open General Settings for all bars and profiles.']   = '모든 바와 프로필에 대한 일반 설정을 엽니다.'
L['Open Backdrop Settings for the current bar.']        = '현재 바의 배경 설정을 엽니다.'

L['Right-Click'] = '우클릭'
L['Left-Click and Drag'] = '좌클릭 후 드래그'
L['to show options menu'] = '하여 옵션 메뉴 표시'
L['bar frame or drag frame'] = '바 프레임 또는 드래그 프레임을'
L['to move the bar'] = '하여 바 이동'

L['ESC'] = 'ESC'
L['press the desired key'] = '원하는 키를 누르세요'
L['You are in Quick Keybind Mode']                      = '빠른 단축키 지정 모드입니다'
L['Mouse over a button and %s to set its binding']      = '버튼 위에 마우스를 올리고 %s하여 단축키를 지정하세요'
L['or press %s to clear it']                            = '또는 %s를 눌러 지우세요'
L['Canceling will remove you from Quick Keybind Mode']  = '취소하면 빠른 단축키 지정 모드에서 나갑니다'
