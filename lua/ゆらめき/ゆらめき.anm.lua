--label:${ROOT_CATEGORY}\アニメーション効果
---$track:サイズ
---min=10
---max=2000
---step=0.1
local track_mesh_size = 50

---$track:形状変化
---min=0
---max=10000
---step=0.1
local track_shape_change = 0

---$track:ランダム形状[%]
---min=0
---max=100
---step=0.1
local track_random_shape_percent = 20

---$track:形状乱数シード
---min=0
---max=100000
---step=1
local track_shape_seed = 0

local vertex_x = {}
local vertex_y = {}

local image_width, image_height = obj.getpixel()

local mesh_size = track_mesh_size

local shape_progress = track_shape_change * 0.01
local shape_step = math.floor(shape_progress)
shape_progress = shape_progress - shape_step
local inverse_shape_progress = 1 - shape_progress

local random_shape_ratio = math.abs(track_random_shape_percent) * 0.01
if random_shape_ratio > 1 then
    random_shape_ratio = 1
end
random_shape_ratio = random_shape_ratio / 2.3

obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
obj.setoption("antialias", 1)
obj.setoption("blend", "alpha_add")

local horizontal_cell_count = math.floor(image_width / mesh_size)
local vertical_cell_count = math.floor(image_height / mesh_size)

if horizontal_cell_count < 2 then
    horizontal_cell_count = 2
elseif horizontal_cell_count > image_width then
    horizontal_cell_count = image_width
end
if vertical_cell_count < 2 then
    vertical_cell_count = 2
elseif vertical_cell_count > image_height then
    vertical_cell_count = image_height
end

local random_offset_x = image_width / horizontal_cell_count * random_shape_ratio
local random_offset_y = image_height / vertical_cell_count * random_shape_ratio

local current_x_seed = track_shape_seed + shape_step
local next_x_seed = current_x_seed + 1
local current_y_seed = 1000 + current_x_seed
local next_y_seed = 1000 + next_x_seed

for x = 0, horizontal_cell_count do
    vertex_x[x] = {}
    vertex_y[x] = {}
    for y = 0, vertical_cell_count do
        vertex_x[x][y] = image_width * (x / horizontal_cell_count - 0.5)
            + inverse_shape_progress * obj.rand(-random_offset_x, random_offset_x, x, y + current_x_seed)
            + shape_progress * obj.rand(-random_offset_x, random_offset_x, x, y + next_x_seed)
        vertex_y[x][y] = image_height * (y / vertical_cell_count - 0.5)
            + inverse_shape_progress * obj.rand(-random_offset_y, random_offset_y, x, y + current_y_seed)
            + shape_progress * obj.rand(-random_offset_y, random_offset_y, x, y + next_y_seed)
    end
end

local half_extent = image_width * 0.5
for y = 0, vertical_cell_count do
    vertex_x[0][y] = -half_extent
    vertex_x[horizontal_cell_count][y] = half_extent
end

half_extent = image_height * 0.5
for x = 0, horizontal_cell_count do
    vertex_y[x][0] = -half_extent
    vertex_y[x][vertical_cell_count] = half_extent
end

for y = 0, vertical_cell_count - 1 do
    for x = 0, horizontal_cell_count - 1 do
        local texture_left = image_width * x / horizontal_cell_count
        local texture_top = image_height * y / vertical_cell_count
        local texture_right = image_width * (x + 1) / horizontal_cell_count
        local texture_bottom = image_height * (y + 1) / vertical_cell_count
        obj.drawpoly(
            vertex_x[x][y],
            vertex_y[x][y],
            0,
            vertex_x[x + 1][y],
            vertex_y[x + 1][y],
            0,
            vertex_x[x + 1][y + 1],
            vertex_y[x + 1][y + 1],
            0,
            vertex_x[x][y + 1],
            vertex_y[x][y + 1],
            0,
            texture_left,
            texture_top,
            texture_right,
            texture_top,
            texture_right,
            texture_bottom,
            texture_left,
            texture_bottom
        )
    end
end

obj.load("tempbuffer")
