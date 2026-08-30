--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:移動量
---min=-500
---max=500
---step=0.1
local track_move_amount = 0

---$select:合成モード
---加算=0
---スクリーン=1
local track_blend_mode = 0

---$color:ベースカラー
local base_color = 0x5588ff

---$check:位置移動
local interpolate_position = 0

---$value:座標
local positions = { -200, -100, 0, 0, 0, 0 }

--hide@track_move_amount:interpolate_position==0

local source_z
if interpolate_position == 0 then
    obj.setanchor("positions", 2, "line", "xyz")
    T_CUSTOM_FLARE_SOURCE_X = positions[1]
    T_CUSTOM_FLARE_SOURCE_Y = positions[2]
    source_z = positions[3]
    T_CUSTOM_FLARE_CENTER_X = positions[4]
    T_CUSTOM_FLARE_CENTER_Y = positions[5]
    T_CUSTOM_FLARE_CENTER_Z = positions[6]
else
    obj.setanchor("positions", 4, "line", "xyz", "inout")
    local s = track_move_amount * 0.01
    T_CUSTOM_FLARE_SOURCE_X = (1 - s) * positions[1] + s * positions[7]
    T_CUSTOM_FLARE_SOURCE_Y = (1 - s) * positions[2] + s * positions[8]
    source_z = (1 - s) * positions[3] + s * positions[9]
    T_CUSTOM_FLARE_CENTER_X = (1 - s) * positions[4] + s * positions[10]
    T_CUSTOM_FLARE_CENTER_Y = (1 - s) * positions[5] + s * positions[11]
    T_CUSTOM_FLARE_CENTER_Z = (1 - s) * positions[6] + s * positions[12]
end
T_CUSTOM_FLARE_DELTA_X = T_CUSTOM_FLARE_CENTER_X - T_CUSTOM_FLARE_SOURCE_X
T_CUSTOM_FLARE_DELTA_Y = T_CUSTOM_FLARE_CENTER_Y - T_CUSTOM_FLARE_SOURCE_Y
T_CUSTOM_FLARE_DELTA_Z = T_CUSTOM_FLARE_CENTER_Z - source_z
T_CUSTOM_FLARE_COLOR = base_color
T_CUSTOM_FLARE_WIDTH, T_CUSTOM_FLARE_HEIGHT = obj.getpixel()
T_CUSTOM_FLARE_BLEND_MODE = 1 + 3 * track_blend_mode
