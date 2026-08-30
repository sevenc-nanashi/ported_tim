--label:${ROOT_CATEGORY}\装飾\@ストロークT
---$track:進捗度1
---min=0
---max=100
---step=0.01
local track_progress_1 = 100

---$track:進捗度2
---min=0
---max=100
---step=0.01
local track_progress_2 = 0

---$track:区間個数
---min=1
---max=5000
---step=1
local track_count = 10

---$track:ランダム性
---min=0
---max=100
---step=0.1
local track_randomness = 0

---$check:重なり反転
local check_reverse_overlap = 0

---$check:環状軌道
local check_closed_path = 0

---$select:軌道
---曲線=0
---円=1
---直線=2
local path_type = 1

---$check:進行方向
local check_follow_direction = 0

---$check:先頭表示
local check_show_leading_object = 0

---$track:位置ランダム性
---min=0
---max=10000
---step=1
local position_randomness = 200

---$track:領域拡大
---min=-5000
---max=5000
---step=1
local area_padding = 0

---$track:精度
---min=1
---max=1000
---step=1
local path_resolution = 20

local t1 = track_progress_1 * 0.01
local t2 = track_progress_2 * 0.01
if t2 < t1 then
    t1, t2 = t2, t1
end
local segment_count = track_count
local randomness = track_randomness * 0.01

