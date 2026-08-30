--label:${ROOT_CATEGORY}\配置\@モーションパスC
local sample_path, scaled_path_position, curve_index, curve_position, sampled_x, sampled_y, sampled_z, sampled_twist, previous_curve_position, next_curve_position, interpolation_ratio, calculate_cross_section_offset, vector_length, cross_axis_y, cross_axis_x, normal_axis_z, normal_axis_y, normal_axis_x, twist_cosine, twist_sine, animation_progress, x_quadratic_coefficients, x_linear_coefficients, x_constant_coefficients, y_quadratic_coefficients, y_linear_coefficients, y_constant_coefficients, z_quadratic_coefficients, z_linear_coefficients, z_constant_coefficients, twist_quadratic_coefficients, twist_linear_coefficients, twist_constant_coefficients, draw_segment_count, texture_segment_count, partial_segment_fraction, previous_path_twist, previous_path_z, previous_path_y, previous_path_x, current_path_twist, current_path_z, current_path_y, current_path_x, cross_section_offset_z, cross_section_offset_y, cross_section_offset_x, previous_positive_z, previous_positive_y, previous_positive_x, previous_negative_z, previous_negative_y, previous_negative_x, current_positive_z, current_positive_y, current_positive_x, current_negative_z, current_negative_y, current_negative_x, current_texture_v, previous_texture_v, leading_sample_index, half_height_scale, unused_sampled_twist, guide_half_width, path_start_z, path_start_y, path_start_x, path_end_z, path_end_y, path_end_x
---$track:X座標
---min=-10000
---max=10000
---step=0.1
local track_x_coord = 0

---$track:Y座標
---min=-10000
---max=10000
---step=0.1
local track_y_coord = -100

---$track:Z座標
---min=-10000
---max=10000
---step=0.1
local track_z_coord = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local track_twist = 0

---$track:分割数
---min=1
---max=200
---step=1
local track_division_count = 20

---$select:描画方法
---タイプ0=0
---タイプ1=1
---タイプ2=2
---タイプ3=3
---タイプ4=4
local select_draw_method = 0

---$select:相対/絶対
---相対=0
---絶対=1
local select_coordinate_mode = 0

---$check:パス描画
local check_draw_path = 0

---$color:パス描画色1
local path_start_color = 0xff0000

---$color:パス描画色2
local path_end_color = 0x0000ff

---$track:フォーカス
---min=1
---max=999
---step=1
local track_focus = 1

---$track:文字サイズ補正
---min=0
---max=5
---step=0.01
local track_font_size_scale = 0.5

---$check:先頭表示
local check_show_leading_edge = 0

---$select:内部
---タイプ0=0
---タイプ1=1
---タイプ2=2
local select_internal_axis_mode = 0

--hide@path_start_color:check_draw_path==0
--hide@path_end_color:check_draw_path==0
--hide@track_focus:check_draw_path==0
--hide@track_font_size_scale:check_draw_path==0
--hide@check_show_leading_edge:select_draw_method>2

-- 関数共通

