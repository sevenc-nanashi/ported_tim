--label:${ROOT_CATEGORY}\アニメーション効果\@砕けたガラス
---$track:粉砕度
---min=0
---max=10000
---step=0.1
local track_shatter_amount = 50

---$track:サイズ
---min=10
---max=1000
---step=0.1
local track_size = 150

---$track:屈折率
---min=0
---max=5000
---step=0.1
local track_refractive_index = 25

---$track:動径速度
---min=0
---max=500
---step=0.1
local track_diameter_speed = 10

---$select:分割パターン
---ファイル読込=0
---四角形=1
---四角形+三角形=2
---ランダム四角形=3
---ランダム四角形+三角形=4
local track_split_pattern = 1

---$track:限界サイズ
---min=5
---max=1000
---step=0.1
local track_limit_size = 50

---$track:光散乱
---min=1
---max=100
---step=0.1
local track_light_scatter = 30

---$track:拡大率
---min=0
---max=1000
---step=0.1
local track_scale = 100

---$file:ファイル
local split_file = ""

---$check:オリジナル表示
local check_show_original = false

---$track:回転速度
---min=0
---max=100
---step=0.1
local rotation_speed = 5

---$track:Z速度
---min=-100
---max=100
---step=0.1
local z_speed = 7

---$track:XY速度中心X
---min=-10000
---max=10000
---step=0.1
local track_xy_speed_center_x = 0

---$track:XY速度中心Y
---min=-10000
---max=10000
---step=0.1
local track_xy_speed_center_y = 0

--trackgroup@track_xy_speed_center_x,track_xy_speed_center_y:XY速度中心

---$value:重力方向
local gravity_direction = { 0, 100, 0 }

---$track:ぼかし
---min=0
---max=500
---step=0.1
local blur = 25

---$track:透明度[%]
---min=0
---max=100
---step=0.1
local alpha = 25

---$track:厚さ
---min=0
---max=100
---step=0.1
local thickness = 5

---$value:光線方向
local light_direction = { 1, 0, 1 }

---$track:正反射強度[%]
---min=0
---max=200
---step=0.1
local specular_strength = 75

---$value:形状&速度ランダム性[%]
local randomness_values = { 70, 50 }

---$track:乱数パターン
---min=0
---max=10000
---step=1
local random_seed = 100

--hide@track_limit_size:track_split_pattern<3
--hide@split_file:track_split_pattern~=0

local piece_count, glass_size, w, h, half_width, half_height, shape_randomness, speed_randomness, vertices_x, vertices_y, normal_x, normal_y, normal_z
local split_random_quad

local function split_grid()
    local shape_randomness_ratio = shape_randomness * 0.0001
    local grid_column_count = -math.floor(-w / glass_size)
    local grid_row_count = -math.floor(-h / glass_size)

    piece_count = grid_column_count * grid_row_count

    for k = 0, grid_column_count - 1 do
        for j = 0, grid_row_count - 1 do
            local i = k + grid_column_count * j

            vertices_x[i] = {}
            vertices_x[i][0] = glass_size * (k + shape_randomness_ratio * obj.rand(-50, 50, j, k + random_seed))
                - half_width
            vertices_x[i][1] = glass_size * (k + 1 + shape_randomness_ratio * obj.rand(-50, 50, j, k + 1 + random_seed))
                - half_width
            vertices_x[i][2] = glass_size
                    * (k + 1 + shape_randomness_ratio * obj.rand(-50, 50, j + 1, k + 1 + random_seed))
                - half_width
            vertices_x[i][3] = glass_size * (k + shape_randomness_ratio * obj.rand(-50, 50, j + 1, k + random_seed))
                - half_width

            vertices_y[i] = {}
            vertices_y[i][0] = glass_size * (j + shape_randomness_ratio * obj.rand(-50, 50, j, k + random_seed))
                - half_height
            vertices_y[i][1] = glass_size * (j + shape_randomness_ratio * obj.rand(-50, 50, j, k + 1 + random_seed))
                - half_height
            vertices_y[i][2] = glass_size
                    * (j + 1 + shape_randomness_ratio * obj.rand(-50, 50, j + 1, k + 1 + random_seed))
                - half_height
            vertices_y[i][3] = glass_size * (j + 1 + shape_randomness_ratio * obj.rand(-50, 50, j + 1, k + random_seed))
                - half_height
        end
    end

    for j = 0, grid_row_count - 1 do
        local i = grid_column_count * j
        vertices_x[i][0] = -half_width
        vertices_x[i][3] = -half_width
        i = grid_column_count - 1 + grid_column_count * j
        vertices_x[i][1] = half_width
        vertices_x[i][2] = half_width

        if vertices_x[i - 1][1] > half_width then
            vertices_x[i - 1][1] = half_width
        end
        if vertices_x[i - 1][2] > half_width then
            vertices_x[i - 1][2] = half_width
        end
        if vertices_x[i][0] > half_width then
            vertices_x[i][0] = half_width
        end
        if vertices_x[i][3] > half_width then
            vertices_x[i][3] = half_width
        end
    end

    for k = 0, grid_column_count - 1 do
        vertices_y[k][0] = -half_height
        vertices_y[k][1] = -half_height
        local i = k + grid_column_count * (grid_row_count - 1)
        vertices_y[i][2] = half_height
        vertices_y[i][3] = half_height

        if vertices_y[i - grid_column_count][2] > half_height then
            vertices_y[i - grid_column_count][2] = half_height
        end
        if vertices_y[i - grid_column_count][3] > half_height then
            vertices_y[i - grid_column_count][3] = half_height
        end

        if vertices_y[i][0] > half_height then
            vertices_y[i][0] = half_height
        end
        if vertices_y[i][1] > half_height then
            vertices_y[i][1] = half_height
        end
    end
