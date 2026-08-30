--label:${ROOT_CATEGORY}\変形\@モーフィング
---$track:ポイント数
---min=1
---max=16
---step=1
local track_point_count = 1

---$value:座標
local point_positions = { 0, 0 }

local anchor_count = track_point_count
obj.setanchor("point_positions", anchor_count)

local morph_points = T_MORPHING_OBJECTS[T_MORPHING_POINT_COUNT].pos
local existing_point_count = #morph_points
for i = 1, anchor_count do
    morph_points[existing_point_count + i] = {}
    morph_points[existing_point_count + i].x = point_positions[2 * i - 1]
    morph_points[existing_point_count + i].y = point_positions[2 * i]
end

if obj.getoption("script_name", 1, true) ~= "モーフィング-ポイント追加@モーフィング@tim.anm2" then
    T_MORPHING_DRAW_ANCHOR()
    T_MORPHING_DRAW_ANCHOR = nil
end
