--label:${ROOT_CATEGORY}\装飾\@ジグザグ塗りT
---$track:進捗
---min=0
---max=100
---step=0.01
local track_progress = 100

---$track:サイズ
---min=2
---max=1000
---step=1
local track_size = 20

---$track:線間隔
---min=4
---max=1000
---step=1
local track_line_spacing = 10

---$track:領域調整
---min=-500
---max=500
---step=1
local track_area_adjust = 0

---$select:表示モード
---通常(本体→ライン)=0
---通常(ライン→本体)=1
---アルファ減算(本体→ライン)=2
---アルファ減算(ライン→本体)=3
---反転+アルファ減算(本体→ライン)=4
---反転+アルファ減算(ライン→本体)=5
local select_display_mode = 0

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 20

---$color:線色
local line_color = 0xffffff

---$track:本体α
---min=0
---max=100
---step=0.1
local track_alpha = 100

---$track:ラインα
---min=0
---max=100
---step=0.1
local track_alpha_2 = 100

---$track:ぼかし
---min=0
---max=500
---step=1
local track_blur = 0

--group:ディスプレイスメント,false

---$track:MAPレイヤ
---min=0
---max=100
---step=1
local track_map = 0

---$track:変形X
---min=-500
---max=500
---step=0.1
local track_deform_x = 10

---$track:変形Y
---min=-500
---max=500
---step=0.1
local track_deform_y = 10

---$track:変形方法
---min=0
---max=2
---step=1
local track_deform_method = 0

---$track:ディスプレイスメントぼかし
---min=0
---max=500
---step=1
local track_displacement_blur = 5

---$track:領域拡張X
---min=-500
---max=500
---step=1
local track_displacement_expand_x = 0

---$track:領域拡張Y
---min=-500
---max=500
---step=1
local track_displacement_expand_y = 0

---$check:MAPサイズ調整
local check_map_resize = false

--group:

---$track:水平ランダム
---min=0
---max=1000
---step=0.1
local track_horizontal_randomness = 0

---$track:垂直ランダム
---min=0
---max=1000
---step=0.1
local track_vertical_randomness = 0

--group:乱数
---$track:シード
---min=-100000
---max=100000
---step=1
local track_random_seed = 0

---$track:変動フレーム長
---min=0
---max=1000
---step=1
local track_variation_frame_length = 0
--group:

---$track:αしきい値
---min=0
---max=255
---step=1
local track_alpha_threshold = 127

---$check:距離∝時間ﾓｰﾄﾞ
local check_distance_proportional_time = 1

---$track:イージング
---min=0
---max=10
---step=0.1
local track_easing = 0

---$check:角丸なし
local check_disable_rounding = false

local tim2 = obj.module("tim2")
local progress = track_progress / 100
local line_half_width = math.floor(track_size)
local line_spacing = math.floor(track_line_spacing)
local area_adjustment = math.floor(track_area_adjust)
local angle_degrees = track_angle
local angle_radians = math.rad(angle_degrees)
local source_alpha = track_alpha / 100
local line_alpha = track_alpha_2 / 100
local blur_amount = track_blur
track_variation_frame_length = math.abs(track_variation_frame_length)
track_easing = 1 + math.abs((track_easing or 0))
if track_variation_frame_length > 1 then
    local variation_index = math.floor(obj.time * obj.framerate / track_variation_frame_length)
    track_random_seed = track_random_seed + obj.rand(0, 10000, -variation_index, track_random_seed)
end
obj.copybuffer("cache:LT_ORG", "object")
local source_width, source_height = obj.getpixel()
if angle_degrees ~= 0 then
    local absolute_cosine = math.abs(math.cos(angle_radians))
    local absolute_sine = math.abs(math.sin(angle_radians))
    local rotated_width, rotated_height =
        source_width * absolute_cosine + source_height * absolute_sine + 2,
        source_width * absolute_sine + source_height * absolute_cosine + 2
    obj.setoption("drawtarget", "tempbuffer", rotated_width, rotated_height)
    obj.draw(0, 0, 0, 1, 1, 0, 0, angle_degrees)
    obj.copybuffer("object", "tempbuffer")
