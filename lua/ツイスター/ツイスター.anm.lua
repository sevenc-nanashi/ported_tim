--label:${ROOT_CATEGORY}\アニメーション効果
---$track:ひねり量
---min=0
---max=100
---step=0.01
local track_twist_amount = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:中心ズレ
---min=-5000
---max=5000
---step=0.1
local track_center_offset = 0

---$track:切替映像
---min=-1
---max=1000
---step=1
local track_switch_video = 0

---$check:レイヤー読込
local check_load_layer = true

---$track:分割数
---min=5
---max=300
---step=1
local track_division_count = 25

---$track:収束半径
---min=0
---max=5000
---step=0.01
local track_convergence_radius = 0.1

---$track:シェーディング[%]
---min=0
---max=100
---step=0.1
local track_shading_strength = 100

---$check:シェーディングを逆に
local check_reverse_shading = 0

---$track:範囲拡張X
---min=-5000
---max=5000
---step=1
local track_expand_x = 0

---$track:範囲拡張Y
---min=-5000
---max=5000
---step=1
local track_expand_y = 0

local twister = function(
    grid_x_positions,
    grid_y_positions,
    normalized_twist,
    rotation_radians,
    center_offset,
    division_count,
    image_width,
    image_height,
    half_width,
    half_height,
    rotation_sine,
    rotation_cosine,
    rotated_width,
    rotated_height,
    twist_center_x,
    twist_center_y,
    convergence_radius_squared,
    source_image_index,
    intersection_orientation,
    x1,
    y1,
    x2,
    y2,
    x3,
    y3,
    x4,
    y4,
    x5,
    y5
)
    obj.copybuffer("object", "cache:img" .. source_image_index)

    if x5 == nil then
        x4 = x4 or x3
        y4 = y4 or y3
        for i = 0, division_count do
            local edge_start_x = (i * x4 + (division_count - i) * x1) / division_count
            local edge_start_y = (i * y4 + (division_count - i) * y1) / division_count
            local edge_end_x = (i * x3 + (division_count - i) * x2) / division_count
            local edge_end_y = (i * y3 + (division_count - i) * y2) / division_count
            for j = 0, division_count do
                grid_x_positions[i][j] = (j * edge_end_x + (division_count - j) * edge_start_x) / division_count
                grid_y_positions[i][j] = (j * edge_end_y + (division_count - j) * edge_start_y) / division_count
            end
        end
    else
        if intersection_orientation == 0 then
            x1, x2, x3, x4, x5 = x2, x1, x5, x4, x3
            y1, y2, y3, y4, y5 = y2, y1, y5, y4, y3
        end
        local first_edge_length = math.sqrt((x2 - x3) * (x2 - x3) + (y2 - y3) * (y2 - y3))
        local second_edge_length = math.sqrt((x4 - x5) * (x4 - x5) + (y4 - y5) * (y4 - y5))
        local second_division_count = math.min(
            math.max(1, math.floor(division_count * first_edge_length / second_edge_length)),
            division_count - 1
        )
        local first_division_count = division_count - second_division_count
        for i = 0, division_count do
            local edge_start_x
            local edge_start_y
            if i <= first_division_count then
                edge_start_x = (i * x2 + (first_division_count - i) * x1) / first_division_count
                edge_start_y = (i * y2 + (first_division_count - i) * y1) / first_division_count
            else
                edge_start_x = ((i - first_division_count) * x3 + (division_count - i) * x2) / second_division_count
                edge_start_y = ((i - first_division_count) * y3 + (division_count - i) * y2) / second_division_count
            end
            local edge_end_x = (i * x4 + (division_count - i) * x5) / division_count
            local edge_end_y = (i * y4 + (division_count - i) * y5) / division_count
            for j = 0, division_count do
                grid_x_positions[i][j] = (j * edge_end_x + (division_count - j) * edge_start_x) / division_count
                grid_y_positions[i][j] = (j * edge_end_y + (division_count - j) * edge_start_y) / division_count
            end
        end
    end

    convergence_radius_squared = convergence_radius_squared * convergence_radius_squared
    local half_rotated_width, half_rotated_height = rotated_width * 0.5, rotated_height * 0.5
    local texture_u_positions = {}
    local texture_v_positions = {}
    local center_shift_x = rotation_cosine * center_offset
    local center_shift_y = -rotation_sine * center_offset
    local vertices = {}
    for i = 0, division_count do
        texture_u_positions[i] = {}
        texture_v_positions[i] = {}
        for j = 0, division_count do
            texture_u_positions[i][j] = grid_x_positions[i][j] + half_width
            texture_v_positions[i][j] = grid_y_positions[i][j] + half_height

            local twist_weight = rotation_sine * grid_x_positions[i][j]
                + rotation_cosine * grid_y_positions[i][j]
                - 2 * rotated_height * normalized_twist
            if -half_rotated_height <= twist_weight and twist_weight <= half_rotated_height then
                twist_weight = math.abs(math.sin(twist_weight * math.pi / rotated_height))
                local x = grid_x_positions[i][j]
                    + rotation_cosine
                        * (-rotation_cosine * (grid_x_positions[i][j] + center_shift_x) + rotation_sine * (grid_y_positions[i][j] + center_shift_y))
                        * (1 - twist_weight)
                local y = grid_y_positions[i][j]
                    - rotation_sine
                        * (-rotation_cosine * (grid_x_positions[i][j] + center_shift_x) + rotation_sine * (grid_y_positions[i][j] + center_shift_y))
                        * (1 - twist_weight)
                if
                    (x - twist_center_x + center_shift_x) * (x - twist_center_x + center_shift_x)
                        + (y - twist_center_y + center_shift_y) * (y - twist_center_y + center_shift_y)
                    < convergence_radius_squared
                then
                    grid_x_positions[i][j], grid_y_positions[i][j] =
                        twist_center_x - center_shift_x, twist_center_y - center_shift_y
                else
                    grid_x_positions[i][j], grid_y_positions[i][j] = x, y
                end
            end
        end
    end
    for i = 0, division_count - 1 do
        for j = 0, division_count - 1 do
            vertices[#vertices + 1] = {
                grid_x_positions[i][j],
                grid_y_positions[i][j],
                0,
                grid_x_positions[i + 1][j],
                grid_y_positions[i + 1][j],
                0,
                grid_x_positions[i + 1][j + 1],
                grid_y_positions[i + 1][j + 1],
                0,
                grid_x_positions[i][j + 1],
                grid_y_positions[i][j + 1],
                0,
                texture_u_positions[i][j],
                texture_v_positions[i][j],
                texture_u_positions[i + 1][j],
                texture_v_positions[i + 1][j],
                texture_u_positions[i + 1][j + 1],
                texture_v_positions[i + 1][j + 1],
                texture_u_positions[i][j + 1],
                texture_v_positions[i][j + 1],
            }
        end
    end
    if #vertices > 0 then
        obj.drawpoly(vertices)
    end