end

local function triangulate_grid()
    for i = 0, piece_count - 1 do
        vertices_x[i + piece_count] = {}
        vertices_y[i + piece_count] = {}

        if obj.rand(0, 100, i, 10000 + random_seed) > 50 then
            vertices_x[i + piece_count][0] = vertices_x[i][0]
            vertices_x[i + piece_count][1] = vertices_x[i][0]
            vertices_x[i + piece_count][2] = vertices_x[i][1]
            vertices_x[i + piece_count][3] = vertices_x[i][3]
            vertices_y[i + piece_count][0] = vertices_y[i][0]
            vertices_y[i + piece_count][1] = vertices_y[i][0]
            vertices_y[i + piece_count][2] = vertices_y[i][1]
            vertices_y[i + piece_count][3] = vertices_y[i][3]
            vertices_x[i][0] = vertices_x[i][1]
            vertices_y[i][0] = vertices_y[i][1]
        else
            vertices_x[i + piece_count][0] = vertices_x[i][0]
            vertices_x[i + piece_count][1] = vertices_x[i][0]
            vertices_x[i + piece_count][2] = vertices_x[i][1]
            vertices_x[i + piece_count][3] = vertices_x[i][2]
            vertices_y[i + piece_count][0] = vertices_y[i][0]
            vertices_y[i + piece_count][1] = vertices_y[i][0]
            vertices_y[i + piece_count][2] = vertices_y[i][1]
            vertices_y[i + piece_count][3] = vertices_y[i][2]
            vertices_x[i][1] = vertices_x[i][0]
            vertices_y[i][1] = vertices_y[i][0]
        end
    end
    piece_count = 2 * piece_count
end

local function split_random_quads()
    piece_count = 0
    vertices_x[0] = {}
    vertices_x[0][0] = -half_width
    vertices_x[0][1] = half_width
    vertices_x[0][2] = half_width
    vertices_x[0][3] = -half_width
    vertices_y[0] = {}
    vertices_y[0][0] = -half_height
    vertices_y[0][1] = -half_height
    vertices_y[0][2] = half_height
    vertices_y[0][3] = half_height
    split_random_quad(0) --ランダム４角形に割る
    piece_count = piece_count + 1
end