end
if area_adjustment > 0 then
    obj.effect("縁取り", "サイズ", area_adjustment, "ぼかし", 0)
elseif area_adjustment < 0 then
    obj.effect("領域拡張", "上", 1, "下", 1, "左", 1, "右", 1, "塗りつぶし", 0)
    obj.setoption("drawtarget", "tempbuffer")
    obj.copybuffer("tempbuffer", "object")
    obj.effect("反転", "透明度反転", 1)
    obj.effect("縁取り", "サイズ", -area_adjustment, "ぼかし", 0)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("object", "tempbuffer")
    obj.setoption("blend", 0)
end
local userdata, pixel_width, pixel_height = obj.getpixeldata("object", "bgra")
local output_width, output_height, path_point_count, path_points = tim2.linefill_line_fill(
    userdata,
    pixel_width,
    pixel_height,
    line_spacing,
    angle_radians,
    track_alpha_threshold,
    track_horizontal_randomness,
    track_vertical_randomness,
    track_random_seed
)
output_width, output_height =
    math.max(output_width + line_half_width, source_width), math.max(output_height + line_half_width, source_height)
output_width = output_width + (output_width - source_width) % 2
output_height = output_height + (output_height - source_height) % 2
obj.setoption("drawtarget", "tempbuffer", output_width, output_height)
T_LINE_FILL_LAST_X, T_LINE_FILL_LAST_Y = path_points[1], path_points[2]
if progress > 0 and path_point_count > 0 then
    local visible_point_count = 0
    local interpolation_weight
    if check_distance_proportional_time == 1 then
        local total_path_length = 0
        local segment_lengths = {}
        local x0, y0 = path_points[1], path_points[2]
        for i = 1, path_point_count - 1 do
            local x1, y1 = path_points[2 * i + 1], path_points[2 * i + 2]
            segment_lengths[i] = math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
            total_path_length = total_path_length + segment_lengths[i]
            x0, y0 = x1, y1
        end
        local accumulated_length = 0
        for i = 1, path_point_count - 1 do
            accumulated_length = accumulated_length + segment_lengths[i]
            if progress * total_path_length <= accumulated_length then
                visible_point_count = i + 1
                break
            end
        end
        interpolation_weight = (accumulated_length - progress * total_path_length)
            / segment_lengths[visible_point_count - 1]
    else
        local ps_value = progress * (path_point_count - 1) + 1
        visible_point_count = math.ceil(ps_value)
        visible_point_count = math.min(visible_point_count, path_point_count)
        interpolation_weight = visible_point_count - ps_value
    end

    if track_easing > 1 then
        if interpolation_weight < 0.5 then
            interpolation_weight = math.pow(2 * interpolation_weight, track_easing) / 2
        else
            interpolation_weight = 2 - 2 * interpolation_weight
            interpolation_weight = 1 - math.pow(interpolation_weight, track_easing) / 2
        end
    end

    T_LINE_FILL_LAST_X, T_LINE_FILL_LAST_Y =
        interpolation_weight * path_points[2 * visible_point_count - 3]
            + (1 - interpolation_weight) * path_points[2 * visible_point_count - 1],
        interpolation_weight * path_points[2 * visible_point_count - 2]
            + (1 - interpolation_weight) * path_points[2 * visible_point_count]
    path_points[2 * visible_point_count - 1], path_points[2 * visible_point_count] =
        T_LINE_FILL_LAST_X, T_LINE_FILL_LAST_Y
    if not check_disable_rounding then
        obj.load("figure", "円", line_color, 2 * line_half_width)
        obj.effect("リサイズ", "拡大率", 50)
        for i = 1, visible_point_count do
            obj.draw(path_points[2 * i - 1], path_points[2 * i])
        end
    end
    obj.load("figure", "四角形", line_color, 1)
    local x0, y0 = path_points[1], path_points[2]
    local vertices = {}
    local u0, v0, u1, v1 = 0, 0, obj.w, obj.h
    for i = 1, visible_point_count - 1 do
        local x1, y1 = path_points[2 * i + 1], path_points[2 * i + 2]
        local dx, dy = y1 - y0, x0 - x1
        local normal_denominator = 2 * math.sqrt(dx * dx + dy * dy)
        dx, dy = (line_half_width - 1) * dx / normal_denominator, (line_half_width - 1) * dy / normal_denominator
        vertices[#vertices + 1] = {
            x0 + dx,
            y0 + dy,
            0,
            x1 + dx,
            y1 + dy,
            0,
            x1 - dx,
            y1 - dy,
            0,
            x0 - dx,
            y0 - dy,
            0,
            u0,
            v0,
            u1,
            v0,
            u1,
            v1,
            u0,
            v1,
        }
        x0, y0 = x1, y1
    end
    if #vertices > 0 then
        obj.drawpoly(vertices)
    end