end

local draw_shading = function(
    twist_center_x,
    twist_center_y,
    rotated_width,
    rotated_height,
    rotation_sine,
    rotation_cosine,
    center_offset,
    shading_strength,
    reverse_shading
)
    local shading_color
    if reverse_shading == 0 then
        shading_color = 0xffffff
    else
        shading_color = 0x000000
    end

    obj.load("figure", "円", shading_color, rotated_height / 3)
    obj.effect("ぼかし", "範囲", rotated_height / 8)

    local half_rotated_width = rotated_width * 0.5
    local shading_blur_radius = rotated_height / 8

    local x = twist_center_x - shading_blur_radius * rotation_sine - half_rotated_width * rotation_cosine
    local y = twist_center_y - shading_blur_radius * rotation_cosine + half_rotated_width * rotation_sine
    local width_vector_x = half_rotated_width * rotation_cosine
    local width_vector_y = -half_rotated_width * rotation_sine
    local height_vector_x = rotated_height / 4 * rotation_sine
    local height_vector_y = rotated_height / 4 * rotation_cosine
    obj.drawpoly(
        x - width_vector_x - height_vector_x,
        y - width_vector_y - height_vector_y,
        0,
        x + width_vector_x - height_vector_x - rotation_cosine * center_offset,
        y + width_vector_y - height_vector_y + rotation_sine * center_offset,
        0,
        x + width_vector_x + height_vector_x - rotation_cosine * center_offset,
        y + width_vector_y + height_vector_y + rotation_sine * center_offset,
        0,
        x - width_vector_x + height_vector_x,
        y - width_vector_y + height_vector_y,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        shading_strength
    )

    obj.effect("反転", "輝度反転", 1)
    x = twist_center_x + shading_blur_radius * rotation_sine + half_rotated_width * rotation_cosine
    y = twist_center_y + shading_blur_radius * rotation_cosine - half_rotated_width * rotation_sine
    obj.drawpoly(
        x - width_vector_x - height_vector_x - rotation_cosine * center_offset,
        y - width_vector_y - height_vector_y + rotation_sine * center_offset,
        0,
        x + width_vector_x - height_vector_x,
        y + width_vector_y - height_vector_y,
        0,
        x + width_vector_x + height_vector_x,
        y + width_vector_y + height_vector_y,
        0,
        x - width_vector_x + height_vector_x - rotation_cosine * center_offset,
        y - width_vector_y + height_vector_y + rotation_sine * center_offset,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        shading_strength
    )
