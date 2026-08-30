--label:${ROOT_CATEGORY}\色調整
---$track:半径
---min=0
---max=1000
---step=0.1
local track_radius = 100

---$track:彩度
---min=0
---max=100
---step=0.1
local track_saturation = 100

---$track:明度
---min=0
---max=100
---step=0.1
local track_lightness = 100

---$track:幅％
---min=0
---max=100
---step=0.1
local track_width_percent = 25

---$track:分割数
---min=3
---max=360
---step=1
local track_split_count = 24

local split_count = math.max(3, math.floor(track_split_count or 24))
local outer_radius = track_radius
local inner_radius = outer_radius * (100 - track_width_percent) * 0.01
local saturation = track_saturation
local value = track_lightness
obj.setoption("drawtarget", "tempbuffer", 2 * outer_radius, 2 * outer_radius)
obj.setoption("blend", "alpha_add")
local previous_angle = (-1 / split_count + 2 / 3) * math.pi
local x1, y1 = outer_radius * math.sin(previous_angle), outer_radius * math.cos(previous_angle)
local x2, y2 = inner_radius * math.sin(previous_angle), inner_radius * math.cos(previous_angle)
for i = 0, split_count do
    obj.load("figure", "四角形", HSV(360 * i / split_count, saturation, value), 1)
    local current_angle = (-(2 * i - 1) / split_count + 2 / 3) * math.pi
    local x0, y0 = outer_radius * math.sin(current_angle), outer_radius * math.cos(current_angle)
    local x3, y3 = inner_radius * math.sin(current_angle), inner_radius * math.cos(current_angle)
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
    previous_angle, x1, y1, x2, y2 = current_angle, x0, y0, x3, y3
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
