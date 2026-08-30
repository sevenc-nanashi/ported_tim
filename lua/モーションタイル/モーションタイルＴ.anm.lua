--label:${ROOT_CATEGORY}\配置
---$track:中心位置
---min=-20000
---max=20000
---step=0.1
local track_center_position = 0

---$track:出力幅％
---min=0
---max=5000
---step=0.1
local track_width_percent = 150

---$track:出力高％
---min=0
---max=5000
---step=0.1
local track_height_percent = 150

---$track:フェーズ
---min=-5000
---max=5000
---step=0.1
local track_phase = 0

---$track:速度方向(度)
---min=-3600
---max=3600
---step=0.01
local track_speed_direction_degrees = 0

---$check:X反転配置
local check_mirror_x = 0

---$check:Y反転配置
local check_mirror_y = 0

---$check:水平シフト
local check_horizontal_shift = true

local center_distance = track_center_position
local output_width_scale = track_width_percent * 0.01
local output_height_scale = track_height_percent * 0.01
local phase_shift = -track_phase * 0.01

local tile_width, tile_height = obj.getpixel()

local output_width = tile_width * output_width_scale
local output_height = tile_height * output_height_scale

local buffer_width = 2 * math.floor(output_width * 0.5)
local buffer_height = 2 * math.floor(output_height * 0.5)

obj.setoption("drawtarget", "tempbuffer", buffer_width, buffer_height)
obj.setoption("blend", "alpha_add")

local offset_x = center_distance * math.cos(track_speed_direction_degrees * math.pi / 180)
local offset_y = center_distance * math.sin(track_speed_direction_degrees * math.pi / 180)
local mirror_rotation_x = 180 * check_mirror_x
local mirror_rotation_y = 180 * check_mirror_y

local output_half_width = output_width * 0.5
local output_half_height = output_height * 0.5

if check_horizontal_shift then
    local first_row = math.ceil((-offset_y - output_half_height) / tile_height - 0.5)
    local last_row = math.floor((-offset_y + output_half_height) / tile_height + 0.5)
    for j = first_row, last_row do
        local first_column = math.ceil((-offset_x - output_half_width) / tile_width - phase_shift * j - 0.5)
        local last_column = math.floor((-offset_x + output_half_width) / tile_width - phase_shift * j + 0.5)
        for i = first_column, last_column do
            obj.draw(
                tile_width * (i + phase_shift * j) + offset_x,
                tile_height * j + offset_y,
                0,
                1,
                1,
                mirror_rotation_y * j,
                mirror_rotation_x * i,
                0
            )
        end
    end
else
    local first_column = math.ceil((-offset_x - output_half_width) / tile_width - 0.5)
    local last_column = math.floor((-offset_x + output_half_width) / tile_width + 0.5)
    for i = first_column, last_column do
        local first_row = math.ceil((-offset_y - output_half_height) / tile_height - phase_shift * i - 0.5)
        local last_row = math.floor((-offset_y + output_half_height) / tile_height - phase_shift * i + 0.5)
        for j = first_row, last_row do
            obj.draw(
                tile_width * i + offset_x,
                tile_height * (j + phase_shift * i) + offset_y,
                0,
                1,
                1,
                mirror_rotation_y * j,
                mirror_rotation_x * i,
                0
            )
        end
    end
end

obj.load("tempbuffer")
