--label:tim2
--track0:高さ,0,2000,80
--track1:幅,0,2000,250
--track2:くびれ,0,2000,10
--track3:つぶれ,0,100,40

--value@col:色/col,"0xffffff"
--value@N:分割,30
--value@rpN:繰り返し,1
--value@HA:高精度/chk,0

HA = HA or 0

local r1 = obj.track0 * 0.5
local w = obj.track1 * 0.5
local q = obj.track2 * 0.5
local asp = 1 - obj.track3 * 0.01
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
