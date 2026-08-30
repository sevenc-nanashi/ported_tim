--label:${ROOT_CATEGORY}\変形
---$track:蓋角度
---min=-90
---max=270
---step=0.1
local track_lid_angle = 0

---$track:側面角度
---min=-90
---max=270
---step=0.1
local track_side_angle = 0

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 100

---$track:奥行き(%)
---min=0
---max=5000
---step=0.1
local track_depth_percent = 100

---$track:高さ(%)
---min=0
---max=5000
---step=0.1
local track_height_percent = 100

---$select:配置
---同一画像=0
---展開画像(3x2)=1
local select_layout = 0

---$check:表裏反転
local check_flip_faces = 0

---$check:アンチエイリアス
local check_antialias = 0

local surface_x0 = {}
local surface_y0 = {}
local surface_z0 = {}
local surface_x1 = {}
local surface_y1 = {}
local surface_z1 = {}
local surface_x2 = {}
local surface_y2 = {}
local surface_z2 = {}
local surface_x3 = {}
local surface_y3 = {}
local surface_z3 = {}

local u0 = {}
local u1 = {}
local u2 = {}
local u3 = {}
local v0 = {}
local v1 = {}
local v2 = {}
local v3 = {}

local lid_angle = track_lid_angle
local side_angle = track_side_angle

local antialias_enabled = check_antialias or 0
local height_scale = (track_height_percent or 100) * 0.01

obj.setoption("antialias", antialias_enabled)

local box_width, box_height, box_depth
if select_layout == 0 then
    box_width = track_size
    box_height = box_width * obj.h / obj.w
    box_depth = box_width * track_depth_percent / 100
else
    box_width = track_size
    box_height = box_width * (obj.h / 2) / (obj.w / 3)
    box_depth = box_width * track_depth_percent / 100
end

local half_width = box_width / 2
local half_height = box_height / 2
local half_depth = box_depth / 2

if select_layout == 0 then
    for face_index = 0, 5 do
        u0[face_index], v0[face_index] = 0, 0
        u1[face_index], v1[face_index] = obj.w, 0
        u2[face_index], v2[face_index] = obj.w, obj.h
        u3[face_index], v3[face_index] = 0, obj.h
    end
else
    u0[0], v0[0] = 0, 0
    u1[0], v1[0] = obj.w / 3, 0
    u2[0], v2[0] = obj.w / 3, obj.h / 2
    u3[0], v3[0] = 0, obj.h / 2

    u0[1], v0[1] = obj.w / 3, 0
    u1[1], v1[1] = 2 * obj.w / 3, 0
    u2[1], v2[1] = 2 * obj.w / 3, obj.h / 2
    u3[1], v3[1] = obj.w / 3, obj.h / 2

    u0[2], v0[2] = 0, obj.h / 2
    u1[2], v1[2] = obj.w / 3, obj.h / 2
    u2[2], v2[2] = obj.w / 3, obj.h
    u3[2], v3[2] = 0, obj.h

    u0[3], v0[3] = obj.w / 3, obj.h / 2
    u1[3], v1[3] = 2 * obj.w / 3, obj.h / 2
    u2[3], v2[3] = 2 * obj.w / 3, obj.h
    u3[3], v3[3] = obj.w / 3, obj.h

    u0[4], v0[4] = 2 * obj.w / 3, 0
    u1[4], v1[4] = obj.w, 0
    u2[4], v2[4] = obj.w, obj.h / 2
    u3[4], v3[4] = 2 * obj.w / 3, obj.h / 2

    u0[5], v0[5] = 2 * obj.w / 3, obj.h / 2
    u1[5], v1[5] = obj.w, obj.h / 2
    u2[5], v2[5] = obj.w, obj.h
    u3[5], v3[5] = 2 * obj.w / 3, obj.h
end

surface_x0[0] = -half_width
surface_y0[0] = half_height * height_scale - box_height * math.cos(side_angle / 180 * math.pi) * height_scale
surface_z0[0] = -half_depth - box_height * math.sin(side_angle / 180 * math.pi) * height_scale
surface_x1[0] = half_width
surface_y1[0] = surface_y0[0]
surface_z1[0] = surface_z0[0]
surface_x2[0] = half_width
surface_y2[0] = half_height * height_scale
surface_z2[0] = -half_depth
surface_x3[0] = -half_width
surface_y3[0] = half_height * height_scale
surface_z3[0] = -half_depth

