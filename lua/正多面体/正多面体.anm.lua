--label:${ROOT_CATEGORY}\変形
--group:基本,true

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$select:タイプ
---正四面体=1
---立方体=2
---正八面体=3
---正二十面体=4
---正十二面体=5
local select_polyhedron_type = 1

---$track:枠％
---min=0
---max=100
---step=0.1
local track_frame_percent = 0

---$color:枠色
local color_frame = 0xffffff

---$check:縮尺補正
local check_aspect_ratio_correction = false

---$check:90度回転
local check_rotate_90_degrees = false

obj.setoption("blend", 0) --念のため

local create_face_drawer = function(cos_72, cos_36, sin_72, sin_36, polyhedron_type)
    local texture_side_y_ratio = (1 - cos_72) / (1 + cos_36)
    local texture_right_x_ratio = 1 / 2 + 1 / (2 + 4 * cos_72)
    local texture_left_x_ratio = 1 / 2 - 1 / (2 + 4 * cos_72)
    local texture_width, texture_height = obj.w, obj.h

    if polyhedron_type == 2 then
        return function(vertices, p1, p2, p3, p4)
            obj.drawpoly(
                vertices[p1][1],
                vertices[p1][2],
                vertices[p1][3],
                vertices[p2][1],
                vertices[p2][2],
                vertices[p2][3],
                vertices[p3][1],
                vertices[p3][2],
                vertices[p3][3],
                vertices[p4][1],
                vertices[p4][2],
                vertices[p4][3]
            )
        end
    elseif polyhedron_type == 4 then
        return function(vertices, p1, p2, p3, p4, p5)
            obj.drawpoly(
                vertices[p1][1],
                vertices[p1][2],
                vertices[p1][3],
                vertices[p1][1],
                vertices[p1][2],
                vertices[p1][3],
                vertices[p2][1],
                vertices[p2][2],
                vertices[p2][3],
                vertices[p5][1],
                vertices[p5][2],
                vertices[p5][3],
                texture_width / 2,
                0,
                texture_width / 2,
                0,
                texture_width,
                texture_side_y_ratio * texture_height,
                0,
                texture_side_y_ratio * texture_height
            )

            obj.drawpoly(
                vertices[p2][1],
                vertices[p2][2],
                vertices[p2][3],
                vertices[p3][1],
                vertices[p3][2],
                vertices[p3][3],
                vertices[p4][1],
                vertices[p4][2],
                vertices[p4][3],
                vertices[p5][1],
                vertices[p5][2],
                vertices[p5][3],
                texture_width,
                texture_side_y_ratio * texture_height,
                texture_width * texture_right_x_ratio,
                texture_height,
                texture_width * texture_left_x_ratio,
                texture_height,
                0,
                texture_side_y_ratio * texture_height
            )
        end
    else
        return function(vertices, p1, p2, p3)
            obj.drawpoly(
                vertices[p1][1],
                vertices[p1][2],
                vertices[p1][3],
                vertices[p1][1],
                vertices[p1][2],
                vertices[p1][3],
                vertices[p2][1],
                vertices[p2][2],
                vertices[p2][3],
                vertices[p3][1],
                vertices[p3][2],
                vertices[p3][3],
                texture_width / 2,
                0,
                texture_width / 2,
                0,
                texture_width,
                texture_height,
                0,
                texture_height
            )
        end
    end
end

local size = track_size --内接球の半径
local polyhedron_type = select_polyhedron_type
local vertex_counts = { 4, 8, 6, 20, 12 }
local cos_72, cos_36, sin_72, sin_36 = 0, 0, 0, 0
local vertices = {}
local frame_ratio = track_frame_percent * 0.01

--最初から規格化すれば良いのだけれど・・めんどくさいので＞＜
if polyhedron_type == 1 then
    vertices = { { 0, -math.sqrt(8 / 3), -1 / math.sqrt(3) }, { 0, 0, -math.sqrt(3) }, { -1, 0, 0 }, { 1, 0, 0 } }
elseif polyhedron_type == 2 then
    vertices = {
        { 1, -1, -1 },
        { -1, -1, -1 },
        { -1, -1, 1 },
        { 1, -1, 1 },
        { 1, 1, -1 },
        { -1, 1, -1 },
        { -1, 1, 1 },
        {
            1,
            1,
            1,
        },
    }
elseif polyhedron_type == 3 then
    vertices =
        { { 0, -math.sqrt(2), 0 }, { 1, 0, -1 }, { -1, 0, -1 }, { -1, 0, 1 }, { 1, 0, 1 }, { 0, math.sqrt(2), 0 } }
