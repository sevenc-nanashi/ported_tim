--label:${ROOT_CATEGORY}\配置\@TrackingラインEasy
---$track:開始/シフト
---min=0
---max=100
---step=0.01
local track_start_shift = 50

---$track:終了/全長
---min=0
---max=100
---step=0.01
local track_end_total_length = 0

---$track:頂点数
---min=2
---max=16
---step=1
local track_vertex_count = 2

---$track:間隔
---min=0.1
---max=500
---step=0.1
local track_interval = 5

---$select:描画方法
---直線=0
---曲線=1
---方法2=2
local drawing_method = 1

---$track:定数(方法2のみ)
---min=0
---max=100
---step=0.1
local curve_tension = 35

---$check:等速度_等間隔
local use_equal_spacing = 0

---$track:精度
---min=1
---max=1000
---step=1
local interpolation_accuracy = 20

---$check:環状にする
local closed_loop = 0

---$check:同時に出現
local simultaneous = 0

---$check:全長指定表示
local use_total_length = 0

---$value:線幅
local line_width_percentages = { 100, 100, 100 }

---$color:変化色
local gradient_color = nil

---$value:領域拡張
local area_padding = { 0, 0 }

---$value:座標
local control_points = { 0, 0, 100, 100 }

---$check:頂点群を分離
local separate_vertex_groups = false

--hide@curve_tension:drawing_method~=2
--hide@interpolation_accuracy:use_equal_spacing==0
--hide@interpolation_accuracy:drawing_method==0

T_TRACKING = {}

