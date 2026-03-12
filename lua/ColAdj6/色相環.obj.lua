--label:tim2\色調整
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
local width_percent = 25

---$track:分割数
---min=3
---max=360
---step=1
local track_split_count = 24

local split_count = math.max(3, math.floor(track_split_count or 24))
local Ro = track_radius
local Ri = Ro * (100 - width_percent) * 0.01
local s = track_saturation
local v = track_lightness
obj.setoption("drawtarget", "tempbuffer", 2 * Ro, 2 * Ro)
obj.setoption("blend", "alpha_add")
local s2 = (-1 / split_count + 2 / 3) * math.pi
local x1, y1 = Ro * math.sin(s2), Ro * math.cos(s2)
local x2, y2 = Ri * math.sin(s2), Ri * math.cos(s2)
for i = 0, split_count do
    obj.load("figure", "四角形", HSV(360 * i / split_count, s, v), 1)
    local s1 = (-(2 * i - 1) / split_count + 2 / 3) * math.pi
    local x0, y0 = Ro * math.sin(s1), Ro * math.cos(s1)
    local x3, y3 = Ri * math.sin(s1), Ri * math.cos(s1)
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
    s2, x1, y1, x2, y2 = s1, x0, y0, x3, y3
end
obj.load("tempbuffer")
obj.setoption("blend", 0)