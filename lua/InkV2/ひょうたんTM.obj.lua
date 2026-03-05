--label:tim2
---$track:高さ
---min=0
---max=2000
---step=0.1
local rename_me_track0 = 80

---$track:幅
---min=0
---max=2000
---step=0.1
local rename_me_track1 = 250

---$track:くびれ
---min=0
---max=2000
---step=0.1
local rename_me_track2 = 10

---$track:つぶれ
---min=0
---max=100
---step=0.1
local rename_me_track3 = 40

---$color:色
local col = "0xffffff"

---$value:分割
local N = 30

---$value:繰り返し
local rpN = 1

---$check:高精度
local HA = 0

HA = HA or 0

local r1 = rename_me_track0 * 0.5
local w = rename_me_track1 * 0.5
local q = rename_me_track2 * 0.5
local asp = 1 - rename_me_track3 * 0.01
r1 = math.min(w, r1)
q = math.min(q, r1)
if HA == 1 then
    r1, w, q = 2 * r1, 2 * w, 2 * q
end

local m = w - r1
local r2, x0, y0
if r1 == q then
    --r2=∞
    x0 = m
    y0 = r1
else
    r2 = 0.5 * (m * m / (r1 - q) - r1 - q)
    x0 = m * r2 / (r1 + r2)
    y0 = (q + r2) * r1 / (r1 + r2)
end

local N1 = N
local N2 = N

rpN = math.max(1, math.floor(rpN))

obj.setoption("drawtarget", "tempbuffer", 2 * w, 2 * r1 * asp)

obj.load("figure", "四角形", col, 1)
obj.setoption("blend", "alpha_add2")

local x1 = x0
local y1 = math.sqrt(r1 * r1 - (x1 - m) ^ 2) * asp
for i = 1, N1 do
    local x2 = i * (w - x0) / N1 + x0
    local y2 = math.sqrt(r1 * r1 - (x2 - m) ^ 2) * asp
    obj.drawpoly(x1, -y1, 0, x2, -y2, 0, x2, y2, 0, x1, y1, 0)
    obj.drawpoly(-x2, -y2, 0, -x1, -y1, 0, -x1, y1, 0, -x2, y2, 0)
    x1, y1 = x2, y2
end

if r1 == q then
    local y1 = q * asp
    obj.drawpoly(0, -y1, 0, x0, -y1, 0, x0, y1, 0, 0, y1, 0)
    obj.drawpoly(-x0, -y1, 0, 0, -y1, 0, 0, y1, 0, -x0, y1, 0)
else
    local x1 = 0
    local y1 = q * asp
    for i = 1, N2 do
        local x2 = i * x0 / N2
        local y2 = (q + r2 - math.sqrt(r2 * r2 - x2 * x2)) * asp
        obj.drawpoly(x1, -y1, 0, x2, -y2, 0, x2, y2, 0, x1, y1, 0)
        obj.drawpoly(-x2, -y2, 0, -x1, -y1, 0, -x1, y1, 0, -x2, y2, 0)
        x1, y1 = x2, y2
    end
end

obj.load("tempbuffer")

if rpN > 1 then
    obj.setoption("drawtarget", "tempbuffer", 2 * w, 2 * w)
    obj.setoption("blend", 0)
    for i = 0, rpN - 1 do
        obj.draw(0, 0, 0, 1, 1, 0, 0, i / rpN * 180)
    end
    obj.load("tempbuffer")
end

if HA == 1 then
    obj.effect("リサイズ", "拡大率", 50)
end
