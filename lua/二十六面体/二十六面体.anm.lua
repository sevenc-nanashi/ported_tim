--label:${ROOT_CATEGORY}\変形
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$track:切込量
---min=0
---max=5000
---step=0.1
local track_cutting_size = 20

---$color:色2
local color_beveled_faces = 0xccffcc

---$color:色3
local color_triangular_faces = 0xffff00

-- おそらくAviUtl2で削除されたので消す
-- sampler="clip"/"dot"もやってみたけど差を感じなかったのでないものとする
-- ---$check:アンチエイリアス
-- local antialias = true

local draw_quad = function(a, b, c, d)
    obj.drawpoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, d.x, d.y, d.z)
end

local zoom = obj.getvalue("zoom") * 0.01
local scaled_size = track_size * zoom
local scaled_cutting_size = track_cutting_size * zoom

local half_size = scaled_size * 0.5
local inset_half_size = half_size - scaled_cutting_size

local face_vertices = {}
for i = 1, 6 do
    face_vertices[i] = {}
end
face_vertices[1] = {
    { x = -inset_half_size, y = -inset_half_size, z = -half_size },
    { x = inset_half_size, y = -inset_half_size, z = -half_size },
    { x = inset_half_size, y = inset_half_size, z = -half_size },
    {
        x = -inset_half_size,
        y = inset_half_size,
        z = -half_size,
    },
}
face_vertices[2] = {
    { z = -inset_half_size, y = -inset_half_size, x = half_size },
    { z = inset_half_size, y = -inset_half_size, x = half_size },
    { z = inset_half_size, y = inset_half_size, x = half_size },
    {
        z = -inset_half_size,
        y = inset_half_size,
        x = half_size,
    },
}
face_vertices[3] = {
    { x = inset_half_size, y = -inset_half_size, z = half_size },
    { x = -inset_half_size, y = -inset_half_size, z = half_size },
    { x = -inset_half_size, y = inset_half_size, z = half_size },
    {
        x = inset_half_size,
        y = inset_half_size,
        z = half_size,
    },
}
face_vertices[4] = {
    { z = inset_half_size, y = -inset_half_size, x = -half_size },
    { z = -inset_half_size, y = -inset_half_size, x = -half_size },
    { z = -inset_half_size, y = inset_half_size, x = -half_size },
    {
        z = inset_half_size,
        y = inset_half_size,
        x = -half_size,
    },
}
face_vertices[5] = {
    { x = -inset_half_size, z = inset_half_size, y = -half_size },
    { x = inset_half_size, z = inset_half_size, y = -half_size },
    { x = inset_half_size, z = -inset_half_size, y = -half_size },
    {
        x = -inset_half_size,
        z = -inset_half_size,
        y = -half_size,
    },
}
face_vertices[6] = {
    { x = -inset_half_size, z = -inset_half_size, y = half_size },
    { x = inset_half_size, z = -inset_half_size, y = half_size },
    { x = inset_half_size, z = inset_half_size, y = half_size },
    {
        x = -inset_half_size,
        z = inset_half_size,
        y = half_size,
    },
}

-- obj.setoption("antialias", ANT)
for i = 1, 6 do
    draw_quad(face_vertices[i][1], face_vertices[i][2], face_vertices[i][3], face_vertices[i][4])
end

obj.load("figure", "四角形", color_beveled_faces, scaled_size)
-- obj.setoption("antialias", ANT)
for i = 1, 4 do
    local next_face_index = (i % 4) + 1
    local previous_face_index = ((next_face_index - 2) % 4) + 1
    local reversed_vertex_index = 5 - i
    local next_reversed_vertex_index = 5 - next_face_index
    draw_quad(
        face_vertices[i][3],
        face_vertices[i][2],
        face_vertices[next_face_index][1],
        face_vertices[next_face_index][4]
    )
    draw_quad(
        face_vertices[i][2],
        face_vertices[i][1],
        face_vertices[5][reversed_vertex_index],
        face_vertices[5][next_reversed_vertex_index]
    )
    draw_quad(face_vertices[i][4], face_vertices[i][3], face_vertices[6][next_face_index], face_vertices[6][i])
end

obj.load("figure", "四角形", color_triangular_faces, scaled_size)
-- obj.setoption("antialias", ANT)
for i = 1, 4 do
    local next_face_index = 5 - i
    local previous_face_index = ((next_face_index - 2) % 4) + 1
    local reversed_vertex_index = ((i - 2) % 4) + 1
    draw_quad(
        face_vertices[5][i],
        face_vertices[5][i],
        face_vertices[next_face_index][1],
        face_vertices[previous_face_index][2]
    )
    draw_quad(face_vertices[6][i], face_vertices[6][i], face_vertices[reversed_vertex_index][3], face_vertices[i][4])
end