elseif polyhedron_type == 4 then
    cos_72 = math.cos(2 * math.pi / 5)
    cos_36 = math.cos(math.pi / 5)
    sin_72 = math.sin(2 * math.pi / 5)
    sin_36 = math.sin(math.pi / 5)
    local a = (1 + math.sqrt(5)) / 2
    vertices = {
        { 0, 1, 1 },
        { sin_72, cos_72, 1 },
        { sin_36, -cos_36, 1 },
        { -sin_36, -cos_36, 1 },
        { -sin_72, cos_72, 1 },
        { 0, a, 0 },
        { a * sin_72, a * cos_72, 0 },
        { a * sin_36, -a * cos_36, 0 },
        { -a * sin_36, -a * cos_36, 0 },
        { -a * sin_72, a * cos_72, 0 },
        { a * sin_36, a * cos_36, 1 - a },
        { a * sin_72, -a * cos_72, 1 - a },
        { 0, -a, 1 - a },
        { -a * sin_72, -a * cos_72, 1 - a },
        { -a * sin_36, a * cos_36, 1 - a },
        { 0, -1, -a },
        { -sin_72, -cos_72, -a },
        { -sin_36, cos_36, -a },
        { sin_36, cos_36, -a },
        { sin_72, -cos_72, -a },
    }
else --(polyhedron_type==5)
    local a = 1 / math.sqrt(5)
    local b = (1 - a) / 2
    local c = (1 + a) / 2
    local d = math.sqrt(b)
    local e = math.sqrt(c)
    vertices = {
        { 0, -1, 0 },
        { 0, -a, 2 * a },
        { e, -a, b },
        { d, -a, -c },
        { -d, -a, -c },
        { -e, -a, b },
        { d, a, c },
        { e, a, -b },
        { 0, a, -2 * a },
        { -e, a, -b },
        { -d, a, c },
        { 0, 1, 0 },
    }
end

--縦横比補正
if check_aspect_ratio_correction then
    local a, b
    local w, h = obj.getpixel()
    if polyhedron_type == 2 then
        a = 1
    elseif polyhedron_type == 4 then
        a = 2 * sin_72 / (1 + cos_36)
    else
        a = 2 / math.sqrt(3)
    end
    if w > h * a then
        a, b = h * a, h
    else
        a, b = w, w / a
    end
    obj.setoption("drawtarget", "tempbuffer", a, b)
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end

--枠
if frame_ratio > 0 then
    local w, h = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.draw()
    obj.load("figure", "四角形", color_frame, math.max(w, h))

    local w2 = w / 2
    local h2 = h / 2

    if polyhedron_type == 2 then
        local wf = w2 - w2 * frame_ratio
        local hf = h2 - h2 * frame_ratio
        obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, -hf, 0, -w2, -hf, 0)
        obj.drawpoly(-w2, hf, 0, w2, hf, 0, w2, h2, 0, -w2, h2, 0)
        obj.drawpoly(-w2, -h2, 0, -wf, -h2, 0, -wf, h2, 0, -w2, h2, 0)
        obj.drawpoly(wf, -h2, 0, w2, -h2, 0, w2, h2, 0, wf, h2, 0)
    elseif polyhedron_type == 4 then
        local hg = h / (1 + cos_36)
        local a = hg * cos_36 * frame_ratio
        local hf = h2 - a
        obj.drawpoly(-w2, hf, 0, w2, hf, 0, w2, h2, 0, -w2, h2, 0)
        local b = hg * (1 - cos_72)
        local hm = -h2 + b
        local c = w * (1 + cos_36) / (2 * sin_72 * h)
        local dw = c * a * b / math.sqrt(w2 * w2 + b * b)
        local dh = a * w2 / math.sqrt(w2 * w2 + b * b)
        obj.drawpoly(-dw, -h2 + dh, 0, dw, -h2 - dh, 0, w2 + dw, hm - dh, 0, w2 - dw, hm + dh, 0)
        obj.drawpoly(-dw, -h2 - dh, 0, dw, -h2 + dh, 0, -w2 + dw, hm + dh, 0, -w2 - dw, hm - dh, 0)
        local wm = c * sin_36 * hg
        local d = hg * (sin_72 - sin_36)
        local e = h - b
        local dw = c * a * e / math.sqrt(d * d + e * e)
        local dh = a * d / math.sqrt(d * d + e * e)
        obj.drawpoly(w2 - dw, hm - dh, 0, w2 + dw, hm + dh, 0, wm + dw, h2 + dh, 0, wm - dw, h2 - dh, 0)
        obj.drawpoly(-w2 - dw, hm + dh, 0, -w2 + dw, hm - dh, 0, -wm + dw, h2 - dh, 0, -wm - dw, h2 + dh, 0)
    else
        local hf = h2 - h / 3 * frame_ratio
        local a = w * h / (3 * h * h + 0.75 * w * w) * frame_ratio
        local ah = a * h
        local aw = a * w2
        local hp = h2 + aw
        local hm = h2 - aw
        obj.drawpoly(-w2, hf, 0, w2, hf, 0, w2, h2, 0, -w2, h2, 0)
        obj.drawpoly(-ah, -hm, 0, ah, -hp, 0, w2 + ah, hm, 0, w2 - ah, hp, 0)
        obj.drawpoly(-ah, -hp, 0, ah, -hm, 0, -w2 + ah, hp, 0, -w2 - ah, hm, 0)
    end
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end

