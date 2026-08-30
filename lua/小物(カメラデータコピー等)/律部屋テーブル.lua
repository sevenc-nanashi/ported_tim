--label:${ROOT_CATEGORY}\カスタムオブジェクト\@けいおんグッズ
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 250

---$track:厚さ補正
---min=0
---max=5000
---step=0.1
local track_top_thickness_percent = 100

---$track:脚長補正
---min=0
---max=5000
---step=0.1
local track_leg_length_percent = 100

---$color:テーブル色
local color_tabletop = 0xc0c0a0

---$color:脚の色
local color_legs = 0xffffff

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

local function draw_x_face(x, y1, y2, z1, z2)
    push_poly(x, y1, z1, x, y1, z2, x, y2, z2, x, y2, z1)
end

local function draw_y_face(x1, x2, y, z1, z2)
    push_poly(x1, y, z1, x2, y, z1, x2, y, z2, x1, y, z2)
end

local function draw_z_face(x1, y1, x2, y2, z)
    push_poly(x1, y1, z, x2, y1, z, x2, y2, z, x1, y2, z)
end

local function draw_box(x1, y1, z1, x2, y2, z2) -- 数値は対角線指定(1<2)で表裏が正確に
    draw_z_face(x1, y1, x2, y2, z1)
    draw_z_face(x1, y2, x2, y1, z2)
    draw_y_face(x1, x2, y1, z2, z1)
    draw_y_face(x1, x2, y2, z1, z2)
    draw_x_face(x1, y1, y2, z2, z1)
    draw_x_face(x2, y1, y2, z1, z2)
end

local function draw_leg(x1, y1, z1, x2, y2, z2, size)
    local x1_1 = x1 - size
    local x1_2 = x1 + size
    local z1_1 = z1 - size
    local z1_2 = z1 + size
    local x2_1 = x2 - size
    local x2_2 = x2 + size
    local z2_1 = z2 - size
    local z2_2 = z2 + size
    draw_y_face(x1_1, x1_2, y1, z1_2, z1_1)
    draw_y_face(x2_1, x2_2, y2, z2_1, z2_2)
    push_poly(x1_1, y1, z1_1, x1_2, y1, z1_1, x2_2, y2, z2_1, x2_1, y2, z2_1)
    push_poly(x1_2, y1, z1_2, x1_1, y1, z1_2, x2_1, y2, z2_2, x2_2, y2, z2_2)
    push_poly(x1_1, y1, z1_2, x1_1, y1, z1_1, x2_1, y2, z2_1, x2_1, y2, z2_2)
    push_poly(x1_2, y1, z1_1, x1_2, y1, z1_2, x2_2, y2, z2_2, x2_2, y2, z2_1)
end

local zoom = obj.getvalue("zoom") * 0.01
local table_half_size = track_size * zoom
local scale_ratio = table_half_size / 250
local top_thickness_ratio = track_top_thickness_percent * 0.01
local leg_length_ratio = track_leg_length_percent * 0.01

local y1 = -150 * scale_ratio * leg_length_ratio
local vertical_offset = 150 * scale_ratio * (1 - leg_length_ratio)
local y2 = 0

obj.load("figure", "四角形", color_tabletop, table_half_size)
draw_box(
    -table_half_size,
    (-150 - 10 * top_thickness_ratio) * scale_ratio + vertical_offset,
    -table_half_size,
    table_half_size,
    -150 * scale_ratio + vertical_offset,
    table_half_size
)
flush_polys()

obj.load("figure", "四角形", color_legs, 150 * scale_ratio * leg_length_ratio)
local leg_half_width = 8 * scale_ratio / 2
local leg_inner_position = (225 - 12) * scale_ratio
local leg_outer_position = (225 + 12) * scale_ratio
local foot_position = 275 * scale_ratio

draw_leg(-leg_outer_position, y1, -leg_inner_position, -foot_position, y2, -foot_position, leg_half_width)
draw_leg(-leg_inner_position, y1, -leg_outer_position, -foot_position, y2, -foot_position, leg_half_width)
draw_leg(leg_outer_position, y1, -leg_outer_position, foot_position, y2, -foot_position, leg_half_width)
draw_leg(leg_inner_position, y1, -leg_inner_position, foot_position, y2, -foot_position, leg_half_width)
draw_leg(leg_outer_position, y1, leg_inner_position, foot_position, y2, foot_position, leg_half_width)
draw_leg(leg_inner_position, y1, leg_outer_position, foot_position, y2, foot_position, leg_half_width)
draw_leg(-leg_outer_position, y1, leg_outer_position, -foot_position, y2, foot_position, leg_half_width)
draw_leg(-leg_inner_position, y1, leg_inner_position, -foot_position, y2, foot_position, leg_half_width)

flush_polys()
