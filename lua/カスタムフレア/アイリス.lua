--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:形状
---min=1
---max=14
---step=1
local track_shape = 1

---$track:数
---min=1
---max=100
---step=1
local track_count = 4

---$track:サイズ％
---min=0
---max=5000
---step=0.1
local track_size_percent = 30

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$track:サイズ幅％
---min=0
---max=100
---step=0.1
local size_variation_percent = 50

---$check:順次拡大
local check_sequential_scale = 0

---$track:強度幅％
---min=0
---max=100
---step=0.1
local intensity_variation_percent = 5

---$check:ベースカラー
local check_use_base_color = 1

---$color:色
local color = 0xccccff

---$track:色幅％
---min=0
---max=100
---step=0.1
local color_variation_percent = 5

---$value:位置％
local position_range_percent = { 0, 5 }

---$value:位置オフセット
local position_offset = { 0, 0, 0 }

---$value:散らばり％
local distribution_percent = { 100, 25 }

---$value:回転
local rotation_range = { 0, 0 }

---$check:アンカーに合わせる
local check_align_to_anchor = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 10

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

--hide@color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
local tim2_images = obj.module("tim2")
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local shape_index = track_shape
local count = track_count
local size = track_size_percent * 0.01
local intensity = track_intensity * 0.01
local t = position_range_percent[1] * 0.01
local position_variation = position_range_percent[2]
local distribution_scale = distribution_percent[1] * 0.01
local distribution_variation = distribution_percent[2]
local base_rotation = rotation_range[1]
local rotation_variation = rotation_range[2] * 0.5
position_offset[1] = position_offset[1] * 0.01
position_offset[2] = position_offset[2] * 0.01
position_offset[3] = position_offset[3] * 0.01
local data, w, h = tim2_images.custom_flare_load_image("I" .. shape_index)
obj.putpixeldata("object", data, w, h)
obj.effect("グラデーション", "color", color, "color2", color, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local frame_index = math.floor(obj.time * obj.framerate)
for i = 1, count do
    if color_variation_percent > 0 then
        local data, w, h = tim2_images.custom_flare_load_image("I" .. shape_index)
        obj.putpixeldata("object", data, w, h)
        local h, s, v = HSV(color)
        h = math.floor(h + math.floor(3.6 * obj.rand(0, color_variation_percent, i, seed))) % 360
        color = HSV(h, s, v)
        obj.effect("グラデーション", "color", color, "color2", color, "blend", 5)
        obj.effect("ぼかし", "範囲", blur)
    end
    local hi = ((i - 0.5) / count - 0.5)
        * (1 + obj.rand(-distribution_variation, distribution_variation, i, 1000 + seed) * 0.01)
    hi = t + hi * distribution_scale
    local ox = T_CUSTOM_FLARE_DELTA_X
        * (hi + obj.rand(-position_variation, position_variation, i, 2000 + seed) * 0.005 + position_offset[1])
    local oy = T_CUSTOM_FLARE_DELTA_Y
        * (hi + obj.rand(-position_variation, position_variation, i, 3000 + seed) * 0.005 + position_offset[2])
    local oz = T_CUSTOM_FLARE_DELTA_Z
        * (hi + obj.rand(-position_variation, position_variation, i, 4000 + seed) * 0.005 + position_offset[3])
    local zoom = T_CUSTOM_FLARE_DELTA_X * T_CUSTOM_FLARE_DELTA_X
        + T_CUSTOM_FLARE_DELTA_Y * T_CUSTOM_FLARE_DELTA_Y
        + T_CUSTOM_FLARE_DELTA_Z * T_CUSTOM_FLARE_DELTA_Z
    if zoom == 0 or check_sequential_scale == 0 then
        zoom = 1
    else
        zoom = math.sqrt(
            (
                (T_CUSTOM_FLARE_DELTA_X + ox) * (T_CUSTOM_FLARE_DELTA_X + ox)
                + (T_CUSTOM_FLARE_DELTA_Y + oy) * (T_CUSTOM_FLARE_DELTA_Y + oy)
                + (T_CUSTOM_FLARE_DELTA_Z + oz) * (T_CUSTOM_FLARE_DELTA_Z + oz)
            )
                / zoom
                * 0.25
        )
    end
    ox = T_CUSTOM_FLARE_CENTER_X + ox
    oy = T_CUSTOM_FLARE_CENTER_Y + oy
    oz = T_CUSTOM_FLARE_CENTER_Z + oz
    zoom = zoom * size * (1 - obj.rand(0, size_variation_percent, i, 5000 + seed) * 0.01)
    local alpha = obj.rand(0, 100, i, frame_index + seed) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = intensity
        * alpha
        * obj.rand(100 - intensity_variation_percent * 0.5, 100 + intensity_variation_percent * 0.5, i, 6000 + seed)
        * 0.01
    local rz = base_rotation + obj.rand(-rotation_variation, rotation_variation, i, 7000 + seed)
    if check_align_to_anchor == 1 then
        rz = rz + math.deg(math.atan2(T_CUSTOM_FLARE_DELTA_Y, T_CUSTOM_FLARE_DELTA_X))
    end
    obj.draw(ox, oy, oz, zoom, alpha, 0, 0, rz)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
