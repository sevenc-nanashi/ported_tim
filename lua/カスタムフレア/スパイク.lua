--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:長さ
---min=0
---max=3000
---step=0.1
local track_length = 230

---$track:数
---min=0
---max=5000
---step=1
local track_count = 50

---$track:強度
---min=0
---max=200
---step=0.1
local track_intensity = 40

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local check_use_base_color = 1

---$color:光芒色
local ray_color = 0x9999ff

---$track:幅比率％
---min=0
---max=100
---step=0.1
local base_width_ratio = 8

---$track:高さランダム％
---min=0
---max=100
---step=0.1
local height_randomness = 50

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 5

---$track:ステップ角度
---min=-3600
---max=3600
---step=0.1
local angle_step = 0

---$track:誤差角度
---min=0
---max=3600
---step=0.1
local angle_randomness = 360

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = -100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$select:形状
---1=1
---2=2
---3=3
---4=4
local shape_index = 1

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

local figmax = 4
obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    ray_color = T_CUSTOM_FLARE_COLOR
end
local base_half_length = track_length * 0.5
local ray_count = track_count
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.02
base_width_ratio = base_half_length * base_width_ratio * 0.01
angle_randomness = angle_randomness * 0.5
shape_index = math.floor(shape_index)
if shape_index > figmax then
    shape_index = figmax
end
if shape_index < 1 then
    shape_index = 1
end
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X + T_CUSTOM_FLARE_CENTER_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y + T_CUSTOM_FLARE_CENTER_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z + T_CUSTOM_FLARE_CENTER_Z
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("spike" .. shape_index)
obj.putpixeldata("object", data, w, h)
obj.effect("グラデーション", "color", ray_color, "color2", ray_color, "blend", 3)
obj.effect("ぼかし", "範囲", blur)
local w0, h0 = obj.getpixel()
local rz = {}
for i = 1, ray_count do
    local rnd = obj.rand(100 - height_randomness, 100, i, seed) * 0.01
    local d_h = base_width_ratio * rnd
    local d_l = base_half_length * rnd
    d_h = w0 * d_h / 30
    d_l = h0 * d_l / 100
    local rz = math.rad(i * angle_step + obj.rand(-angle_randomness, angle_randomness, i, 1000 + seed) - track_rotation)
    local r = d_l
    local s = math.sin(rz)
    local c = math.cos(rz)
    local lr1 = d_l + r
    local lr2 = -d_l + r
    local x0, y0 = -d_h * c + lr1 * s + draw_x, d_h * s + lr1 * c + draw_y
    local x1, y1 = d_h * c + lr1 * s + draw_x, -d_h * s + lr1 * c + draw_y
    local x2, y2 = d_h * c + lr2 * s + draw_x, -d_h * s + lr2 * c + draw_y
    local x3, y3 = -d_h * c + lr2 * s + draw_x, d_h * s + lr2 * c + draw_y
    local alpha_integer_part = math.floor(alpha)
    local alpha_fractional_part = alpha - alpha_integer_part
    for i = 1, alpha_integer_part do
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
            1
        )
    end
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
        alpha_fractional_part
    )
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