--重心移動
if polyhedron_type == 1 or polyhedron_type == 4 then
    local s = { 0, 0, 0 }
    for j = 1, 3 do
        for i = 1, vertex_counts[polyhedron_type] do
            s[j] = s[j] + vertices[i][j]
        end
        s[j] = s[j] / vertex_counts[polyhedron_type]
    end
    for i = 1, vertex_counts[polyhedron_type] do
        for j = 1, 3 do
            vertices[i][j] = vertices[i][j] - s[j]
        end
    end
end

--サイズ変更
for i = 1, vertex_counts[polyhedron_type] do
    local r = 0
    for j = 1, 3 do
        r = r + vertices[i][j] * vertices[i][j]
    end
    r = math.sqrt(r)
    for j = 1, 3 do
        vertices[i][j] = size * vertices[i][j] / r
    end
end

--回転
if polyhedron_type == 4 then
    check_rotate_90_degrees = not check_rotate_90_degrees
end
if check_rotate_90_degrees then
    for i = 1, vertex_counts[polyhedron_type] do
        vertices[i][2], vertices[i][3] = -vertices[i][3], vertices[i][2]
    end
end

local draw_face = create_face_drawer(cos_72, cos_36, sin_72, sin_36, polyhedron_type)

--描画
if polyhedron_type == 1 then
    draw_face(vertices, 1, 2, 3)
    draw_face(vertices, 1, 3, 4)
    draw_face(vertices, 1, 4, 2)
    draw_face(vertices, 2, 4, 3)
elseif polyhedron_type == 2 then
    draw_face(vertices, 3, 4, 1, 2)
    draw_face(vertices, 2, 1, 5, 6)
    draw_face(vertices, 3, 2, 6, 7)
    draw_face(vertices, 4, 3, 7, 8)
    draw_face(vertices, 1, 4, 8, 5)
    draw_face(vertices, 6, 5, 8, 7)
elseif polyhedron_type == 3 then
    draw_face(vertices, 1, 2, 3)
    draw_face(vertices, 1, 3, 4)
    draw_face(vertices, 1, 4, 5)
    draw_face(vertices, 1, 5, 2)
    draw_face(vertices, 6, 3, 2)
    draw_face(vertices, 6, 4, 3)
    draw_face(vertices, 6, 5, 4)
    draw_face(vertices, 6, 2, 5)
elseif polyhedron_type == 4 then
    draw_face(vertices, 1, 2, 3, 4, 5)
    draw_face(vertices, 11, 7, 2, 1, 6)
    draw_face(vertices, 12, 8, 3, 2, 7)
    draw_face(vertices, 13, 9, 4, 3, 8)
    draw_face(vertices, 14, 10, 5, 4, 9)
    draw_face(vertices, 15, 6, 1, 5, 10)
    draw_face(vertices, 6, 15, 18, 19, 11)
    draw_face(vertices, 10, 14, 17, 18, 15)
    draw_face(vertices, 9, 13, 16, 17, 14)
    draw_face(vertices, 8, 12, 20, 16, 13)
    draw_face(vertices, 7, 11, 19, 20, 12)
    draw_face(vertices, 16, 20, 19, 18, 17)
else --(polyhedron_type==5)
    draw_face(vertices, 1, 2, 3)
    draw_face(vertices, 1, 3, 4)
    draw_face(vertices, 1, 4, 5)
    draw_face(vertices, 1, 5, 6)
    draw_face(vertices, 1, 6, 2)
    draw_face(vertices, 2, 11, 7)
    draw_face(vertices, 3, 7, 8)
    draw_face(vertices, 4, 8, 9)
    draw_face(vertices, 5, 9, 10)
    draw_face(vertices, 6, 10, 11)
    draw_face(vertices, 7, 3, 2)
    draw_face(vertices, 8, 4, 3)
    draw_face(vertices, 9, 5, 4)
    draw_face(vertices, 10, 6, 5)
    draw_face(vertices, 11, 2, 6)
    draw_face(vertices, 12, 7, 11)
    draw_face(vertices, 12, 8, 7)
    draw_face(vertices, 12, 9, 8)
    draw_face(vertices, 12, 10, 9)
    draw_face(vertices, 12, 11, 10)
end
