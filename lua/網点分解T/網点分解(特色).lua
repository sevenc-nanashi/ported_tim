--label:${ROOT_CATEGORY}\加工\@網点分解T
---$track:サイズ
---min=5
---max=1000
---step=0.1
local track_size = 10

---$track:最小
---min=0
---max=500
---step=0.1
local track_min = 0

---$track:最大
---min=0
---max=500
---step=0.1
local track_max = 120

---$track:ボカシ補正
---min=0
---max=500
---step=1
local track_adjust = 50

---$figure:形状
local dot_figure = "円"

---$track:網点角度1
---min=0
---max=360
---step=0.1
local track_dot_angle_1 = 15

---$track:網点角度2
---min=0
---max=360
---step=0.1
local track_dot_angle_2 = 75

---$track:網点角度3
---min=0
---max=360
---step=0.1
local track_dot_angle_3 = 30

---$check:網点も回転
local check_rotate_dots = 0

---$track:公転速度
---min=-10
---max=10
---step=0.1
local track_orbit_speed = 0

---$track:自転速度
---min=-10
---max=10
---step=0.1
local track_rotation_speed = 0

---$color:色1
local separation_color_1 = 0x00ffff

---$color:色2
local separation_color_2 = 0xff00ff

---$color:色3
local separation_color_3 = 0xffff00

---$color:背景色
local background_color = 0xffffff

---$select:型抜法
---なし=0
---網点のみ=1
---網点と元画像=2
local select_cutout_method = 2

local simple_preview_active = 0

local dot_size = track_size
local minimum_dot_scale = track_min * 0.01
local maximum_dot_scale = track_max * 0.01
local blur_size = track_adjust * 0.01 * dot_size

if simple_preview_active == 1 then
    dot_size = dot_size / 4
    blur_size = blur_size / 4
    obj.effect("リサイズ", "拡大率", 25)
end

local channel_angles = { track_dot_angle_1, track_dot_angle_2, track_dot_angle_3 }
local image_width, image_height = obj.getpixel()
local half_width, half_height = image_width / 2, image_height / 2

local orbit_angle = obj.time * track_orbit_speed
local rotation_angle = obj.time * track_rotation_speed

local separation_color_count
if not separation_color_1 then
    separation_color_count = 3
    separation_color_1 = 0x00ffff
    separation_color_2 = 0xff00ff
    separation_color_3 = 0xffff00
elseif not separation_color_2 then
    separation_color_count = 1
elseif not separation_color_3 then
    separation_color_count = 2
else
    separation_color_count = 3
end

local inverse_red_1, inverse_green_1, inverse_blue_1 = RGB(separation_color_1)
local inverse_red_2, inverse_green_2, inverse_blue_2 = RGB(separation_color_2 or 0x0)
local inverse_red_3, inverse_green_3, inverse_blue_3 = RGB(separation_color_3 or 0x0)
inverse_red_1, inverse_green_1, inverse_blue_1 = 255 - inverse_red_1, 255 - inverse_green_1, 255 - inverse_blue_1
inverse_red_2, inverse_green_2, inverse_blue_2 = 255 - inverse_red_2, 255 - inverse_green_2, 255 - inverse_blue_2
inverse_red_3, inverse_green_3, inverse_blue_3 = 255 - inverse_red_3, 255 - inverse_green_3, 255 - inverse_blue_3

local separation_coefficients = {}
if separation_color_count == 1 then
    local inverse_determinant = 1
        / (inverse_red_1 * inverse_red_1 + inverse_green_1 * inverse_green_1 + inverse_blue_1 * inverse_blue_1)
    separation_coefficients[1] = {
        inverse_red_1 * inverse_determinant,
        inverse_green_1 * inverse_determinant,
        inverse_blue_1 * inverse_determinant,
    }