split_random_quad = function(i)
    local l1 = math.sqrt(
        (vertices_x[i][0] - vertices_x[i][1]) * (vertices_x[i][0] - vertices_x[i][1])
            + (vertices_y[i][0] - vertices_y[i][1]) * (vertices_y[i][0] - vertices_y[i][1])
    )
    local l2 = math.sqrt(
        (vertices_x[i][1] - vertices_x[i][2]) * (vertices_x[i][1] - vertices_x[i][2])
            + (vertices_y[i][1] - vertices_y[i][2]) * (vertices_y[i][1] - vertices_y[i][2])
    )
    local l3 = math.sqrt(
        (vertices_x[i][2] - vertices_x[i][3]) * (vertices_x[i][2] - vertices_x[i][3])
            + (vertices_y[i][2] - vertices_y[i][3]) * (vertices_y[i][2] - vertices_y[i][3])
    )
    local l4 = math.sqrt(
        (vertices_x[i][3] - vertices_x[i][0]) * (vertices_x[i][3] - vertices_x[i][0])
            + (vertices_y[i][3] - vertices_y[i][0]) * (vertices_y[i][3] - vertices_y[i][0])
    )

    local max_l = math.max(l1, l2, l3, l4)

    if max_l > minimum_piece_size then
        if
            (max_l - minimum_piece_size) / (glass_size - minimum_piece_size) * 100
            > obj.rand(0, 100, i + random_seed, piece_count)
        then
            piece_count = piece_count + 1

            local nsave = piece_count

            vertices_x[piece_count] = {}
            vertices_y[piece_count] = {}
            local p11 = obj.rand(-shape_randomness / 4, shape_randomness / 4, i + random_seed, piece_count + 1000)
                * 0.01
            local p21 = obj.rand(-shape_randomness / 3, shape_randomness / 3, i + random_seed, piece_count + 2000)
                * 0.01
            if p11 * p21 > 0 then
                p21 = -p21
            end
            p11 = p11 + 0.5
            p21 = p21 + 0.5
            local p12 = 1 - p11
            local p22 = 1 - p21

            local u10, v10, u11, v11, u12, v12, u13, v13

            if max_l == l1 or max_l == l3 then
                u10, v10 = vertices_x[i][0], vertices_y[i][0]
                u11, v11 =
                    p11 * vertices_x[i][0] + p12 * vertices_x[i][1], p11 * vertices_y[i][0] + p12 * vertices_y[i][1]
                u12, v12 =
                    p21 * vertices_x[i][2] + p22 * vertices_x[i][3], p21 * vertices_y[i][2] + p22 * vertices_y[i][3]
                u13, v13 = vertices_x[i][3], vertices_y[i][3]

                vertices_x[piece_count][0], vertices_y[piece_count][0] = u11, v11
                vertices_x[piece_count][1], vertices_y[piece_count][1] = vertices_x[i][1], vertices_y[i][1]
                vertices_x[piece_count][2], vertices_y[piece_count][2] = vertices_x[i][2], vertices_y[i][2]
                vertices_x[piece_count][3], vertices_y[piece_count][3] = u12, v12
            else
                u10, v10 = vertices_x[i][0], vertices_y[i][0]
                u11, v11 = vertices_x[i][1], vertices_y[i][1]
                u12, v12 =
                    p11 * vertices_x[i][1] + p12 * vertices_x[i][2], p11 * vertices_y[i][1] + p12 * vertices_y[i][2]
                u13, v13 =
                    p21 * vertices_x[i][0] + p22 * vertices_x[i][3], p21 * vertices_y[i][0] + p22 * vertices_y[i][3]

                vertices_x[piece_count][0], vertices_y[piece_count][0] = u13, v13
                vertices_x[piece_count][1], vertices_y[piece_count][1] = u12, v12
                vertices_x[piece_count][2], vertices_y[piece_count][2] = vertices_x[i][2], vertices_y[i][2]
                vertices_x[piece_count][3], vertices_y[piece_count][3] = vertices_x[i][3], vertices_y[i][3]
            end

            vertices_x[i][0], vertices_y[i][0] = u10, v10
            vertices_x[i][1], vertices_y[i][1] = u11, v11
            vertices_x[i][2], vertices_y[i][2] = u12, v12
            vertices_x[i][3], vertices_y[i][3] = u13, v13

            split_random_quad(i)
            split_random_quad(nsave)
        end
    end
end