end
if track_map > 0 then
    local dx_value, dy_value = math.abs(track_displacement_expand_x), math.abs(track_displacement_expand_y)
    output_width, output_height = output_width + 2 * dx_value, output_height + 2 * dy_value
    obj.copybuffer("cache:LT_LIN", "tempbuffer")
    obj.load("layer", math.floor(track_map), true)
    if check_map_resize then
        obj.setoption("drawtarget", "tempbuffer", output_width, output_height)
        obj.draw()
    else
        obj.copybuffer("tempbuffer", "object")
    end
    obj.copybuffer("object", "cache:LT_LIN")
    obj.effect("領域拡張", "上", dy_value, "下", dy_value, "左", dx_value, "右", dx_value, "塗りつぶし", 0)
    obj.effect(
        "ディスプレイスメントマップ",
        "param0",
        track_deform_x,
        "param1",
        track_deform_y,
        "ぼかし",
        track_displacement_blur,
        "元のサイズに合わせる",
        1,
        "type",
        0,
        "name",
        "*tempbuffer",
        "mode",
        0,
        "calc",
        track_deform_method
    )
    obj.effect("ぼかし", "範囲", blur_amount)
    obj.copybuffer("cache:LT_LIN", "object")
else
    obj.copybuffer("object", "tempbuffer")
    obj.effect("ぼかし", "範囲", blur_amount)
    obj.copybuffer("cache:LT_LIN", "object")
end
output_width, output_height = output_width + blur_amount, output_height + blur_amount
obj.setoption("drawtarget", "tempbuffer", output_width, output_height)
local first_buffer, second_buffer, first_alpha, second_alpha
if select_display_mode % 2 == 0 then
    first_buffer, second_buffer = "cache:LT_ORG", "cache:LT_LIN"
    first_alpha, second_alpha = source_alpha, line_alpha
else
    first_buffer, second_buffer = "cache:LT_LIN", "cache:LT_ORG"
    first_alpha, second_alpha = line_alpha, source_alpha
end
obj.copybuffer("object", first_buffer)
obj.draw(0, 0, 0, 1, first_alpha)
obj.copybuffer("object", second_buffer)
if select_display_mode >= 4 then
    obj.setoption("blend", "alpha_sub")
    local buffer_width, buffer_height = obj.getpixel()
    local dx, dy = (output_width - buffer_width) / 2 + 1, (output_height - buffer_height) / 2 + 1
    obj.effect("領域拡張", "上", dy, "下", dy, "左", dx, "右", dx, "塗りつぶし", 0)
    obj.effect("反転", "透明度反転", 1)
elseif select_display_mode >= 2 then
    obj.setoption("blend", "alpha_sub")
end
obj.draw(0, 0, 0, 1, second_alpha)
obj.copybuffer("object", "tempbuffer")
obj.setoption("blend", 0)