function sample_path(path_ratio) -- 0s<=1
    scaled_path_position = T_MP_SECTION_COUNT * path_ratio
    curve_index = math.floor(scaled_path_position)
    curve_position = (scaled_path_position - curve_index) / 2

    if curve_index <= 0 then
        sampled_x = x_quadratic_coefficients[1] * curve_position * curve_position
            + x_linear_coefficients[1] * curve_position
            + x_constant_coefficients[1]
        sampled_y = y_quadratic_coefficients[1] * curve_position * curve_position
            + y_linear_coefficients[1] * curve_position
            + y_constant_coefficients[1]
        sampled_z = z_quadratic_coefficients[1] * curve_position * curve_position
            + z_linear_coefficients[1] * curve_position
            + z_constant_coefficients[1]
        sampled_twist = twist_quadratic_coefficients[1] * curve_position * curve_position
            + twist_linear_coefficients[1] * curve_position
            + twist_constant_coefficients[1]
    elseif curve_index == T_MP_SECTION_COUNT - 1 then
        previous_curve_position = curve_position + 0.5
        sampled_x = x_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + x_linear_coefficients[curve_index] * previous_curve_position
            + x_constant_coefficients[curve_index]
        sampled_y = y_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + y_linear_coefficients[curve_index] * previous_curve_position
            + y_constant_coefficients[curve_index]
        sampled_z = z_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + z_linear_coefficients[curve_index] * previous_curve_position
            + z_constant_coefficients[curve_index]
        sampled_twist = twist_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + twist_linear_coefficients[curve_index] * previous_curve_position
            + twist_constant_coefficients[curve_index]
    elseif path_ratio == 1 then
        sampled_x = T_MP_X_POSITIONS[T_MP_SECTION_COUNT]
        sampled_y = T_MP_Y_POSITIONS[T_MP_SECTION_COUNT]
        sampled_z = T_MP_Z_POSITIONS[T_MP_SECTION_COUNT]
        sampled_twist = T_MP_TWISTS[T_MP_SECTION_COUNT]
    else
        previous_curve_position = curve_position + 0.5
        next_curve_position = curve_position
        interpolation_ratio = 2 * curve_position
        sampled_x = (
            x_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + x_linear_coefficients[curve_index] * previous_curve_position
            + x_constant_coefficients[curve_index]
        )
                * (1 - interpolation_ratio)
            + interpolation_ratio
                * (x_quadratic_coefficients[curve_index + 1] * next_curve_position * next_curve_position + x_linear_coefficients[curve_index + 1] * next_curve_position + x_constant_coefficients[curve_index + 1])
        sampled_y = (
            y_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + y_linear_coefficients[curve_index] * previous_curve_position
            + y_constant_coefficients[curve_index]
        )
                * (1 - interpolation_ratio)
            + interpolation_ratio
                * (y_quadratic_coefficients[curve_index + 1] * next_curve_position * next_curve_position + y_linear_coefficients[curve_index + 1] * next_curve_position + y_constant_coefficients[curve_index + 1])
        sampled_z = (
            z_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + z_linear_coefficients[curve_index] * previous_curve_position
            + z_constant_coefficients[curve_index]
        )
                * (1 - interpolation_ratio)
            + interpolation_ratio
                * (z_quadratic_coefficients[curve_index + 1] * next_curve_position * next_curve_position + z_linear_coefficients[curve_index + 1] * next_curve_position + z_constant_coefficients[curve_index + 1])
        sampled_twist = (
            twist_quadratic_coefficients[curve_index] * previous_curve_position * previous_curve_position
            + twist_linear_coefficients[curve_index] * previous_curve_position
            + twist_constant_coefficients[curve_index]
        )
                * (1 - interpolation_ratio)
            + interpolation_ratio
                * (twist_quadratic_coefficients[curve_index + 1] * next_curve_position * next_curve_position + twist_linear_coefficients[curve_index + 1] * next_curve_position + twist_constant_coefficients[curve_index + 1])
    end
    return sampled_x, sampled_y, sampled_z, sampled_twist
end

function calculate_cross_section_offset(path_direction_x, path_direction_y, path_direction_z, twist_degrees)
    vector_length = (path_direction_x * path_direction_x + path_direction_y * path_direction_y) ^ 0.5
    cross_axis_x, cross_axis_y = path_direction_y / vector_length, -path_direction_x / vector_length
    normal_axis_x, normal_axis_y, normal_axis_z =
        path_direction_x * path_direction_z,
        path_direction_y * path_direction_z,
        -path_direction_x * path_direction_x - path_direction_y * path_direction_y
    vector_length = (normal_axis_x * normal_axis_x + normal_axis_y * normal_axis_y + normal_axis_z * normal_axis_z)
        ^ 0.5
    normal_axis_x, normal_axis_y, normal_axis_z =
        normal_axis_x / vector_length, normal_axis_y / vector_length, normal_axis_z / vector_length
    twist_cosine = math.cos(twist_degrees / 180 * math.pi)
    twist_sine = math.sin(twist_degrees / 180 * math.pi)
    return obj.w * (cross_axis_x * twist_cosine + normal_axis_x * twist_sine) / 2,
        obj.w * (cross_axis_y * twist_cosine + normal_axis_y * twist_sine) / 2,
        obj.w * (normal_axis_z * twist_sine) / 2
end

obj.setoption("antialias", 1)

T_MP_X_POSITIONS = {}
T_MP_Y_POSITIONS = {}
T_MP_Z_POSITIONS = {}
T_MP_TWISTS = {}