local function randomly_triangulate(i, nmax)
    local l1 = math.sqrt(
        (vertices_x[i][0] - vertices_x[i][1]) * (vertices_x[i][0] - vertices_x[i][1])
            + (vertices_y[i][0] - vertices_y[i][1]) * (vertices_y[i][0] - vertices_y[i][1])
    )
    local l2 = math.sqrt(
        (vertices_x[i][1] - vertices_x[i][2]) * (vertices_x[i][1] - vertices_x[i][2])
            + (vertices_y[i][1] - vertices_y[i][2]) * (vertices_y[i][1] - vertices_y[i][2])
    )
    local l3 = math.sqrt(
        (vertices_x[i][2] - vertices_x[i][3]) * (vertices_x[i][2] - vertices_x[i][3])
            + (vertices_y[i][2] - vertices_y[i][3]) * (vertices_y[i][2] - vertices_y[i][3])
    )
    local l4 = math.sqrt(
        (vertices_x[i][3] - vertices_x[i][0]) * (vertices_x[i][3] - vertices_x[i][0])
            + (vertices_y[i][3] - vertices_y[i][0]) * (vertices_y[i][3] - vertices_y[i][0])
    )

    local min_l = math.min(l1, l2, l3, l4)

    if min_l > minimum_piece_size then
        if obj.rand(0, 100, i, 11000 + random_seed) > 50 then
            vertices_x[piece_count] = {}
            vertices_y[piece_count] = {}

            if obj.rand(0, 100, i, 12000 + random_seed) > 50 then
                vertices_x[piece_count][0] = vertices_x[i][0]
                vertices_y[piece_count][0] = vertices_y[i][0]
                vertices_x[piece_count][1] = vertices_x[i][0]
                vertices_y[piece_count][1] = vertices_y[i][0]
                vertices_x[piece_count][2] = vertices_x[i][2]
                vertices_y[piece_count][2] = vertices_y[i][2]
                vertices_x[piece_count][3] = vertices_x[i][3]
                vertices_y[piece_count][3] = vertices_y[i][3]

                vertices_x[i][3] = vertices_x[i][2]
                vertices_y[i][3] = vertices_y[i][2]
                vertices_x[i][2] = vertices_x[i][1]
                vertices_y[i][2] = vertices_y[i][1]
                vertices_x[i][1] = vertices_x[i][0]
                vertices_y[i][1] = vertices_y[i][0]
            else
                vertices_x[piece_count][0] = vertices_x[i][0]
                vertices_y[piece_count][0] = vertices_y[i][0]
                vertices_x[piece_count][1] = vertices_x[i][0]
                vertices_y[piece_count][1] = vertices_y[i][0]
                vertices_x[piece_count][2] = vertices_x[i][1]
                vertices_y[piece_count][2] = vertices_y[i][1]
                vertices_x[piece_count][3] = vertices_x[i][3]
                vertices_y[piece_count][3] = vertices_y[i][3]

                vertices_x[i][0] = vertices_x[i][1]
                vertices_y[i][0] = vertices_y[i][1]
            end
            piece_count = piece_count + 1
        end
    end

    if i < nmax then
        randomly_triangulate(i + 1, nmax)
    end
end

local function load_split_file()
    local function split(str, delim)
        if string.find(str, delim) == nil then
            return { str }
        end

        local result = {}
        local pat = "(.-)" .. delim .. "()"
        local last_pos
        for part, pos in string.gfind(str, pat) do
            table.insert(result, part)
            last_pos = pos
        end
        table.insert(result, string.sub(str, last_pos))
        return result
    end

    local line_data = {}
    local one = io.input(split_file)
    while one do
        one = io.read("*light_direction")
        if one then
            table.insert(line_data, one)
        end
    end
    piece_count = #line_data

    for i = 0, piece_count - 1 do
        local t = split(line_data[i + 1], ",")

        vertices_x[i] = {}
        vertices_x[i][0] = t[1]
        vertices_x[i][1] = t[3]
        vertices_x[i][2] = t[5]
        vertices_x[i][3] = t[7]

        vertices_y[i] = {}
        vertices_y[i][0] = t[2]
        vertices_y[i][1] = t[4]
        vertices_y[i][2] = t[6]
        vertices_y[i][3] = t[8]
    end
end

-------------------------------------------------

local shatter_progress = track_shatter_amount
glass_size = track_size
local refractive_index = track_refractive_index
local radial_speed = track_diameter_speed

w, h = obj.getpixel()
half_width = w * 0.5
half_height = h * 0.5
obj.setanchor("track_xy_speed_center_x,track_xy_speed_center_y", 0)
thickness = thickness * 0.5

obj.setoption("drawtarget", "tempbuffer", w, h)

if check_show_original then
    obj.draw()
end

alpha = 1 - alpha / 100
gravity_direction[1] = gravity_direction[1] / 1000
gravity_direction[2] = gravity_direction[2] / 1000
gravity_direction[3] = gravity_direction[3] / 100000
z_speed = z_speed / 1000

local minimum_piece_size = track_limit_size
local split_pattern = track_split_pattern
local light_scatter_limit = (100 - track_light_scatter) * 0.01
local glass_zoom = track_scale * 0.01

