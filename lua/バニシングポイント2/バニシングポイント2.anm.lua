--label:${ROOT_CATEGORY}\変形
---$track:サイズ補正
---min=0
---max=20000
---step=0.1
local track_size_adjust = 200

---$select:表示モード
---ガイド=0
---プレビュー=1
---変形=2
local display_mode = 0

---$track:視X/深度
---min=-10000
---max=10000
---step=0.1
local track_view_x_depth = 100

---$track:視点Y
---min=-10000
---max=10000
---step=0.1
local track_view_point_y = 100

---$track:分割数
---min=1
---max=300
---step=1
local division_count = 30

---$value:領域
local area = { -100, -100, 100, 100, 0, 0 }

---$track:ガイド径
---min=1
---max=500
---step=1
local guide_radius = 40

---$track:ライン幅
---min=1
---max=100
---step=1
local line_width = 4

--hide@track_view_x_depth:display_mode==0
--hide@track_view_point_y:display_mode~=1
--hide@division_count:display_mode~=2
--hide@guide_radius:display_mode~=0
--hide@line_width:display_mode~=0

-- ---$check:アンチエイリアス
-- local antialias = 1

local line_vertices
local preview_vertices
local transform_vertices
local source_points, projected_points, view_point, center_point, output_width, output_height
local vx, vy, bvx, bvy
local zoom, w2, h2, l, qcp

local function line_draw(p1, p2)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local r = math.sqrt(dx * dx + dy * dy)
    dx, dy = line_width * dy / r, -line_width * dx / r
    local u0, v0, u1, v1 = 0, 0, obj.w, obj.h
    line_vertices[#line_vertices + 1] = {
        p1.x + dx,
        p1.y + dy,
        0,
        p1.x - dx,
        p1.y - dy,
        0,
        p2.x - dx,
        p2.y - dy,
        0,
        p2.x + dx,
        p2.y + dy,
        0,
        u0,
        v0,
        u1,
        v0,
        u1,
        v1,
        u0,
        v1,
    }
end

local function sdp(a, b)
    preview_vertices[#preview_vertices + 1] = {
        source_points[a].x - vx,
        source_points[a].y - vy,
        0,
        source_points[b].x - vx,
        source_points[b].y - vy,
        0,
        projected_points[b].x + bvx,
        projected_points[b].y + bvy,
        0,
        projected_points[a].x + bvx,
        projected_points[a].y + bvy,
        0,
        source_points[a].x + output_width / 2,
        source_points[a].y + output_height / 2,
        source_points[b].x + output_width / 2,
        source_points[b].y + output_height / 2,
        projected_points[b].x + output_width / 2,
        projected_points[b].y + output_height / 2,
        projected_points[a].x + output_width / 2,
        projected_points[a].y + output_height / 2,
    }
end

local function dtd(a, b)
    for i = 0, division_count - 1 do
        local xxa_1 = (1 - i / division_count) * source_points[a].x + i / division_count * projected_points[a].x
        local xxa_2 = (1 - (i + 1) / division_count) * source_points[a].x
            + (i + 1) / division_count * projected_points[a].x
        local xxb_1 = (1 - i / division_count) * source_points[b].x + i / division_count * projected_points[b].x
        local xxb_2 = (1 - (i + 1) / division_count) * source_points[b].x
            + (i + 1) / division_count * projected_points[b].x

        local yya_1 = (1 - i / division_count) * source_points[a].y + i / division_count * projected_points[a].y
        local yya_2 = (1 - (i + 1) / division_count) * source_points[a].y
            + (i + 1) / division_count * projected_points[a].y
        local yyb_1 = (1 - i / division_count) * source_points[b].y + i / division_count * projected_points[b].y
        local yyb_2 = (1 - (i + 1) / division_count) * source_points[b].y
            + (i + 1) / division_count * projected_points[b].y

        local k1 = l
            * ((projected_points[a].x - view_point.x + center_point.x) / (xxa_1 - view_point.x + center_point.x) - 1)
        local k2 = l
            * ((projected_points[a].x - view_point.x + center_point.x) / (xxa_2 - view_point.x + center_point.x) - 1)
        transform_vertices[#transform_vertices + 1] = {
            zoom * (projected_points[a].x - qcp.x),
            zoom * (projected_points[a].y - qcp.y),
            zoom * k1,
            zoom * (projected_points[b].x - qcp.x),
            zoom * (projected_points[b].y - qcp.y),
            zoom * k1,
            zoom * (projected_points[b].x - qcp.x),
            zoom * (projected_points[b].y - qcp.y),
            zoom * k2,
            zoom * (projected_points[a].x - qcp.x),
            zoom * (projected_points[a].y - qcp.y),
            zoom * k2,
            zoom * (xxa_1 + w2),
            zoom * (yya_1 + h2),
            zoom * (xxb_1 + w2),
            zoom * (yyb_1 + h2),
            zoom * (xxb_2 + w2),
            zoom * (yyb_2 + h2),
            zoom * (xxa_2 + w2),
            zoom * (yya_2 + h2),
        }
    end