T_TRACKING.draw = function(tracking_state)
    local start_progress = tracking_state.start_progress
    local end_progress = tracking_state.end_progress

    local interpolate_point
    if tracking_state.drawing_method == 1 then
        interpolate_point = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            return obj.interpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
        end
    elseif tracking_state.drawing_method == 2 then
        interpolate_point = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            local x10 = x1 - x0
            local x21 = x2 - x1
            local x32 = x3 - x2
            local y10 = y1 - y0
            local y21 = y2 - y1
            local y32 = y3 - y2

            local l0 = math.sqrt(x10 * x10 + y10 * y10)
            local l1 = math.sqrt(x21 * x21 + y21 * y21)
            local l2 = math.sqrt(x32 * x32 + y32 * y32)

            if l1 > 0 then
                x0 = x1 + tracking_state.curve_tension * (x21 * l0 + x10 * l1) / (l1 + l0)
                x3 = x2 - tracking_state.curve_tension * (x21 * l2 + x32 * l1) / (l1 + l2)
                y0 = y1 + tracking_state.curve_tension * (y21 * l0 + y10 * l1) / (l1 + l0)
                y3 = y2 - tracking_state.curve_tension * (y21 * l2 + y32 * l1) / (l1 + l2)
                local s = 1 - t
                x1 = s * s * s * x1 + 3 * s * s * t * x0 + 3 * s * t * t * x3 + t * t * t * x2
                y1 = s * s * s * y1 + 3 * s * s * t * y0 + 3 * s * t * t * y3 + t * t * t * y2
            end
            return x1, y1
        end
    else
        interpolate_point = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            return x1 + t * (x2 - x1), y1 + t * (y2 - y1)
        end
    end

    if tracking_state.use_total_length == 1 then
        local st = start_progress
        local ed = end_progress
        end_progress = st * (ed + 1) - ed
        start_progress = end_progress + ed
    else
        if start_progress < end_progress then
            start_progress, end_progress = end_progress, start_progress
        end
    end

    local output_alpha = 0

    if not tracking_state.separate_vertex_groups then
        for i = 2, #tracking_state.points_x do
            for j = 1, #tracking_state.points_x[i] do
                table.insert(tracking_state.points_x[1], tracking_state.points_x[i][j])
                table.insert(tracking_state.points_y[1], tracking_state.points_y[i][j])
            end
            tracking_state.points_x[i] = nil
        end
    end

    local point_counts = {}
    for i = 1, #tracking_state.points_x do
        point_counts[i] = #tracking_state.points_x[i]
        if tracking_state.closed_loop[i] == 1 then --円の場合
            tracking_state.points_x[i][0] = tracking_state.points_x[i][point_counts[i]]
            tracking_state.points_y[i][0] = tracking_state.points_y[i][point_counts[i]]
            tracking_state.points_x[i][point_counts[i] + 1] = tracking_state.points_x[i][1]
            tracking_state.points_y[i][point_counts[i] + 1] = tracking_state.points_y[i][1]
            tracking_state.points_x[i][point_counts[i] + 2] = tracking_state.points_x[i][2]
            tracking_state.points_y[i][point_counts[i] + 2] = tracking_state.points_y[i][2]
            point_counts[i] = point_counts[i] + 1
        else --その他
            tracking_state.points_x[i][0] = tracking_state.points_x[i][1]
            tracking_state.points_y[i][0] = tracking_state.points_y[i][1]
            tracking_state.points_x[i][point_counts[i] + 1] = tracking_state.points_x[i][point_counts[i]]
            tracking_state.points_y[i][point_counts[i] + 1] = tracking_state.points_y[i][point_counts[i]]
        end
    end

    local cumulative_lengths = {}
    local segment_length_ratios = {}
    cumulative_lengths[0] = 0
    if tracking_state.use_equal_spacing == 0 then
        for i = 1, #tracking_state.points_x do
            cumulative_lengths[i] = cumulative_lengths[i - 1] + point_counts[i] - 1
        end
    else
        for i = 1, #tracking_state.points_x do
            segment_length_ratios[i] = {}
            segment_length_ratios[i][0] = 0
            for j = 1, point_counts[i] - 1 do
                segment_length_ratios[i][j] = 0
                local x0 = tracking_state.points_x[i][j - 1]
                local x1 = tracking_state.points_x[i][j]
                local x2 = tracking_state.points_x[i][j + 1]
                local x3 = tracking_state.points_x[i][j + 2]

                local y0 = tracking_state.points_y[i][j - 1]
                local y1 = tracking_state.points_y[i][j]
                local y2 = tracking_state.points_y[i][j + 1]
                local y3 = tracking_state.points_y[i][j + 2]

                local sampled_points_x = {}
                local sampled_points_y = {}

                local sample_count = math.ceil(tracking_state.interpolation_accuracy * 0.5)
                for k = 0, sample_count do
                    local t = k / sample_count
                    sampled_points_x[k], sampled_points_y[k] = interpolate_point(t, x0, y0, x1, y1, x2, y2, x3, y3)
                end
                for k = 0, sample_count - 1 do
                    segment_length_ratios[i][j] = segment_length_ratios[i][j]
                        + math.sqrt(
                            (sampled_points_x[k + 1] - sampled_points_x[k]) ^ 2
                                + (sampled_points_y[k + 1] - sampled_points_y[k]) ^ 2
                        )
                end
                segment_length_ratios[i][j] = segment_length_ratios[i][j] + segment_length_ratios[i][j - 1]
            end
            cumulative_lengths[i] = segment_length_ratios[i][point_counts[i] - 1] + cumulative_lengths[i - 1]
            for j = 1, point_counts[i] - 1 do
                segment_length_ratios[i][j] = segment_length_ratios[i][j]
                    / segment_length_ratios[i][point_counts[i] - 1]
            end
        end
    end

    local max_x = math.max(unpack(tracking_state.points_x[1]))
    local max_y = math.max(unpack(tracking_state.points_y[1]))
    local min_x = math.min(unpack(tracking_state.points_x[1]))
    local min_y = math.min(unpack(tracking_state.points_y[1]))
    for i = 2, #tracking_state.points_x do
        max_x = math.max(max_x, unpack(tracking_state.points_x[i]))
        max_y = math.max(max_y, unpack(tracking_state.points_y[i]))
        min_x = math.min(min_x, unpack(tracking_state.points_x[i]))
        min_y = math.min(min_y, unpack(tracking_state.points_y[i]))
    end

    local render_width = (max_x - min_x) * 1.2 + 2 * tracking_state.base_size + tracking_state.area_padding[1]
    local render_height = (max_y - min_y) * 1.2 + 2 * tracking_state.base_size + tracking_state.area_padding[2]
    local render_center_x = (max_x + min_x) * 0.5
    local render_center_y = (max_y + min_y) * 0.5

    obj.setoption("drawtarget", "tempbuffer", render_width, render_height)

    local total_path_length = cumulative_lengths[#tracking_state.points_x]
    for i = 1, #tracking_state.points_x do
        cumulative_lengths[i] = cumulative_lengths[i] / total_path_length
    end

    local t = start_progress
    local t0 = t * total_path_length
    for i = 0, #tracking_state.points_x - 1 do
        if cumulative_lengths[i] <= t and t < cumulative_lengths[i + 1] then
            t0 = (i + (t - cumulative_lengths[i]) / (cumulative_lengths[i + 1] - cumulative_lengths[i]))
            break
        end
    end
    start_progress = t0

    t = end_progress
    t0 = t * total_path_length
    for i = 0, #tracking_state.points_x - 1 do
        if cumulative_lengths[i] <= t and t < cumulative_lengths[i + 1] then
            t0 = (i + (t - cumulative_lengths[i]) / (cumulative_lengths[i + 1] - cumulative_lengths[i]))
            break
        end
    end
    end_progress = t0

    local max_group_length_ratio = 0
    if tracking_state.simultaneous == 1 then
        for i = 1, #tracking_state.points_x do
            max_group_length_ratio = math.max(max_group_length_ratio, cumulative_lengths[i] - cumulative_lengths[i - 1])
        end
    end

    for i = 1, #tracking_state.points_x do
        local start_progress = start_progress
        local end_progress = end_progress

        if tracking_state.simultaneous == 0 then
            start_progress = start_progress - i + 1
            end_progress = end_progress - i + 1
        else
            start_progress = start_progress / #tracking_state.points_x
            end_progress = end_progress / #tracking_state.points_x
            if tracking_state.use_equal_spacing == 1 then
                start_progress = start_progress
                    * max_group_length_ratio
                    / (cumulative_lengths[i] - cumulative_lengths[i - 1])
                end_progress = end_progress
                    * max_group_length_ratio
                    / (cumulative_lengths[i] - cumulative_lengths[i - 1])
            end
        end

        if not (start_progress < 0 or end_progress > 1) then
            if start_progress > 1 then
                start_progress = 1
            end
            if end_progress < 0 then
                end_progress = 0
            end

            if tracking_state.use_equal_spacing == 1 then
                local equalized_start_progress = start_progress
                local t0 = equalized_start_progress
                for j = 0, point_counts[i] - 2 do
                    if
                        segment_length_ratios[i][j] <= equalized_start_progress
                        and equalized_start_progress < segment_length_ratios[i][j + 1]
                    then
                        t0 = (
                            j
                            + (equalized_start_progress - segment_length_ratios[i][j])
                                / (segment_length_ratios[i][j + 1] - segment_length_ratios[i][j])
                        ) / (point_counts[i] - 1)
                        break
                    end
                end
                start_progress = t0

                local equalized_end_progress = end_progress
                t0 = equalized_end_progress
                for j = 0, point_counts[i] - 2 do
                    if
                        segment_length_ratios[i][j] <= equalized_end_progress
                        and equalized_end_progress < segment_length_ratios[i][j + 1]
                    then
                        t0 = (
                            j
                            + (equalized_end_progress - segment_length_ratios[i][j])
                                / (segment_length_ratios[i][j + 1] - segment_length_ratios[i][j])
                        ) / (point_counts[i] - 1)
                        break
                    end
                end
                end_progress = t0
            end
            local drawn_point_count = 0
            local drawn_points_x = {}
            local drawn_points_y = {}
            for j = 1, point_counts[i] - 1 do
                local step_direction
                if j == point_counts[i] - 1 and tracking_state.closed_loop[i] == 0 then
                    step_direction = 1
                else
                    step_direction = -1
                end

                local x0 = tracking_state.points_x[i][j - 1]
                local x1 = tracking_state.points_x[i][j]
                local x2 = tracking_state.points_x[i][j + 1]
                local x3 = tracking_state.points_x[i][j + 2]

                local y0 = tracking_state.points_y[i][j - 1]
                local y1 = tracking_state.points_y[i][j]
                local y2 = tracking_state.points_y[i][j + 1]
                local y3 = tracking_state.points_y[i][j + 2]

                local r
                local sampled_length_ratios = {}

                if tracking_state.use_equal_spacing == 1 then
                    local sampled_points_x = {}
                    local sampled_points_y = {}
                    for k = 0, tracking_state.interpolation_accuracy do
                        local t = k / tracking_state.interpolation_accuracy
                        sampled_points_x[k], sampled_points_y[k] = interpolate_point(t, x0, y0, x1, y1, x2, y2, x3, y3)
                    end
                    sampled_length_ratios[0] = 0
                    for k = 1, tracking_state.interpolation_accuracy do
                        sampled_length_ratios[k] = sampled_length_ratios[k - 1]
                            + math.sqrt(
                                (sampled_points_x[k] - sampled_points_x[k - 1]) ^ 2
                                    + (sampled_points_y[k] - sampled_points_y[k - 1]) ^ 2
                            )
                    end

                    r = sampled_length_ratios[tracking_state.interpolation_accuracy]

                    for k = 1, tracking_state.interpolation_accuracy do
                        sampled_length_ratios[k] = sampled_length_ratios[k]
                            / sampled_length_ratios[tracking_state.interpolation_accuracy]
                    end
                else
                    r = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
                end

                local step = 1 / math.ceil(r / tracking_state.interval)

                local start_progress = (point_counts[i] - 1) * start_progress - (j - 1)
                local end_progress = (point_counts[i] - 1) * end_progress - (j - 1)

                if not (start_progress < 0 or end_progress > 1) then
                    if start_progress > 1 then
                        start_progress = 1
                    end
                    if end_progress < 0 then
                        end_progress = 0
                    end
                    end_progress = step * math.ceil(end_progress / step)

                    if tracking_state.use_equal_spacing == 0 then
                        for t = end_progress, start_progress + step_direction * step * 0.01, step do
                            local x, y = interpolate_point(t, x0, y0, x1, y1, x2, y2, x3, y3)
                            drawn_point_count = drawn_point_count + 1
                            drawn_points_x[drawn_point_count], drawn_points_y[drawn_point_count] =
                                x - render_center_x, y - render_center_y
                            output_alpha = 1
                        end
                    else
                        for t = end_progress, start_progress + step_direction * step * 0.01, step do
                            local t0 = t
                            for k = 0, tracking_state.interpolation_accuracy - 1 do
                                if sampled_length_ratios[k] <= t and t < sampled_length_ratios[k + 1] then
                                    t0 = (
                                        k
                                        + (t - sampled_length_ratios[k])
                                            / (sampled_length_ratios[k + 1] - sampled_length_ratios[k])
                                    ) / tracking_state.interpolation_accuracy
                                    break
                                end
                            end

                            local x, y = interpolate_point(t0, x0, y0, x1, y1, x2, y2, x3, y3)
                            drawn_point_count = drawn_point_count + 1
                            drawn_points_x[drawn_point_count], drawn_points_y[drawn_point_count] =
                                x - render_center_x, y - render_center_y
                            output_alpha = 1
                        end
                    end
                end
            end

            if tracking_state.gradient_color == "" then
                for k = 1, drawn_point_count do
                    local s = (k - 1) / (drawn_point_count - 1)
                    s = s * tracking_state.line_width_percentages[3]
                        + (
                                2
                                    * s
                                    * (2 * tracking_state.line_width_percentages[2] - tracking_state.line_width_percentages[1] - tracking_state.line_width_percentages[3])
                                + tracking_state.line_width_percentages[1]
                            )
                            * (1 - s)
                    obj.draw(drawn_points_x[k], drawn_points_y[k], 0, s * 0.01)
                end
            else
                obj.copybuffer("cache:img", "object")
                for k = 1, drawn_point_count do
                    local s = (k - 1) / (drawn_point_count - 1)
                    local s2 = s * tracking_state.line_width_percentages[3]
                        + (
                                2
                                    * s
                                    * (2 * tracking_state.line_width_percentages[2] - tracking_state.line_width_percentages[1] - tracking_state.line_width_percentages[3])
                                + tracking_state.line_width_percentages[1]
                            )
                            * (1 - s)
                    obj.copybuffer("object", "cache:img")
                    obj.effect(
                        "単色化",
                        "color",
                        tracking_state.gradient_color,
                        "輝度を保持する",
                        0,
                        "強さ",
                        100 * (1 - s)
                    )
                    obj.draw(drawn_points_x[k], drawn_points_y[k], 0, s2 * 0.01)
                end
            end
        end
    end
    obj.alpha = output_alpha
    obj.load("tempbuffer")
    obj.cx = obj.cx - render_center_x
    obj.cy = obj.cy - render_center_y
end

T_TRACKING.base_size = math.max(obj.getpixel())
T_TRACKING.drawing_method = drawing_method or 1
T_TRACKING.curve_tension = (curve_tension or 35) * 0.01
T_TRACKING.use_equal_spacing = use_equal_spacing or 0
T_TRACKING.interpolation_accuracy = interpolation_accuracy or 10
T_TRACKING.use_total_length = use_total_length or 0
T_TRACKING.simultaneous = simultaneous or 0
T_TRACKING.line_width_percentages = line_width_percentages or { 100, 100, 100 }
T_TRACKING.gradient_color = gradient_color or ""
T_TRACKING.area_padding = area_padding or { 0, 0 }

T_TRACKING.start_progress = track_start_shift * 0.01
T_TRACKING.end_progress = track_end_total_length * 0.01
local vertex_count = track_vertex_count
T_TRACKING.interval = track_interval
T_TRACKING.separate_vertex_groups = separate_vertex_groups

obj.setanchor("control_points", vertex_count, "line")

T_TRACKING.closed_loop = {}
T_TRACKING.closed_loop[1] = closed_loop or 0
T_TRACKING.points_x = {}
T_TRACKING.points_y = {}
T_TRACKING.points_x[1] = {}
T_TRACKING.points_y[1] = {}
for i = 1, vertex_count do
    T_TRACKING.points_x[1][i] = control_points[2 * i - 1]
    T_TRACKING.points_y[1][i] = control_points[2 * i]
end
if obj.getoption("script_name", 1) ~= "TrackingラインEasy(頂点追加)@TrackingラインEasy@tim.anm2" then
    T_TRACKING.draw(T_TRACKING)
    T_TRACKING = nil
end
