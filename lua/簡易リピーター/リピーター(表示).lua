--label:${ROOT_CATEGORY}\配置\@簡易リピーター
---$track:透過率%
---min=0
---max=100
---step=0.1
local track_transparency_percent = 0

---$track:個数
---min=2
---max=100
---step=1
local track_count = 5

---$track:基準回転
---min=-3600
---max=3600
---step=0.1
local track_base_rotation = 0

---$track:基準拡大
---min=0
---max=5000
---step=0.1
local track_base_scale = 100

---$check:重なり順
local check_reverse_order = 0

---$check:色の上書き
local check_override_color = 0

---$color:基準色
local start_color = 0xff0000

---$color:最終色
local end_color = 0x0000ff

---$select:合成モード
---通常=0
---加算=1
---減算=2
---乗算=3
---スクリーン=4
---オーバーレイ=5
---比較(明)=6
---比較(暗)=7
---輝度=8
---色差=9
---陰影=10
---明暗=11
---差分=12
local blend_mode = 0

---$check:位置ズレ補正
local check_restore_position = 1

--hide@start_color:check_override_color==0
--hide@end_color:check_override_color==0
--hide@blend_mode:check_override_color==0

local apply_change_rate = function(progress, change_rate)
    if change_rate > 0 then
        return progress ^ (1 + 5 * change_rate)
    else
        return 1 - (1 - progress) ^ (1 - 5 * change_rate)
    end
end

local original_ox = obj.ox
local original_oy = obj.oy
local original_cx = obj.cx
local original_cy = obj.cy
check_restore_position = check_restore_position or 0

local transparency_ratio = track_transparency_percent * 0.01
local repeat_count = math.floor(track_count)
local base_rotation = track_base_rotation
local base_scale = track_base_scale * 0.01

local start_rgb = { RGB(start_color) }
local end_rgb = { RGB(end_color) }

local position_x = T_REPEATER_X
local position_y = T_REPEATER_Y
local rotation_step = T_REPEATER_ROTATION
local scale_step = T_REPEATER_SCALE
local mode = T_REPEATER_MODE

local file_path, start_time, time_step, loop_movie, load_alpha
if mode == 1 then
    file_path = T_REPEATER_FILE
    start_time = T_REPEATER_START_TIME
    time_step = T_REPEATER_TIME_STEP
    loop_movie = T_REPEATER_LOOP
    load_alpha = T_REPEATER_LOAD_ALPHA

    T_REPEATER_FILE = nil
    T_REPEATER_START_TIME = nil
    T_REPEATER_TIME_STEP = nil
    T_REPEATER_LOOP = nil
    T_REPEATER_LOAD_ALPHA = nil
end

local x_change_rate = T_REPEATER_X_RATE or 0
local y_change_rate = T_REPEATER_Y_RATE or 0
local scale_change_rate = T_REPEATER_SCALE_RATE or 0
local rotation_change_rate = T_REPEATER_ROTATION_RATE or 0

T_REPEATER_X = nil
T_REPEATER_Y = nil
T_REPEATER_ROTATION = nil
T_REPEATER_SCALE = nil
T_REPEATER_MODE = nil
T_REPEATER_X_RATE = nil
T_REPEATER_Y_RATE = nil
T_REPEATER_SCALE_RATE = nil
T_REPEATER_ROTATION_RATE = nil

local start_index, end_index, index_step
if check_reverse_order == 0 then
    start_index, end_index, index_step = 0, repeat_count - 1, 1
else
    start_index, end_index, index_step = repeat_count - 1, 0, -1
end

local movie_duration
if mode == 1 then
    movie_duration = obj.load("movie", file_path)
end

local w, h = obj.getpixel()

local positions_x = {}
local positions_y = {}
local scales = {}
local rotations = {}
local max_x = 0
local max_y = 0
local min_x = 0
local min_y = 0

for i = 0, repeat_count - 1 do
    local progress = i / (repeat_count - 1)
    local prx = apply_change_rate(progress, x_change_rate)
    local pry = apply_change_rate(progress, y_change_rate)
    local przo = apply_change_rate(progress, scale_change_rate)
    local prrz = apply_change_rate(progress, rotation_change_rate)
    positions_x[i] = position_x * prx
    positions_y[i] = position_y * pry
    scales[i] = (1 + (scale_step - 1) * przo) * base_scale
    rotations[i] = base_rotation + rotation_step * prrz

    local rotations = math.rad(rotations[i])
    local co = math.abs(math.cos(rotations))
    local si = math.abs(math.sin(rotations))
    local ww1 = (w * co + h * si) * scales[i] * 0.5
    local hh1 = (w * si + h * co) * scales[i] * 0.5
    max_x = math.max(ww1 + positions_x[i], max_x)
    max_y = math.max(hh1 + positions_y[i], max_y)
    min_x = math.min(-ww1 + positions_x[i], min_x)
    min_y = math.min(-hh1 + positions_y[i], min_y)
end

local center_x = (max_x + min_x) * 0.5
local center_y = (max_y + min_y) * 0.5

obj.setoption("drawtarget", "tempbuffer", max_x - min_x, max_y - min_y)

for i = start_index, end_index, index_step do
    local progress = i / (repeat_count - 1)
    if mode == 1 then
        local time = start_time + i * time_step
        if loop_movie == 1 then
            time = time % movie_duration
        end
        obj.load("movie", file_path, time, load_alpha)
    end
    if check_override_color == 1 then
        local cc = RGB(
            math.floor((1 - progress) * start_rgb[1] + progress * end_rgb[1]),
            math.floor((1 - progress) * start_rgb[2] + progress * end_rgb[2]),
            math.floor((1 - progress) * start_rgb[3] + progress * end_rgb[3])
        )
        obj.effect("グラデーション", "color", cc, "color2", cc, "blend", blend_mode)
    end
    obj.draw(
        positions_x[i] - center_x,
        positions_y[i] - center_y,
        0,
        scales[i],
        1 - progress * transparency_ratio,
        0,
        0,
        rotations[i]
    )
end
obj.load("tempbuffer")
if check_restore_position == 1 then
    obj.ox = original_ox
    obj.oy = original_oy
    obj.cx = original_cx
    obj.cy = original_cy
end
obj.cx = obj.cx - center_x
obj.cy = obj.cy - center_y