T_STROKE_DRAW = function()
    local t_to_d = function(datat, segment_count)
        local data_d = {}
        local f_n = #datat
        datat[0] = datat[1]
        datat[f_n + 1] = datat[f_n]
        datat[f_n + 2] = datat[f_n]
        for i = 0, segment_count do
            local x = i * (f_n - 1) / segment_count + 1
            local xn = math.floor(x)
            local dx = x - xn
            data_d[i] = obj.interpolation(dx, datat[xn - 1], datat[xn], datat[xn + 1], datat[xn + 2])
        end
        return data_d
    end

    local interpolation_t = (function(k)
        if k == 0 then
            return function(t, x0, y0, x1, y1, x2, y2, x3, y3)
                if t <= 0.5 then
                    s = t + 0.5
                    return ((1 - s) * (1 - s) * x0 + (1 + 2 * s - 2 * s * s) * x1 + s * s * x2) / 2,
                        ((1 - s) * (1 - s) * y0 + (1 + 2 * s - 2 * s * s) * y1 + s * s * y2) / 2
                else
                    s = t - 0.5
                    return ((1 - s) * (1 - s) * x1 + (1 + 2 * s - 2 * s * s) * x2 + s * s * x3) / 2,
                        ((1 - s) * (1 - s) * y1 + (1 + 2 * s - 2 * s * s) * y2 + s * s * y3) / 2
                end
            end
        elseif k == 1 then
            return function(t, x0, y0, x1, y1, x2, y2, x3, y3) --正方形配置で円になるように特殊な計算
                local s, ax, ay, cx, cy, control_x, control_y, ex, ey, fx, fy
                if t <= 0.5 then
                    t = t + 0.5
                    ex, ey = (x0 + x1) * 0.5, (y0 + y1) * 0.5
                    control_x, control_y = x1, y1
                    fx, fy = (x1 + x2) * 0.5, (y1 + y2) * 0.5
                else
                    t = t - 0.5
                    ex, ey = (x1 + x2) * 0.5, (y1 + y2) * 0.5
                    control_x, control_y = x2, y2
                    fx, fy = (x2 + x3) * 0.5, (y2 + y3) * 0.5
                end
                t = math.tan(math.pi * 0.5 * t * 0.5)
                ax, ay = (1 - t) * ex + t * control_x, (1 - t) * ey + t * control_y
                s = 2 * t / (1 + t)
                cx, cy = (1 - s) * control_x + s * fx, (1 - s) * control_y + s * fy
                s = t * (1 + t) / (1 + t * t)
                return (1 - s) * ax + s * cx, (1 - s) * ay + s * cy
            end
        else
            return function(t, x0, y0, x1, y1, x2, y2, x3, y3)
                return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
            end
        end
    end)(path_type)

    local gosa_x, gosa_y, gosa_s, gosa_r, gosa_a, seed
    local zoomt, rott, alpt

    if T_STROKE_RANDOM_ENABLED then
        gosa_x = T_STROKE_ERROR_X
        gosa_y = T_STROKE_ERROR_Y
        gosa_s = T_STROKE_ERROR_SCALE
        gosa_r = T_STROKE_ERROR_ROTATION
        gosa_a = T_STROKE_ERROR_ALPHA
        seed = T_STROKE_SEED
        zoomt = T_STROKE_ZOOM_VALUES
        rott = T_STROKE_ROTATION_VALUES
        alpt = T_STROKE_ALPHA_VALUES
    else
        gosa_x = position_randomness
        gosa_y = position_randomness
        gosa_s = 60
        gosa_r = 40
        gosa_a = 0
        seed = 0
        zoomt = { 100 }
        rott = { 0 }
        alpt = { 0 }
    end
    T_STROKE_RANDOM_ENABLED = nil

    local anc = T_STROKE_ANCHORS
    local ac_n = T_STROKE_ANCHOR_COUNT

    if check_closed_path == 1 then
        ac_n = ac_n + 1
        anc[2 * ac_n - 1] = anc[1]
        anc[2 * ac_n] = anc[2]
    end

    local anc_x = {}
    local anc_y = {}
    for i = 1, ac_n do
        anc_x[i] = anc[2 * i - 1]
        anc_y[i] = anc[2 * i]
    end

    if check_closed_path == 0 then
        anc_x[0] = 2 * anc_x[1] - anc_x[2]
        anc_y[0] = 2 * anc_y[1] - anc_y[2]
        anc_x[ac_n + 1] = 2 * anc_x[ac_n] - anc_x[ac_n - 1]
        anc_y[ac_n + 1] = 2 * anc_y[ac_n] - anc_y[ac_n - 1]
    else
        anc_x[0] = anc_x[ac_n - 1]
        anc_y[0] = anc_y[ac_n - 1]
        anc_x[ac_n + 1] = anc_x[2]
        anc_y[ac_n + 1] = anc_y[2]
    end

    local ipos_x = {}
    local ipos_y = {}
    local current_segment_index = 1
    local x0, y0 = anc_x[0], anc_y[0]
    local x1, y1 = anc_x[1], anc_y[1]
    local x2, y2 = anc_x[2], anc_y[2]
    for i = 1, ac_n - 1 do
        local x3, y3 = anc_x[i + 2], anc_y[i + 2]
        for j = 0, path_resolution - 1 do
            local time = j / path_resolution
            ipos_x[current_segment_index], ipos_y[current_segment_index] =
                interpolation_t(time, x0, y0, x1, y1, x2, y2, x3, y3)
            current_segment_index = current_segment_index + 1
        end
        x0, y0 = x1, y1
        x1, y1 = x2, y2
        x2, y2 = x3, y3
    end
    if check_closed_path == 0 then
        ipos_x[current_segment_index], ipos_y[current_segment_index] = anc_x[ac_n], anc_y[ac_n]
    else
        ipos_x[current_segment_index], ipos_y[current_segment_index] = ipos_x[1], ipos_y[1]
    end
    local cumulative_lengths = {}
    cumulative_lengths[0] = 0
    for i = 1, current_segment_index - 1 do
        cumulative_lengths[i] = cumulative_lengths[i - 1]
            + math.sqrt((ipos_x[i + 1] - ipos_x[i]) ^ 2 + (ipos_y[i + 1] - ipos_y[i]) ^ 2)
    end
    --posN
    local pos_x = {}
    local pos_y = {}

    local step = cumulative_lengths[current_segment_index - 1] / (segment_count - 1)

    local k = 1
    local i = 1
    pos_x[1], pos_y[1] = ipos_x[1], ipos_y[1]

    repeat
        if cumulative_lengths[i] > k * step then
            local y = (k * step - cumulative_lengths[i - 1]) / (cumulative_lengths[i] - cumulative_lengths[i - 1])
            k = k + 1
            pos_x[k] = (1 - y) * ipos_x[i] + y * ipos_x[i + 1]
            pos_y[k] = (1 - y) * ipos_y[i] + y * ipos_y[i + 1]
        else
            i = i + 1
        end
    until i > current_segment_index - 1

    if check_closed_path == 0 then
        pos_x[segment_count], pos_y[segment_count] = ipos_x[current_segment_index], ipos_y[current_segment_index]
        pos_x[0], pos_y[0] = pos_x[1], pos_y[1]
        pos_x[segment_count + 1], pos_y[segment_count + 1] = pos_x[segment_count], pos_y[segment_count]
    else
        pos_x[segment_count], pos_y[segment_count] = pos_x[1], pos_y[1]
        pos_x[0], pos_y[0] = pos_x[segment_count - 1], pos_y[segment_count - 1]
        pos_x[segment_count + 1], pos_y[segment_count + 1] = pos_x[2], pos_y[2]
        segment_count = segment_count - 1
    end
    local i1, i2, sti
    if check_reverse_overlap == 0 then
        i1 = math.floor(1 + (segment_count - 1) * t1)
        i2 = math.floor(1 + (segment_count - 1) * t2)
        sti = 1
    else
        i2 = math.floor(1 + (segment_count - 1) * t1)
        i1 = math.floor(1 + (segment_count - 1) * t2)
        sti = -1
    end
    if check_show_leading_object == 1 then
        i1 = math.ceil(i2)
    end

    --変動率率作成
    local x_d = {}
    local y_d = {}
    local zoom_d = {}
    local rot_d = {}
    local alp_d = {}

    zoom_d = t_to_d(zoomt, segment_count)
    rot_d = t_to_d(rott, segment_count)
    alp_d = t_to_d(alpt, segment_count)

    --自動角度
    local rotation_offsets = {}
    if check_follow_direction == 1 then
        for i = 1, segment_count do
            rotation_offsets[i] = math.deg(math.atan2(pos_y[i + 1] - pos_y[i - 1], pos_x[i + 1] - pos_x[i - 1]))
        end
    else
        for i = 1, segment_count do
            rotation_offsets[i] = 0
        end
    end

    for i = 1, segment_count do
        pos_x[i] = pos_x[i] + obj.rand(-gosa_x * 0.5, gosa_x * 0.5, i, 1000 + seed) * randomness
        pos_y[i] = pos_y[i] + obj.rand(-gosa_y * 0.5, gosa_y * 0.5, i, 2000 + seed) * randomness
    end

    --最大最小検出
    local max_x = pos_x[1]
    local min_x = pos_x[1]
    local max_y = pos_y[1]
    local min_y = pos_y[1]
    for i = 2, segment_count do
        max_x = math.max(pos_x[i], max_x)
        min_x = math.min(pos_x[i], min_x)
        max_y = math.max(pos_y[i], max_y)
        min_y = math.min(pos_y[i], min_y)
    end

    local w, h = obj.getpixel()
    local dw = math.max(w, h)

    local ww = max_x - min_x + dw + area_padding
    local hh = max_y - min_y + dw + area_padding
    local cw = (max_x + min_x) * 0.5
    local ch = (max_y + min_y) * 0.5

    obj.setoption("drawtarget", "tempbuffer", ww, hh)

    for i = i1, i2, sti do
        local zoom = zoom_d[i] * (1 + obj.rand(-gosa_s * 0.5, gosa_s * 0.5, i, 3000 + seed) * randomness * 0.01) * 0.01
        local alpha = (100 - alp_d[i]) * (1 + obj.rand(-gosa_a * 0.5, gosa_a * 0.5, i, 4000 + seed) * randomness * 0.01)
        local rz = obj.rand(-gosa_r * 0.5, gosa_r * 0.5, i, 5000 + seed) * randomness + rotation_offsets[i] + rot_d[i]
        alpha = math.min(1, math.max(0, alpha * 0.01))
        obj.draw(pos_x[i] - cw, pos_y[i] - ch, 0, zoom, alpha, 0, 0, rz)
    end

    obj.load("tempbuffer")
    obj.cx = obj.cx - cw
    obj.cy = obj.cy - ch
end

---$embed
local common = require("common")
if common.is_last_chain() then
    T_STROKE_DRAW()
    T_STROKE_ANCHORS = nil
    T_STROKE_ANCHOR_COUNT = nil
end
