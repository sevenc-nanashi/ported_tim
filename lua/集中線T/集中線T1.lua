--label:${ROOT_CATEGORY}\カスタムオブジェクト\@集中線T
---$track:発生確率
---min=0
---max=100
---step=0.1
local track_spawn_probability = 40

---$track:線幅
---min=1
---max=400
---step=0.1
local track_line_width = 15

---$track:中心
---min=0
---max=100
---step=0.1
local track_center = 15

---$track:局所性
---min=0
---max=100
---step=0.1
local track_locality = 0

---$color:色
local color = 0xffffff

---$track:中心位置X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心位置Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

--trackgroup@track_center_x,track_center_y:中心位置

---$track:中心ランダム度
---min=0
---max=1000
---step=0.1
local track_center_randomness = 30

---$track:局所ジャンプ率[%]
---min=0
---max=100
---step=0.1
local track_local_jump_probability = 15

---$track:変化速度
---min=-100
---max=100
---step=0.1
local track_change_speed = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 0

---$track:最大本数
---min=1
---max=5000
---step=1
local track_max_line_count = 500

---$track:シード
---min=0
---max=1000000
---step=1
local track_seed = 0

---$track:幅
---min=0
---max=10000
---step=1
local track_width = 0

---$track:高さ
---min=0
---max=10000
---step=1
local track_height = 0

---$track:中心追尾レイヤー
---min=0
---max=1000
---step=1
---zero_label=なし
local track_follow_center_layer = 0

---$check:最大本数自動計算
local check_auto_max_line_count = false

--hide@track_max_line_count:check_auto_max_line_count==1

local find_ellipse_intersection = function(x0, y0, x1, y1, ellipse_radius_x, ellipse_radius_y)
    local quadratic_a = ((x1 - x0) / ellipse_radius_x) ^ 2 + ((y1 - y0) / ellipse_radius_y) ^ 2
    local quadratic_b = x0 * (x1 - x0) / (ellipse_radius_x * ellipse_radius_x)
        + y0 * (y1 - y0) / (ellipse_radius_y * ellipse_radius_y)
    local quadratic_c = x0 * x0 / (ellipse_radius_x * ellipse_radius_x)
        + y0 * y0 / (ellipse_radius_y * ellipse_radius_y)
        - 1
    local distance_ratio = (-quadratic_b + math.sqrt(quadratic_b * quadratic_b - quadratic_a * quadratic_c))
        / quadratic_a
    local intersection_x = x0 + distance_ratio * (x1 - x0)
    local intersection_y = y0 + distance_ratio * (y1 - y0)
    return intersection_x, intersection_y
end

local center_x
local center_y
if track_follow_center_layer == nil or track_follow_center_layer == 0 then
    obj.setanchor("track_center_x,track_center_y", 0)
    center_x = track_center_x
    center_y = track_center_y
else
    center_x = obj.getvalue("layer" .. track_follow_center_layer .. ".x")
    center_y = obj.getvalue("layer" .. track_follow_center_layer .. ".y")
end

local vertices_buffer = {}
local function push_poly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3)
    table.insert(
        vertices_buffer,
        { x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, 0, 0, obj.w, 0, obj.w, obj.h, obj.h, 0 }
    )
end
local function flush_polys()
    obj.drawpoly(vertices_buffer)
    vertices_buffer = {}
end

local spawn_probability = track_spawn_probability
local line_width = track_line_width
local inner_radius_ratio = track_center * 0.01
local locality_weight = 1 - math.log(track_locality + 1) / math.log(101)
local screen_w = track_width > 0 and track_width or obj.screen_w
local screen_h = track_height > 0 and track_height or obj.screen_h
local max_line_count = track_max_line_count
local size = math.sqrt(screen_w * screen_w + screen_h * screen_h)
if check_auto_max_line_count then
    max_line_count = math.floor(200 * math.pi / line_width)
end
local center_randomness = track_center_randomness * 0.01
local local_jump_probability = track_local_jump_probability
line_width = line_width * size / 1000
inner_radius_ratio = inner_radius_ratio * size
local seed = track_seed + math.floor(obj.time * obj.framerate * track_change_speed)
obj.load("figure", "四角形", color, 1)
obj.setoption("drawtarget", "tempbuffer", screen_w, screen_h)
local selected_lines = {}
if track_locality == 0 or spawn_probability == 100 then
    for i = 1, max_line_count do
        if spawn_probability >= obj.rand(0, 100, -i, seed + 1000) then
            selected_lines[i] = 1
        end
    end
else
    local block_count = 3 + (max_line_count / 4 - 3) * locality_weight
    local lines_per_block = max_line_count / block_count
    spawn_probability = spawn_probability * 0.01
    for j = 0, block_count - 1 do
        for distance_ratio = 0, spawn_probability * lines_per_block - 1 do
            local selected_line_index = math.floor(distance_ratio + lines_per_block * j + 1)
            selected_lines[selected_line_index] = 1
        end
    end
    for i = 1, max_line_count do
        if local_jump_probability >= obj.rand(0, 100, -i, seed + 2000) and local_jump_probability > 0 then
            local swap_line_index = obj.rand(1, max_line_count, -i, seed + 4000)
            selected_lines[i], selected_lines[swap_line_index] = selected_lines[swap_line_index], selected_lines[i]
        end
    end
end
local angle_step = 2 * math.pi / max_line_count
local angle_offset = obj.rand(0, 3600, -1, seed + 4000) * math.pi / 1800
local ellipse_radius_x = screen_w / math.sqrt(2)
local ellipse_radius_y = screen_h / math.sqrt(2)

for i = 1, max_line_count do
    if selected_lines[i] == 1 then
        local line_angle = angle_step * i + angle_offset
        local inner_radius = inner_radius_ratio + size * center_randomness * obj.rand(0, 1000, -i, seed + 5000) / 1000
        local outer_radius = inner_radius + size
        local x0 = inner_radius * math.sin(line_angle)
        local y0 = inner_radius * math.cos(line_angle)
        local x1 = -line_width * math.cos(line_angle) + outer_radius * math.sin(line_angle)
        local y1 = line_width * math.sin(line_angle) + outer_radius * math.cos(line_angle)
        local x2 = line_width * math.cos(line_angle) + outer_radius * math.sin(line_angle)
        local y2 = -line_width * math.sin(line_angle) + outer_radius * math.cos(line_angle)

        x1, y1 = find_ellipse_intersection(x0, y0, x1, y1, ellipse_radius_x, ellipse_radius_y)
        x2, y2 = find_ellipse_intersection(x0, y0, x2, y2, ellipse_radius_x, ellipse_radius_y)
        local radial_x = (x1 + x2) / 2 - center_x
        local radial_y = (y1 + y2) / 2 - center_y
        local radial_distance = math.sqrt(radial_x * radial_x + radial_y * radial_y)
        x0, y0 =
            center_x + radial_x * inner_radius / radial_distance, center_y + radial_y * inner_radius / radial_distance
        local direction_x = (x1 + x2) / 2 - x0
        local direction_y = (y1 + y2) / 2 - y0

        if direction_x * radial_x + direction_y * radial_y > 0 then
            push_poly(x0, y0, 0, x0, y0, 0, x1, y1, 0, x2, y2, 0)
        end
    end
end
flush_polys()
obj.load("tempbuffer")
obj.effect("ぼかし", "範囲", track_blur, "サイズ固定", 1)