surface_x0[1] = half_width + box_height * math.sin(side_angle / 180 * math.pi) * height_scale
surface_y0[1] = half_height * height_scale - box_height * math.cos(side_angle / 180 * math.pi) * height_scale
surface_z0[1] = -half_depth
surface_x1[1] = surface_x0[1]
surface_y1[1] = surface_y0[1]
surface_z1[1] = half_depth
surface_x2[1] = half_width
surface_y2[1] = half_height * height_scale
surface_z2[1] = half_depth
surface_x3[1] = half_width
surface_y3[1] = half_height * height_scale
surface_z3[1] = -half_depth

surface_x0[2] = half_width
surface_y0[2] = half_height * height_scale - box_height * math.cos(side_angle / 180 * math.pi) * height_scale
surface_z0[2] = half_depth + box_height * math.sin(side_angle / 180 * math.pi) * height_scale
surface_x1[2] = -half_width
surface_y1[2] = surface_y0[2]
surface_z1[2] = surface_z0[2]
surface_x2[2] = -half_width
surface_y2[2] = half_height * height_scale
surface_z2[2] = half_depth
surface_x3[2] = half_width
surface_y3[2] = half_height * height_scale
surface_z3[2] = half_depth

surface_x0[3] = -half_width - box_height * math.sin(side_angle / 180 * math.pi) * height_scale
surface_y0[3] = half_height * height_scale - box_height * math.cos(side_angle / 180 * math.pi) * height_scale
surface_z0[3] = half_depth
surface_x1[3] = surface_x0[3]
surface_y1[3] = surface_y0[3]
surface_z1[3] = -half_depth
surface_x2[3] = -half_width
surface_y2[3] = half_height * height_scale
surface_z2[3] = -half_depth
surface_x3[3] = -half_width
surface_y3[3] = half_height * height_scale
surface_z3[3] = half_depth

surface_x0[4] = surface_x1[2]
surface_y0[4] = surface_y1[2]
surface_z0[4] = surface_z1[2]
surface_x1[4] = surface_x0[2]
surface_y1[4] = surface_y0[2]
surface_z1[4] = surface_z0[2]
surface_x2[4] = surface_x1[4]
surface_y2[4] = surface_y1[4] - box_depth * math.sin((lid_angle + side_angle) / 180 * math.pi)
surface_z2[4] = surface_z1[4] - box_depth * math.cos((lid_angle + side_angle) / 180 * math.pi)
surface_x3[4] = surface_x0[4]
surface_y3[4] = surface_y0[4] - box_depth * math.sin((lid_angle + side_angle) / 180 * math.pi)
surface_z3[4] = surface_z0[4] - box_depth * math.cos((lid_angle + side_angle) / 180 * math.pi)

surface_x0[5] = -half_width
surface_y0[5] = half_height * height_scale
surface_z0[5] = -half_depth
surface_x1[5] = half_width
surface_y1[5] = half_height * height_scale
surface_z1[5] = -half_depth
surface_x2[5] = half_width
surface_y2[5] = half_height * height_scale
surface_z2[5] = half_depth
surface_x3[5] = -half_width
surface_y3[5] = half_height * height_scale
surface_z3[5] = half_depth

if check_flip_faces == 1 then
    for face_index = 0, 5 do
        surface_x0[face_index], surface_x1[face_index] = surface_x1[face_index], surface_x0[face_index]
        surface_y0[face_index], surface_y1[face_index] = surface_y1[face_index], surface_y0[face_index]
        surface_z0[face_index], surface_z1[face_index] = surface_z1[face_index], surface_z0[face_index]

        surface_x2[face_index], surface_x3[face_index] = surface_x3[face_index], surface_x2[face_index]
        surface_y2[face_index], surface_y3[face_index] = surface_y3[face_index], surface_y2[face_index]
        surface_z2[face_index], surface_z3[face_index] = surface_z3[face_index], surface_z2[face_index]
    end
end

for face_index = 0, 5 do
    obj.drawpoly(
        surface_x0[face_index],
        surface_y0[face_index],
        surface_z0[face_index],
        surface_x1[face_index],
        surface_y1[face_index],
        surface_z1[face_index],
        surface_x2[face_index],
        surface_y2[face_index],
        surface_z2[face_index],
        surface_x3[face_index],
        surface_y3[face_index],
        surface_z3[face_index],
        u0[face_index],
        v0[face_index],
        u1[face_index],
        v1[face_index],
        u2[face_index],
        v2[face_index],
        u3[face_index],
        v3[face_index]
    )
end -- s