shape_randomness = randomness_values[1]
specular_strength = specular_strength * 0.01
speed_randomness = randomness_values[2] * 0.0001
light_direction[3] = math.abs(light_direction[3])

vertices_x = {}
vertices_y = {}

normal_x = {}
normal_y = {}
normal_z = {}

--自動分割---

if split_pattern == 2 then
    split_grid() --４角形に割る
    triangulate_grid() --４角形を３角形に割る
elseif split_pattern == 3 then
    split_random_quads() --ランダム４角形に割る
elseif split_pattern == 4 then
    split_random_quads() --ランダム４角形に割る
    randomly_triangulate(0, piece_count - 1) --ランダムに４角形を３角形に割る
elseif split_pattern == 0 then
    load_split_file() --ファイル読込
else
    split_grid() --４角形に割る
end

--------
if glass_zoom then
    for i = 0, piece_count - 1 do
        vertices_x[i][0] = vertices_x[i][0] * glass_zoom
        vertices_x[i][1] = vertices_x[i][1] * glass_zoom
        vertices_x[i][2] = vertices_x[i][2] * glass_zoom
        vertices_x[i][3] = vertices_x[i][3] * glass_zoom

        vertices_y[i][0] = vertices_y[i][0] * glass_zoom
        vertices_y[i][1] = vertices_y[i][1] * glass_zoom
        vertices_y[i][2] = vertices_y[i][2] * glass_zoom
        vertices_y[i][3] = vertices_y[i][3] * glass_zoom
    end
end

for i = 0, piece_count - 1 do
    local avx = (vertices_x[i][0] + vertices_x[i][1] + vertices_x[i][2] + vertices_x[i][3]) * 0.25
    local avy = (vertices_y[i][0] + vertices_y[i][1] + vertices_y[i][2] + vertices_y[i][3]) * 0.25

    local vx = radial_speed
        * (avx - track_xy_speed_center_x)
        / w
        * (1 + speed_randomness * obj.rand(-50, 50, i, 1000 + random_seed))
    local vy = radial_speed
        * (avy - track_xy_speed_center_y)
        / w
        * (1 + speed_randomness * obj.rand(-50, 50, i, 2000 + random_seed))

    local dx = shatter_progress * vx + gravity_direction[1] * shatter_progress * shatter_progress
    local dy = shatter_progress * vy + gravity_direction[2] * shatter_progress * shatter_progress

    local t1 = math.rad((obj.rand(-100, 100, i, 3000 + random_seed) / 100 * rotation_speed * shatter_progress))
    local t2 = math.rad((obj.rand(-100, 100, i, 4000 + random_seed) / 100 * rotation_speed * shatter_progress))
    local t3 = math.rad((obj.rand(-100, 100, i, 5000 + random_seed) / 100 * rotation_speed * shatter_progress))
    local zoom = z_speed * shatter_progress + gravity_direction[3] * shatter_progress * shatter_progress

    local c1 = math.cos(t1)
    local s1 = math.sin(t1)
    local c2 = math.cos(t2)
    local s2 = math.sin(t2)
    local c3 = math.cos(t3)
    local s3 = math.sin(t3)

    for s = 0, 3 do
        vertices_x[i][s] = vertices_x[i][s] - avx
        vertices_y[i][s] = vertices_y[i][s] - avy

        local z = -s2 * vertices_x[i][s]
        vertices_x[i][s] = c2 * vertices_x[i][s]
        vertices_x[i][s], vertices_y[i][s] =
            c1 * vertices_x[i][s] + s1 * vertices_y[i][s], -s1 * vertices_x[i][s] + c1 * vertices_y[i][s]
        vertices_y[i][s] = c3 * vertices_y[i][s] + s3 * z

        vertices_x[i][s] = vertices_x[i][s] * (1 + zoom)
        vertices_y[i][s] = vertices_y[i][s] * (1 + zoom)

        vertices_x[i][s] = vertices_x[i][s] + avx + dx
        vertices_y[i][s] = vertices_y[i][s] + avy + dy
    end

    normal_x[i] = -c1 * s2
    normal_y[i] = s1 * s2 * c3 - c2 * s3
    normal_z[i] = -c2 * c3 - s1 * s2 * s3
end

