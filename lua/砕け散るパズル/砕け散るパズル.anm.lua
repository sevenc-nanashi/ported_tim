--label:${ROOT_CATEGORY}\アニメーション効果
---$track:展開
---min=0
---max=5000
---step=0.1
local track_unfold = 50

---$track:速度
---min=-5000
---max=5000
---step=0.1
local track_speed = 100

---$track:向き
---min=-180
---max=180
---step=0.1
local track_direction = 30

---$track:サイズ
---min=4
---max=1000
---step=1
local track_piece_size = 120

---$track:P形状
---min=-1000
---max=22
---step=1
local track_piece_shape = 1

---$check:読込画像表示
local check_show_loaded_image = 0

---$check:配置ズレ
local check_shift_placement = 0

--group:飛散中心
---$track:飛散中心X
---min=-2000
---max=2000
---step=0.1
local track_scatter_center_x = 0

---$track:飛散中心Y
---min=-2000
---max=2000
---step=0.1
local track_scatter_center_y = 0
--trackgroup@track_scatter_center_x,track_scatter_center_y

--group

---$track:回転速度
---min=-1000
---max=1000
---step=0.1
local track_rotation_speed = 100

--group:重力
---$track:重力X
---min=-1000
---max=1000
---step=0.1
local track_gravity_x = 0

---$track:重力Y
---min=-1000
---max=1000
---step=0.1
local track_gravity_y = 100

---$track:重力Z
---min=-1000
---max=1000
---step=0.1
local track_gravity_z = 0
--trackgroup@track_gravity_x,track_gravity_y,track_gravity_z

--group

---$check:マップ画像読込
local check_load_map_image = 0

---$track:MAP番号
---min=1
---max=6
---step=1
local track_map_number = 1

---$track:マップ角度
---min=-360
---max=360
---step=0.1
local track_map_angle = 0

---$value:マップ中心
local value_map_center = { 0, 0 }

--group

---$track:マップ限界%
---min=0
---max=1000
---step=0.1
local track_map_limit_percent = 500

---$track:隙間
---min=0
---max=200
---step=0.1
local track_gap = 0

---$track:乱数シード
---min=0
---max=1000000
---step=1
local track_random_seed = 0

---$check:表裏反転
local check_reverse_faces = 0

---$check:マップ反転
local check_invert_map = false

--hide@track_map_angle:check_load_map_image==1
--hide@value_map_center:check_load_map_image==1

local scatter_center = { track_scatter_center_x, track_scatter_center_y }
local gravity = { track_gravity_x, track_gravity_y, track_gravity_z }

