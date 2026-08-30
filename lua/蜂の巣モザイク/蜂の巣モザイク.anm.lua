--label:${ROOT_CATEGORY}\加工
---$track:サイズ
---min=2
---max=1500
---step=1
local track_cell_size = 50

---$track:補正
---min=0
---max=1000
---step=1
local track_cell_inset = 0

---$track:最小ｻｲｽﾞ
---min=2
---max=1500
---step=1
local track_min_size = 10

---$track:ﾓｻﾞｲｸ回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:背景を透明
local check_transparent_background = 0

---$check:背景をシャープ
local check_sharp_background = 0

--group:凸エッジ
---$check:凸エッジ有効
local check_enable_bevel = 0

---$track:凸エッジ幅
---min=0
---max=100
---step=1
local track_bevel_width = 2

---$value:凸エッジ高さ
---min=0
---max=100
---step=1
local value_bevel_height = 1

---$track:凸エッジ角度
---min=-360
---max=360
---step=1
local track_bevel_angle = -45

--hide@check_sharp_background:check_transparent_background==1
--hide@track_bevel_width:check_enable_bevel==0
--hide@value_bevel_height:check_enable_bevel==0
--hide@track_bevel_angle:check_enable_bevel==0

local draw = obj.draw
local effect = obj.effect

local w, h = obj.getpixel()
local original_width, original_height = w, h
local rotation_degrees = track_rotation % 360

if rotation_degrees ~= 0 then
    local rotation_radians = math.rad(rotation_degrees)
    local cos = math.abs(math.cos(rotation_radians))
    local sin = math.abs(math.sin(rotation_radians))
    w, h = w * cos + h * sin, w * sin + h * cos
    obj.setoption("drawtarget", "tempbuffer", w, h)
    draw(0, 0, 0, 1, 1, 0, 0, -rotation_degrees)
    obj.load("tempbuffer")
end

local cell_size = track_cell_size
cell_size = math.max(cell_size, track_min_size)
local hexagon_size = math.max(cell_size - track_cell_inset, 2)
obj.copybuffer("cache:back", "object")

local blur_length = 0.402963724433828 * cell_size
effect("方向ブラー", "範囲", blur_length, "角度", 0, "サイズ固定", 1)
effect("方向ブラー", "範囲", blur_length, "角度", 90, "サイズ固定", 1)

if check_sharp_background == 0 then
    obj.copybuffer("cache:back", "object")
end

local half_width = w * 0.5
local half_height = h * 0.5
local horizontal_spacing = math.sqrt(3) * 0.5 * cell_size
local vertical_spacing = 1.5 * cell_size

local first_grid_horizontal_radius = math.floor((w / horizontal_spacing + 1) * 0.5)
local first_grid_vertical_radius = math.floor((h / cell_size + 1) / 3)
local second_grid_column_count = 2 * math.ceil(0.5 * w / horizontal_spacing)
local second_grid_row_count = 2 * math.floor((h / cell_size + 2.5) / 3)
local second_grid_center_x = (second_grid_column_count + 1) * 0.5
local second_grid_center_y = (second_grid_row_count + 1) * 0.5

local first_grid_colors = {}
local first_grid_alphas = {}
for i = -first_grid_horizontal_radius, first_grid_horizontal_radius do
    first_grid_colors[i] = {}
    first_grid_alphas[i] = {}
    for j = -first_grid_vertical_radius, first_grid_vertical_radius do
        local u = horizontal_spacing * i + half_width
        local v = vertical_spacing * j + half_height
        if u < 0 then
            u = 0
        end
        if u > w - 1 then
            u = w - 1
        end
        if v < 0 then
            v = 0
        end
        if v > h - 1 then
            v = h - 1
        end
        first_grid_colors[i][j], first_grid_alphas[i][j] = obj.getpixel(u, v, "col")
    end
end

local second_grid_colors = {}
local second_grid_alphas = {}
for i = 1, second_grid_column_count do
    second_grid_colors[i] = {}
    second_grid_alphas[i] = {}
    for j = 1, second_grid_row_count do
        local u = horizontal_spacing * (second_grid_center_x - i) + half_width
        local v = vertical_spacing * (second_grid_center_y - j) + half_height
        if u < 0 then
            u = 0
        end
        if u > w - 1 then
            u = w - 1
        end
        if v < 0 then
            v = 0
        end
        if v > h - 1 then
            v = h - 1
        end
        second_grid_colors[i][j], second_grid_alphas[i][j] = obj.getpixel(u, v, "col")
    end
end

obj.setoption("drawtarget", "tempbuffer", hexagon_size, hexagon_size)
local hexagon_half_width = hexagon_size * math.sqrt(3) * 0.5
obj.load("figure", "四角形", 0xffffff, 2 * hexagon_size)
effect("斜めクリッピング", "中心Y", -hexagon_size, "角度", 150)
effect("斜めクリッピング", "中心Y", -hexagon_size, "角度", -150)
effect("斜めクリッピング", "中心Y", hexagon_size, "角度", 30)
effect("斜めクリッピング", "中心Y", hexagon_size, "角度", -30)
effect("斜めクリッピング", "中心X", -hexagon_half_width, "角度", 90)
effect("斜めクリッピング", "中心X", hexagon_half_width, "角度", -90)
draw(0, 0, 0, 0.5)
obj.copybuffer("object", "tempbuffer")

if check_transparent_background == 1 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.setoption("blend", "alpha_add")
else
    obj.copybuffer("tempbuffer", "cache:back")
end

if track_bevel_width * value_bevel_height == 0 or check_enable_bevel == 0 then
    for i = -first_grid_horizontal_radius, first_grid_horizontal_radius do
        for j = -first_grid_vertical_radius, first_grid_vertical_radius do
            local x = horizontal_spacing * i
            local y = vertical_spacing * j
            effect("単色化", "color", first_grid_colors[i][j], "輝度を保持する", 0)
            draw(x, y, 0, 1, first_grid_alphas[i][j])
        end
    end
    for i = 1, second_grid_column_count do
        for j = 1, second_grid_row_count do
            local x = horizontal_spacing * (second_grid_center_x - i)
            local y = vertical_spacing * (second_grid_center_y - j)
            effect("単色化", "color", second_grid_colors[i][j], "輝度を保持する", 0)
            draw(x, y, 0, 1, second_grid_alphas[i][j])
        end
    end
else
    for i = -first_grid_horizontal_radius, first_grid_horizontal_radius do
        for j = -first_grid_vertical_radius, first_grid_vertical_radius do
            local x = horizontal_spacing * i
            local y = vertical_spacing * j
            effect("単色化", "color", first_grid_colors[i][j], "輝度を保持する", 0)
            effect("凸エッジ", "幅", track_bevel_width, "高さ", value_bevel_height, "角度", track_bevel_angle)
            draw(x, y, 0, 1, first_grid_alphas[i][j])
        end
    end

    for i = 1, second_grid_column_count do
        for j = 1, second_grid_row_count do
            local x = horizontal_spacing * (second_grid_center_x - i)
            local y = vertical_spacing * (second_grid_center_y - j)
            effect("単色化", "color", second_grid_colors[i][j], "輝度を保持する", 0)
            effect("凸エッジ", "幅", track_bevel_width, "高さ", value_bevel_height, "角度", track_bevel_angle)
            draw(x, y, 0, 1, second_grid_alphas[i][j])
        end
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)

if rotation_degrees ~= 0 then
    obj.setoption("drawtarget", "tempbuffer", original_width, original_height)
    draw(0, 0, 0, 1, 1, 0, 0, rotation_degrees)
    obj.load("tempbuffer")
end
