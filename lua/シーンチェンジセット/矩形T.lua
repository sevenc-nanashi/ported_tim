--label:tim2\シーンチェンジ\@シーンチェンジセットT.scn
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

local ROT = function(x, y, cos, sin)
    return x * cos - y * sin, x * sin + y * cos
end

local w = obj.w
local h = obj.h

if track_tip_width_percent > 50 then
    track_tip_width_percent = 50
elseif track_tip_width_percent < 0 then
    track_tip_width_percent = 0
end
local t = 1 - obj.getvalue("scenechange")

local S0 = track_width
local S2 = S0 * track_tip_width_percent * 0.01
local S1 = S0 - S2
local S1h = S1 * 0.5
local S2h = S2 * 0.5
local D0 = track_height
local D0h = D0 * 0.5

local deg = track_angle
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

-- NOTE: AviUtl2 beta36a現在、alpha_subで描画した部分のアルファ値がマイナスになると描画がおかしくなるので、u8の範囲で飽和させてから描画するようにする
obj.putpixeldata("tempbuffer", obj.getpixeldata("tempbuffer"))

obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
