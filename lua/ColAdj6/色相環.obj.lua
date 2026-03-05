--label:tim2
---$track:半径
---min=0
---max=1000
---step=0.1
local rename_me_track0 = 100

---$track:彩度
---min=0
---max=100
---step=0.1
local rename_me_track1 = 100

---$track:明度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 100

---$track:幅％
---min=0
---max=100
---step=0.1
local rename_me_track3 = 25

---$value:分割
local spN = 24

---$value:幅%(旧ﾊﾟﾗﾒｰﾀ)
local wp = 0

local wp2 = (wp == 0 or rename_me_track3 > 0) and rename_me_track3 or wp
local Ro = rename_me_track0
local Ri = Ro * (100 - wp2) * 0.01
local s = rename_me_track1
local v = rename_me_track2
obj.setoption("drawtarget", "tempbuffer", 2 * Ro, 2 * Ro)
obj.setoption("blend", "alpha_add")
local s2 = (-1 / spN + 2 / 3) * math.pi
local x1, y1 = Ro * math.sin(s2), Ro * math.cos(s2)
local x2, y2 = Ri * math.sin(s2), Ri * math.cos(s2)
for i = 0, spN do
    obj.load("figure", "四角形", HSV(360 * i / spN, s, v), 1)
    local s1 = (-(2 * i - 1) / spN + 2 / 3) * math.pi
    local x0, y0 = Ro * math.sin(s1), Ro * math.cos(s1)
    local x3, y3 = Ri * math.sin(s1), Ri * math.cos(s1)
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
    s2, x1, y1, x2, y2 = s1, x0, y0, x3, y3
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