T_MP_SECTION_COUNT = obj.getoption("section_num")

for i = 0, T_MP_SECTION_COUNT - 1 do
    T_MP_X_POSITIONS[i] = obj.getvalue("track.track_x_coord", 0, i)
    T_MP_Y_POSITIONS[i] = obj.getvalue("track.track_y_coord", 0, i)
    T_MP_Z_POSITIONS[i] = obj.getvalue("track.track_z_coord", 0, i)
    T_MP_TWISTS[i] = obj.getvalue("track.track_twist", 0, i)
end

T_MP_X_POSITIONS[T_MP_SECTION_COUNT] = obj.getvalue("track.track_x_coord", 0, -1)
T_MP_Y_POSITIONS[T_MP_SECTION_COUNT] = obj.getvalue("track.track_y_coord", 0, -1)
T_MP_Z_POSITIONS[T_MP_SECTION_COUNT] = obj.getvalue("track.track_z_coord", 0, -1)
T_MP_TWISTS[T_MP_SECTION_COUNT] = obj.getvalue("track.track_twist", 0, -1)

if select_internal_axis_mode == 1 and select_draw_method < 3 then
    for i = 0, T_MP_SECTION_COUNT do
        T_MP_X_POSITIONS[i], T_MP_Y_POSITIONS[i], T_MP_Z_POSITIONS[i] =
            T_MP_Z_POSITIONS[i], T_MP_X_POSITIONS[i], T_MP_Y_POSITIONS[i]
        T_MP_TWISTS[i] = T_MP_TWISTS[i] + 90
    end
elseif select_internal_axis_mode == 2 and select_draw_method < 3 then
    for i = 0, T_MP_SECTION_COUNT do
        T_MP_X_POSITIONS[i], T_MP_Z_POSITIONS[i] = T_MP_Z_POSITIONS[i], T_MP_X_POSITIONS[i]
        T_MP_TWISTS[i] = T_MP_TWISTS[i] + 90
    end
end
-- --------以降共通

obj.effect()

if select_coordinate_mode == 0 then
    for i = 1, T_MP_SECTION_COUNT do
        T_MP_X_POSITIONS[i] = T_MP_X_POSITIONS[i - 1] + T_MP_X_POSITIONS[i]
        T_MP_Y_POSITIONS[i] = T_MP_Y_POSITIONS[i - 1] + T_MP_Y_POSITIONS[i]
        T_MP_Z_POSITIONS[i] = T_MP_Z_POSITIONS[i - 1] + T_MP_Z_POSITIONS[i]
    end
end

animation_progress = (1 + obj.frame) / (1 + obj.totalframe)

x_quadratic_coefficients = {}
x_linear_coefficients = {}
x_constant_coefficients = {}
y_quadratic_coefficients = {}
y_linear_coefficients = {}
y_constant_coefficients = {}
z_quadratic_coefficients = {}
z_linear_coefficients = {}
z_constant_coefficients = {}
twist_quadratic_coefficients = {}
twist_linear_coefficients = {}
twist_constant_coefficients = {}

