--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:大きさ
---min=1
---max=5000
---step=0.1
local track_size = 250

---$track:長さ％
---min=1
---max=100
---step=0.1
local track_length_percent = 20

---$track:強度％
---min=1
---max=100
---step=0.1
local track_intensity_percent = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = 50

---$track:虹輪開％
---min=0
---max=100
---step=0.1
local radial_blur_percent = 20

---$track:裁ち落とし％
---min=0
---max=100
---step=0.1
local radial_shift_percent = 0

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$check:自動拡大
local check_auto_hide = 0

---$track:基準距離
---min=0
---max=5000
---step=0.1
local reference_distance = 400

---$track:偏平率％
---min=0
---max=200
---step=0.1
local aspect_ratio = 100

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 1

---$select:パターン
---1=1
---2=2
---3=3
---4=4
local shape_index = 1

---$check:色上書き
local check_override_color = 0

---$color:上書き色
local override_color = 0xccccff

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

---$value:発光
local color_stops = { 0, 250, 80, 0 }

--hide@reference_distance:check_auto_hide==0
--hide@override_color:check_override_color==0

local figmax = 4
obj.copybuffer("cache:BKIMG", "object") --背景をBKIMGに保存
local layer_count = 10
local base_radius = track_size * 0.5
if check_auto_hide == 1 then
    base_radius = base_radius
        * math.sqrt(
            T_CUSTOM_FLARE_DELTA_X * T_CUSTOM_FLARE_DELTA_X
                + T_CUSTOM_FLARE_DELTA_Y * T_CUSTOM_FLARE_DELTA_Y
                + T_CUSTOM_FLARE_DELTA_Z * T_CUSTOM_FLARE_DELTA_Z
        )
        / reference_distance
end
local radius_extension = base_radius * track_length_percent * 0.01
local wh = 2 * (base_radius + radius_extension)
obj.setoption("drawtarget", "tempbuffer", wh, wh)
obj.setoption("blend", 0)
local pi = math.pi
local cos = math.cos
local sin = math.sin
local alpha = track_intensity_percent * 0.01
local rotation_radians = track_rotation / 180 * pi
radial_blur_percent = radial_blur_percent * 0.01
radial_shift_percent = radial_shift_percent * 0.01
aspect_ratio = aspect_ratio * 0.01
shape_index = math.floor(shape_index)
if shape_index > figmax then
    shape_index = figmax
end
if shape_index < 1 then
    shape_index = 1
end

-- obj.load("image", obj.getinfo("script_path") .. "CF-image\\hoop" .. shape_index .. ".webp")
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("hoop" .. shape_index)
obj.putpixeldata("object", data, w, h)
obj.setoption("antialias", 1)

local draw_x = T_CUSTOM_FLARE_DELTA_X * (position_percent + position_offset[1]) * 0.01 + T_CUSTOM_FLARE_CENTER_X
local draw_y = T_CUSTOM_FLARE_DELTA_Y * (position_percent + position_offset[2]) * 0.01 + T_CUSTOM_FLARE_CENTER_Y
local draw_z = T_CUSTOM_FLARE_DELTA_Z * (position_percent + position_offset[3]) * 0.01 + T_CUSTOM_FLARE_CENTER_Z
rotation_radians = rotation_radians + math.atan2(T_CUSTOM_FLARE_DELTA_Y, T_CUSTOM_FLARE_DELTA_X)
local sample_count = 20 * layer_count
local previous_sample = -1
for i = 0, layer_count - 1 do
    for j = 0, 19 do
        previous_sample = previous_sample + 1
        local k1 = previous_sample + 1
        if
            radial_shift_percent * 0.5 * sample_count < previous_sample
            and k1 < (1 - radial_shift_percent * 0.5) * sample_count
        then
            local t0 = (2 * previous_sample / sample_count - 1) * pi
            local t1 = (2 * k1 / sample_count - 1) * pi
            if t0 > 0 then
                t0 = t0 * 0.99
            else
                t0 = t0 * 1.01
            end
            if t1 < 0 then
                t1 = t1 * 0.99
            else
                t1 = t1 * 1.01
            end
            local s0 = t0
            local s1 = t1
            local t0 = t0 / (1 - radial_blur_percent)
            local t1 = t1 / (1 - radial_blur_percent)
            if t0 < -pi then
                t0 = -pi
            end
            if t1 < -pi then
                t1 = -pi
            end
            if t0 > pi then
                t0 = pi
            end
            if t1 > pi then
                t1 = pi
            end
            local r01 = base_radius + radius_extension * (cos(t0) + 1) / 2
            local r02 = base_radius - radius_extension * (cos(t0) + 1) / 2
            local r11 = base_radius + radius_extension * (cos(t1) + 1) / 2
            local r12 = base_radius - radius_extension * (cos(t1) + 1) / 2
            local x0 = r01 * cos(s0)
            local y0 = r01 * sin(s0)
            local x1 = r11 * cos(s1)
            local y1 = r11 * sin(s1)
            local x2 = r12 * cos(s1)
            local y2 = r12 * sin(s1)
            local x3 = r02 * cos(s0)
            local y3 = r02 * sin(s0)
            local u0 = j * obj.w * 0.05
            local u1 = (j + 1) * obj.w * 0.05
            local v2 = obj.h
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, 0, u1, 0, u1, v2, u0, v2, 1)
        end
    end
end
obj.load("tempbuffer")
obj.copybuffer("tempbuffer", "cache:BKIMG")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
local flicker_alpha = obj.rand(0, 100) / 100 + (1 - blink)
if flicker_alpha > 1 then
    flicker_alpha = 1
end
alpha = flicker_alpha * alpha
if check_override_color == 1 then
    obj.effect("グラデーション", "color", override_color, "color2", override_color, "blend", 3)
end
obj.effect("ぼかし", "範囲", blur)
obj.effect(
    "発光",
    "強さ",
    color_stops[1],
    "拡散",
    color_stops[2],
    "しきい値",
    color_stops[3],
    "拡散速度",
    color_stops[4],
    "サイズ固定",
    1
)
local w, h = obj.getpixel()
w = w * 0.5
h = h * 0.5
local wc = w * cos(rotation_radians)
local ws = -w * sin(rotation_radians)
local hc = h * cos(rotation_radians)
local hs = -h * sin(rotation_radians)
local x0 = -wc - hs + draw_x
local y0 = (ws - hc) * aspect_ratio + draw_y
local x1 = wc - hs + draw_x
local y1 = (-ws - hc) * aspect_ratio + draw_y
local x2 = wc + hs + draw_x
local y2 = (-ws + hc) * aspect_ratio + draw_y
local x3 = -wc + hs + draw_x
local y3 = (ws + hc) * aspect_ratio + draw_y
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
    alpha
)
obj.load("tempbuffer")
obj.setoption("blend", 0)
