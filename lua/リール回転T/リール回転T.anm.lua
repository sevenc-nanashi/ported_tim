--label:${ROOT_CATEGORY}\アニメーション効果

---$track:開始位置％
---min=0
---max=5000
---step=0.1
local track_open_position_percent = 200

---$track:オーバー量％
---min=0
---max=100
---step=0.1
local track_over_percent = 10

---$track:方向
---min=-360
---max=360
---step=0.1
local track_direction = -180

---$track:ブラー
---min=0
---max=1000
---step=0.1
local track_blur = 100

---$select:基準軸
---縦=0
---横=1
local select_base_axis = 0

---$check:開始位置角度自動調整
local check_auto_adjust_start_angle = false

---$track:開始オーバー補正％
---min=0
---max=500
---step=0.1
local track_start_over_correction_percent = 100

---$track:終了オーバー補正％
---min=0
---max=500
---step=0.1
local track_end_over_correction_percent = 100

---$track:開始オーバー時間％
---min=0
---max=100
---step=0.1
local track_start_over_time_percent = 10

---$track:終了オーバー時間％
---min=0
---max=100
---step=0.1
local track_end_over_time_percent = 10

---$track:オフセット％
---min=-5000
---max=5000
---step=0.1
local track_offset_percent = 0

---$track:時間範囲開始％
---min=0
---max=100
---step=0.1
local track_time_range_start_percent = 0

---$track:時間範囲終了％
---min=0
---max=100
---step=0.1
local track_time_range_end_percent = 100

local smooth_position = function(time_progress)
    return time_progress * time_progress * (3 - 2 * time_progress)
end
local smooth_speed = function(time_progress)
    return 6 * time_progress * (1 - time_progress)
end

local image_width, image_height = obj.getpixel()
local time_progress = obj.time / obj.totaltime

local initial_position = track_open_position_percent * 0.01
local overshoot_amount = track_over_percent * 0.01
local direction_degrees = track_direction
local blur_ratio = track_blur * 0.01

local direction_cosine = math.cos(direction_degrees * math.pi / 180)
local direction_sine = math.sin(-direction_degrees * math.pi / 180)
local base_size = (select_base_axis == 1) and image_width or image_height

if check_auto_adjust_start_angle then
    local x = base_size * initial_position * direction_sine
    local y = base_size * initial_position * direction_cosine
    x = image_width * math.floor((x + image_width * 0.5) / image_width)
    y = image_height * math.floor((y + image_height * 0.5) / image_height)
    local adjusted_distance = math.sqrt(x * x + y * y)
    initial_position = adjusted_distance / base_size
    direction_degrees = math.atan2(x, y)
    direction_cosine = math.cos(direction_degrees)
    direction_sine = math.sin(direction_degrees)
    direction_degrees = 180 - direction_degrees * 180 / math.pi
end

local start_overshoot = overshoot_amount * track_start_over_correction_percent * 0.01
local end_overshoot = overshoot_amount * track_end_over_correction_percent * 0.01

local start_overshoot_duration = track_start_over_time_percent * 0.01
local end_overshoot_duration = track_end_over_time_percent * 0.01

local time_range_start = math.max(0, math.min(1, track_time_range_start_percent * 0.01))
local time_range_end = math.max(0, math.min(1, track_time_range_end_percent * 0.01))
time_progress = time_range_start * (1 - time_progress) + time_progress * time_range_end

local position_offset = track_offset_percent * 0.01

blur_ratio = blur_ratio * (time_range_end - time_range_start) / (obj.totaltime * obj.framerate)

local reel_position
if time_progress < start_overshoot_duration and start_overshoot_duration ~= 0 then
    time_progress = time_progress / start_overshoot_duration
    reel_position = initial_position + start_overshoot * smooth_position(time_progress) + position_offset
    blur_ratio = blur_ratio * start_overshoot * smooth_speed(time_progress) / start_overshoot_duration
elseif time_progress > 1 - end_overshoot_duration and end_overshoot_duration ~= 0 then
    time_progress = (time_progress - 1 + end_overshoot_duration) / end_overshoot_duration
    reel_position = -end_overshoot * (1 - smooth_position(time_progress)) + position_offset
    blur_ratio = blur_ratio * end_overshoot * smooth_speed(time_progress) / end_overshoot_duration
else
    time_progress = (time_progress - start_overshoot_duration) / (1 - start_overshoot_duration - end_overshoot_duration)
    reel_position = initial_position
        + start_overshoot
        - (initial_position + start_overshoot + end_overshoot) * smooth_position(time_progress)
        + position_offset
    blur_ratio = blur_ratio
        * (initial_position + start_overshoot + end_overshoot)
        * smooth_speed(time_progress)
        / (1 - start_overshoot_duration - end_overshoot_duration)
end
blur_ratio = math.abs(blur_ratio / 2)

obj.setoption("drawtarget", "tempbuffer", image_width, image_height)

local draw_position_y = base_size * reel_position * direction_cosine
local draw_position_x = base_size * reel_position * direction_sine
draw_position_x = (draw_position_x % image_width)
draw_position_y = (draw_position_y % image_height)

obj.draw(draw_position_x, draw_position_y)
obj.draw(draw_position_x, draw_position_y - image_height)
obj.draw(draw_position_x - image_width, draw_position_y)
obj.draw(draw_position_x - image_width, draw_position_y - image_height)
obj.load("tempbuffer")
obj.effect("方向ブラー", "角度", direction_degrees, "範囲", blur_ratio * base_size, "サイズ固定", 1)