for coefficient_index = 1, T_MP_SECTION_COUNT - 1 do
    x_quadratic_coefficients[coefficient_index] = 2 * T_MP_X_POSITIONS[coefficient_index - 1]
        - 4 * T_MP_X_POSITIONS[coefficient_index]
        + 2 * T_MP_X_POSITIONS[coefficient_index + 1]
    x_linear_coefficients[coefficient_index] = -3 * T_MP_X_POSITIONS[coefficient_index - 1]
        + 4 * T_MP_X_POSITIONS[coefficient_index]
        - T_MP_X_POSITIONS[coefficient_index + 1]
    x_constant_coefficients[coefficient_index] = T_MP_X_POSITIONS[coefficient_index - 1]
    y_quadratic_coefficients[coefficient_index] = 2 * T_MP_Y_POSITIONS[coefficient_index - 1]
        - 4 * T_MP_Y_POSITIONS[coefficient_index]
        + 2 * T_MP_Y_POSITIONS[coefficient_index + 1]
    y_linear_coefficients[coefficient_index] = -3 * T_MP_Y_POSITIONS[coefficient_index - 1]
        + 4 * T_MP_Y_POSITIONS[coefficient_index]
        - T_MP_Y_POSITIONS[coefficient_index + 1]
    y_constant_coefficients[coefficient_index] = T_MP_Y_POSITIONS[coefficient_index - 1]
    z_quadratic_coefficients[coefficient_index] = 2 * T_MP_Z_POSITIONS[coefficient_index - 1]
        - 4 * T_MP_Z_POSITIONS[coefficient_index]
        + 2 * T_MP_Z_POSITIONS[coefficient_index + 1]
    z_linear_coefficients[coefficient_index] = -3 * T_MP_Z_POSITIONS[coefficient_index - 1]
        + 4 * T_MP_Z_POSITIONS[coefficient_index]
        - T_MP_Z_POSITIONS[coefficient_index + 1]
    z_constant_coefficients[coefficient_index] = T_MP_Z_POSITIONS[coefficient_index - 1]
    twist_quadratic_coefficients[coefficient_index] = 2 * T_MP_TWISTS[coefficient_index - 1]
        - 4 * T_MP_TWISTS[coefficient_index]
        + 2 * T_MP_TWISTS[coefficient_index + 1]
    twist_linear_coefficients[coefficient_index] = -3 * T_MP_TWISTS[coefficient_index - 1]
        + 4 * T_MP_TWISTS[coefficient_index]
        - T_MP_TWISTS[coefficient_index + 1]
    twist_constant_coefficients[coefficient_index] = T_MP_TWISTS[coefficient_index - 1]
end

if select_draw_method == 0 then
    draw_segment_count = T_MP_SECTION_COUNT * track_division_count
    texture_segment_count = draw_segment_count
    partial_segment_fraction = 0
elseif select_draw_method == 1 then
    draw_segment_count = math.floor(T_MP_SECTION_COUNT * track_division_count * animation_progress)
    texture_segment_count = T_MP_SECTION_COUNT * track_division_count
    partial_segment_fraction = T_MP_SECTION_COUNT * track_division_count * animation_progress - draw_segment_count
elseif select_draw_method == 2 then
    draw_segment_count = math.floor(T_MP_SECTION_COUNT * track_division_count * animation_progress)
    texture_segment_count = draw_segment_count
    partial_segment_fraction = T_MP_SECTION_COUNT * track_division_count * animation_progress - draw_segment_count
elseif select_draw_method == 3 then
    draw_segment_count = math.floor(T_MP_SECTION_COUNT * track_division_count * animation_progress)
else
    draw_segment_count = T_MP_SECTION_COUNT * track_division_count
end

