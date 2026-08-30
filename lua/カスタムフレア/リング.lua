--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$track:幅
---min=0
---max=4000
---step=0.1
local track_width = 10

---$track:数
---min=1
---max=100
---step=1
local track_count = 3

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
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local size = track_size
local ring_width = track_width
local count = track_count
local intensity = track_intensity * 0.01
local t = position_range_percent[1]
local position_variation = position_range_percent[2]
local distribution_scale = distribution_percent[1] * 0.01
local distribution_variation = distribution_percent[2]
position_offset[1] = position_offset[1] * 0.01
position_offset[2] = position_offset[2] * 0.01
position_offset[3] = position_offset[3] * 0.01
obj.load("figure", "円", color, size, ring_width)
obj.effect("ぼかし", "範囲", blur)
local frame_index = math.floor(obj.time * obj.framerate)
for i = 1, count do
    if color_variation_percent > 0 then
        local h, s, v = HSV(color)
        h = math.floor(h + 3.6 * obj.rand(0, color_variation_percent, i, seed)) % 360
        color = HSV(h, s, v)
        obj.load("figure", "円", color, size, ring_width)
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
    zoom = zoom * (1 - obj.rand(0, size_variation_percent, i, 5000 + seed) * 0.01)
    local alpha = obj.rand(0, 100, i, frame_index + seed) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = intensity
        * alpha
        * obj.rand(100 - intensity_variation_percent * 0.5, 100 + intensity_variation_percent * 0.5, i, 6000 + seed)
        * 0.01
    obj.draw(ox, oy, oz, zoom, alpha)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