for i = 0, piece_count - 1 do
    local wi = w / 2 + normal_x[i] * refractive_index
    local hi = h / 2 + normal_y[i] * refractive_index
    obj.drawpoly(
        vertices_x[i][0],
        vertices_y[i][0],
        0,
        vertices_x[i][1],
        vertices_y[i][1],
        0,
        vertices_x[i][2],
        vertices_y[i][2],
        0,
        vertices_x[i][3],
        vertices_y[i][3],
        0,
        vertices_x[i][0] + wi,
        vertices_y[i][0] + hi,
        vertices_x[i][1] + wi,
        vertices_y[i][1] + hi,
        vertices_x[i][2] + wi,
        vertices_y[i][2] + hi,
        vertices_x[i][3] + wi,
        vertices_y[i][3] + hi
    )
end

if shatter_progress > 0 then
    obj.load("figure", "四角形", 0xffffff, glass_size)
    obj.effect("マスク", "サイズ", glass_size, "マスクの反転", 1, "ぼかし", blur)
    for i = 0, piece_count - 1 do
        obj.drawpoly(
            vertices_x[i][0],
            vertices_y[i][0],
            0,
            vertices_x[i][1],
            vertices_y[i][1],
            0,
            vertices_x[i][2],
            vertices_y[i][2],
            0,
            vertices_x[i][3],
            vertices_y[i][3],
            0,
            0,
            0,
            obj.w,
            0,
            obj.w,
            obj.h,
            0,
            obj.h,
            alpha
        )
    end
end

obj.load("figure", "四角形", 0xffffff, glass_size)
for i = 0, piece_count - 1 do
    local zoom = z_speed * shatter_progress + gravity_direction[3] * shatter_progress * shatter_progress

    local wi = thickness * normal_x[i] * (1 + zoom)
    local hi = thickness * normal_y[i] * (1 + zoom)

    obj.drawpoly(
        vertices_x[i][0] - wi,
        vertices_y[i][0] - hi,
        0,
        vertices_x[i][0] + wi,
        vertices_y[i][0] + hi,
        0,
        vertices_x[i][1] + wi,
        vertices_y[i][1] + hi,
        0,
        vertices_x[i][1] - wi,
        vertices_y[i][1] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
    obj.drawpoly(
        vertices_x[i][1] - wi,
        vertices_y[i][1] - hi,
        0,
        vertices_x[i][1] + wi,
        vertices_y[i][1] + hi,
        0,
        vertices_x[i][2] + wi,
        vertices_y[i][2] + hi,
        0,
        vertices_x[i][2] - wi,
        vertices_y[i][2] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
    obj.drawpoly(
        vertices_x[i][2] - wi,
        vertices_y[i][2] - hi,
        0,
        vertices_x[i][2] + wi,
        vertices_y[i][2] + hi,
        0,
        vertices_x[i][3] + wi,
        vertices_y[i][3] + hi,
        0,
        vertices_x[i][3] - wi,
        vertices_y[i][3] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
    obj.drawpoly(
        vertices_x[i][3] - wi,
        vertices_y[i][3] - hi,
        0,
        vertices_x[i][3] + wi,
        vertices_y[i][3] + hi,
        0,
        vertices_x[i][0] + wi,
        vertices_y[i][0] + hi,
        0,
        vertices_x[i][0] - wi,
        vertices_y[i][0] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
end

obj.load("figure", "四角形", 0xffffff, glass_size)
obj.setoption("blend", 1)

for i = 0, piece_count - 1 do
    local nx = normal_x[i]
    local ny = normal_y[i]
    local nz = normal_z[i]

    local ib = nx * light_direction[1] + ny * light_direction[2] + nz * light_direction[3]

    local rz = -(light_direction[3] - 2 * ib * nz)
        / math.sqrt(
            light_direction[1] * light_direction[1]
                + light_direction[2] * light_direction[2]
                + light_direction[3] * light_direction[3]
        )

    if rz > light_scatter_limit then
        obj.drawpoly(
            vertices_x[i][0],
            vertices_y[i][0],
            0,
            vertices_x[i][1],
            vertices_y[i][1],
            0,
            vertices_x[i][2],
            vertices_y[i][2],
            0,
            vertices_x[i][3],
            vertices_y[i][3],
            0,
            0,
            0,
            obj.w,
            0,
            obj.w,
            obj.h,
            0,
            obj.h,
            specular_strength * ((rz - light_scatter_limit) * 0.3) / (1 - light_scatter_limit) ^ 2
        )
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
