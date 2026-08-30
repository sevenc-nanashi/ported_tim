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
local track_ray_height = 5

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local check_use_base_color = 1

---$color:光芒色
local ray_color = 0x9999ff

---$track:本数
---min=1
---max=5000
---step=1
local ray_count = 3

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = -100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$track:拡大率
---min=0
---max=1000
---step=0.1
local scale_percent = 50

---$track:間隔
---min=0
---max=1000
---step=0.1
local ray_spacing = 5

---$track:間隔ランダム
---min=0
---max=1000
---step=0.1
local spacing_randomness = 5

---$track:横ランダム
---min=0
---max=1000
---step=0.1
local horizontal_randomness = 10

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.1

--hide@ray_color:check_use_base_color==1

obj.copybuffer("cache:BKIMG", "object") --背景をBKIMGに保存
if check_use_base_color == 1 then
    ray_color = T_CUSTOM_FLARE_COLOR
end
local ray_length = track_ray_length * 2
local half_ray_height = track_ray_height * 0.5
local rotation = track_rotation
scale_percent = scale_percent * 0.01
obj.load("figure", "円", ray_color, half_ray_height)
obj.effect("ぼかし", "範囲", half_ray_height / 2.5)
obj.setoption("blend", 0)
obj.setoption("drawtarget", "tempbuffer", 2 * ray_length, 8 * half_ray_height)
local layer_half_height = half_ray_height
for i = 1, 3 do
    obj.drawpoly(
        -ray_length,
        -layer_half_height,
        0,
        -ray_length,
        layer_half_height,
        0,
        ray_length,
        layer_half_height,
        0,
        ray_length,
        -layer_half_height,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h
    )
    layer_half_height = layer_half_height * 2
end
obj.load("tempbuffer")
obj.copybuffer("tempbuffer", "cache:BKIMG")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X + T_CUSTOM_FLARE_CENTER_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y + T_CUSTOM_FLARE_CENTER_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z + T_CUSTOM_FLARE_CENTER_Z
local cos = math.cos(rotation * math.pi / 180)
local sin = math.sin(-rotation * math.pi / 180)
local frame_seed = obj.time * obj.framerate
for i = 0, ray_count - 1 do
    local alpha = obj.rand(0, 100, i, frame_seed) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = alpha * track_intensity * 0.01
    local ox = obj.rand(-horizontal_randomness, horizontal_randomness, i, 1000) * 0.5
    local oy = (i - (ray_count - 1) * 0.5) * ray_spacing
        + obj.rand(-spacing_randomness, spacing_randomness, i, 2000) * 0.5
    ox, oy = cos * ox + sin * oy, -sin * ox + cos * oy
    obj.draw(ox + draw_x, oy + draw_y, draw_z, scale_percent, alpha, 0, 0, rotation)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
