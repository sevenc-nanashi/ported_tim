--label:tim2\アニメーション効果
--group:基本,true

---$track:水位
---min=-5000
---max=5000
---step=0.1
local track_water_level = 0

---$track:振幅
---min=-1000
---max=1000
---step=0.1
local track_width = 10

---$track:波長
---min=2
---max=5000
---step=1
local track_wavelength = 100

---$track:本体α
---min=0
---max=100
---step=0.1
local track_alpha = 100

--group:波,false

---$track:波α
---min=0
---max=100
---step=0.1
local track_wave_alpha = 100

---$color:波色
local col = 0x80ffff

---$track:振動速度
---min=-10
---max=10
---step=0.001
local track_vibration_speed = 0

---$track:位相ズレ
---min=-5000
---max=5000
---step=0.1
local track_phase_offset = 0

---$track:位相速度
---min=-1000
---max=1000
---step=0.1
local track_phase_speed = 0

--group:反転波,false

---$check:表示
local Rw = false

---$color:反転色
local colr = 0x53c9c9

--group:枠,false

---$color:枠色
local colw = 0xffffff

---$track:幅
---min=0
---max=100
---step=0.1
local track_frame_width = 6

---$track:ぼかし
---min=0
---max=100
---step=0.1
local track_frame_blur = 4

--group:

local pi = math.pi
local Pr = { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
local Z = -track_water_level
local A = track_width
local L = math.floor(track_wavelength)
local T = track_alpha / 100
local Ta = track_wave_alpha
local S = track_vibration_speed
local D = track_phase_offset
local V = track_phase_speed
local ws = track_frame_width
local wb = track_frame_blur
local SG = 1
A = A * math.cos(obj.time * 2 * pi * S)
if A < 0 then
    A, SG = -A, -1
end
local w0, h0 = obj.getpixel()
local w, h = w0 + 20, math.floor(4 * math.ceil(A))
local w2, h2 = w / 2, h / 2
D = D + V * obj.time
if Rw then
    col, colr = colr, col
end
obj.copybuffer("cache:OrgW", "obj")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", 0xffffff, 1)
obj.effect("リサイズ", "X", w, "Y", 1, "ドット数でサイズ指定", 1)
obj.pixeloption("type", "rgb")
for i = 0, w - 1 do
    local g = 127.5 * math.sin(2 * pi * (i - w2 - D) / L)
    if math.abs(g) <= 0.5 then
        obj.putpixel(i, 0, 0, 0, 0, 0)
    else
        g = 127.5 + g
        obj.putpixel(i, 0, 0, g, 0, 255)
    end
end
obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, h2, 0, -w2, h2, 0)
obj.load("figure", "四角形", col, 1)
obj.effect("リサイズ", "X", w, "Y", h2, "ドット数でサイズ指定", 1)
obj.effect("領域拡張", "上", h2)
obj.effect(
    "ディスプレイスメントマップ",
    "param1",
    SG * A,
    "元のサイズに合わせる",
    1,
    "type",
    0,
    "name",
    "*tempbuffer",
    "ぼかし",
    0
)
obj.setoption("drawtarget", "tempbuffer", w0, h0)
obj.draw(0, Z, 0, 1, 1, 0, (Rw and 1 or 0) * 180, 0)
obj.draw(0, Z + h2 / 2, 0, 1, 1, 0, (Rw and 1 or 0) * 180, 0)
obj.load("figure", "四角形", col, 1)
h1, h2 = Z + A + 0.5, h0 / 2
obj.drawpoly(-w2, h1, 0, w2, h1, 0, w2, h2, 0, -w2, h2, 0)
if Rw then
    obj.copybuffer("cache:WaveW", "tmp")
    obj.copybuffer("obj", "cache:WaveW")
    obj.effect("単色化", "輝度を保持する", 0, "color", colr)
    obj.effect("反転", "左右反転", 1)
    obj.draw()
end
obj.copybuffer("obj", "cache:OrgW")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("cache:WaveW", "tmp")
obj.copybuffer("obj", "cache:OrgW")
obj.effect("縁取り", "ぼかし", wb, "サイズ", ws)
obj.effect("単色化", "輝度を保持する", 0, "color", colw)
obj.copybuffer("tmp", "obj")
obj.copybuffer("obj", "cache:OrgW")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.setoption("blend", "alpha_add2")
obj.copybuffer("obj", "cache:WaveW")
obj.draw(0, 0, 0, 1, Ta / 100)
obj.copybuffer("cache:WaveW", "tmp") --フリンジ対策で先に波と縁を合成
obj.copybuffer("obj", "cache:OrgW")
obj.draw(0, 0, 0, 1, T)
obj.copybuffer("obj", "cache:WaveW")
obj.setoption("blend", 0)
obj.draw()
obj.copybuffer("obj", "tmp")
obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)