end

local normalized_twist = track_twist_amount * 0.01 - 0.5
local rotation = track_rotation
local rotation_radians = math.rad(180 - rotation)
local center_offset = track_center_offset
local layer_index = math.floor(track_switch_video)

local division_count = math.floor(math.max(track_division_count or 25, 5))
local convergence_radius = math.abs(track_convergence_radius or 0.1)
local shading_strength = math.abs(track_shading_strength or 100) * 0.01
local expand_x = track_expand_x or 0
local expand_y = track_expand_y or 0

local image_width, image_height = obj.getpixel()
local half_width, half_height = image_width * 0.5, image_height * 0.5

local rotation_sine = math.sin(rotation_radians)
local rotation_cosine = math.cos(rotation_radians)

local rotated_height = image_width * math.abs(rotation_sine) + image_height * math.abs(rotation_cosine)
local rotated_width = image_width * math.abs(rotation_cosine) + image_height * math.abs(rotation_sine)

local twist_center_x = normalized_twist * rotated_height * rotation_sine * 2
local twist_center_y = normalized_twist * rotated_height * rotation_cosine * 2

if shading_strength > 0 then
    obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
    obj.draw()
    draw_shading(
        twist_center_x,
        twist_center_y,
        rotated_width,
        rotated_height,
        rotation_sine,
        rotation_cosine,
        center_offset,
        shading_strength,
        check_reverse_shading
    )
    obj.copybuffer("cache:img0", "tempbuffer")
else
    obj.copybuffer("cache:img0", "object")
end

if layer_index > 0 then
    if check_load_layer == false then
        ---$embed
        local extbuffer = require("extbuffer")
        extbuffer.read(layer_index)
    else
        obj.load("layer", layer_index, true)
    end

    if shading_strength > 0 then
        obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
        obj.draw()
        draw_shading(
            twist_center_x,
            twist_center_y,
            rotated_width,
            rotated_height,
            rotation_sine,
            rotation_cosine,
            center_offset,
            shading_strength,
            check_reverse_shading
        )
        obj.copybuffer("cache:img1", "tempbuffer")
    else
        obj.copybuffer("cache:img1", "object")
    end
elseif layer_index < 0 then
    obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
    obj.copybuffer("cache:img1", "tempbuffer")
else
    obj.copybuffer("object", "cache:img0")
    obj.copybuffer("cache:img1", "object")
end

obj.setoption("drawtarget", "tempbuffer", math.max(image_width + expand_x, 1), math.max(image_height + expand_y, 1))
obj.setoption("blend", "alpha_add")

local grid_x_positions = {}
local grid_y_positions = {}
for i = 0, division_count do
    grid_x_positions[i] = {}
    grid_y_positions[i] = {}
end

local intersection_orientation = 0
if math.abs(rotation_cosine) < math.abs(rotation_sine) then -- if math.abs(cos*h)<math.abs(sin*w) then
    intersection_orientation = 1
end

local boundary_intersections = {}
local kasan = 0

if (rotation - 90) % 180 == 0 then
    if -half_width < twist_center_x and twist_center_x < half_width then
        kasan = 5
        boundary_intersections[0] = twist_center_x
        boundary_intersections[2] = twist_center_x
    end
elseif rotation % 180 == 0 then
    if -half_height < twist_center_y and twist_center_y < half_height then
        kasan = 10
        boundary_intersections[1] = twist_center_y
        boundary_intersections[3] = twist_center_y
    end
