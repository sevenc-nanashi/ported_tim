--label:${ROOT_CATEGORY}\シーンチェンジ\@シーンチェンジセットT
---$track:幅
---min=5
---max=1000
---step=0.1
local track_width = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:先端幅％
---min=0
---max=50
---step=0.1
local track_tip_width_percent = 35

---$track:高さ
---min=1
---max=1000
---step=0.1
local track_height = 50

local rotate_point = function(x, y, cos, sin)
    return x * cos - y * sin, x * sin + y * cos
end

local image_width = obj.w
local image_height = obj.h

if track_tip_width_percent > 50 then
    track_tip_width_percent = 50
elseif track_tip_width_percent < 0 then
    track_tip_width_percent = 0
end
local transition_remaining = 1 - obj.getvalue("scenechange")

local shape_width = track_width
local tip_width = shape_width * track_tip_width_percent * 0.01
local base_width = shape_width - tip_width
local base_half_width = base_width * 0.5
local tip_half_width = tip_width * 0.5
local shape_height = track_height
local shape_half_height = shape_height * 0.5

local angle_degrees = track_angle
local angle_radians = angle_degrees * math.pi / 180

obj.copybuffer("cache:bf", "object")

obj.setoption("drawtarget", "tempbuffer", shape_width + 2, shape_height + 2)
obj.load("figure", "四角形", 0xffffff, math.max(shape_width, shape_height))

obj.drawpoly(
    -base_half_width,
    -shape_half_height,
    0,
    base_half_width,
    -shape_half_height,
    0,
    tip_half_width,
    shape_half_height,
    0,
    -tip_half_width,
    shape_half_height,
    0
)
obj.drawpoly(
    -base_half_width - 1,
    -shape_half_height - 1,
    0,
    base_half_width + 1,
    -shape_half_height - 1,
    0,
    base_half_width,
    -shape_half_height,
    0,
    -base_half_width,
    -shape_half_height,
    0
)
obj.copybuffer("object", "tempbuffer")
obj.setoption("blend", "alpha_sub")

obj.copybuffer("tempbuffer", "cache:bf")

local cos = math.cos(angle_radians)
local sin = math.sin(angle_radians)
local absolute_cosine = math.abs(cos)
local absolute_sine = math.abs(sin)
local rotated_width = image_width * absolute_cosine + image_height * absolute_sine
local rotated_height = image_height * absolute_cosine + image_width * absolute_sine

local rotated_half_width = rotated_width * 0.5
local rotated_half_height = rotated_height * 0.5

local horizontal_repeat_count = -math.floor(-rotated_half_width / shape_width)

local sweep_y = transition_remaining * (rotated_half_height + shape_half_height)
for i = -horizontal_repeat_count, horizontal_repeat_count do
    local x1, y1 = rotate_point(i * shape_width, -sweep_y, cos, sin)
    obj.draw(x1, y1, 0, 1, 1, 0, 0, angle_degrees)
end
local reverse_angle_degrees = 180 + angle_degrees
for i = 1, horizontal_repeat_count do
    local dx = (i - 0.5) * shape_width
    local x1, y1 = rotate_point(dx, sweep_y, cos, sin)
    obj.draw(x1, y1, 0, 1, 1, 0, 0, reverse_angle_degrees)
    x1, y1 = rotate_point(-dx, sweep_y, cos, sin)
    obj.draw(x1, y1, 0, 1, 1, 0, 0, reverse_angle_degrees)
end

obj.load("figure", "四角形", 0xffffff, math.max(image_width, image_height))
obj.setoption("blend", "alpha_sub")
sweep_y = sweep_y + shape_half_height
local x0, y0 = rotate_point(-rotated_half_width, -rotated_half_height, cos, sin)
local x1, y1 = rotate_point(rotated_half_width, -rotated_half_height, cos, sin)
local x2, y2 = rotate_point(rotated_half_width, -sweep_y, cos, sin)
local x3, y3 = rotate_point(-rotated_half_width, -sweep_y, cos, sin)
obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
x0, y0 = rotate_point(-rotated_half_width, sweep_y, cos, sin)
x1, y1 = rotate_point(rotated_half_width, sweep_y, cos, sin)
x2, y2 = rotate_point(rotated_half_width, rotated_half_height, cos, sin)
x3, y3 = rotate_point(-rotated_half_width, rotated_half_height, cos, sin)
obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)

obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