if select_draw_method < 3 then
    if check_show_leading_edge == 0 then
        previous_path_x, previous_path_y, previous_path_z, previous_path_twist = sample_path(0)
        current_path_x, current_path_y, current_path_z, current_path_twist =
            sample_path(0.5 / (T_MP_SECTION_COUNT * track_division_count))
        cross_section_offset_x, cross_section_offset_y, cross_section_offset_z = calculate_cross_section_offset(
            current_path_x - previous_path_x,
            current_path_y - previous_path_y,
            current_path_z - previous_path_z,
            T_MP_TWISTS[0]
        )
        previous_positive_x, previous_positive_y, previous_positive_z =
            previous_path_x + cross_section_offset_x,
            previous_path_y + cross_section_offset_y,
            previous_path_z + cross_section_offset_z
        previous_negative_x, previous_negative_y, previous_negative_z =
            previous_path_x - cross_section_offset_x,
            previous_path_y - cross_section_offset_y,
            previous_path_z - cross_section_offset_z

        for i = 1, draw_segment_count do
            current_path_x, current_path_y, current_path_z, current_path_twist =
                sample_path(i / (T_MP_SECTION_COUNT * track_division_count))
            cross_section_offset_x, cross_section_offset_y, cross_section_offset_z = calculate_cross_section_offset(
                current_path_x - previous_path_x,
                current_path_y - previous_path_y,
                current_path_z - previous_path_z,
                current_path_twist
            )
            current_positive_x, current_positive_y, current_positive_z =
                current_path_x + cross_section_offset_x,
                current_path_y + cross_section_offset_y,
                current_path_z + cross_section_offset_z
            current_negative_x, current_negative_y, current_negative_z =
                current_path_x - cross_section_offset_x,
                current_path_y - cross_section_offset_y,
                current_path_z - cross_section_offset_z
            current_texture_v = obj.h * (1 - i / (texture_segment_count + partial_segment_fraction))
            previous_texture_v = obj.h * (1 - (i - 1) / (texture_segment_count + partial_segment_fraction))

            if select_internal_axis_mode == 1 then
                obj.drawpoly(
                    previous_negative_y,
                    previous_negative_z,
                    previous_negative_x,
                    previous_positive_y,
                    previous_positive_z,
                    previous_positive_x,
                    current_positive_y,
                    current_positive_z,
                    current_positive_x,
                    current_negative_y,
                    current_negative_z,
                    current_negative_x,
                    0,
                    previous_texture_v,
                    obj.w,
                    previous_texture_v,
                    obj.w,
                    current_texture_v,
                    0,
                    current_texture_v
                )
            elseif select_internal_axis_mode == 2 then
                obj.drawpoly(
                    previous_negative_z,
                    previous_negative_y,
                    previous_negative_x,
                    previous_positive_z,
                    previous_positive_y,
                    previous_positive_x,
                    current_positive_z,
                    current_positive_y,
                    current_positive_x,
                    current_negative_z,
                    current_negative_y,
                    current_negative_x,
                    0,
                    previous_texture_v,
                    obj.w,
                    previous_texture_v,
                    obj.w,
                    current_texture_v,
                    0,
                    current_texture_v
                )
            else
                obj.drawpoly(
                    previous_negative_x,
                    previous_negative_y,
                    previous_negative_z,
                    previous_positive_x,
                    previous_positive_y,
                    previous_positive_z,
                    current_positive_x,
                    current_positive_y,
                    current_positive_z,
                    current_negative_x,
                    current_negative_y,
                    current_negative_z,
                    0,
                    previous_texture_v,
                    obj.w,
                    previous_texture_v,
                    obj.w,
                    current_texture_v,
                    0,
                    current_texture_v
                )
            end
            previous_negative_x, previous_negative_y, previous_negative_z =
                current_negative_x, current_negative_y, current_negative_z
            previous_positive_x, previous_positive_y, previous_positive_z =
                current_positive_x, current_positive_y, current_positive_z
            previous_path_x, previous_path_y, previous_path_z = current_path_x, current_path_y, current_path_z
        end -- i

        if partial_segment_fraction > 0 then
            current_path_x, current_path_y, current_path_z, current_path_twist = sample_path(
                (draw_segment_count + partial_segment_fraction) / (T_MP_SECTION_COUNT * track_division_count)
            )
            cross_section_offset_x, cross_section_offset_y, cross_section_offset_z = calculate_cross_section_offset(
                current_path_x - previous_path_x,
                current_path_y - previous_path_y,
                current_path_z - previous_path_z,
                current_path_twist
            )
            current_positive_x, current_positive_y, current_positive_z =
                current_path_x + cross_section_offset_x,
                current_path_y + cross_section_offset_y,
                current_path_z + cross_section_offset_z
            current_negative_x, current_negative_y, current_negative_z =
                current_path_x - cross_section_offset_x,
                current_path_y - cross_section_offset_y,
                current_path_z - cross_section_offset_z
            current_texture_v = obj.h
                * (
                    1
                    - (draw_segment_count + partial_segment_fraction)
                        / (texture_segment_count + partial_segment_fraction)
                )
            previous_texture_v = obj.h * (1 - draw_segment_count / (texture_segment_count + partial_segment_fraction))
            if select_internal_axis_mode == 1 then
                obj.drawpoly(
                    previous_negative_y,
                    previous_negative_z,
                    previous_negative_x,
                    previous_positive_y,
                    previous_positive_z,
                    previous_positive_x,
                    current_positive_y,
                    current_positive_z,
                    current_positive_x,
                    current_negative_y,
                    current_negative_z,
                    current_negative_x,
                    0,
                    previous_texture_v,
                    obj.w,
                    previous_texture_v,
                    obj.w,
                    current_texture_v,
                    0,
                    current_texture_v
                )
            elseif select_internal_axis_mode == 2 then
                obj.drawpoly(
                    previous_negative_z,
                    previous_negative_y,
                    previous_negative_x,
                    previous_positive_z,
                    previous_positive_y,
                    previous_positive_x,
                    current_positive_z,
                    current_positive_y,
                    current_positive_x,
                    current_negative_z,
                    current_negative_y,
                    current_negative_x,
                    0,
                    previous_texture_v,
                    obj.w,
                    previous_texture_v,
                    obj.w,
                    current_texture_v,
                    0,
                    current_texture_v
                )
            else
                obj.drawpoly(
                    previous_negative_x,
                    previous_negative_y,
                    previous_negative_z,
                    previous_positive_x,
                    previous_positive_y,
                    previous_positive_z,
                    current_positive_x,
                    current_positive_y,
                    current_positive_z,
                    current_negative_x,
                    current_negative_y,
                    current_negative_z,
                    0,
                    previous_texture_v,
                    obj.w,
                    previous_texture_v,
                    obj.w,
                    current_texture_v,
                    0,
                    current_texture_v
                )
            end
        end
    else
        if T_MP_SECTION_COUNT * track_division_count * animation_progress <= 1 / 2 then
            leading_sample_index = 1 / 2
        else
            leading_sample_index = T_MP_SECTION_COUNT * track_division_count * animation_progress
        end

        if select_draw_method == 0 then
            leading_sample_index = T_MP_SECTION_COUNT * track_division_count
        end

        previous_path_x, previous_path_y, previous_path_z, previous_path_twist =
            sample_path((leading_sample_index - 1 / 2) / (T_MP_SECTION_COUNT * track_division_count))
        current_path_x, current_path_y, current_path_z, current_path_twist =
            sample_path(leading_sample_index / (T_MP_SECTION_COUNT * track_division_count))

        cross_section_offset_x, cross_section_offset_y, cross_section_offset_z =
            current_path_x - previous_path_x, current_path_y - previous_path_y, current_path_z - previous_path_z
        half_height_scale = obj.h
            / (cross_section_offset_x * cross_section_offset_x + cross_section_offset_y * cross_section_offset_y + cross_section_offset_z * cross_section_offset_z) ^ 0.5
            / 2
        cross_section_offset_x, cross_section_offset_y, cross_section_offset_z =
            cross_section_offset_x * half_height_scale,
            cross_section_offset_y * half_height_scale,
            cross_section_offset_z * half_height_scale

        previous_path_x, previous_path_y, previous_path_z =
            current_path_x - cross_section_offset_x,
            current_path_y - cross_section_offset_y,
            current_path_z - cross_section_offset_z
        current_path_x, current_path_y, current_path_z =
            current_path_x + cross_section_offset_x,
            current_path_y + cross_section_offset_y,
            current_path_z + cross_section_offset_z
        cross_section_offset_x, cross_section_offset_y, cross_section_offset_z = calculate_cross_section_offset(
            cross_section_offset_x,
            cross_section_offset_y,
            cross_section_offset_z,
            current_path_twist
        )

        current_negative_x, current_negative_y, current_negative_z =
            previous_path_x - cross_section_offset_x,
            previous_path_y - cross_section_offset_y,
            previous_path_z - cross_section_offset_z
        current_positive_x, current_positive_y, current_positive_z =
            previous_path_x + cross_section_offset_x,
            previous_path_y + cross_section_offset_y,
            previous_path_z + cross_section_offset_z
        previous_positive_x, previous_positive_y, previous_positive_z =
            current_path_x + cross_section_offset_x,
            current_path_y + cross_section_offset_y,
            current_path_z + cross_section_offset_z
        previous_negative_x, previous_negative_y, previous_negative_z =
            current_path_x - cross_section_offset_x,
            current_path_y - cross_section_offset_y,
            current_path_z - cross_section_offset_z
        if select_internal_axis_mode == 1 then
            obj.drawpoly(
                previous_negative_y,
                previous_negative_z,
                previous_negative_x,
                previous_positive_y,
                previous_positive_z,
                previous_positive_x,
                current_positive_y,
                current_positive_z,
                current_positive_x,
                current_negative_y,
                current_negative_z,
                current_negative_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        elseif select_internal_axis_mode == 2 then
            obj.drawpoly(
                previous_negative_z,
                previous_negative_y,
                previous_negative_x,
                previous_positive_z,
                previous_positive_y,
                previous_positive_x,
                current_positive_z,
                current_positive_y,
                current_positive_x,
                current_negative_z,
                current_negative_y,
                current_negative_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        else
            obj.drawpoly(
                previous_negative_x,
                previous_negative_y,
                previous_negative_z,
                previous_positive_x,
                previous_positive_y,
                previous_positive_z,
                current_positive_x,
                current_positive_y,
                current_positive_z,
                current_negative_x,
                current_negative_y,
                current_negative_z,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        end
    end
else
    for i = 0, draw_segment_count do
        obj.ox, obj.oy, obj.oz, unused_sampled_twist = sample_path(i / (T_MP_SECTION_COUNT * track_division_count))
        obj.draw()
    end
end

-- ---------ここから違う

if check_draw_path == 1 then
    guide_half_width = obj.screen_w / 80
    for i = 0, T_MP_SECTION_COUNT do
        if i == track_focus - 1 then
            obj.load("figure", "円", path_end_color, 100)
        else
            obj.load("figure", "円", path_start_color, 100)
        end
        current_path_x, current_path_y, current_path_z, current_path_twist = sample_path(i / T_MP_SECTION_COUNT)

        if select_internal_axis_mode == 1 then
            obj.drawpoly(
                current_path_y + guide_half_width,
                current_path_z,
                current_path_x + guide_half_width,
                current_path_y + guide_half_width,
                current_path_z,
                current_path_x - guide_half_width,
                current_path_y - guide_half_width,
                current_path_z,
                current_path_x - guide_half_width,
                current_path_y - guide_half_width,
                current_path_z,
                current_path_x + guide_half_width,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                current_path_y,
                current_path_z + guide_half_width,
                current_path_x + guide_half_width,
                current_path_y,
                current_path_z + guide_half_width,
                current_path_x - guide_half_width,
                current_path_y,
                current_path_z - guide_half_width,
                current_path_x - guide_half_width,
                current_path_y,
                current_path_z - guide_half_width,
                current_path_x + guide_half_width,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                current_path_y + guide_half_width,
                current_path_z + guide_half_width,
                current_path_x,
                current_path_y - guide_half_width,
                current_path_z + guide_half_width,
                current_path_x,
                current_path_y - guide_half_width,
                current_path_z - guide_half_width,
                current_path_x,
                current_path_y + guide_half_width,
                current_path_z - guide_half_width,
                current_path_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        elseif select_internal_axis_mode == 2 then
            obj.drawpoly(
                current_path_z,
                current_path_y + guide_half_width,
                current_path_x + guide_half_width,
                current_path_z,
                current_path_y + guide_half_width,
                current_path_x - guide_half_width,
                current_path_z,
                current_path_y - guide_half_width,
                current_path_x - guide_half_width,
                current_path_z,
                current_path_y - guide_half_width,
                current_path_x + guide_half_width,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                current_path_z + guide_half_width,
                current_path_y,
                current_path_x + guide_half_width,
                current_path_z + guide_half_width,
                current_path_y,
                current_path_x - guide_half_width,
                current_path_z - guide_half_width,
                current_path_y,
                current_path_x - guide_half_width,
                current_path_z - guide_half_width,
                current_path_y,
                current_path_x + guide_half_width,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                current_path_z + guide_half_width,
                current_path_y + guide_half_width,
                current_path_x,
                current_path_z + guide_half_width,
                current_path_y - guide_half_width,
                current_path_x,
                current_path_z - guide_half_width,
                current_path_y - guide_half_width,
                current_path_x,
                current_path_z - guide_half_width,
                current_path_y + guide_half_width,
                current_path_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        else
            obj.drawpoly(
                current_path_x + guide_half_width,
                current_path_y + guide_half_width,
                current_path_z,
                current_path_x - guide_half_width,
                current_path_y + guide_half_width,
                current_path_z,
                current_path_x - guide_half_width,
                current_path_y - guide_half_width,
                current_path_z,
                current_path_x + guide_half_width,
                current_path_y - guide_half_width,
                current_path_z,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                current_path_x + guide_half_width,
                current_path_y,
                current_path_z + guide_half_width,
                current_path_x - guide_half_width,
                current_path_y,
                current_path_z + guide_half_width,
                current_path_x - guide_half_width,
                current_path_y,
                current_path_z - guide_half_width,
                current_path_x + guide_half_width,
                current_path_y,
                current_path_z - guide_half_width,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                current_path_x,
                current_path_y + guide_half_width,
                current_path_z + guide_half_width,
                current_path_x,
                current_path_y - guide_half_width,
                current_path_z + guide_half_width,
                current_path_x,
                current_path_y - guide_half_width,
                current_path_z - guide_half_width,
                current_path_x,
                current_path_y + guide_half_width,
                current_path_z - guide_half_width,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        end
    end -- i

    for i = 1, T_MP_SECTION_COUNT do
        if i == track_focus then
            obj.load("figure", "四角形", path_end_color, 100)
        else
            obj.load("figure", "四角形", path_start_color, 100)
        end
        path_start_x, path_start_y, path_start_z, current_path_twist = sample_path((i - 1) / T_MP_SECTION_COUNT)
        path_end_x, path_end_y, path_end_z, current_path_twist = sample_path(i / T_MP_SECTION_COUNT)

        if select_internal_axis_mode == 1 then
            obj.drawpoly(
                path_start_y,
                path_start_z,
                path_start_x + 1,
                path_start_y,
                path_start_z,
                path_start_x - 1,
                path_end_y,
                path_end_z,
                path_end_x - 1,
                path_end_y,
                path_end_z,
                path_end_x + 1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                path_start_y + 1,
                path_start_z,
                path_start_x,
                path_start_y - 1,
                path_start_z,
                path_start_x,
                path_end_y - 1,
                path_end_z,
                path_end_x,
                path_end_y + 1,
                path_end_z,
                path_end_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                path_start_y,
                path_start_z + 1,
                path_start_x,
                path_start_y,
                path_start_z - 1,
                path_start_x,
                path_end_y,
                path_end_z - 1,
                path_end_x,
                path_end_y,
                path_end_z + 1,
                path_end_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        elseif select_internal_axis_mode == 2 then
            obj.drawpoly(
                path_start_z,
                path_start_y,
                path_start_x + 1,
                path_start_z,
                path_start_y,
                path_start_x - 1,
                path_end_z,
                path_end_y,
                path_end_x - 1,
                path_end_z,
                path_end_y,
                path_end_x + 1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                path_start_z,
                path_start_y + 1,
                path_start_x,
                path_start_z,
                path_start_y - 1,
                path_start_x,
                path_end_z,
                path_end_y - 1,
                path_end_x,
                path_end_z,
                path_end_y + 1,
                path_end_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                path_start_z + 1,
                path_start_y,
                path_start_x,
                path_start_z - 1,
                path_start_y,
                path_start_x,
                path_end_z - 1,
                path_end_y,
                path_end_x,
                path_end_z + 1,
                path_end_y,
                path_end_x,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        else
            obj.drawpoly(
                path_start_x + 1,
                path_start_y,
                path_start_z,
                path_start_x - 1,
                path_start_y,
                path_start_z,
                path_end_x - 1,
                path_end_y,
                path_end_z,
                path_end_x + 1,
                path_end_y,
                path_end_z,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                path_start_x,
                path_start_y + 1,
                path_start_z,
                path_start_x,
                path_start_y - 1,
                path_start_z,
                path_end_x,
                path_end_y - 1,
                path_end_z,
                path_end_x,
                path_end_y + 1,
                path_end_z,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                path_start_x,
                path_start_y,
                path_start_z + 1,
                path_start_x,
                path_start_y,
                path_start_z - 1,
                path_end_x,
                path_end_y,
                path_end_z - 1,
                path_end_x,
                path_end_y,
                path_end_z + 1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        end

        obj.setfont("Georgia", 70 * obj.screen_w / 128 * track_font_size_scale, 1, 0xffffff, 0x000000)
        obj.load("text", i)

        if select_internal_axis_mode == 1 then
            obj.ox, obj.oy, obj.oz =
                (path_end_y + path_start_y) / 2, (path_end_z + path_start_z) / 2, (path_end_x + path_start_x) / 2
        elseif select_internal_axis_mode == 2 then
            obj.ox, obj.oy, obj.oz =
                (path_end_z + path_start_z) / 2, (path_end_y + path_start_y) / 2, (path_end_x + path_start_x) / 2
        else
            obj.ox, obj.oy, obj.oz =
                (path_end_x + path_start_x) / 2, (path_end_y + path_start_y) / 2, (path_end_z + path_start_z) / 2
        end
        obj.draw()
    end -- i
end