else
    local a1 = rotation_cosine * half_height / rotation_sine
    local b1 = rotation_cosine * twist_center_y / rotation_sine + twist_center_x
    local a2 = rotation_sine * half_width / rotation_cosine
    local b2 = rotation_sine * twist_center_x / rotation_cosine + twist_center_y

    boundary_intersections[0] = a1 + b1
    boundary_intersections[1] = -a2 + b2
    boundary_intersections[2] = -a1 + b1
    boundary_intersections[3] = a2 + b2

    if -half_width <= boundary_intersections[0] and boundary_intersections[0] < half_width then
        kasan = kasan + 1
    end
    if -half_height <= boundary_intersections[1] and boundary_intersections[1] < half_height then
        kasan = kasan + 2
    end
    if -half_width < boundary_intersections[2] and boundary_intersections[2] <= half_width then
        kasan = kasan + 4
    end
    if -half_height < boundary_intersections[3] and boundary_intersections[3] <= half_height then
        kasan = kasan + 8
    end
end

local source_image_index = 1

if kasan == 3 then
    if rotation_sine > 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        boundary_intersections[0],
        -half_height,
        half_width,
        boundary_intersections[1],
        half_width,
        half_height,
        -half_width,
        half_height,
        -half_width,
        -half_height
    )
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        1 - source_image_index,
        intersection_orientation,
        half_width,
        boundary_intersections[1],
        boundary_intersections[0],
        -half_height,
        half_width,
        -half_height
    )
elseif kasan == 6 then
    if rotation_sine > 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        half_width,
        boundary_intersections[1],
        boundary_intersections[2],
        half_height,
        -half_width,
        half_height,
        -half_width,
        -half_height,
        half_width,
        -half_height
    )
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        1 - source_image_index,
        intersection_orientation,
        boundary_intersections[2],
        half_height,
        half_width,
        boundary_intersections[1],
        half_width,
        half_height
    )
elseif kasan == 12 then
    if rotation_sine < 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        boundary_intersections[2],
        half_height,
        -half_width,
        boundary_intersections[3],
        -half_width,
        -half_height,
        half_width,
        -half_height,
        half_width,
        half_height
    )
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        1 - source_image_index,
        intersection_orientation,
        -half_width,
        boundary_intersections[3],
        boundary_intersections[2],
        half_height,
        -half_width,
        half_height
    )
elseif kasan == 9 then
    if rotation_sine < 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        -half_width,
        boundary_intersections[3],
        boundary_intersections[0],
        -half_height,
        half_width,
        -half_height,
        half_width,
        half_height,
        -half_width,
        half_height
    )
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        1 - source_image_index,
        intersection_orientation,
        boundary_intersections[0],
        -half_height,
        -half_width,
        boundary_intersections[3],
        -half_width,
        -half_height
    )
elseif kasan == 5 then
    if rotation_sine > 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        -half_width,
        -half_height,
        boundary_intersections[0],
        -half_height,
        boundary_intersections[2],
        half_height,
        -half_width,
        half_height
    )
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        1 - source_image_index,
        intersection_orientation,
        half_width,
        -half_height,
        half_width,
        half_height,
        boundary_intersections[2],
        half_height,
        boundary_intersections[0],
        -half_height
    )
elseif kasan == 10 then
    if rotation_cosine > 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        -half_width,
        -half_height,
        half_width,
        -half_height,
        half_width,
        boundary_intersections[1],
        -half_width,
        boundary_intersections[3]
    )
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        1 - source_image_index,
        intersection_orientation,
        half_width,
        half_height,
        -half_width,
        half_height,
        -half_width,
        boundary_intersections[3],
        half_width,
        boundary_intersections[1]
    )
else
    if normalized_twist > 0 then
        source_image_index = 1
    else
        source_image_index = 0
    end
    twister(
        grid_x_positions,
        grid_y_positions,
        normalized_twist,
        rotation_radians,
        center_offset,
        division_count,
        image_width,
        image_height,
        half_width,
        half_height,
        rotation_sine,
        rotation_cosine,
        rotated_width,
        rotated_height,
        twist_center_x,
        twist_center_y,
        convergence_radius,
        source_image_index,
        intersection_orientation,
        -half_width,
        -half_height,
        half_width,
        -half_height,
        half_width,
        half_height,
        -half_width,
        half_height
    )
end

obj.load("tempbuffer")