elseif separation_color_count == 2 then
    local gram_11 = inverse_red_1 * inverse_red_1 + inverse_green_1 * inverse_green_1 + inverse_blue_1 * inverse_blue_1
    local gram_22 = inverse_red_2 * inverse_red_2 + inverse_green_2 * inverse_green_2 + inverse_blue_2 * inverse_blue_2
    local gram_12 = inverse_red_1 * inverse_red_2 + inverse_green_1 * inverse_green_2 + inverse_blue_1 * inverse_blue_2
    local inverse_determinant = 1 / (gram_11 * gram_22 - gram_12 * gram_12)
    local inverse_gram_11 = gram_22 * inverse_determinant
    local inverse_gram_12 = -gram_12 * inverse_determinant
    local inverse_gram_22 = gram_11 * inverse_determinant
    separation_coefficients[1] = {
        inverse_gram_11 * inverse_red_1 + inverse_gram_12 * inverse_red_2,
        inverse_gram_11 * inverse_green_1 + inverse_gram_12 * inverse_green_2,
        inverse_gram_11 * inverse_blue_1 + inverse_gram_12 * inverse_blue_2,
    }
    separation_coefficients[2] = {
        inverse_gram_12 * inverse_red_1 + inverse_gram_22 * inverse_red_2,
        inverse_gram_12 * inverse_green_1 + inverse_gram_22 * inverse_green_2,
        inverse_gram_12 * inverse_blue_1 + inverse_gram_22 * inverse_blue_2,
    }
else
    local inverse_determinant = 1
        / (
            inverse_red_1 * inverse_green_2 * inverse_blue_3
            + inverse_red_2 * inverse_green_3 * inverse_blue_1
            + inverse_red_3 * inverse_green_1 * inverse_blue_2
            - inverse_red_1 * inverse_green_3 * inverse_blue_2
            - inverse_red_2 * inverse_green_1 * inverse_blue_3
            - inverse_red_3 * inverse_green_2 * inverse_blue_1
        )
    separation_coefficients[1] = {
        (inverse_green_2 * inverse_blue_3 - inverse_green_3 * inverse_blue_2) * inverse_determinant,
        -(inverse_red_2 * inverse_blue_3 - inverse_red_3 * inverse_blue_2) * inverse_determinant,
        (inverse_red_2 * inverse_green_3 - inverse_red_3 * inverse_green_2) * inverse_determinant,
    }
    separation_coefficients[2] = {
        -(inverse_green_1 * inverse_blue_3 - inverse_green_3 * inverse_blue_1) * inverse_determinant,
        (inverse_red_1 * inverse_blue_3 - inverse_red_3 * inverse_blue_1) * inverse_determinant,
        -(inverse_red_1 * inverse_green_3 - inverse_red_3 * inverse_green_1) * inverse_determinant,
    }
    separation_coefficients[3] = {
        (inverse_green_1 * inverse_blue_2 - inverse_green_2 * inverse_blue_1) * inverse_determinant,
        -(inverse_red_1 * inverse_blue_2 - inverse_red_2 * inverse_blue_1) * inverse_determinant,
        (inverse_red_1 * inverse_green_2 - inverse_red_2 * inverse_green_1) * inverse_determinant,
    }
end

local channel_colors = {}
channel_colors[1] = RGB(inverse_red_1, inverse_green_1, inverse_blue_1)
channel_colors[2] = RGB(inverse_red_2, inverse_green_2, inverse_blue_2)
channel_colors[3] = RGB(inverse_red_3, inverse_green_3, inverse_blue_3)

local channel_alphas = {}
local channel_x_positions = {}
local channel_y_positions = {}
local channel_scales = {}
local channel_rotations = {}
local channel_point_counts = {}

