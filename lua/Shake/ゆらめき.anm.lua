--label:tim2\未分類
---$track:サイズ
---min=10
---max=2000
---step=0.1
local track_size = 50

---$track:形状変化
---min=0
---max=10000
---step=0.1
local track_change = 0

---$value:ランダム形状
local Rpat = 20

---$value:形状乱数シード
local seed1 = 0

local px = {}
local py = {}

local xl, yl = obj.getpixel()

local size = track_size

local tt = track_change * 0.01
local ss = math.floor(tt)
tt = tt - ss
local tti = 1 - tt

Rpat = math.abs(Rpat) * 0.01
if Rpat > 1 then
    Rpat = 1
end
Rpat = Rpat / 2.3

obj.setoption("drawtarget", "tempbuffer", xl, yl)
obj.setoption("antialias", 1)
obj.setoption("blend", "alpha_add")

local w = math.floor(xl / size)
local h = math.floor(yl / size)

if w < 2 then
    w = 2
elseif w > xl then
    w = xl
end
if h < 2 then
    h = 2
elseif h > yl then
    h = yl
end

local pw = xl / w * Rpat
local ph = yl / h * Rpat

sd1 = seed1 + ss
sd2 = sd1 + 1
sd3 = 1000 + sd1
sd4 = 1000 + sd2

for x = 0, w do
    px[x] = {}
    py[x] = {}
    for y = 0, h do
        px[x][y] = xl * (x / w - 0.5) + tti * obj.rand(-pw, pw, x, y + sd1) + tt * obj.rand(-pw, pw, x, y + sd2)
        py[x][y] = yl * (y / h - 0.5) + tti * obj.rand(-ph, ph, x, y + sd3) + tt * obj.rand(-ph, ph, x, y + sd4)
    end
end

s1 = xl * 0.5
for y = 0, h do
    px[0][y] = -s1
    px[w][y] = s1
end

s1 = yl * 0.5
for x = 0, w do
    py[x][0] = -s1
    py[x][h] = s1
end

for y = 0, h - 1 do
    for x = 0, w - 1 do
        local px1 = xl * x / w
        local py1 = yl * y / h
        local px2 = xl * (x + 1) / w
        local py2 = yl * (y + 1) / h
        obj.drawpoly(
            px[x][y],
            py[x][y],
            0,
            px[x + 1][y],
            py[x + 1][y],
            0,
            px[x + 1][y + 1],
            py[x + 1][y + 1],
            0,
            px[x][y + 1],
            py[x][y + 1],
            0,
            px1,
            py1,
            px2,
            py1,
            px2,
            py2,
            px1,
            py2
        )
    end
end

obj.load("tempbuffer")