end

obj.setanchor("area", 3)
local size_scale = track_size_adjust / 100
local current_display_mode = display_mode or 0
local w, h = obj.getpixel()
-- if antialias == nil then
--     antialias = 0
-- elseif antialias == false then
--     antialias = 0
-- elseif antialias == true then
--     antialias = 1
-- end
source_points = {}
source_points[1] = { x = area[1], y = area[2] }
source_points[2] = { x = area[3], y = area[2] }
source_points[3] = { x = area[3], y = area[4] }
source_points[4] = { x = area[1], y = area[4] }
view_point = {}
view_point.x = area[5]
view_point.y = area[6]
projected_points = {}
for i = 1, 4 do
    projected_points[i] = {
        x = size_scale * (source_points[i].x - view_point.x) + view_point.x,
        y = size_scale * (source_points[i].y - view_point.y) + view_point.y,
    }
end

local max_w = math.max(
    source_points[1].x,
    source_points[2].x,
    source_points[3].x,
    source_points[4].x,
    projected_points[1].x,
    projected_points[2].x,
    projected_points[3].x,
    projected_points[4].x,
    w / 2
)
local min_w = math.min(
    source_points[1].x,
    source_points[2].x,
    source_points[3].x,
    source_points[4].x,
    projected_points[1].x,
    projected_points[2].x,
    projected_points[3].x,
    projected_points[4].x,
    -w / 2
)
local max_h = math.max(
    source_points[1].y,
    source_points[2].y,
    source_points[3].y,
    source_points[4].y,
    projected_points[1].y,
    projected_points[2].y,
    projected_points[3].y,
    projected_points[4].y,
    h / 2
)
local min_h = math.min(
    source_points[1].y,
    source_points[2].y,
    source_points[3].y,
    source_points[4].y,
    projected_points[1].y,
    projected_points[2].y,
    projected_points[3].y,
    projected_points[4].y,
    -h / 2
)
center_point = { x = (max_w + min_w) / 2, y = (max_h + min_h) / 2 }

output_width = max_w - min_w + guide_radius
output_height = max_h - min_h + guide_radius

for i = 1, 4 do
    source_points[i].x = source_points[i].x - center_point.x
    source_points[i].y = source_points[i].y - center_point.y
    projected_points[i].x = projected_points[i].x - center_point.x
    projected_points[i].y = projected_points[i].y - center_point.y
end

obj.setoption("drawtarget", "tempbuffer", output_width, output_height)
obj.draw(-center_point.x, -center_point.y, 0)

