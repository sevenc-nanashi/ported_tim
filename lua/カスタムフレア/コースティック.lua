--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 20

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 5

---$check:ベースカラー
local check_use_base_color = 1

---$color:色
local color = 0xccccff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = 100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$track:最大半径
---min=0
---max=5000
---step=0.1
local max_radius = 400

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

--hide@color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local size = track_size
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
local blur = track_blur
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("ctc1")
obj.putpixeldata("object", data, w, h)
obj.effect("グラデーション", "color", color, "color2", color, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z
local remaining_depth = max_radius * max_radius - draw_y * draw_y - draw_x * draw_x
local yaw_angle, pitch_angle
if remaining_depth > 0 then
    remaining_depth = math.sqrt(remaining_depth)
    local horizontal_distance = math.sqrt(remaining_depth * remaining_depth + draw_y * draw_y)
    if math.abs(draw_x) * 10000 > horizontal_distance then
        yaw_angle = math.atan2(draw_x, horizontal_distance) / math.pi * 180
        pitch_angle = math.atan2(draw_y, remaining_depth) / math.pi * 180
        draw_x = T_CUSTOM_FLARE_CENTER_X + draw_x
        draw_y = T_CUSTOM_FLARE_CENTER_Y + draw_y
        draw_z = T_CUSTOM_FLARE_CENTER_Z + draw_z
    else
        draw_x, draw_y, draw_z, alpha, yaw_angle, pitch_angle = 0, 0, 0, 0, 0, 0
    end
else
    draw_x, draw_y, draw_z, alpha, yaw_angle, pitch_angle = 0, 0, 0, 0, 0, 0
end
obj.draw(draw_x, draw_y, draw_z, size / 200, alpha, pitch_angle, -yaw_angle, 0)
local data, w, h = tim2_images.custom_flare_load_image("ctc2")
obj.putpixeldata("object", data, w, h)
obj.effect("グラデーション", "color", color, "color2", color, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local trail_sample_count = 30
for i = 0, trail_sample_count - 1 do
    local trail_progress = i / trail_sample_count
    obj.draw(
        draw_x + trail_progress * T_CUSTOM_FLARE_DELTA_X * 0.5,
        draw_y + trail_progress * T_CUSTOM_FLARE_DELTA_Y * 0.5,
        draw_z + trail_progress * T_CUSTOM_FLARE_DELTA_Z * 0.5,
        (1 - trail_progress) * size / 200,
        3 * alpha / trail_sample_count,
        pitch_angle,
        -yaw_angle,
        0
    )
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
