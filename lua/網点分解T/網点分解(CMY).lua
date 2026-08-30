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

---$track:網点角度C
---min=0
---max=360
---step=0.1
local track_cyan_angle = 15

---$track:網点角度M
---min=0
---max=360
---step=0.1
local track_magenta_angle = 75

---$track:網点角度Y
---min=0
---max=360
---step=0.1
local track_yellow_angle = 30

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

---$color:背景色
local background_color = 0xffffff

---$select:型抜法
---なし=0
---網点のみ=1
---網点と元画像=2
local select_cutout_method = 2

---$check:簡易表示
local check_simple_preview = false

local simple_preview_active = 0
if check_simple_preview and obj.getinfo("saving") == false then
    simple_preview_active = 1
end

local dot_size = track_size
local minimum_dot_scale = track_min * 0.01
local maximum_dot_scale = track_max * 0.01
local blur_size = track_adjust * 0.01 * dot_size

if simple_preview_active == 1 then
    dot_size = dot_size / 4
    blur_size = blur_size / 4
    obj.effect("リサイズ", "拡大率", 25)
end

local image_width, image_height = obj.getpixel()
local half_width, half_height = image_width / 2, image_height / 2

local orbit_angle = obj.time * track_orbit_speed
local rotation_angle = obj.time * track_rotation_speed

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
                channel_alphas[channel_index][point_count] = pixel_alpha / 255
                channel_x_positions[channel_index][point_count] = point_x
                channel_y_positions[channel_index][point_count] = point_y
                channel_scales[channel_index][point_count] = math.sqrt((255 - pixel_channels[channel_index]) / 255)
                        * (maximum_dot_scale - minimum_dot_scale)
                    + minimum_dot_scale
            end
        end
    end
    channel_rotations[channel_index] = base_rotation * check_rotate_dots + orbit_angle + rotation_angle
    channel_point_counts[channel_index] = point_count
end

local render_channel = function(channel_color, channel_index)
    obj.setoption("drawtarget", "tempbuffer", image_width, image_height)

    if dot_size < 100 then
        obj.load("figure", dot_figure, channel_color, 100)
        obj.effect("リサイズ", "拡大率", dot_size)
    else
        obj.load("figure", dot_figure, channel_color, dot_size)
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

obj.copybuffer("cache:ori_img", "object")

obj.effect("ぼかし", "範囲", blur_size, "縦横比", 0, "光の強さ", 0, "サイズ固定", 1)
obj.copybuffer("cache:ori_img", "object")

generate_channel_data(1, track_cyan_angle)
generate_channel_data(2, track_magenta_angle)
generate_channel_data(3, track_yellow_angle)

render_channel(0xff0000, 1)
render_channel(0x00ff00, 2)
render_channel(0x0000ff, 3)

obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
if select_cutout_method > 0 then
    obj.copybuffer("object", "cache:C1")
    obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", background_color)
    obj.draw()
    obj.copybuffer("object", "cache:C2")
    obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", background_color)
    obj.draw()
    obj.copybuffer("object", "cache:C3")
    obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", background_color)
    obj.draw()
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
obj.copybuffer("object", "cache:C1")
obj.draw()
obj.copybuffer("object", "cache:C2")
obj.draw()
obj.copybuffer("object", "cache:C3")
obj.draw()

obj.load("tempbuffer")
if simple_preview_active == 1 then
    obj.effect("リサイズ", "拡大率", 400)
end
obj.setoption("blend", 0)