if current_display_mode == 0 then
    line_width = line_width / 2
    obj.load("figure", "円", 0xff5555, guide_radius)
    obj.draw(view_point.x - center_point.x, view_point.y - center_point.y, 0)
    obj.load("figure", "円", 0xffffff, guide_radius)
    obj.draw(source_points[1].x, source_points[1].y, 0)
    obj.draw(source_points[3].x, source_points[3].y, 0)
    obj.load("figure", "円", 0x5555ff, guide_radius)
    obj.draw(source_points[2].x, source_points[2].y, 0)
    obj.draw(source_points[4].x, source_points[4].y, 0)
    obj.load("figure", "円", 0x00ff00, guide_radius)
    for i = 1, 4 do
        obj.draw(projected_points[i].x, projected_points[i].y, 0)
    end
    obj.load("figure", "四角形", 0xffffff, guide_radius)
    line_vertices = {}
    line_draw(source_points[1], source_points[2])
    line_draw(source_points[2], source_points[3])
    line_draw(source_points[3], source_points[4])
    line_draw(source_points[4], source_points[1])
    line_draw(projected_points[1], projected_points[2])
    line_draw(projected_points[2], projected_points[3])
    line_draw(projected_points[3], projected_points[4])
    line_draw(projected_points[4], projected_points[1])
    line_draw(source_points[1], projected_points[1])
    line_draw(source_points[2], projected_points[2])
    line_draw(source_points[3], projected_points[3])
    line_draw(source_points[4], projected_points[4])
    if #line_vertices > 0 then
        obj.drawpoly(line_vertices)
    end
    obj.load("tempbuffer")
    obj.cx = obj.cx - center_point.x
    obj.cy = obj.cy - center_point.y
elseif current_display_mode == 1 then
    obj.load("tempbuffer")
    -- obj.setoption("antialias", antialias)
    vx = track_view_x_depth
    vy = track_view_point_y
    bvx = size_scale * vx
    bvy = size_scale * vy
    obj.setoption("drawtarget", "tempbuffer", output_width + 2 * math.abs(bvx), output_height + 2 * math.abs(bvy)) --面倒臭くなって適当＞＜;
    obj.setoption("antialias", 0)
    preview_vertices = {
        {
            source_points[1].x - vx,
            source_points[1].y - vy,
            0,
            source_points[2].x - vx,
            source_points[2].y - vy,
            0,
            source_points[3].x - vx,
            source_points[3].y - vy,
            0,
            source_points[4].x - vx,
            source_points[4].y - vy,
            0,
            source_points[1].x + output_width / 2,
            source_points[1].y + output_height / 2,
            source_points[2].x + output_width / 2,
            source_points[2].y + output_height / 2,
            source_points[3].x + output_width / 2,
            source_points[3].y + output_height / 2,
            source_points[4].x + output_width / 2,
            source_points[4].y + output_height / 2,
        },
    }
    sdp(1, 4)
    sdp(3, 2)
    sdp(1, 2)
    sdp(3, 4)
    obj.drawpoly(preview_vertices)
    obj.load("tempbuffer")
    obj.cx = obj.cx - center_point.x
    obj.cy = obj.cy - center_point.y
else
    obj.load("tempbuffer")
    -- obj.setoption("antialias", antialias)
    w, h = obj.getpixel()
    obj.setoption("drawtarget", "framebuffer")
    zoom = obj.getvalue("zoom") * 0.01
    w2 = w / 2 --/zoom
    h2 = h / 2 --/zoom
    l = w * track_view_x_depth / 100
    qcp = {
        x = (projected_points[1].x + projected_points[2].x) / 2,
        y = (projected_points[1].y + projected_points[4].y) / 2,
    }
    local k = l * (size_scale - 1)

    transform_vertices = {
        {
            zoom * (projected_points[1].x - qcp.x),
            zoom * (projected_points[1].y - qcp.y),
            zoom * k,
            zoom * (projected_points[2].x - qcp.x),
            zoom * (projected_points[2].y - qcp.y),
            zoom * k,
            zoom * (projected_points[3].x - qcp.x),
            zoom * (projected_points[3].y - qcp.y),
            zoom * k,
            zoom * (projected_points[4].x - qcp.x),
            zoom * (projected_points[4].y - qcp.y),
            zoom * k,
            zoom * (source_points[1].x + w2),
            zoom * (source_points[1].y + h2),
            zoom * (source_points[2].x + w2),
            zoom * (source_points[2].y + h2),
            zoom * (source_points[3].x + w2),
            zoom * (source_points[3].y + h2),
            zoom * (source_points[4].x + w2),
            zoom * (source_points[4].y + h2),
        },
    }
    dtd(3, 2)
    dtd(4, 1)
    dtd(1, 2)
    dtd(3, 4)
    obj.drawpoly(transform_vertices)
end
