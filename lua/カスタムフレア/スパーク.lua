--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 400

---$track:長さ
---min=0
---max=1000
---step=0.1
local track_length = 60

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 20

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:数
---min=1
---max=5000
---step=1
local ray_count = 150

---$check:ベースカラー
local check_use_base_color = 1

---$color:光芒色
local ray_color = 0x9999ff

---$track:幅比率％
---min=0
---max=100
---step=0.1
local width_ratio = 10

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 5

---$track:放射ブラー
---min=0
---max=1000
---step=0.1
local radial_blur = 50

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = -100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$track:動径方向バラツキ％
---min=0
---max=200
---step=0.1
local radial_randomness = 100

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

---$track:乱数シード
---min=0
---max=100000
---step=1
local seed = 0

--hide@ray_color:check_use_base_color==1

obj.copybuffer("cache:BKIMG", "object") --背景をBKIMGに保存
if check_use_base_color == 1 then
    ray_color = T_CUSTOM_FLARE_COLOR
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
local size = track_size * 0.5
local half_length = track_length * 0.5
alpha = alpha * track_intensity * 0.01
local rotation = track_rotation
width_ratio = half_length * width_ratio * 0.01
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X + T_CUSTOM_FLARE_CENTER_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y + T_CUSTOM_FLARE_CENTER_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z + T_CUSTOM_FLARE_CENTER_Z
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("leaf")
obj.putpixeldata("object", data, w, h)
obj.effect("グラデーション", "color", ray_color, "color2", ray_color, "blend", 3)
obj.effect("ぼかし", "範囲", blur)
local w0, h0 = obj.getpixel()
local minimum_radius = half_length
local maximum_radius = math.max(size * 0.5, half_length)
width_ratio = w0 * width_ratio / 30
half_length = h0 * half_length / 100
radial_randomness = radial_randomness * 0.01
local buffer_size = 2 * (half_length + maximum_radius)
obj.setoption("drawtarget", "tempbuffer", buffer_size, buffer_size)
obj.setoption("blend", 6)
minimum_radius = radial_randomness * minimum_radius + (1 - radial_randomness) * maximum_radius
for i = 1, ray_count do
    local angle_radians = (obj.rand(-3600, 3600, i, seed) * 0.1 - rotation) * math.pi / 180
    local r = obj.rand(minimum_radius, maximum_radius, i, 1000 + seed)
    local s = math.sin(angle_radians)
    local c = math.cos(angle_radians)
    local x0 = -width_ratio
    local y0 = -half_length + r
    local x1 = width_ratio
    local y1 = -half_length + r
    local x2 = width_ratio
    local y2 = half_length + r
    local x3 = -width_ratio
    local y3 = half_length + r
    x0, y0 = x0 * c + y0 * s, -x0 * s + y0 * c
    x1, y1 = x1 * c + y1 * s, -x1 * s + y1 * c
    x2, y2 = x2 * c + y2 * s, -x2 * s + y2 * c
    x3, y3 = x3 * c + y3 * s, -x3 * s + y3 * c
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha)
end
obj.load("tempbuffer")
obj.effect("放射ブラー", "範囲", radial_blur)
obj.copybuffer("tempbuffer", "cache:BKIMG")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
obj.draw(draw_x, draw_y, draw_z)
obj.load("tempbuffer")
obj.setoption("blend", 0)
