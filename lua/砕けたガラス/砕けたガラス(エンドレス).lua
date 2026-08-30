--label:${ROOT_CATEGORY}\アニメーション効果\@砕けたガラス
---$track:サイズ
---min=-1000
---max=1000
---step=0.1
local track_size = 100

---$track:ガラス量
---min=0
---max=5000
---step=1
local track_glass_amount = 20

---$track:屈折率
---min=0
---max=5000
---step=0.1
local track_refractive_index = 25

---$track:移動速度
---min=-500
---max=500
---step=0.1
local track_move_speed = 10

---$check:オリジナル表示
local check_show_original = false

---$track:回転速度
---min=0
---max=100
---step=0.1
local rotation_speed = 5

---$track:ぼかし
---min=0
---max=500
---step=0.1
local blur = 25

---$track:透明度[%]
---min=0
---max=100
---step=0.1
local alpha = 20

---$track:厚さ
---min=0
---max=100
---step=0.1
local thickness = 3

---$value:光線方向
local light_direction = { 1, 0, 1 }

---$track:正反射強度[%]
---min=0
---max=200
---step=0.1
local specular_strength = 75

---$track:形状ランダム性[%]
---min=0
---max=200
---step=0.1
local shape_randomness = 100

---$track:サイズランダム性[%]
---min=0
---max=100
---step=0.1
local size_randomness = 0

---$track:小サイズ出現度
---min=10
---max=500
---step=0.1
local small_size_exponent = 100

---$track:速度ランダム性[%]
---min=0
---max=200
---step=0.1
local speed_randomness = 100

---$track:乱数パターン
---min=0
---max=10000
---step=1
local random_seed = 100

local w, h = obj.getpixel()

obj.setoption("drawtarget", "tempbuffer", w, h)

if check_show_original then
    obj.draw()
end

alpha = 1 - alpha / 100

local glass_count = track_glass_amount
local move_speed = track_move_speed
local frame_offset = obj.time * obj.framerate

local size_sign = 1
local glass_size = track_size
if glass_size < 0 then
    glass_size = -glass_size
    size_sign = 0
end
if glass_size < 10 then
    glass_size = 10
end

local half_glass_size = glass_size / 2
local refractive_index = track_refractive_index
local movement_width = w + glass_size
local movement_height = h + glass_size

shape_randomness = shape_randomness * 0.0001
speed_randomness = speed_randomness * 0.0001
specular_strength = specular_strength * 0.01
light_direction[3] = math.abs(light_direction[3])

local size_randomness_ratio = (size_randomness or 0) * 0.01
if size_randomness_ratio > 1 then
    size_randomness_ratio = 1
end
if size_randomness_ratio < 0 then
    size_randomness_ratio = 0
end

small_size_exponent = (small_size_exponent or 100) * 0.01
if small_size_exponent < 0.1 then
    small_size_exponent = 0.1
end

local vertices_x = {}
local vertices_y = {}

local normal_x = {}
local normal_y = {}
local normal_z = {}

for i = 1, glass_count do
    vertices_x[i] = {}
    vertices_y[i] = {}
    if size_sign == 1 then
        vertices_x[i][0], vertices_y[i][0] =
            -half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 1 + random_seed)),
            -half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 5 + random_seed))
        vertices_x[i][1], vertices_y[i][1] =
            half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 2 + random_seed)),
            -half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 6 + random_seed))
    else
        vertices_x[i][0], vertices_y[i][0] =
            -half_glass_size * shape_randomness * obj.rand(-100, 100, i, 1 + random_seed),
            -half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 5 + random_seed))
        vertices_x[i][1], vertices_y[i][1] = vertices_x[i][0], vertices_y[i][0]
    end
    vertices_x[i][2], vertices_y[i][2] =
        half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 3 + random_seed)),
        half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 7 + random_seed))
    vertices_x[i][3], vertices_y[i][3] =
        -half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 4 + random_seed)),
        half_glass_size * (1 + shape_randomness * obj.rand(-50, 50, i, 8 + random_seed))

    local t1 = math.rad(
        obj.rand(0, 360, i, 9 + random_seed)
            + obj.rand(-100, 100, i, 11 + random_seed) / 100 * rotation_speed * frame_offset
    )
    local t2 = math.rad(
        obj.rand(0, 360, i, 10 + random_seed)
            + obj.rand(-100, 100, i, 12 + random_seed) / 100 * rotation_speed * frame_offset
    )
    local t3 = math.rad(
        obj.rand(0, 360, i, 10 + random_seed)
            + obj.rand(-100, 100, i, 13 + random_seed) / 100 * rotation_speed * frame_offset
    )

    local dyori = obj.rand(0, movement_height, i, 14 + random_seed)
        + move_speed * frame_offset * (1 + speed_randomness * obj.rand(0, 100, i, 1000 + random_seed))
    local dy = dyori % movement_height - movement_height / 2

    local dx =
        obj.rand(-movement_width / 2, movement_width / 2, i + math.floor(dyori / movement_height), 3000 + random_seed)
    dx = (dx + movement_width / 2) % movement_width - movement_width / 2

    local c1 = math.cos(t1)
    local s1 = math.sin(t1)
    local c2 = math.cos(t2)
    local s2 = math.sin(t2)
    local c3 = math.cos(t3)
    local s3 = math.sin(t3)

    local zoom = obj.rand(0, 100, i, 2000 + random_seed) * 0.01
    zoom = zoom ^ small_size_exponent
    zoom = 1 - size_randomness_ratio + zoom * size_randomness_ratio

    for s = 0, 3 do
        local z = -s2 * vertices_x[i][s]
        vertices_x[i][s] = c2 * vertices_x[i][s]
        vertices_x[i][s], vertices_y[i][s] =
            c1 * vertices_x[i][s] + s1 * vertices_y[i][s], -s1 * vertices_x[i][s] + c1 * vertices_y[i][s]
        vertices_y[i][s] = c3 * vertices_y[i][s] + s3 * z
        vertices_x[i][s], vertices_y[i][s] = zoom * vertices_x[i][s] + dx, zoom * vertices_y[i][s] + dy
    end

    normal_x[i] = -c1 * s2
    normal_y[i] = s1 * s2 * c3 - c2 * s3
    normal_z[i] = -c2 * c3 - s1 * s2 * s3
end

for i = 1, glass_count do
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

obj.load("figure", "四角形", 0xffffff, glass_size)
obj.effect("マスク", "サイズ", glass_size, "マスクの反転", 1, "ぼかし", blur)

for i = 1, glass_count do
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

obj.load("figure", "四角形", 0xffffff, glass_size)
for i = 1, glass_count do
    local wi = thickness * normal_x[i]
    local hi = thickness * normal_y[i]

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
for i = 1, glass_count do
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

    if rz > 0.7 then
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
            specular_strength * ((rz - 0.7) / 0.3)
        )
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)

-----------------------------------------------------------
