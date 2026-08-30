--label:${ROOT_CATEGORY}\変形\@モーフィング
local initial_direction
---$track:変化度
---min=0
---max=100
---step=0.1
local track_change_amount = 50

---$track:サイズ
---min=0
---max=1000
---step=0.1
local track_size = 10

---$track:点数
---min=0
---max=20000
---step=1
local track_point_count = 120

---$track:オフセット
---min=-2000
---max=2000
---step=0.1
local track_offset = 0

---$track:変形前画像レイヤー
---min=0
---max=1000
---step=1
---zero_label=なし
local track_source_layer_index = 0

---$check:エフェクト取得
local check_include_effects = 1

---$figure:形状
local guide_figure = "円"

---$color:ドット色
local guide_color = 0xffffff

---$check:自動方向
local check_auto_direction = 0

---$check:一時保存EXT
local check_use_temp_save_extension = 0

--hide@check_include_effects:check_use_temp_save_extension==1

T_OUTLINE_MORPHING_OPTIONS = function(options)
    local make_outline = function(
        outline_x,
        outline_y,
        cumulative_lengths,
        threshold,
        image_width,
        image_height,
        target_point_offset_ratio
    )
        local diagonal_step = math.sqrt(2)
        local neighbor_offset_x = { -1, 0, 1, 1, 1, 0, -1, -1 }
        local neighbor_offset_y = { 1, 1, 1, 0, -1, -1, -1, 0 }
        local neighbor_distances = { diagonal_step, 1, diagonal_step, 1, diagonal_step, 1, diagonal_step, 1 }
        local half_width, half_height = image_width * 0.5, image_height * 0.5
        local outline_point_count = 0
        local previous_direction = 0
        local pixel_red, pixel_green, pixel_blue, pixel_alpha
        for j = 0, image_height - 1 do
            for i = 0, image_width - 1 do
                pixel_red, pixel_green, pixel_blue, pixel_alpha = obj.getpixel(i, j, "rgb")
                if pixel_alpha > threshold then
                    outline_x[0] = i
                    outline_y[0] = j
                    break
                end
            end
            if pixel_alpha > threshold then
                break
            end
        end
        cumulative_lengths[0] = 0
        local found_next_point
        local direction_index
        local neighbor_x
        local neighbor_y
        repeat
            found_next_point = 0
            for i = 0, 7 do
                direction_index = (previous_direction + 6 + i) % 8
                neighbor_x = outline_x[outline_point_count] + neighbor_offset_x[direction_index + 1]
                neighbor_y = outline_y[outline_point_count] + neighbor_offset_y[direction_index + 1]
                if neighbor_x >= 0 and neighbor_x < image_width and neighbor_y >= 0 and neighbor_y < image_height then
                    pixel_red, pixel_green, pixel_blue, pixel_alpha = obj.getpixel(neighbor_x, neighbor_y, "rgb")
                    if pixel_alpha > threshold then
                        outline_point_count = outline_point_count + 1
                        outline_x[outline_point_count] = neighbor_x
                        outline_y[outline_point_count] = neighbor_y
                        cumulative_lengths[outline_point_count] = neighbor_distances[direction_index + 1]
                        previous_direction = direction_index
                        if outline_point_count == 1 then
                            initial_direction = direction_index
                        end
                        found_next_point = 1
                        break
                    end
                end
            end
        until (
                outline_x[outline_point_count - 1] == outline_x[0]
                and outline_y[outline_point_count - 1] == outline_y[0]
                and initial_direction == direction_index
                and outline_point_count > 1
            ) or found_next_point == 0
        outline_point_count = outline_point_count - 1
        local total_outline_length = 0
        cumulative_lengths[-1] = 0

        if target_point_offset_ratio ~= 0 then
            target_point_offset_ratio = math.floor(target_point_offset_ratio * (outline_point_count - 1))
            local original_outline_x = {}
            local original_outline_y = {}
            for i = 0, outline_point_count do
                original_outline_x[i], original_outline_y[i] = outline_x[i], outline_y[i]
            end

            for i = 0, outline_point_count do
                local shifted_index = (i + target_point_offset_ratio) % outline_point_count
                outline_x[i], outline_y[i] = original_outline_x[shifted_index], original_outline_y[shifted_index]
            end
        end

        for i = 0, outline_point_count do
            outline_x[i], outline_y[i] = outline_x[i] - half_width, outline_y[i] - half_height
            total_outline_length = total_outline_length + cumulative_lengths[i]
            cumulative_lengths[i] = cumulative_lengths[i] + cumulative_lengths[i - 1]
        end
        for i = 1, outline_point_count do
            cumulative_lengths[i] = cumulative_lengths[i] / total_outline_length
        end
        return outline_point_count
    end

    local resample_outline = function(
        outline_x,
        outline_y,
        cumulative_lengths,
        outline_point_count,
        resampled_x,
        resampled_y,
        sample_count,
        sampling_offset
    )
        sampling_offset = sampling_offset % 1
        sampling_offset = sampling_offset % (1 / sample_count)
        local sample_index = 0
        for i = 0, outline_point_count do
            if sample_index / sample_count + sampling_offset <= cumulative_lengths[i] then
                resampled_x[sample_index] = outline_x[i]
                resampled_y[sample_index] = outline_y[i]
                sample_index = sample_index + 1
            end
        end
    end

    local source_weight = options.source_weight or 50
    local guide_size = options.guide_size or 10
    local sample_count = options.sample_count or 120
    local sampling_offset = options.sampling_offset or 0
    local threshold = options.threshold or 128
    local track_source_layer_index = options.source_layer_index or 1
    local guide_figure = options.guide_figure or "円"
    local guide_color = options.guide_color or 0xffffff
    local line_color = options.line_color or 0xffffff
    local check_auto_direction = options.auto_direction or 0
    local rotation_degrees = options.rotation_degrees or 0
    local line_width = options.line_width or 0
    local target_point_offset_ratio = (options.point_offset or 0) * 0.01

    local source_width, source_height = obj.getpixel()
    local source_outline_x = {}
    local source_outline_y = {}
    local source_cumulative_lengths = {}
    local source_outline_count = make_outline(
        source_outline_x,
        source_outline_y,
        source_cumulative_lengths,
        threshold,
        source_width,
        source_height,
        0
    )

    if check_use_temp_save_extension == 0 then
        check_include_effects = check_include_effects == 1 and true or false
        obj.load("layer", track_source_layer_index, check_include_effects)
    else
        ---$embed
        local extbuffer = require("extbuffer")
        extbuffer.read(track_source_layer_index)
    end

    local target_width, target_height = obj.getpixel()
    local target_outline_x = {}
    local target_outline_y = {}
    local target_cumulative_lengths = {}
    local target_outline_count = make_outline(
        target_outline_x,
        target_outline_y,
        target_cumulative_lengths,
        threshold,
        target_width,
        target_height,
        target_point_offset_ratio
    )

    sample_count = (sample_count > source_outline_count * 0.5 and source_outline_count * 0.5) or sample_count
    sample_count = (sample_count > target_outline_count * 0.5 and target_outline_count * 0.5) or sample_count
    sample_count = math.floor(sample_count)

    local resampled_source_x = {}
    local resampled_source_y = {}
    resample_outline(
        source_outline_x,
        source_outline_y,
        source_cumulative_lengths,
        source_outline_count,
        resampled_source_x,
        resampled_source_y,
        sample_count,
        sampling_offset
    )

    local resampled_target_x = {}
    local resampled_target_y = {}
    resample_outline(
        target_outline_x,
        target_outline_y,
        target_cumulative_lengths,
        target_outline_count,
        resampled_target_x,
        resampled_target_y,
        sample_count,
        sampling_offset
    )

    obj.setoption(
        "drawtarget",
        "tempbuffer",
        math.max(source_width, target_width) + 2 * guide_size,
        math.max(source_height, target_height) + 2 * guide_size
    )

    for i = 0, sample_count - 1 do
        resampled_source_x[i] = resampled_source_x[i] * source_weight + resampled_target_x[i] * (1 - source_weight)
        resampled_source_y[i] = resampled_source_y[i] * source_weight + resampled_target_y[i] * (1 - source_weight)
    end
    resampled_source_x[sample_count] = resampled_source_x[0]
    resampled_source_y[sample_count] = resampled_source_y[0]
    resampled_source_x[-1] = resampled_source_x[sample_count - 1]
    resampled_source_y[-1] = resampled_source_y[sample_count - 1]
    if line_width > 0 then
        local half_line_width = line_width * 0.5
        obj.load("figure", "四角形", line_color, 1) --  math.min(w1,w2,h1,h2))
        local previous_x, previous_y = resampled_source_x[0], resampled_source_y[0]
        for i = 0, sample_count - 1 do
            local current_x, current_y = resampled_source_x[i + 1], resampled_source_y[i + 1]
            local normal_offset_x, normal_offset_y = current_x - previous_x, current_y - previous_y
            local segment_length = math.sqrt(normal_offset_x * normal_offset_x + normal_offset_y * normal_offset_y)
            if segment_length > 0 then
                normal_offset_x, normal_offset_y =
                    half_line_width * normal_offset_y / segment_length,
                    -half_line_width * normal_offset_x / segment_length
                obj.drawpoly(
                    previous_x - normal_offset_x,
                    previous_y - normal_offset_y,
                    0,
                    current_x - normal_offset_x,
                    current_y - normal_offset_y,
                    0,
                    current_x + normal_offset_x,
                    current_y + normal_offset_y,
                    0,
                    previous_x + normal_offset_x,
                    previous_y + normal_offset_y,
                    0
                )
            end
            previous_x, previous_y = current_x, current_y
        end
    end
    obj.load("figure", guide_figure, guide_color, guide_size)
    if check_auto_direction == 0 then
        for i = 0, sample_count - 1 do
            obj.draw(resampled_source_x[i], resampled_source_y[i], 0, 1, 1, 0, 0, rotation_degrees)
        end
    else
        for i = 0, sample_count - 1 do
            local r_value = math.atan2(
                resampled_source_x[i + 1] - resampled_source_x[i - 1],
                resampled_source_y[i + 1] - resampled_source_y[i - 1]
            )
            obj.draw(
                resampled_source_x[i],
                resampled_source_y[i],
                0,
                1,
                1,
                0,
                0,
                rotation_degrees - r_value * 180 / math.pi - 90
            )
        end
    end
    obj.load("tempbuffer")
end

T_OUTLINE_MORPHING_RESULT = T_OUTLINE_MORPHING_RESULT or {}
T_OUTLINE_MORPHING_RESULT.source_weight = track_change_amount * 0.01
T_OUTLINE_MORPHING_RESULT.guide_size = track_size
T_OUTLINE_MORPHING_RESULT.sample_count = track_point_count
T_OUTLINE_MORPHING_RESULT.sampling_offset = -track_offset * 0.01

T_OUTLINE_MORPHING_RESULT.source_layer_index = track_source_layer_index or 1
T_OUTLINE_MORPHING_RESULT.guide_figure = guide_figure
T_OUTLINE_MORPHING_RESULT.guide_color = guide_color
T_OUTLINE_MORPHING_RESULT.auto_direction = check_auto_direction

if
    obj.getoption("script_name", 1, true) ~= "モーフィング(輪郭)-オプション@モーフィング@tim.anm2"
then
    T_OUTLINE_MORPHING_OPTIONS(T_OUTLINE_MORPHING_RESULT)
    T_OUTLINE_MORPHING_OPTIONS = nil
    T_OUTLINE_MORPHING_RESULT = nil
end
