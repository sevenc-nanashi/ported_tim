--label:tim2\シーンチェンジセットT.scn
---$track:幅
---min=5
---max=1000
---step=0.1
local rename_me_track0 = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local rename_me_track1 = 0

---$value:先端幅[0〜50]％
local S2 = 35

---$value:高さ
local D0 = 50

local ROT = function(x, y, cos, sin)
    return x * cos - y * sin, x * sin + y * cos
end

local w = obj.w
local h = obj.h

if S2 > 50 then
    S2 = 50
elseif S2 < 0 then
    S2 = 0
end
local t = 1 - obj.getvalue("scenechange")

local S0 = rename_me_track0
S2 = S0 * S2 * 0.01
local S1 = S0 - S2
local S1h = S1 * 0.5
local S2h = S2 * 0.5
local D0h = D0 * 0.5

local deg = rename_me_track1
local rad = deg * math.pi / 180

obj.copybuffer("cache:bf", "obj")

obj.setoption("drawtarget", "tempbuffer", S0 + 2, D0 + 2)
obj.load("figure", "四角形", 0xffffff, math.max(S0, D0))

obj.drawpoly(-S1h, -D0h, 0, S1h, -D0h, 0, S2h, D0h, 0, -S2h, D0h, 0)
obj.drawpoly(-S1h - 1, -D0h - 1, 0, S1h + 1, -D0h - 1, 0, S1h, -D0h, 0, -S1h, -D0h, 0)
obj.copybuffer("obj", "tmp")
obj.setoption("blend", "alpha_sub")

obj.copybuffer("tmp", "cache:bf")

local cos = math.cos(rad)
local sin = math.sin(rad)
local abcos = math.abs(cos)
local absin = math.abs(sin)
local ww = w * abcos + h * absin
local hh = h * abcos + w * absin

local w2 = ww * 0.5
local h2 = hh * 0.5

local n1 = -math.floor(-w2 / S0)

y = t * (h2 + D0h)
for i = -n1, n1 do
    local x1, y1 = ROT(i * S0, -y, cos, sin)
    obj.draw(x1, y1, 0, 1, 1, 0, 0, deg)
end
local deg2 = 180 + deg
for i = 1, n1 do
    local dx = (i - 0.5) * S0
    local x1, y1 = ROT(dx, y, cos, sin)
    obj.draw(x1, y1, 0, 1, 1, 0, 0, deg2)
    x1, y1 = ROT(-dx, y, cos, sin)
    obj.draw(x1, y1, 0, 1, 1, 0, 0, deg2)
end

obj.load("figure", "四角形", 0xffffff, math.max(w, h))
obj.setoption("blend", "alpha_sub")
y = y + D0h
local x0, y0 = ROT(-w2, -h2, cos, sin)
local x1, y1 = ROT(w2, -h2, cos, sin)
local x2, y2 = ROT(w2, -y, cos, sin)
local x3, y3 = ROT(-w2, -y, cos, sin)
obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
x0, y0 = ROT(-w2, y, cos, sin)
x1, y1 = ROT(w2, y, cos, sin)
x2, y2 = ROT(w2, h2, cos, sin)
x3, y3 = ROT(-w2, h2, cos, sin)
obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)

obj.copybuffer("obj", "tmp")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
