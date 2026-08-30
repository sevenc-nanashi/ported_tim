--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:個数
---min=0
---max=1000
---step=0.1
local track_bubble_count = 200

---$track:速度
---min=-50
---max=50
---step=0.1
local track_rise_speed = -8

---$track:方向
---min=-50
---max=50
---step=0.1
local track_horizontal_direction = 0

---$track:形状補正
---min=0
---max=100
---step=0.1
local track_shape_adjustment = 50

---$track:サイズ
---min=0
---max=1000
---step=0.1
local track_size = 100

---$color:色
local bubble_color = 0xffffff

---$track:ゆらぎ幅
---min=0
---max=10
---step=0.1
local track_fluctuation_width = 2

---$track:ゆらぎ速度
---min=-50
---max=50
---step=0.1
local track_fluctuation_speed = 2

---$track:奥行き
---min=0
---max=100
---step=0.1
local track_depth = 15

---$check:事後エフェクト
local check_after_effect = false

---$track:表示領域補正
---min=0.1
---max=10
---step=0.1
local track_display_area_correction = 1

obj.load("figure", "円", bubble_color, track_size)
obj.effect("ぼかし", "範囲", track_size)
obj.effect("クリッピング", "右", track_size * 1.4 * track_shape_adjustment / 100)
obj.effect("クリッピング", "左", track_size * 1.4 * track_shape_adjustment / 100)
obj.effect("斜めクリッピング")
obj.effect("極座標変換")

local horizontal_extent = obj.screen_w * track_display_area_correction / 2 + obj.w
local vertical_extent = obj.screen_h * track_display_area_correction / 2 + obj.h
if not check_after_effect then
    obj.effect()
else
    obj.setoption(
        "drawtarget",
        "tempbuffer",
        obj.screen_w * track_display_area_correction,
        obj.screen_h * track_display_area_correction
    )
end
local elapsed_progress = track_rise_speed / 10
local horizontal_travel = track_horizontal_direction * obj.w
elapsed_progress = elapsed_progress * obj.time
local fluctuation_phase = track_fluctuation_speed * obj.time * math.pi * 2 / 10
local bubble_count = track_bubble_count
local fluctuation_width = track_fluctuation_width * obj.w
local minimum_x = -horizontal_extent
local maximum_x = horizontal_extent
if horizontal_travel < 0 then
    maximum_x = maximum_x - horizontal_travel
else
    minimum_x = minimum_x - horizontal_travel
end
for i = 1, bubble_count do
    local depth_scale = 1 / (1 + track_depth * i / bubble_count)
    local cycle_progress = elapsed_progress * depth_scale + obj.rand(0, 1000, i, 1000) / 1000
    local cycle_index = math.floor(cycle_progress)
    cycle_progress = cycle_progress - cycle_index
    local fluctuation_angle = fluctuation_phase + math.pi * 2 * obj.rand(0, 1000, i, 1001) / 1000
    local bubble_x = obj.rand(minimum_x, maximum_x, i, cycle_index)
        + (math.sin(fluctuation_angle) * fluctuation_width + cycle_progress * horizontal_travel) * depth_scale
    local bubble_y = cycle_progress * vertical_extent * 2 - vertical_extent
    obj.draw(bubble_x, bubble_y, 0, depth_scale)
end

if check_after_effect then
    obj.load("tempbuffer")
end