local generate_channel_data = function(channel_index, base_rotation)
    local grid_rotation_radians = math.pi * ((base_rotation + orbit_angle) % 90) / 180 --dxが0になることはない
    local grid_cosine, grid_sine = math.cos(grid_rotation_radians), math.sin(grid_rotation_radians) --cos,sin>=0
    local grid_step_x, grid_step_y = dot_size * grid_cosine, dot_size * grid_sine
    local grid_line_count = math.floor((half_width * grid_sine + half_height * grid_cosine) / dot_size)
    local point_count = 0

    channel_alphas[channel_index] = {}
    channel_x_positions[channel_index] = {}
    channel_y_positions[channel_index] = {}
    channel_scales[channel_index] = {}

    for k = -grid_line_count, grid_line_count do
        local line_origin_x = -k * grid_step_y
        local line_origin_y = k * grid_step_x
        local first_grid_index = math.ceil(
            math.max(
                (-half_width - line_origin_x) / math.abs(grid_step_x),
                (-half_height - line_origin_y) / math.abs(grid_step_y)
            )
        ) --dy=0でもうまくいく
        local last_grid_index = math.floor(
            math.min(
                (half_width - line_origin_x) / math.abs(grid_step_x),
                (half_height - line_origin_y) / math.abs(grid_step_y)
            )
        )
        for j = first_grid_index, last_grid_index do
            local point_x = j * grid_step_x + line_origin_x
            local point_y = j * grid_step_y + line_origin_y
            local pixel_channels = {}
            local pixel_alpha
            pixel_channels[1], pixel_channels[2], pixel_channels[3], pixel_alpha =
                obj.getpixel(point_x + half_width, point_y + half_height, "rgb")
            if pixel_alpha > 0 then
                point_count = point_count + 1
                local channel_amount = separation_coefficients[channel_index][1] * (255 - pixel_channels[1])
                    + separation_coefficients[channel_index][2] * (255 - pixel_channels[2])
                    + separation_coefficients[channel_index][3] * (255 - pixel_channels[3])
                if channel_amount < 0 then
                    channel_amount = 0
                elseif channel_amount > 1 then
                    channel_amount = 1
                end
                channel_alphas[channel_index][point_count] = pixel_alpha / 255
                channel_x_positions[channel_index][point_count] = point_x
                channel_y_positions[channel_index][point_count] = point_y
                channel_scales[channel_index][point_count] = math.sqrt(channel_amount)
                        * (maximum_dot_scale - minimum_dot_scale)
                    + minimum_dot_scale
            end
        end
    end
    channel_rotations[channel_index] = base_rotation * check_rotate_dots + orbit_angle + rotation_angle
    channel_point_counts[channel_index] = point_count
end

local render_channel = function(channel_colors, channel_index)
    obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
    if dot_size < 100 then
        obj.load("figure", dot_figure, channel_colors, 100)
        obj.effect("リサイズ", "拡大率", dot_size)
    else
        obj.load("figure", dot_figure, channel_colors, dot_size)
    end
    for i = 1, channel_point_counts[channel_index] do
        obj.draw(
            channel_x_positions[channel_index][i],
            channel_y_positions[channel_index][i],
            0,
            channel_scales[channel_index][i],
            channel_alphas[channel_index][i],
            0,
            0,
            channel_rotations[channel_index]
        )
    end
    obj.copybuffer("cache:C" .. channel_index, "tempbuffer")
end

obj.effect("ぼかし", "範囲", blur_size, "縦横比", 0, "光の強さ", 0, "サイズ固定", 1)
obj.copybuffer("cache:ori_img", "object")

for i = 1, separation_color_count do
    generate_channel_data(i, channel_angles[i])
end

for i = 1, separation_color_count do
    render_channel(channel_colors[i], i)
end

if select_cutout_method > 0 then
    for i = 1, separation_color_count do
        obj.copybuffer("object", "cache:C" .. i)
        obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", background_color)
        obj.draw()
    end
    if select_cutout_method == 2 then
        obj.copybuffer("object", "cache:ori_img")
        obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", background_color)
        obj.draw()
    end
else
    obj.load("figure", "四角形", background_color, 1)
    obj.drawpoly(
        -half_width,
        -half_height,
        0,
        half_width,
        -half_height,
        0,
        half_width,
        half_height,
        0,
        -half_width,
        half_height,
        0
    )
end

obj.setoption("blend", 2)
for i = 1, separation_color_count do
    obj.copybuffer("object", "cache:C" .. i)
    obj.draw()
end

obj.load("tempbuffer")
if simple_preview_active == 1 then
    obj.effect("リサイズ", "拡大率", 400)
end
obj.setoption("blend", 0)
