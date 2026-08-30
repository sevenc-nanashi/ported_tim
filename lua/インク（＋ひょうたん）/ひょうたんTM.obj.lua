--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:高さ
---min=0
---max=2000
---step=0.1
local track_height = 80

---$track:幅
---min=0
---max=2000
---step=0.1
local track_width = 250

---$track:くびれ
---min=0
---max=2000
---step=0.1
local track_neck = 10

---$track:つぶれ
---min=0
---max=100
---step=0.1
local track_squash = 40

---$color:色
local color = 0xffffff

---$track:分割数
---min=1
---max=200
---step=1
local track_segment_count = 30

---$track:繰り返し
---min=1
---max=180
---step=1
local track_repeat_count = 1

---$check:高精度
local check_high_accuracy = false

local height_radius = track_height * 0.5
local half_width = track_width * 0.5
local neck_radius = track_neck * 0.5
local vertical_scale = 1 - track_squash * 0.01
local segment_count = math.max(1, math.floor(track_segment_count or 30))
local repeat_count = math.max(1, math.floor(track_repeat_count or 1))
local use_high_accuracy = check_high_accuracy == true or check_high_accuracy == 1
height_radius = math.min(half_width, height_radius)
neck_radius = math.min(neck_radius, height_radius)
if use_high_accuracy then
    height_radius, half_width, neck_radius = 2 * height_radius, 2 * half_width, 2 * neck_radius
end

local center_offset = half_width - height_radius
local inner_arc_radius, x0, y0
if height_radius == neck_radius then
    --inner_arc_radius=∞
    x0 = center_offset
    y0 = height_radius
else
    inner_arc_radius = 0.5
        * (center_offset * center_offset / (height_radius - neck_radius) - height_radius - neck_radius)
    x0 = center_offset * inner_arc_radius / (height_radius + inner_arc_radius)
    y0 = (neck_radius + inner_arc_radius) * height_radius / (height_radius + inner_arc_radius)
end

local outer_segment_count = segment_count
local inner_segment_count = segment_count

obj.setoption("drawtarget", "tempbuffer", 2 * half_width, 2 * height_radius * vertical_scale)

obj.load("figure", "四角形", color, 1)
obj.setoption("blend", "alpha_add2")

local x1 = x0
local y1 = math.sqrt(height_radius * height_radius - (x1 - center_offset) ^ 2) * vertical_scale
for i = 1, outer_segment_count do
    local x2 = i * (half_width - x0) / outer_segment_count + x0
    local y2 = math.sqrt(height_radius * height_radius - (x2 - center_offset) ^ 2) * vertical_scale
    obj.drawpoly(x1, -y1, 0, x2, -y2, 0, x2, y2, 0, x1, y1, 0)
    obj.drawpoly(-x2, -y2, 0, -x1, -y1, 0, -x1, y1, 0, -x2, y2, 0)
    x1, y1 = x2, y2
end

if height_radius == neck_radius then
    local y1 = neck_radius * vertical_scale
    obj.drawpoly(0, -y1, 0, x0, -y1, 0, x0, y1, 0, 0, y1, 0)
    obj.drawpoly(-x0, -y1, 0, 0, -y1, 0, 0, y1, 0, -x0, y1, 0)
else
    local x1 = 0
    local y1 = neck_radius * vertical_scale
    for i = 1, inner_segment_count do
        local x2 = i * x0 / inner_segment_count
        local y2 = (neck_radius + inner_arc_radius - math.sqrt(inner_arc_radius * inner_arc_radius - x2 * x2))
            * vertical_scale
        obj.drawpoly(x1, -y1, 0, x2, -y2, 0, x2, y2, 0, x1, y1, 0)
        obj.drawpoly(-x2, -y2, 0, -x1, -y1, 0, -x1, y1, 0, -x2, y2, 0)
        x1, y1 = x2, y2
    end
end

obj.load("tempbuffer")

if repeat_count > 1 then
    obj.setoption("drawtarget", "tempbuffer", 2 * half_width, 2 * half_width)
    obj.setoption("blend", 0)
    for i = 0, repeat_count - 1 do
        obj.draw(0, 0, 0, 1, 1, 0, 0, i / repeat_count * 180)
    end
    obj.load("tempbuffer")
end

if use_high_accuracy then
    obj.effect("リサイズ", "拡大率", 50)
end
