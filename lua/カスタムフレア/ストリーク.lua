--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:光芒長
---min=0
---max=2000
---step=0.1
local track_ray_length = 400

---$track:光芒高さ
---min=0
---max=2000
---step=0.1
local track_ray_height = 20

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local check_use_base_color = 1

---$color:光芒色
local ray_color = 0x9999ff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = -100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$check:アンカーに合わせる
local check_align_to_anchor = 0

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.1

--hide@ray_color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    ray_color = T_CUSTOM_FLARE_COLOR
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
local ray_length = track_ray_length * 2
local half_ray_height = track_ray_height * 0.5
local rotation_radians = -track_rotation / 180 * math.pi
if check_align_to_anchor == 1 then
    rotation_radians = rotation_radians - math.atan2(T_CUSTOM_FLARE_DELTA_Y, T_CUSTOM_FLARE_DELTA_X)
end
obj.load("figure", "円", ray_color, half_ray_height)
obj.effect("ぼかし", "範囲", half_ray_height / 2.5)
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X + T_CUSTOM_FLARE_CENTER_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y + T_CUSTOM_FLARE_CENTER_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z + T_CUSTOM_FLARE_CENTER_Z
local layer_alpha = alpha
local layer_half_height = half_ray_height
local cos_rotation = math.cos(rotation_radians)
local sin_rotation = math.sin(rotation_radians)
for i = 1, 3 do
    local x0, y0 =
        -ray_length * cos_rotation - layer_half_height * sin_rotation + draw_x,
        ray_length * sin_rotation - layer_half_height * cos_rotation + draw_y
    local x1, y1 =
        -ray_length * cos_rotation + layer_half_height * sin_rotation + draw_x,
        ray_length * sin_rotation + layer_half_height * cos_rotation + draw_y
    local x2, y2 =
        ray_length * cos_rotation + layer_half_height * sin_rotation + draw_x,
        -ray_length * sin_rotation + layer_half_height * cos_rotation + draw_y
    local x3, y3 =
        ray_length * cos_rotation - layer_half_height * sin_rotation + draw_x,
        -ray_length * sin_rotation - layer_half_height * cos_rotation + draw_y
    obj.drawpoly(
        x0,
        y0,
        draw_z,
        x1,
        y1,
        draw_z,
        x2,
        y2,
        draw_z,
        x3,
        y3,
        draw_z,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        layer_alpha
    )
    layer_alpha = layer_alpha / 2
    layer_half_height = layer_half_height * 2
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