track_piece_shape = track_piece_shape or 0
if track_piece_shape == 0 then
    local rotate_y_axis_vector = function(y0, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
        local m01 = -cos_y * sin_z
        local m11 = cos_x * cos_z - sin_x * sin_z * sin_y
        local m21 = sin_x * cos_z + cos_x * sin_z * sin_y
        return m01 * y0, m11 * y0, m21 * y0
    end

    local rotate_x_axis_vector = function(x0, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
        local m00 = cos_y * cos_z
        local m10 = cos_x * sin_z + sin_x * cos_z * sin_y
        local m20 = sin_x * sin_z - cos_x * cos_z * sin_y
        return m00 * x0, m10 * x0, m20 * x0
    end

    local create_diamond_piece = function(piece_size, track_gap)
        local draw_diamond_piece = function(edge_x_positions, edge_y_positions, base_size, base_canvas_size)
            obj.setoption("drawtarget", "tempbuffer", base_canvas_size, base_canvas_size)
            local vertices = {}
            for i = 1, 6 do
                vertices[#vertices + 1] = {
                    -edge_x_positions[i],
                    edge_y_positions[i],
                    0,
                    edge_x_positions[i],
                    edge_y_positions[i],
                    0,
                    edge_x_positions[i + 1],
                    edge_y_positions[i + 1],
                    0,
                    -edge_x_positions[i + 1],
                    edge_y_positions[i + 1],
                    0,
                }
                vertices[#vertices + 1] = {
                    -edge_x_positions[i],
                    -edge_y_positions[i],
                    0,
                    edge_x_positions[i],
                    -edge_y_positions[i],
                    0,
                    edge_x_positions[i + 1],
                    -edge_y_positions[i + 1],
                    0,
                    -edge_x_positions[i + 1],
                    -edge_y_positions[i + 1],
                    0,
                }
            end
            vertices[#vertices + 1] = {
                -edge_x_positions[7],
                edge_y_positions[7],
                0,
                edge_x_positions[7],
                edge_y_positions[7],
                0,
                edge_x_positions[7],
                -edge_y_positions[7],
                0,
                -edge_x_positions[7],
                -edge_y_positions[7],
                0,
            }
            vertices[#vertices + 1] = {
                edge_x_positions[7],
                edge_y_positions[7],
                0,
                edge_x_positions[8],
                edge_y_positions[8],
                0,
                edge_x_positions[8],
                -edge_y_positions[8],
                0,
                edge_x_positions[7],
                -edge_y_positions[7],
                0,
            }
            vertices[#vertices + 1] = {
                -edge_x_positions[7],
                edge_y_positions[7],
                0,
                -edge_x_positions[8],
                edge_y_positions[8],
                0,
                -edge_x_positions[8],
                -edge_y_positions[8],
                0,
                -edge_x_positions[7],
                -edge_y_positions[7],
                0,
            }
            vertices[#vertices + 1] = {
                edge_x_positions[8],
                edge_y_positions[8],
                0,
                base_size,
                edge_y_positions[8],
                0,
                base_size,
                -edge_y_positions[8],
                0,
                edge_x_positions[8],
                -edge_y_positions[8],
                0,
            }
            vertices[#vertices + 1] = {
                -edge_x_positions[8],
                edge_y_positions[8],
                0,
                -base_size,
                edge_y_positions[8],
                0,
                -base_size,
                -edge_y_positions[8],
                0,
                -edge_x_positions[8],
                -edge_y_positions[8],
                0,
            }
            obj.drawpoly(vertices)
        end

        local edge_x_positions, edge_y_positions
        local antialias_scale = 2
        local pixel_adjustment = 1
        local scale_ratio = piece_size / 240 * antialias_scale
        local base_half_size = 100 * scale_ratio
        local base_size = base_half_size * 2
        local base_canvas_size = base_half_size * 4

        obj.load("figure", "四角形", 0xffffff, base_size)
        obj.setoption("blend", "alpha_add")

        --一回り小さい
        edge_x_positions = {
            9 * scale_ratio,
            35 * scale_ratio,
            43 * scale_ratio,
            43 * scale_ratio,
            27 * scale_ratio,
            27 * scale_ratio,
            35 * scale_ratio,
            120 * scale_ratio,
        }
        edge_y_positions = {
            200 * scale_ratio,
            191 * scale_ratio,
            176 * scale_ratio,
            155 * scale_ratio,
            128 * scale_ratio,
            120 * scale_ratio,
            113 * scale_ratio,
            120 * scale_ratio,
        }
        draw_diamond_piece(edge_x_positions, edge_y_positions, base_size, base_canvas_size)
        obj.copybuffer("cache:SPC", "tempbuffer")

        --普通サイズ
        edge_x_positions = {
            9 * scale_ratio,
            35 * scale_ratio,
            43 * scale_ratio - pixel_adjustment,
            43 * scale_ratio - pixel_adjustment,
            27 * scale_ratio - pixel_adjustment,
            27 * scale_ratio - pixel_adjustment,
            35 * scale_ratio,
            120 * scale_ratio,
        }
        edge_y_positions = {
            200 * scale_ratio - pixel_adjustment,
            191 * scale_ratio - pixel_adjustment,
            176 * scale_ratio,
            155 * scale_ratio,
            128 * scale_ratio,
            120 * scale_ratio,
            113 * scale_ratio - pixel_adjustment,
            120 * scale_ratio,
        }
        draw_diamond_piece(edge_x_positions, edge_y_positions, base_size, base_canvas_size)
        obj.copybuffer("object", "cache:SPC")

        obj.setoption("blend", "alpha_sub")
        obj.draw(piece_size * antialias_scale, 0, 0, 1, 1, 0, 0, 90)
        obj.draw(-piece_size * antialias_scale, 0, 0, 1, 1, 0, 0, 90)

        obj.copybuffer("object", "tempbuffer")
        obj.effect("縁取り", "サイズ", track_gap, "ぼかし", 0)
        local w2, h2 = obj.getpixel()
        obj.setoption("drawtarget", "tempbuffer", w2 * 0.5, h2 * 0.5)
        obj.setoption("blend", "none")
        obj.draw(0, 0, 0, 1 / antialias_scale)
        obj.copybuffer("cache:PC", "tempbuffer")
    end

    local draw_diamond_pieces = function(
        horizontal_radius,
        vertical_radius,
        piece_size,
        half_buffer_width,
        half_buffer_height,
        track_rotation_speed,
        piece_times,
        piece_offsets,
        primary_parity,
        rotation_degrees,
        zoom,
        track_random_seed
    )
        if (horizontal_radius % 2) == 1 then
            primary_parity = 1 - primary_parity
        end
        local secondary_parity = 1 - primary_parity
        obj.copybuffer("tempbuffer", "cache:ORI")
        obj.copybuffer("object", "cache:PC")
        obj.setoption("blend", "alpha_sub")
        for j = -vertical_radius, vertical_radius do
            for i = -horizontal_radius + ((j + primary_parity) % 2), horizontal_radius, 2 do
                obj.draw(i * piece_size, j * piece_size, 0, 1, 1, 0, 0, rotation_degrees)
            end
        end

        obj.copybuffer("object", "tempbuffer")

        obj.setoption("drawtarget", "framebuffer")
        obj.setoption("blend", "none")

        local piece_size = piece_size * zoom
        local half_buffer_width = half_buffer_width * zoom
        local half_buffer_height = half_buffer_height * zoom
        local vertices = {}

        for j = -vertical_radius, vertical_radius do
            local piece_center_y = piece_size * j
            for i = -horizontal_radius + ((j + secondary_parity) % 2), horizontal_radius, 2 do
                local x0, x1, x2, x3
                local y0, y1, y2, y3
                local z0, z1, z2, z3

                local piece_center_x = piece_size * i

                local translation_x = piece_center_x + half_buffer_width
                local translation_y = piece_center_y + half_buffer_height

                local u0, v0 = translation_x, translation_y - piece_size
                local u1, radial_speed = translation_x + piece_size, translation_y
                local u2, forward_speed = translation_x, translation_y + piece_size
                local u3, v3 = translation_x - piece_size, translation_y

                local rotation_x = obj.rand(
                    -100,
                    100,
                    i + horizontal_radius,
                    j + vertical_radius + 1000 + track_random_seed
                ) * 0.01 * piece_times[i][j] * track_rotation_speed
                local rotation_y = obj.rand(
                    -100,
                    100,
                    i + horizontal_radius,
                    j + vertical_radius + 2000 + track_random_seed
                ) * 0.01 * piece_times[i][j] * track_rotation_speed
                local rotation_z = obj.rand(
                    -100,
                    100,
                    i + horizontal_radius,
                    j + vertical_radius + 3000 + track_random_seed
                ) * 0.01 * piece_times[i][j] * track_rotation_speed
                local sin_x = math.sin(rotation_x)
                local cos_x = math.cos(rotation_x)
                local sin_y = math.sin(rotation_y)
                local cos_y = math.cos(rotation_y)
                local sin_z = math.sin(rotation_z)
                local cos_z = math.cos(rotation_z)

                x0, y0, z0 = rotate_y_axis_vector(-piece_size, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                x1, y1, z1 = rotate_x_axis_vector(piece_size, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                x2, y2, z2 = -x0, -y0, -z0
                x3, y3, z3 = -x1, -y1, -z1

                translation_x = piece_center_x + piece_offsets[i][j].x
                translation_y = piece_center_y + piece_offsets[i][j].y
                local translation_z = piece_offsets[i][j].z

                x0, x1, x2, x3 = x0 + translation_x, x1 + translation_x, x2 + translation_x, x3 + translation_x
                y0, y1, y2, y3 = y0 + translation_y, y1 + translation_y, y2 + translation_y, y3 + translation_y
                z0, z1, z2, z3 = z0 + translation_z, z1 + translation_z, z2 + translation_z, z3 + translation_z

                vertices[#vertices + 1] = {
                    x0,
                    y0,
                    z0,
                    x1,
                    y1,
                    z1,
                    x2,
                    y2,
                    z2,
                    x3,
                    y3,
                    z3,
                    u0,
                    v0,
                    u1,
                    radial_speed,
                    u2,
                    forward_speed,
                    u3,
                    v3,
                }
            end
        end
        if #vertices > 0 then
            obj.drawpoly(vertices)
        end
    end

    local create_generated_map = function(track_map_number, horizontal_radius, vertical_radius, piece_times)
        if track_map_number >= 1 and track_map_number <= 5 then
            local calculate_map_value = ({
                function(i, j, map_normalizer)
                    return math.sqrt(i * i + j * j) / map_normalizer
                end, --円
                function(i, j, map_normalizer)
                    return math.max(math.abs(i), math.abs(j)) / map_normalizer
                end, --四角
                function(i, j, map_normalizer)
                    return math.max(math.abs(i - j), math.abs(i + j)) / map_normalizer
                end, --斜め四角
                function(i, j, map_normalizer)
                    return math.min(math.abs(i), math.abs(j)) / map_normalizer
                end, --十字
                function(i, j, map_normalizer)
                    return math.min(math.abs(i - j), math.abs(i + j)) / map_normalizer
                end, --斜め十字
            })[track_map_number]

            local map_normalizer = ({
                math.sqrt(horizontal_radius * horizontal_radius + vertical_radius * vertical_radius),
                math.max(horizontal_radius, vertical_radius),
                horizontal_radius + vertical_radius,
                math.min(horizontal_radius, vertical_radius),
                math.max(horizontal_radius, vertical_radius),
            })[track_map_number]

            for i = -horizontal_radius, horizontal_radius do
                piece_times[i] = {}
                for j = -vertical_radius, vertical_radius do
                    piece_times[i][j] = calculate_map_value(i, j, map_normalizer)
                end
            end
        else
            local map_normalizer = (2 * horizontal_radius + 1) * (2 * vertical_radius + 1)
            local sequence_index = 0
            for i = -horizontal_radius, horizontal_radius do
                piece_times[i] = {}
                for j = -vertical_radius, vertical_radius do
                    piece_times[i][j] = sequence_index / map_normalizer
                    sequence_index = sequence_index + 1
                end
            end
            for i = -horizontal_radius, horizontal_radius do
                for j = -vertical_radius, vertical_radius do
                    local grid_x = obj.rand(
                        -horizontal_radius,
                        horizontal_radius,
                        i + horizontal_radius,
                        j + vertical_radius + track_random_seed
                    )
                    local grid_y = obj.rand(
                        -vertical_radius,
                        vertical_radius,
                        i + horizontal_radius,
                        j + vertical_radius + track_random_seed + 100000
                    )
                    piece_times[i][j], piece_times[grid_x][grid_y] = piece_times[grid_x][grid_y], piece_times[i][j]
                end
            end
        end
    end

    local load_external_map = function(track_map_number, horizontal_radius, vertical_radius, piece_times)
        ---$embed
        local extbuffer = require("extbuffer")
        extbuffer.read(track_map_number)
        local w, h = obj.getpixel()

        obj.pixeloption("type", "yc")
        obj.pixeloption("get", "object")

        for i = -horizontal_radius, horizontal_radius do
            piece_times[i] = {}
            for j = -vertical_radius, vertical_radius do
                local luminance, blue_difference, red_difference, alpha = obj.getpixel(
                    (w - 1) * (i + horizontal_radius) / (2 * horizontal_radius),
                    (h - 1) * (j + vertical_radius) / (2 * vertical_radius),
                    "yc"
                )
                piece_times[i][j] = luminance / 4096
            end
        end
    end

    local zoom = obj.getvalue("zoom") * 0.01

    obj.setanchor("track_scatter_center_x,track_scatter_center_y", 0)
    local unfold_progress = track_unfold * 0.01
    local scatter_speed = track_speed * 7.5
    local scatter_direction = -math.direction_radians(track_direction)

    track_rotation_speed = track_rotation_speed * 0.03
    gravity[1] = gravity[1] * 30
    gravity[2] = gravity[2] * 30
    gravity[3] = gravity[3] * 30

    track_map_limit_percent = track_map_limit_percent * 0.01

    local piece_size = math.floor(track_piece_size)
    local w, h = obj.getpixel()
    local horizontal_radius = math.floor((w / piece_size + 1) * 0.5)
    local vertical_radius = math.floor((h / piece_size + 1) * 0.5)
    local buffer_width, buffer_height = (2 * horizontal_radius + 2) * piece_size, (2 * vertical_radius + 2) * piece_size
    local half_buffer_width, half_buffer_height = buffer_width * 0.5, buffer_height * 0.5

    obj.setoption("drawtarget", "tempbuffer", buffer_width, buffer_height)
    obj.draw()
    obj.copybuffer("cache:ORI", "tempbuffer")

    --ピース作成
    create_diamond_piece(piece_size, track_gap)

    --マップ作成
    local piece_times = {}
    if check_load_map_image == 0 then
        create_generated_map(track_map_number, horizontal_radius, vertical_radius, piece_times)
    else
        load_external_map(track_map_number, horizontal_radius, vertical_radius, piece_times)
    end

    if check_invert_map then
        for i = -horizontal_radius, horizontal_radius do
            for j = -vertical_radius, vertical_radius do
                piece_times[i][j] = 1 - piece_times[i][j]
            end
        end
    end

    for i = -horizontal_radius, horizontal_radius do
        for j = -vertical_radius, vertical_radius do
            local piece_time
            if piece_times[i][j] <= track_map_limit_percent then
                piece_time = -piece_times[i][j] + unfold_progress
                piece_times[i][j] = math.max(piece_time, 0)
            else
                piece_times[i][j] = 0
            end
        end
    end

    --軌道作成
    local piece_offsets = {}
    for i = -horizontal_radius, horizontal_radius do
        piece_offsets[i] = {}
        local grid_x = i - scatter_center[1] / piece_size
        for j = -vertical_radius, vertical_radius do
            local piece_time = piece_times[i][j]

            local grid_y = j - scatter_center[2] / piece_size
            local direction_radians = scatter_direction * math.sqrt(grid_x * grid_x + grid_y * grid_y) / vertical_radius
            local radial_speed = -scatter_speed * math.sin(direction_radians)
            local forward_speed = scatter_speed * math.cos(direction_radians)
            direction_radians = math.atan2(grid_x, grid_y)

            local velocity_x = radial_speed * math.sin(direction_radians)
            local velocity_y = radial_speed * math.cos(direction_radians)
            local velocity_z = -forward_speed

            piece_offsets[i][j] = {}
            piece_offsets[i][j].x = (gravity[1] * piece_time * piece_time * 0.5 + velocity_x * piece_time) * zoom
            piece_offsets[i][j].y = (gravity[2] * piece_time * piece_time * 0.5 + velocity_y * piece_time) * zoom
            piece_offsets[i][j].z = (gravity[3] * piece_time * piece_time * 0.5 + velocity_z * piece_time) * zoom
        end
    end

    --表示
    draw_diamond_pieces(
        horizontal_radius,
        vertical_radius,
        piece_size,
        half_buffer_width,
        half_buffer_height,
        track_rotation_speed,
        piece_times,
        piece_offsets,
        1,
        0,
        zoom,
        track_random_seed
    )
    obj.setoption("drawtarget", "tempbuffer")
    draw_diamond_pieces(
        horizontal_radius,
        vertical_radius,
        piece_size,
        half_buffer_width,
        half_buffer_height,
        track_rotation_speed,
        piece_times,
        piece_offsets,
        0,
        -90,
        zoom,
        track_random_seed
    )
else
    --ピース作成----------
    local rotate_xy_vector = function(x0, y0, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
        local m00 = cos_y * cos_z
        local m01 = -cos_y * sin_z
        local m10 = cos_x * sin_z + sin_x * sin_y * cos_z
        local m11 = cos_x * cos_z - sin_x * sin_y * sin_z
        local m20 = sin_x * sin_z - cos_x * sin_y * cos_z
        local m21 = sin_x * cos_z + cos_x * sin_y * sin_z
        return m00 * x0 + m01 * y0, m10 * x0 + m11 * y0, m20 * x0 + m21 * y0
    end
    local draw_edge_shapes = function(half_piece_size, rot_value, ...)
        local edge_flags = { ... }
        if edge_flags[1] == 1 then
            obj.draw(0, -half_piece_size, 0, 1, 1, 0, 0, rot_value)
        end
        if edge_flags[2] == 1 then
            obj.draw(half_piece_size, 0, 0, 1, 1, 0, 0, 90 + rot_value)
        end
        if edge_flags[3] == 1 then
            obj.draw(0, half_piece_size, 0, 1, 1, 0, 0, 180 + rot_value)
        end
        if edge_flags[4] == 1 then
            obj.draw(-half_piece_size, 0, 0, 1, 1, 0, 0, 270 + rot_value)
        end
    end
    local create_base_edge_set = function(piece_size, half_piece_size, ...)
        local edge_flags = { ... }
        obj.setoption("drawtarget", "tempbuffer", 2 * piece_size, 2 * piece_size)
        obj.load("figure", "四角形", 0xffffff, 1)
        obj.setoption("blend", "alpha_add")
        obj.drawpoly(
            -half_piece_size,
            -half_piece_size,
            0,
            half_piece_size,
            -half_piece_size,
            0,
            half_piece_size,
            half_piece_size,
            0,
            -half_piece_size,
            half_piece_size,
            0
        )
        obj.copybuffer("object", "cache:Img1")
        obj.setoption("blend", "alpha_add")
        draw_edge_shapes(half_piece_size, 0, edge_flags[1], edge_flags[2], edge_flags[3], edge_flags[4])
        obj.setoption("blend", "alpha_sub")
        draw_edge_shapes(half_piece_size, 180, edge_flags[5], edge_flags[6], edge_flags[7], edge_flags[8])
    end
    local create_combined_edge_set = function(piece_size, half_piece_size, ...)
        local edge_flags = { ... }
        create_base_edge_set(piece_size, half_piece_size, unpack(edge_flags, 1, 8))
        obj.copybuffer("object", "cache:Img2")
        obj.setoption("blend", "alpha_add")
        draw_edge_shapes(half_piece_size, 0, edge_flags[9], edge_flags[10], edge_flags[11], edge_flags[12])
        obj.setoption("blend", "alpha_sub")
        draw_edge_shapes(half_piece_size, 180, edge_flags[13], edge_flags[14], edge_flags[15], edge_flags[16])
    end
    local create_piece_shape = function(piece_size, half_piece_size, track_piece_shape)
        if track_piece_shape == 1 then
            create_combined_edge_set(piece_size, half_piece_size, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0)
        elseif track_piece_shape == 2 then
            create_combined_edge_set(piece_size, half_piece_size, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0)
        elseif track_piece_shape == 3 then
            create_combined_edge_set(piece_size, half_piece_size, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1)
        elseif track_piece_shape == 4 then
            create_combined_edge_set(piece_size, half_piece_size, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0)
        elseif track_piece_shape == 9 or track_piece_shape == 13 or track_piece_shape == 18 then
            create_base_edge_set(piece_size, half_piece_size, 1, 0, 1, 0, 0, 1, 0, 1)
        elseif track_piece_shape == 10 or track_piece_shape == 14 or track_piece_shape == 19 then
            create_base_edge_set(piece_size, half_piece_size, 1, 1, 0, 0, 0, 0, 1, 1)
        elseif track_piece_shape == 11 or track_piece_shape == 15 or track_piece_shape == 20 then
            create_base_edge_set(piece_size, half_piece_size, 1, 1, 1, 1, 0, 0, 0, 0)
        elseif track_piece_shape == 12 or track_piece_shape == 16 or track_piece_shape == 21 then
            create_base_edge_set(piece_size, half_piece_size, 1, 0, 0, 0, 0, 1, 1, 1)
        elseif track_piece_shape == 17 or track_piece_shape == 22 then
            create_base_edge_set(piece_size, half_piece_size, 1, 1, 1, 1, 1, 1, 1, 1)
        end
    end
    local create_piece_caches = function(piece_size, half_piece_size, piece_canvas_size)
        obj.copybuffer("cache:PC1", "tempbuffer")
        obj.copybuffer("cache:PC2", "tempbuffer")
        obj.load("figure", "四角形", 0xffffff, piece_size * 2)
        obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
        obj.setoption("blend", "alpha_add")
        obj.draw()
        obj.copybuffer("object", "cache:PC1")
        obj.setoption("blend", "alpha_sub")
        if track_piece_shape == 18 then
            obj.draw(0, 0, 0, 1.01)
        else
            obj.draw()
        end

        obj.copybuffer("cache:PC1", "tempbuffer")
        if
            track_piece_shape ~= 2
            and track_piece_shape ~= 6
            and track_piece_shape ~= 10
            and track_piece_shape ~= 14
            and track_piece_shape ~= 19
            and track_piece_shape ~= 17
            and track_piece_shape ~= 22
        then
            obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(
                -half_piece_size,
                -half_piece_size,
                0,
                half_piece_size,
                -half_piece_size,
                0,
                half_piece_size,
                half_piece_size,
                0,
                -half_piece_size,
                half_piece_size,
                0
            )
            obj.drawpoly(
                0,
                -piece_size,
                0,
                0,
                -piece_size,
                0,
                half_piece_size,
                -half_piece_size,
                0,
                -half_piece_size,
                -half_piece_size,
                0
            )
            obj.drawpoly(
                piece_size,
                0,
                0,
                piece_size,
                0,
                0,
                half_piece_size,
                half_piece_size,
                0,
                half_piece_size,
                -half_piece_size,
                0
            )
            obj.drawpoly(
                0,
                piece_size,
                0,
                0,
                piece_size,
                0,
                -half_piece_size,
                half_piece_size,
                0,
                half_piece_size,
                half_piece_size,
                0
            )
            obj.drawpoly(
                -piece_size,
                0,
                0,
                -piece_size,
                0,
                0,
                -half_piece_size,
                -half_piece_size,
                0,
                -half_piece_size,
                half_piece_size,
                0
            )
            obj.copybuffer("object", "cache:PC2")
            obj.setoption("blend", "alpha_sub")
            obj.draw(-piece_size, 0, 0)
            obj.draw(piece_size, 0, 0)
            obj.draw(0, -piece_size, 0)
            obj.draw(0, piece_size, 0)

            obj.copybuffer("cache:PC2", "tempbuffer")
            obj.load("figure", "四角形", 0xffffff, piece_size * 2)
            obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
            obj.setoption("blend", "alpha_add")
            obj.draw()
            obj.copybuffer("object", "cache:PC2")
            obj.setoption("blend", "alpha_sub")
            obj.draw()
        end
        obj.copybuffer("cache:PC2", "tempbuffer")
    end
    local create_piece_image = function(piece_size, track_gap, track_piece_shape)
        local piece_size = piece_size
        local half_piece_size = piece_size / 2
        local quarter_piece_size = piece_size / 4
        local piece_canvas_size = 2 * piece_size + piece_size % 2 -- 四隅に隙間ができることがあるのを防止
        local aligned_half_piece_size = 2 * math.floor((half_piece_size + 1) / 2) -- 余分な線が入るのを防止
        if track_piece_shape < 0 then --レイヤー読み込み
            obj.copybuffer("tempbuffer", "cache:LayImg")
        elseif track_piece_shape >= 1 and track_piece_shape <= 4 then
            obj.setoption("drawtarget", "tempbuffer", piece_size, piece_size)
            local antialias_scale = 2
            local scale_ratio = piece_size / 200
            obj.load("figure", "円", 0xffffff, 78 * scale_ratio * antialias_scale)
            obj.setoption("blend", "alpha_add")
            local x0 = -39 * scale_ratio
            local y0 = (-138 - 39 * 0.79 + 100) * scale_ratio
            local y2 = (-138 + 39 * 0.79 + 100 + 2) * scale_ratio
            obj.drawpoly(x0, y0, 0, -x0, y0, 0, -x0, y2, 0, x0, y2, 0)
            local curve_adjustment = (2857 - 21 * math.sqrt(18119)) / 4640
            local x4, y4 = 32.5445 * scale_ratio, (121.0223 + 0.4) * scale_ratio - 100 * scale_ratio
            local x5, y5 = 23.9438 * scale_ratio, 110.7341 * scale_ratio - 100 * scale_ratio
            local x6, y6 =
                (32 + curve_adjustment) * scale_ratio,
                (104 - math.sqrt(21 * 21 / 4 - curve_adjustment * curve_adjustment)) * scale_ratio - 100 * scale_ratio
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(-x4, -y4, 0, x4, -y4, 0, x5, -y5, 0, -x5, -y5, 0)
            obj.drawpoly(-x5, -y5, 0, x5, -y5, 0, x6, -y6, 0, -x6, -y6, 0)
            obj.drawpoly(-x6, -y6, 0, x6, -y6, 0, x6, piece_size / 2, 0, -x6, piece_size / 2, 0)
            obj.drawpoly(x6, -y6, 0, half_piece_size, 0, 0, half_piece_size, half_piece_size, 0, x6, half_piece_size, 0)
            obj.drawpoly(
                -x6,
                -y6,
                0,
                -half_piece_size,
                0,
                0,
                -half_piece_size,
                half_piece_size,
                0,
                -x6,
                half_piece_size,
                0
            )
            obj.load("figure", "円", 0xffffff, 21 * scale_ratio * antialias_scale)
            obj.setoption("blend", "alpha_sub")
            obj.draw(32 * scale_ratio, -104 * scale_ratio + 100 * scale_ratio, 0, 1 / antialias_scale)
            obj.draw(-32 * scale_ratio, -104 * scale_ratio + 100 * scale_ratio, 0, 1 / antialias_scale)

            obj.copybuffer("cache:Img2", "tempbuffer")
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_sub")
            obj.drawpoly(
                -half_piece_size,
                0,
                0,
                half_piece_size,
                0,
                0,
                half_piece_size,
                half_piece_size,
                0,
                -half_piece_size,
                half_piece_size,
                0
            )

            obj.copybuffer("cache:Img1", "tempbuffer")
            obj.copybuffer("tempbuffer", "cache:Img2")
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(
                -half_piece_size,
                0,
                0,
                half_piece_size,
                0,
                0,
                half_piece_size,
                -half_piece_size,
                0,
                -half_piece_size,
                -half_piece_size,
                0
            )
            obj.copybuffer("object", "tempbuffer")
            obj.effect("反転", "透明度反転", 1)
            obj.effect("ローテーション", "90度回転", 2)
            obj.copybuffer("cache:Img2", "object")
            create_piece_shape(piece_size, half_piece_size, track_piece_shape)
        elseif track_piece_shape >= 5 and track_piece_shape <= 8 then
            local diagonal_size = math.sqrt(2) * piece_size + 1
            obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
            obj.load("figure", "円", 0xffffff, 3 * diagonal_size)
            obj.setoption("blend", "alpha_add")
            obj.draw(0, 0, 0, 1 / 3)
            obj.copybuffer("object", "tempbuffer")
            obj.setoption("blend", "alpha_sub")
            if track_piece_shape == 5 then
                obj.draw(-piece_size - 1, 0, 0) --ゴミ対策で±1
                obj.draw(piece_size + 1, 0, 0)
            elseif track_piece_shape == 6 then
                obj.draw(0, piece_size + 1, 0)
                obj.draw(-piece_size - 1, 0, 0)
            elseif track_piece_shape == 8 then
                obj.draw(0, piece_size + 1, 0)
            end
        elseif track_piece_shape >= 9 and track_piece_shape <= 22 then
            local x0, x1, x2, x3
            local y0, y1, y2, y3
            if track_piece_shape >= 9 and track_piece_shape <= 12 then
                x0, y0, x1, y1, x2, y2, x3, y3 =
                    -half_piece_size * 0.44,
                    -half_piece_size * 0.25,
                    half_piece_size * 0.44,
                    -half_piece_size * 0.25,
                    half_piece_size * 0.3,
                    0,
                    -half_piece_size * 0.3,
                    0
            elseif track_piece_shape >= 13 and track_piece_shape <= 17 then
                local notch_unit = piece_size / 5
                x0, y0, x1, y1, x2, y2, x3, y3 =
                    -half_piece_size + notch_unit,
                    -0.6 * notch_unit,
                    -half_piece_size + 2 * notch_unit,
                    -0.6 * notch_unit,
                    -half_piece_size + 2 * notch_unit,
                    0,
                    -half_piece_size + notch_unit,
                    0
            elseif track_piece_shape >= 18 and track_piece_shape <= 22 then
                local notch_unit = piece_size / 7
                x0, y0, x1, y1, x2, y2, x3, y3 =
                    -half_piece_size + 2 * notch_unit,
                    -1.2 * notch_unit,
                    -half_piece_size + 2 * notch_unit,
                    -1.2 * notch_unit,
                    -half_piece_size + 3 * notch_unit,
                    0,
                    -half_piece_size + notch_unit,
                    0
            end
            obj.setoption("drawtarget", "tempbuffer", piece_size, aligned_half_piece_size)
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
            if
                (track_piece_shape >= 13 and track_piece_shape <= 16)
                or (track_piece_shape >= 18 and track_piece_shape <= 21)
            then
                obj.drawpoly(-x0, y0, 0, -x1, y1, 0, -x2, y2, 0, -x3, y3, 0)
            end
            obj.copybuffer("cache:Img1", "tempbuffer")
            create_piece_shape(piece_size, half_piece_size, track_piece_shape)
        end
        create_piece_caches(piece_size, half_piece_size, piece_canvas_size)
        if track_gap > 0 then
            for i = 1, 2 do
                obj.copybuffer("object", "cache:PC" .. i)
                obj.effect("縁取り", "サイズ", track_gap, "ぼかし", 0)
                obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
                obj.setoption("blend", 0)
                obj.draw()
                obj.copybuffer("cache:PC" .. i, "tempbuffer")
            end
        end
    end
    --時間（マップ）作成----------
    local create_animation_map = function(
        piece_size,
        track_map_number,
        track_map_angle,
        horizontal_radius,
        vertical_radius,
        horizontal_extent,
        vertical_extent,
        value_map_center,
        check_load_map_image,
        check_invert_map,
        unfold_progress,
        track_map_limit_percent
    )
        local piece_times = {}
        if check_load_map_image == 0 then
            local calculate_map_value = ({
                function(grid_x, grid_y, map_normalizer, track_random_seed)
                    return math.sqrt(grid_x * grid_x + grid_y * grid_y) / map_normalizer
                end, --1.円
                function(grid_x, grid_y, map_normalizer, track_random_seed)
                    return math.max(math.abs(grid_x), math.abs(grid_y)) / map_normalizer
                end, --2.四角
                function(grid_x, grid_y, map_normalizer, track_random_seed)
                    return math.min(math.abs(grid_x), math.abs(grid_y)) / map_normalizer
                end, --3.十字
                function(grid_x, grid_y, map_normalizer, track_random_seed)
                    return math.abs(grid_y) / map_normalizer
                end, --4.中央直線
                function(grid_x, grid_y, map_normalizer, track_random_seed)
                    return (math.pi - math.atan2(grid_x, grid_y)) / map_normalizer
                end, --5.時計
                function(grid_x, grid_y, map_normalizer, track_random_seed)
                    return obj.rand(
                        0,
                        map_normalizer,
                        -(map_normalizer + grid_x + track_random_seed),
                        map_normalizer + grid_y + 1000
                    ) / map_normalizer
                end, --6.ランダム
            })[track_map_number]
            local map_normalizer = ({
                math.sqrt(horizontal_extent * horizontal_extent + vertical_extent * vertical_extent),
                math.max(horizontal_extent, vertical_extent),
                math.min(horizontal_extent, vertical_extent),
                vertical_radius,
                math.pi * 2,
                (2 * horizontal_extent + 1) * (2 * vertical_extent + 1),
            })[track_map_number]
            local map_center_x, map_center_y = value_map_center[1] / piece_size, value_map_center[2] / piece_size
            local sin, cos = math.sin(track_map_angle), math.cos(track_map_angle)
            for i = -horizontal_radius, horizontal_radius do
                piece_times[i] = {}
                local centered_column = i - map_center_x
                for j = -vertical_radius, vertical_radius do
                    local grid_x, grid_y =
                        centered_column * cos + (j - map_center_y) * sin,
                        -centered_column * sin + (j - map_center_y) * cos
                    piece_times[i][j] = calculate_map_value(grid_x, grid_y, map_normalizer, track_random_seed)
                end
            end
        else
            obj.load("layer", track_map_number, true)
            local w, h = obj.getpixel()
            obj.pixeloption("type", "yc")
            obj.pixeloption("get", "obj")
            for i = -horizontal_radius, horizontal_radius do
                piece_times[i] = {}
                for j = -vertical_radius, vertical_radius do
                    local luminance, blue_difference, red_difference, alpha = obj.getpixel(
                        (w - 1) * (i + horizontal_radius) / (2 * horizontal_radius),
                        (h - 1) * (j + vertical_radius) / (2 * vertical_radius),
                        "yc"
                    )
                    piece_times[i][j] = luminance / 4096
                end
            end
        end
        if check_invert_map then
            local max_map_value = -100000
            for i = -horizontal_radius, horizontal_radius do
                for j = -vertical_radius, vertical_radius do
                    max_map_value = max_map_value > piece_times[i][j] and max_map_value or piece_times[i][j]
                end
            end
            for i = -horizontal_radius, horizontal_radius do
                for j = -vertical_radius, vertical_radius do
                    piece_times[i][j] = max_map_value - piece_times[i][j]
                end
            end
        end
        for i = -horizontal_radius, horizontal_radius do
            for j = -vertical_radius, vertical_radius do
                local piece_time
                if piece_times[i][j] <= track_map_limit_percent then
                    piece_time = -piece_times[i][j] + unfold_progress
                    piece_times[i][j] = math.max(piece_time, 0)
                else
                    piece_times[i][j] = 0
                end
            end
        end
        return piece_times
    end
    --メイン----------
    local zoom = obj.getvalue("zoom") * 0.01
    local unfold_progress = track_unfold * 0.01
    local scatter_speed = track_speed * 7.5
    local scatter_direction = -math.direction_radians(track_direction)
    check_shift_placement = check_shift_placement or 0
    check_show_loaded_image = check_show_loaded_image or 0
    value_map_center = value_map_center or { 0, 0 }
    track_map_angle = (track_map_angle or 0) * math.pi / 180
    check_reverse_faces = check_reverse_faces or 0
    obj.setanchor("value_map_center", #value_map_center / 2, "line")
    obj.setanchor("track_scatter_center_x,track_scatter_center_y", 0)
    if #value_map_center > 3 then
        track_map_angle =
            -math.atan2(value_map_center[3] - value_map_center[1], value_map_center[4] - value_map_center[2])
    end
    track_rotation_speed = track_rotation_speed * 0.03
    gravity[1] = gravity[1] * 30 * zoom
    gravity[2] = gravity[2] * 30 * zoom
    gravity[3] = gravity[3] * 30 * zoom
    track_map_limit_percent = track_map_limit_percent * 0.01
    local piece_size = math.floor(track_piece_size)
    local w, h = obj.getpixel()
    local horizontal_extent = (w - piece_size) / piece_size * 0.5
    local vertical_extent = (h - piece_size) / piece_size * 0.5
    local horizontal_radius = math.floor(w / piece_size * 0.5 + 1)
    local vertical_radius = math.floor(h / piece_size * 0.5 + 1)
    local w2, h2 = w * 0.5, h * 0.5
    local scaled_piece_size = piece_size * zoom
    local scaled_image_width = w * zoom
    local scaled_image_height = h * zoom
    local half_scaled_image_width = scaled_image_width / 2
    local half_scaled_image_height = scaled_image_height / 2
    scatter_speed = scatter_speed * zoom
    scatter_center[1] = scatter_center[1] / piece_size
    scatter_center[2] = scatter_center[2] / piece_size
    if track_piece_shape < 0 then --レイヤー読み込み
        obj.copybuffer("cache:ORI", "object")
        obj.setoption("drawtarget", "tempbuffer", piece_size * 2 + piece_size % 2, piece_size * 2 + piece_size % 2)
        obj.load("layer", -track_piece_shape, true)
        obj.drawpoly(
            -piece_size,
            -piece_size,
            0,
            piece_size,
            -piece_size,
            0,
            piece_size,
            piece_size,
            0,
            -piece_size,
            piece_size,
            0
        )
        obj.copybuffer("cache:LayImg", "tempbuffer")
        if check_show_loaded_image == 1 then
            obj.copybuffer("object", "tempbuffer")
            obj.copybuffer("tempbuffer", "cache:ORI")
            local column_parity = ((horizontal_radius + vertical_radius) % 2 == check_shift_placement) and 1 or 0
            for j = -vertical_radius, vertical_radius do
                column_parity = 1 - column_parity
                for i = -horizontal_radius + column_parity, horizontal_radius, 2 do
                    obj.draw(piece_size * i, piece_size * j)
                end
            end
            obj.copybuffer("cache:ORI", "tempbuffer")
        end
    else
        obj.copybuffer("cache:ORI", "object")
    end
    --ピース作成
    create_piece_image(piece_size, track_gap, track_piece_shape)
    --時間（マップ）作成
    local piece_times = create_animation_map(
        piece_size,
        track_map_number,
        track_map_angle,
        horizontal_radius,
        vertical_radius,
        horizontal_extent,
        vertical_extent,
        value_map_center,
        check_load_map_image,
        check_invert_map,
        unfold_progress,
        track_map_limit_percent
    )
    --表示
    obj.setoption("drawtarget", "tempbuffer")
    local vertices = {}
    local draw_poly = ({
        function(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, radial_speed, u2, forward_speed, u3, v3)
            vertices[#vertices + 1] =
                { x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, radial_speed, u2, forward_speed, u3, v3 }
        end,
        function(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, radial_speed, u2, forward_speed, u3, v3)
            vertices[#vertices + 1] =
                { x3, y3, z3, x2, y2, z2, x1, y1, z1, x0, y0, z0, u3, v3, u2, forward_speed, u1, radial_speed, u0, v0 }
        end,
    })[check_reverse_faces + 1]
    local placement_parity = ((horizontal_radius + vertical_radius) % 2 == check_shift_placement) and 0 or 1
    for row_parity = 0, 1 do
        for column_parity = 0, 1 do
            obj.copybuffer("tempbuffer", "cache:ORI")
            obj.setoption("drawtarget", "tempbuffer")
            if (column_parity + row_parity) % 2 == placement_parity then
                obj.copybuffer("object", "cache:PC1")
            else
                obj.copybuffer("object", "cache:PC2")
            end
            obj.setoption("blend", "alpha_sub")
            for j = -vertical_radius + row_parity, vertical_radius, 2 do
                for i = -horizontal_radius + column_parity, horizontal_radius, 2 do
                    obj.draw(i * piece_size, j * piece_size, 0)
                end
            end

            obj.copybuffer("object", "tempbuffer")
            obj.setoption("drawtarget", "framebuffer")
            obj.setoption("blend", 0)
            vertices = {}
            for j = -vertical_radius + row_parity, vertical_radius, 2 do
                local piece_center_y = scaled_piece_size * j
                for i = -horizontal_radius + column_parity, horizontal_radius, 2 do
                    local piece_time = piece_times[i][j]
                    local piece_center_x = scaled_piece_size * i
                    local x0, x1, x2, x3 =
                        piece_center_x - scaled_piece_size,
                        piece_center_x + scaled_piece_size,
                        piece_center_x + scaled_piece_size,
                        piece_center_x - scaled_piece_size
                    local y0, y1, y2, y3 =
                        piece_center_y - scaled_piece_size,
                        piece_center_y - scaled_piece_size,
                        piece_center_y + scaled_piece_size,
                        piece_center_y + scaled_piece_size
                    local z0, z1, z2, z3
                    x0 = x0 < -half_scaled_image_width and -half_scaled_image_width
                        or (x0 > half_scaled_image_width and half_scaled_image_width or x0)
                    x1 = x1 < -half_scaled_image_width and -half_scaled_image_width
                        or (x1 > half_scaled_image_width and half_scaled_image_width or x1)
                    x2 = x2 < -half_scaled_image_width and -half_scaled_image_width
                        or (x2 > half_scaled_image_width and half_scaled_image_width or x2)
                    x3 = x3 < -half_scaled_image_width and -half_scaled_image_width
                        or (x3 > half_scaled_image_width and half_scaled_image_width or x3)
                    y0 = y0 < -half_scaled_image_height and -half_scaled_image_height
                        or (y0 > half_scaled_image_height and half_scaled_image_height or y0)
                    y1 = y1 < -half_scaled_image_height and -half_scaled_image_height
                        or (y1 > half_scaled_image_height and half_scaled_image_height or y1)
                    y2 = y2 < -half_scaled_image_height and -half_scaled_image_height
                        or (y2 > half_scaled_image_height and half_scaled_image_height or y2)
                    y3 = y3 < -half_scaled_image_height and -half_scaled_image_height
                        or (y3 > half_scaled_image_height and half_scaled_image_height or y3)
                    local u0, u1, u2, u3 =
                        x0 + half_scaled_image_width,
                        x1 + half_scaled_image_width,
                        x2 + half_scaled_image_width,
                        x3 + half_scaled_image_width
                    local v0, radial_speed, forward_speed, v3 =
                        y0 + half_scaled_image_height,
                        y1 + half_scaled_image_height,
                        y2 + half_scaled_image_height,
                        y3 + half_scaled_image_height
                    local rotation_x = obj.rand(
                        -100,
                        100,
                        -(i + horizontal_radius + j + vertical_radius + track_random_seed),
                        2000
                    ) * 0.01 * piece_time * track_rotation_speed
                    local rotation_y = obj.rand(
                        -100,
                        100,
                        -(i + horizontal_radius + j + vertical_radius + track_random_seed),
                        3000
                    ) * 0.01 * piece_time * track_rotation_speed
                    local rotation_z = obj.rand(
                        -100,
                        100,
                        -(i + horizontal_radius + j + vertical_radius + track_random_seed),
                        4000
                    ) * 0.01 * piece_time * track_rotation_speed
                    local sin_x = math.sin(rotation_x)
                    local cos_x = math.cos(rotation_x)
                    local sin_y = math.sin(rotation_y)
                    local cos_y = math.cos(rotation_y)
                    local sin_z = math.sin(rotation_z)
                    local cos_z = math.cos(rotation_z)
                    local dx = (x0 + x1 + x2 + x3) / 4
                    local dy = (y0 + y1 + y2 + y3) / 4
                    x0, y0, z0 = rotate_xy_vector(x0 - dx, y0 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x1, y1, z1 = rotate_xy_vector(x1 - dx, y1 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x2, y2, z2 = rotate_xy_vector(x2 - dx, y2 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x3, y3, z3 = rotate_xy_vector(x3 - dx, y3 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x0, x1, x2, x3 = x0 + dx, x1 + dx, x2 + dx, x3 + dx
                    y0, y1, y2, y3 = y0 + dy, y1 + dy, y2 + dy, y3 + dy
                    local grid_x = i - scatter_center[1]
                    local grid_y = j - scatter_center[2]
                    local direction_radians = scatter_direction
                        * math.sqrt(grid_x * grid_x + grid_y * grid_y)
                        / vertical_radius
                    local radial_speed = -scatter_speed * math.sin(direction_radians)
                    local velocity_z = -scatter_speed * math.cos(direction_radians)
                    direction_radians = math.atan2(grid_x, grid_y)
                    local velocity_x = radial_speed * math.sin(direction_radians)
                    local velocity_y = radial_speed * math.cos(direction_radians)
                    local translation_x = gravity[1] * piece_time * piece_time * 0.5 + velocity_x * piece_time
                    local translation_y = gravity[2] * piece_time * piece_time * 0.5 + velocity_y * piece_time
                    local translation_z = gravity[3] * piece_time * piece_time * 0.5 + velocity_z * piece_time
                    x0, x1, x2, x3 = x0 + translation_x, x1 + translation_x, x2 + translation_x, x3 + translation_x
                    y0, y1, y2, y3 = y0 + translation_y, y1 + translation_y, y2 + translation_y, y3 + translation_y
                    z0, z1, z2, z3 = z0 + translation_z, z1 + translation_z, z2 + translation_z, z3 + translation_z
                    draw_poly(
                        x0,
                        y0,
                        z0,
                        x1,
                        y1,
                        z1,
                        x2,
                        y2,
                        z2,
                        x3,
                        y3,
                        z3,
                        u0,
                        v0,
                        u1,
                        radial_speed,
                        u2,
                        forward_speed,
                        u3,
                        v3
                    )
                end
            end
            if #vertices > 0 then
                obj.drawpoly(vertices)
            end
        end
    end
    obj.setoption("blend", "none")
end
