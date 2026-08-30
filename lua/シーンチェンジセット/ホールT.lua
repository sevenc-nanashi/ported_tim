--label:${ROOT_CATEGORY}\シーンチェンジ\@シーンチェンジセットT
---$track:サイズ
---min=10
---max=2000
---step=0.1
local track_size = 100

---$track:開時間％
---min=0.1
---max=100
---step=0.1
local track_open_duration_percent = 10

---$track:ランダム性％
---min=0
---max=100
---step=0.1
local track_randomness_percent = 100

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_random_seed = 5

local transition_progress = obj.getvalue("scenechange")
local cell_size = track_size
local open_duration = track_open_duration_percent * 0.01
local start_time_scale = 1 - open_duration
local image_width = obj.w
local image_height = obj.h
local half_width = image_width * 0.5
local half_height = image_height * 0.5
local column_count = math.ceil(image_width / cell_size)
local row_count = math.ceil(image_height / cell_size)
local diameter = 2 * cell_size
local random_offset_rate = track_randomness_percent * 0.01
local random_seed = math.floor(track_random_seed)
if random_offset_rate < 0 then
    random_offset_rate = 0
elseif random_offset_rate > 1 then
    random_offset_rate = 1
end
local vertex_x = {}
local vertex_y = {}

for i = 0, column_count do
    vertex_x[i] = {}
    vertex_y[i] = {}
    local base_x = i * cell_size
    for j = 0, row_count do
        vertex_x[i][j] = base_x + obj.rand(-cell_size, cell_size, i, j + random_seed + 1000) * random_offset_rate
        vertex_y[i][j] = j * cell_size + obj.rand(-cell_size, cell_size, i, j + random_seed + 2000) * random_offset_rate
    end
end

for i = 0, column_count do
    vertex_y[i][0] = 0
    vertex_y[i][row_count] = image_height
end

for j = 0, row_count do
    vertex_x[0][j] = 0
    vertex_x[column_count][j] = image_width
end

local cell_start_times = {}
local maximum_start_time = 0
local minimum_start_time = 1000
for i = 0, column_count - 1 do
    cell_start_times[i] = {}
    for j = 0, row_count - 1 do
        cell_start_times[i][j] = obj.rand(0, 1000, i, j + random_seed + 3000)
        if maximum_start_time < cell_start_times[i][j] then
            maximum_start_time = cell_start_times[i][j]
        end
        if minimum_start_time > cell_start_times[i][j] then
            minimum_start_time = cell_start_times[i][j]
        end
    end
end

start_time_scale = start_time_scale / (maximum_start_time - minimum_start_time)
for i = 0, column_count - 1 do
    for j = 0, row_count - 1 do
        cell_start_times[i][j] = start_time_scale * (cell_start_times[i][j] - minimum_start_time)
    end
end

obj.copybuffer("cache:original", "object")
obj.setoption("drawtarget", "tempbuffer", obj.getpixel())

obj.load("figure", "円", 0xffffff, diameter)
for i = 0, column_count - 1 do
    for j = 0, row_count - 1 do
        local cell_progress = (transition_progress - cell_start_times[i][j]) / open_duration
        if cell_progress > 1 then
            cell_progress = 1
        end
        if cell_progress > 0 then
            local cell_center_x = (vertex_x[i][j] + vertex_x[i + 1][j] + vertex_x[i + 1][j + 1] + vertex_x[i][j + 1])
                * 0.25
            local cell_center_y = (vertex_y[i][j] + vertex_y[i + 1][j] + vertex_y[i + 1][j + 1] + vertex_y[i][j + 1])
                * 0.25
            local corner_distance_1 = (vertex_x[i][j] - cell_center_x) * (vertex_x[i][j] - cell_center_x)
                + (vertex_y[i][j] - cell_center_y) * (vertex_y[i][j] - cell_center_y)
            local corner_distance_2 = (vertex_x[i + 1][j] - cell_center_x) * (vertex_x[i + 1][j] - cell_center_x)
                + (vertex_y[i + 1][j] - cell_center_y) * (vertex_y[i + 1][j] - cell_center_y)
            local corner_distance_3 = (vertex_x[i + 1][j + 1] - cell_center_x)
                    * (vertex_x[i + 1][j + 1] - cell_center_x)
                + (vertex_y[i + 1][j + 1] - cell_center_y) * (vertex_y[i + 1][j + 1] - cell_center_y)
            local corner_distance_4 = (vertex_x[i][j + 1] - cell_center_x) * (vertex_x[i][j + 1] - cell_center_x)
                + (vertex_y[i][j + 1] - cell_center_y) * (vertex_y[i][j + 1] - cell_center_y)
            corner_distance_1 = 2
                * math.sqrt(math.max(corner_distance_1, corner_distance_2, corner_distance_3, corner_distance_4))
            obj.draw(
                cell_center_x - half_width,
                cell_center_y - half_height,
                0,
                corner_distance_1 / diameter * cell_progress
            )
        end
    end
end

obj.copybuffer("cache:delete_area", "tempbuffer")
obj.copybuffer("tempbuffer", "cache:original")
obj.setoption("blend", "alpha_sub")
obj.copybuffer("object", "cache:delete_area")
obj.draw()
obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.setoption("blend", "none")
obj.draw()
