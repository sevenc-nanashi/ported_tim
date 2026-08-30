--label:${ROOT_CATEGORY}\切り替え効果
---$track:割合
---min=0
---max=100
---step=0.1
local track_ratio = 30

---$track:幅
---min=5
---max=2000
---step=0.1
local track_width = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 60

---$track:基準
---min=-100
---max=100
---step=0.1
local track_base = 0

---$track:時間差[%]
---min=-100
---max=100
---step=0.1
local track_time_offset_percent = 0

---$check:透明度反転
local check_invert_opacity = 0

local transition_progress = 100 - track_ratio
track_time_offset_percent = track_time_offset_percent * 0.01
local absolute_time_offset = math.abs(track_time_offset_percent)

obj.copybuffer("cache:original", "object")
transition_progress = transition_progress * 0.01
local stripe_width = track_width
local angle_degrees = track_angle
local angle_radians = math.rad(angle_degrees)
local base_offset_ratio = track_base * 0.005

local width, height = obj.getpixel()
local diagonal_length = math.sqrt(width * width + height * height)
local stripe_count = math.ceil(diagonal_length * 0.5 / stripe_width)

local angle_sine = math.sin(angle_radians)
local negative_angle_cosine = -math.cos(angle_radians)

for i = -stripe_count, stripe_count do
    local stripe_progress = transition_progress * (2 * stripe_count * absolute_time_offset + 1)
        - stripe_count * absolute_time_offset
    stripe_progress = stripe_progress - i * track_time_offset_percent
    if stripe_progress > 1 then
        stripe_progress = 1
    end

    local visible_width = math.floor((stripe_width + 1) * stripe_progress)

    local stripe_center_offset = i * stripe_width + visible_width * base_offset_ratio
    if stripe_progress > 0 and visible_width > 0 then
        obj.effect(
            "斜めクリッピング",
            "中心X",
            stripe_center_offset * angle_sine,
            "中心Y",
            stripe_center_offset * negative_angle_cosine,
            "角度",
            angle_degrees,
            "ぼかし",
            0,
            "幅",
            -visible_width
        )
    end
end
if check_invert_opacity == 1 then
    obj.copybuffer("cache:cropped", "object")
    obj.setoption("drawtarget", "tempbuffer", width, height)
    obj.copybuffer("tempbuffer", "cache:original")
    obj.copybuffer("object", "cache:cropped")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("object", "tempbuffer")
end
